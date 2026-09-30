// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/// Chat session controller managing the Genkit `remoteAgent` connection,
/// streamed turns, and the `genui` [SurfaceController].
library;

import 'dart:async';
import 'dart:convert';

import 'package:a2ui_core/a2ui_core.dart' as core;
import 'package:flutter/foundation.dart';
import 'package:genkit/client.dart';
import 'package:genkit_a2ui/client.dart';
import 'package:genui/genui.dart' hide DataPart, TextPart, basicCatalogId;

import 'catalog.dart';

/// Base URL of the Shelf agent server. Override with `--dart-define=AGENT_BASE_URL`.
const String defaultAgentBaseUrl = String.fromEnvironment(
  'AGENT_BASE_URL',
  defaultValue: 'http://localhost:8080',
);

/// Models an entry in the conversation stream: prose text, an interactive
/// A2UI surface, or a user UI interaction badge.
sealed class ChatEntry {
  const ChatEntry();
}

class TextEntry extends ChatEntry {
  TextEntry(this.isUser, this.text);
  final bool isUser;
  String text;
}

class SurfaceEntry extends ChatEntry {
  SurfaceEntry(this.surfaceId);
  final String surfaceId;
}

class ActionEntry extends ChatEntry {
  ActionEntry(this.action);
  final A2uiClientAction action;
}

/// Extracts an [A2uiClientAction] from a `genui` [ChatMessage] emitted by
/// `SurfaceController.onSubmit`.
A2uiClientAction? extractClientAction(ChatMessage message) {
  for (final part in message.parts) {
    final interaction = part.asUiInteractionPart?.interaction;
    if (interaction == null) continue;
    final decoded = jsonDecode(interaction);
    final action = (decoded is Map) ? decoded['action'] : null;
    if (action is Map) {
      final map = action.cast<String, dynamic>();
      return A2uiClientAction(
        name: (map['name'] as String?) ?? 'action',
        surfaceId: (map['surfaceId'] as String?) ?? '',
        sourceComponentId: (map['widgetId'] as String?) ?? '',
        timestamp: DateTime.now().toUtc().toIso8601String(),
        context: (map['context'] as Map?)?.cast<String, dynamic>() ?? const {},
      );
    }
  }
  return null;
}

/// Manages conversation state, `remoteAgent` streaming, and A2UI surface
/// updates for the reservation chat page.
class ChatController extends ChangeNotifier {
  ChatController({String baseUrl = defaultAgentBaseUrl})
    : _agent = remoteAgent(
        url: '$baseUrl/api/uiAgent',
        getSnapshotUrl: '$baseUrl/api/uiAgent/getSnapshot',
        abortUrl: '$baseUrl/api/uiAgent/abort',
      ) {
    _initSession();
  }

  final AgentApi _agent;
  late AgentChat _chat;
  late SurfaceController _surfaceController;
  StreamSubscription<SurfaceUpdate>? _surfaceSub;
  StreamSubscription<ChatMessage>? _submitSub;

  final List<ChatEntry> _entries = <ChatEntry>[];
  bool _busy = false;
  bool _disposed = false;

  List<ChatEntry> get entries => List.unmodifiable(_entries);
  bool get busy => _busy;
  SurfaceController get surfaceController => _surfaceController;

  void _initSession() {
    _chat = _agent.chat();
    _surfaceController = SurfaceController(catalogs: [bistroClientCatalog]);

    _surfaceSub = _surfaceController.surfaceUpdates.listen((update) {
      if (update is SurfaceAdded) {
        final exists = _entries.whereType<SurfaceEntry>().any(
          (e) => e.surfaceId == update.surfaceId,
        );
        if (!exists && !_disposed) {
          _entries.add(SurfaceEntry(update.surfaceId));
          notifyListeners();
        }
      }
    });

    _submitSub = _surfaceController.onSubmit.listen(_onSurfaceSubmit);
  }

  /// Resets the current conversation and creates a fresh A2UI session.
  void resetSession() {
    if (_busy) return;
    _surfaceSub?.cancel();
    _submitSub?.cancel();
    _surfaceController.dispose();
    _entries.clear();
    _initSession();
    notifyListeners();
  }

  /// Sends a user text prompt to the agent.
  Future<void> sendText(String text) async {
    if (text.trim().isEmpty || _busy) return;
    _entries.add(TextEntry(true, text));
    _busy = true;
    notifyListeners();
    await _runTurn(_chat.sendStream(text: text));
  }

  /// Converts a rendered surface's submit interaction into an [A2uiClientAction]
  /// and sends it back to the agent as the next conversation turn.
  Future<void> _onSurfaceSubmit(ChatMessage message) async {
    if (_busy) return;
    final action = extractClientAction(message);
    if (action == null) return;

    _entries.add(ActionEntry(action));
    _busy = true;
    notifyListeners();
    await _runTurn(_chat.sendStream(message: actionToMessage(action)));
  }

  /// Streams a single agent turn, incrementally rendering prose text and
  /// decoding A2UI envelopes into the [SurfaceController].
  Future<void> _runTurn(AgentTurn turn) async {
    TextEntry? prose;
    try {
      await for (final chunk in turn.stream) {
        if (chunk.text.isNotEmpty) {
          if (prose == null) {
            prose = TextEntry(false, '');
            _entries.add(prose);
          }
          prose.text += chunk.text;
          if (!_disposed) notifyListeners();
        }

        for (final envelope in a2uiEnvelopesFromParts(
          chunk.raw.modelChunk?.content,
        )) {
          _handleEnvelope(envelope);
        }
      }
      await turn.response;
    } catch (err) {
      _entries.add(TextEntry(false, 'Error: $err'));
    } finally {
      if (prose != null && prose.text.trim().isEmpty) {
        _entries.remove(prose);
      }
      if (!_disposed) {
        _busy = false;
        notifyListeners();
      }
    }
  }

  void _handleEnvelope(Map<String, dynamic> envelope) {
    try {
      _sanitizeEnvelope(envelope);
      _surfaceController.handleMessage(core.A2uiMessage.fromJson(envelope));
    } catch (err) {
      debugPrint('Failed to apply A2UI envelope: $err');
    }
  }

  /// Prevents infinite height layout exceptions when a `Row` uses `align: stretch`
  /// inside an unbounded vertical scroll view.
  void _sanitizeEnvelope(Map<String, dynamic> envelope) {
    final update = envelope['updateComponents'];
    if (update is! Map) return;
    final components = update['components'];
    if (components is! List) return;
    for (final c in components) {
      if (c is Map && c['component'] == 'Row' && c['align'] == 'stretch') {
        c.remove('align');
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _surfaceSub?.cancel();
    _submitSub?.cancel();
    _surfaceController.dispose();
    _agent.close();
    super.dispose();
  }
}
