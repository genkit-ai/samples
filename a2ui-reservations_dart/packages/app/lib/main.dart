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

/// A2UI Dining Reservations Flutter client entrypoint.
library;

import 'package:flutter/material.dart';

import 'src/theme.dart';

export 'src/catalog.dart';
export 'src/chat_controller.dart';
export 'src/chat_page.dart';
export 'src/theme.dart';

void main() {
  runApp(const A2uiApp());
}
