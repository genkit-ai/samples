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

/// Values shared by the server (`packages/server`) and the Flutter client
/// (`packages/app`).
///
/// This package has no server-only (`dart:io`) or Flutter-only imports so it is
/// safe to depend on from both the Dart VM server and the Flutter Web client.
/// It ensures the custom catalog id is defined in a single place: the server
/// catalog and the client renderer MUST agree on it, otherwise a surface
/// created by the agent won't resolve to the client's widgets.
library;

/// The id of the app's custom A2UI catalog.
///
/// The server registers a catalog under this id (see `bistroCatalog` in
/// `package:a2ui_reservations_server/agent.dart`) and the client registers a
/// matching set of widgets under the same id (see `bistroClientCatalog` in
/// `package:a2ui_reservations_app/src/catalog.dart`). Reverse-domain notation
/// is recommended to avoid clashes with other catalogs.
const String bistroCatalogId = 'com.example.a2ui.bistro';
