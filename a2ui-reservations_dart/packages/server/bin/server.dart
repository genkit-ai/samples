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

/// Shelf server exposing the A2UI-enabled agent over HTTP and serving the
/// compiled Flutter Web client (`packages/app/build/web`) when present.
///
/// The agent is mounted at `POST /api/uiAgent` (the turn action), plus
/// `POST /api/uiAgent/getSnapshot` and `POST /api/uiAgent/abort`. The Flutter
/// client (`packages/app`) talks to it with `remoteAgent` from
/// `package:genkit/client.dart`.
///
/// Run with: `GEMINI_API_KEY=... dart run packages/server/bin/server.dart`
library;

// ignore_for_file: avoid_print

import 'dart:io';

import 'package:a2ui_reservations_server/agent.dart';
import 'package:genkit_shelf/genkit_shelf.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';

Directory? _findFlutterWebBuildDir() {
  final candidates = [
    Directory('packages/app/build/web'),
    Directory('../app/build/web'),
  ];
  for (final dir in candidates) {
    if (dir.existsSync() && File('${dir.path}/index.html').existsSync()) {
      return dir;
    }
  }
  return null;
}

void main() async {
  // Register the app's custom A2UI catalog before serving any turns, so the
  // agent's `a2ui(catalog: bistroCatalogId)` can resolve it from the registry.
  await registerCatalogs();

  final router = Router();

  // Server-managed agent (POST turn + snapshot + abort).
  router.post('/api/uiAgent', shelfHandler(uiAgent.action));
  router.post(
    '/api/uiAgent/getSnapshot',
    shelfHandler(uiAgent.getSnapshotDataAction),
  );
  router.post('/api/uiAgent/abort', shelfHandler(uiAgent.abortAgentAction));

  // If a user opens /api/uiAgent in a browser (GET), redirect to `/` where the
  // Flutter web client is hosted.
  router.get('/api/uiAgent', (Request request) => Response.found('/'));

  final webBuildDir = _findFlutterWebBuildDir();
  final Handler appHandler;
  if (webBuildDir != null) {
    final staticHandler = createStaticHandler(
      webBuildDir.path,
      defaultDocument: 'index.html',
    );
    appHandler = Cascade().add(router.call).add(staticHandler).handler;
  } else {
    router.get('/', (Request request) {
      return Response.ok(
        'Genkit Dart A2UI sample API server.\n\n'
        'The uiAgent POST endpoint is mounted under /api/uiAgent.\n'
        'Run the Flutter client with: cd packages/app && flutter run -d chrome\n',
        headers: {'Content-Type': 'text/plain'},
      );
    });
    appHandler = router.call;
  }

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(
        corsHeaders(
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers':
                'Content-Type, Accept, X-Genkit-Stream-Id',
            'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
          },
        ),
      )
      .addHandler(appHandler);

  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  print('\n🚀 A2UI full-stack server on http://localhost:${server.port}');
  if (webBuildDir != null) {
    print('   Flutter Web UI served at http://localhost:${server.port}/');
  }
  print('   uiAgent POST endpoint mounted at /api/uiAgent\n');
}
