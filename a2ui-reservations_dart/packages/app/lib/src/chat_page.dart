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

/// Chat page and UI widgets for Cymbal Bistro.
library;

import 'package:flutter/material.dart';
import 'package:genkit_a2ui/client.dart';
import 'package:genui/genui.dart' hide DataPart, TextPart, basicCatalogId;

import 'chat_controller.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, this.controller});

  final ChatController? controller;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatController _controller;
  late final bool _ownsController;
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? ChatController();
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
    _scrollToBottom();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _controller.busy) return;
    _input.clear();
    await _controller.sendText(text);
    _scrollToBottom();
    Future.delayed(const Duration(milliseconds: 150), _scrollToBottom);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final entries = _controller.entries;
    final busy = _controller.busy;

    return Scaffold(
      appBar: _buildAppBar(entries.isNotEmpty, busy),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: Column(
            children: [
              if (entries.isNotEmpty) ...[
                _SuggestionBar(onTap: busy ? null : _send),
                const Divider(color: Color(0xFF1A2337), height: 1),
              ],
              Expanded(
                child: entries.isEmpty
                    ? _WelcomeHero(onSelectPrompt: busy ? null : _send)
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        itemCount: entries.length,
                        itemBuilder: (context, i) => _buildEntry(entries[i]),
                      ),
              ),
              if (busy)
                const LinearProgressIndicator(
                  color: Color(0xFF6582CC),
                  backgroundColor: Color(0xFF0F1827),
                  minHeight: 2,
                ),
              _Composer(controller: _input, enabled: !busy, onSend: _send),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool hasEntries, bool busy) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(62),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF070B13),
          border: Border(
            bottom: BorderSide(color: Color(0xFF1A2337), width: 1),
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF141F32),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF222D47)),
                      ),
                      child: const Icon(
                        Icons.restaurant_rounded,
                        color: Color(0xFF7FA2FF),
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cymbal Bistro',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          'Genkit Dart + A2UI Dining Concierge',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const _StatusBadge(label: 'A2UI v0.9'),
                    if (hasEntries) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'New reservation session',
                        onPressed: busy ? null : _controller.resetSession,
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF141F32),
                          foregroundColor: const Color(0xFFCBD5E1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: Color(0xFF222D47)),
                          ),
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEntry(ChatEntry entry) {
    switch (entry) {
      case TextEntry(:final isUser, :final text):
        final trimmed = text.trim();
        if (trimmed.isEmpty) return const SizedBox.shrink();
        if (isUser) {
          return Align(
            alignment: Alignment.centerRight,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6582CC),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  trimmed,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          );
        } else {
          return Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
                child: Text(
                  trimmed,
                  style: const TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 14.5,
                    height: 1.5,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ),
          );
        }

      case ActionEntry(:final action):
        return Align(
          alignment: Alignment.centerRight,
          child: _ActionBadge(action: action),
        );

      case SurfaceEntry(:final surfaceId):
        return Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: IntrinsicHeight(
                child: Surface(
                  surfaceContext: _controller.surfaceController.contextFor(
                    surfaceId,
                  ),
                ),
              ),
            ),
          ),
        );
    }
  }
}

/// Welcome screen shown before the first message is sent.
class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero({required this.onSelectPrompt});
  final void Function(String prompt)? onSelectPrompt;

  static const _starterCards = [
    (
      icon: Icons.dinner_dining_rounded,
      title: 'Dinner Tonight for 4',
      prompt: 'Book a table for 4 at Cymbal Bistro tonight at 7:00 PM.',
    ),
    (
      icon: Icons.wine_bar_rounded,
      title: 'Date Night Tomorrow',
      prompt: 'Reserve a quiet table for 2 tomorrow at 6:30 PM.',
    ),
    (
      icon: Icons.deck_rounded,
      title: 'Friday Group Dining',
      prompt: 'Table for 6 on Friday at 8:00 PM with heated patio seating.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF141F32),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF283756)),
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                color: Color(0xFF7FA2FF),
                size: 26,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Welcome to Cymbal Bistro',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: const Text(
                'An AI dining concierge that streams interactive A2UI surfaces. '
                'Ask for table availability, customize seating, and confirm your reservation.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                for (final card in _starterCards)
                  _StarterPromptCard(
                    icon: card.icon,
                    title: card.title,
                    prompt: card.prompt,
                    onTap: onSelectPrompt == null
                        ? null
                        : () => onSelectPrompt!(card.prompt),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StarterPromptCard extends StatelessWidget {
  const _StarterPromptCard({
    required this.icon,
    required this.title,
    required this.prompt,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String prompt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Material(
        color: const Color(0xFF0F1827),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF222D47)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: const Color(0xFF7FA2FF), size: 20),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  prompt,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Visualizes a user interaction sent back to the agent from an A2UI surface.
class _ActionBadge extends StatelessWidget {
  const _ActionBadge({required this.action});
  final A2uiClientAction action;

  String _formatTitle(String raw) {
    return switch (raw) {
      'confirmReservation' => 'Confirm Reservation',
      'modifyReservation' => 'Modify Reservation',
      _ => raw,
    };
  }

  List<String> _extractSummaryPills() {
    final pills = <String>[];
    final ctx = action.context;
    String? scalar(dynamic val) {
      if (val == null) return null;
      if (val is List && val.isNotEmpty) return val.first.toString();
      final str = val.toString().trim();
      return str.isEmpty ? null : str;
    }

    final date = scalar(ctx['date']);
    final time = scalar(ctx['time'] ?? ctx['timeSlot']);
    final party = scalar(ctx['partySize']);
    final seating = scalar(ctx['seatingArea'] ?? ctx['seating']);

    if (date != null) pills.add(date);
    if (time != null) pills.add(time);
    if (party != null) pills.add('$party guests');
    if (seating != null) pills.add(seating);
    return pills;
  }

  @override
  Widget build(BuildContext context) {
    final pills = _extractSummaryPills();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF141F32),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6582CC).withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.touch_app_rounded,
                color: Color(0xFF7FA2FF),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                _formatTitle(action.name),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (pills.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final pill in pills)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2D4A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      pill,
                      style: const TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 11.5,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF141F32),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF222D47)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF34D399),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionBar extends StatelessWidget {
  const _SuggestionBar({required this.onTap});
  final void Function(String prompt)? onTap;

  static const _prompts = [
    'Book a table for 4 at Cymbal Bistro tonight at 7:00 PM.',
    'Reserve a table for 2 tomorrow at 6:30 PM.',
    'Table for 6 on Friday at 8:00 PM with patio seating.',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final p in _prompts)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(p),
                    backgroundColor: const Color(0xFF0F1827),
                    side: const BorderSide(color: Color(0xFF222D47)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelStyle: const TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 12.5,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    onPressed: onTap == null ? null : () => onTap!(p),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final void Function(String text) onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1827),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFF222D47)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Ask for a table, or adjust dining preferences…',
                  hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: enabled ? onSend : null,
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6582CC),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
              ),
              onPressed: enabled ? () => onSend(controller.text) : null,
              child: const Text(
                'Send',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
