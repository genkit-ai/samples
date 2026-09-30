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

import 'package:a2ui_core/a2ui_core.dart' as core;
import 'package:a2ui_reservations_app/main.dart';
import 'package:a2ui_reservations_shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genkit_a2ui/client.dart';
import 'package:genui/genui.dart' hide DataPart, TextPart, basicCatalogId;

void main() {
  group('Flutter Client UI & A2UI Rendering', () {
    testWidgets('displays welcome hero screen on launch', (tester) async {
      await tester.pumpWidget(const A2uiApp());
      expect(find.text('Welcome to Cymbal Bistro'), findsOneWidget);
      expect(find.text('Dinner Tonight for 4'), findsOneWidget);
      expect(find.text('Date Night Tomorrow'), findsOneWidget);
    });

    testWidgets(
      'renders A2UI reservation surface and dispatches confirmReservation action',
      (tester) async {
        final controller = SurfaceController(catalogs: [bistroClientCatalog]);

        final envelopes = [
          {
            'version': 'v0.9',
            'createSurface': {
              'surfaceId': 'reservation-surface',
              'catalogId': bistroCatalogId,
            },
          },
          {
            'version': 'v0.9',
            'updateComponents': {
              'surfaceId': 'reservation-surface',
              'components': [
                {'id': 'root', 'component': 'Card', 'child': 'formCol'},
                {
                  'id': 'formCol',
                  'component': 'Column',
                  'children': [
                    'title',
                    'timePicker',
                    'seatingPicker',
                    'confirmBtn',
                  ],
                },
                {
                  'id': 'title',
                  'component': 'Text',
                  'text': 'Reserve a Table at Cymbal Bistro',
                  'variant': 'h3',
                },
                {
                  'id': 'timePicker',
                  'component': 'ChoicePicker',
                  'label': 'Time Slot',
                  'displayStyle': 'chips',
                  'variant': 'mutuallyExclusive',
                  'value': {'path': '/time'},
                  'options': [
                    {'label': '6:00 PM', 'value': '6:00 PM'},
                    {'label': '7:30 PM', 'value': '7:30 PM'},
                  ],
                },
                {
                  'id': 'seatingPicker',
                  'component': 'ChoicePicker',
                  'label': 'Seating Area',
                  'displayStyle': 'chips',
                  'variant': 'mutuallyExclusive',
                  'value': {'path': '/seating'},
                  'options': [
                    {'label': 'Indoor Dining', 'value': 'Indoor Dining'},
                    {'label': 'Heated Patio', 'value': 'Heated Patio'},
                  ],
                },
                {
                  'id': 'confirmBtn',
                  'component': 'Button',
                  'variant': 'primary',
                  'child': 'confirmBtnText',
                  'action': {
                    'event': {
                      'name': 'confirmReservation',
                      'context': {
                        'restaurant': 'Cymbal Bistro',
                        'time': {'path': '/time'},
                        'seatingArea': {'path': '/seating'},
                      },
                    },
                  },
                },
                {
                  'id': 'confirmBtnText',
                  'component': 'Text',
                  'text': 'Confirm Reservation',
                },
              ],
            },
          },
          {
            'version': 'v0.9',
            'updateDataModel': {
              'surfaceId': 'reservation-surface',
              'path': '/time',
              'value': ['6:00 PM'],
            },
          },
          {
            'version': 'v0.9',
            'updateDataModel': {
              'surfaceId': 'reservation-surface',
              'path': '/seating',
              'value': ['Indoor Dining'],
            },
          },
        ];

        for (final e in envelopes) {
          controller.handleMessage(core.A2uiMessage.fromJson(e));
        }

        ChatMessage? submittedMessage;
        controller.onSubmit.listen((msg) => submittedMessage = msg);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: IntrinsicHeight(
                  child: Surface(
                    surfaceContext: controller.contextFor(
                      'reservation-surface',
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Select '7:30 PM' and 'Heated Patio'
        await tester.tap(find.text('7:30 PM'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Heated Patio'));
        await tester.pumpAndSettle();

        // Click 'Confirm Reservation'
        await tester.tap(find.text('Confirm Reservation'));
        await tester.pumpAndSettle();

        expect(submittedMessage, isNotNull);
        final action = extractClientAction(submittedMessage!);
        expect(action, isNotNull);
        expect(action!.name, equals('confirmReservation'));
        expect(action.context['time'], equals(['7:30 PM']));
        expect(action.context['seatingArea'], equals(['Heated Patio']));

        final msg = actionToMessage(action);
        expect(msg.content.first.toJson()['text'], contains('confirmReservation'));
      },
    );
  });
}
