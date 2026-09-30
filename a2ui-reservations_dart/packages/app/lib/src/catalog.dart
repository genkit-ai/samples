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

/// Client-side A2UI catalog definition for Cymbal Bistro.
library;

import 'package:a2ui_reservations_shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';

/// Custom `Card` catalog item with comfortable 20px padding for form layouts.
final CatalogItem bistroCardItem = CatalogItem(
  name: 'Card',
  dataSchema: BasicCatalogItems.card.dataSchema,
  widgetBuilder: (itemContext) {
    final childId = (itemContext.data as Map)['child'] as String;
    return Card(
      color: Theme.of(itemContext.buildContext).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: itemContext.buildChild(childId),
      ),
    );
  },
);

/// The client catalog, tagged with the same [bistroCatalogId] advertised by
/// the server's `bistroCatalog` (`package:a2ui_reservations_server/agent.dart`).
final Catalog bistroClientCatalog = BasicCatalogItems.asCatalog().copyWith(
  catalogId: bistroCatalogId,
  newItems: [bistroCardItem],
);
