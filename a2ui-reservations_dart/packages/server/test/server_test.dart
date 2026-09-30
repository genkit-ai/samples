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

import 'dart:io';

import 'package:a2ui_reservations_server/agent.dart';
import 'package:a2ui_reservations_shared/shared.dart';
import 'package:genkit/genkit.dart' show ToolResponseResult;
import 'package:genkit_a2ui/client.dart';
import 'package:test/test.dart';

void main() {
  group('Server Agent & Catalog', () {
    test('registers bistroCatalog and exposes tools', () async {
      await registerCatalogs();
      expect(bistroCatalog.id, equals(bistroCatalogId));
      expect(
        bistroCatalog.components.map((c) => c.name),
        containsAll(['Card', 'DateTimeInput', 'ChoicePicker', 'Button']),
      );
      expect(checkAvailability.name, equals('checkAvailability'));
      expect(confirmReservation.name, equals('confirmReservation'));
    });

    test('checkAvailability returns ISO date and slots', () async {
      final res = await checkAvailability.call(
        CheckAvailabilityInput(
          restaurant: 'Cymbal Bistro',
          date: 'tonight',
          partySize: 4,
        ),
      );
      final output = (res as ToolResponseResult<CheckAvailabilityOutput>).output;
      expect(output.available, isTrue);
      expect(output.date, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
      expect(output.availableSlots, contains('7:00 PM'));
      expect(output.seatingAreas, contains('Heated Patio'));
    });

    test('confirmReservation generates confirmation code', () async {
      final res = await confirmReservation.call(
        ConfirmReservationInput(
          restaurant: 'Cymbal Bistro',
          date: '2026-09-16',
          time: '7:30 PM',
          partySize: 4,
          seatingArea: 'Heated Patio',
          specialRequests: 'Quiet corner',
        ),
      );
      final output =
          (res as ToolResponseResult<ConfirmReservationOutput>).output;
      expect(output.confirmationCode, startsWith('CB-'));
      expect(output.status, equals('Confirmed'));
      expect(output.seatingArea, equals('Heated Patio'));
    });
  });

  // Live E2E test runs only when GEMINI_API_KEY is present in environment
  final apiKey = Platform.environment['GEMINI_API_KEY'];
  if (apiKey != null && apiKey.isNotEmpty) {
    test('Live E2E: Two-turn booking flow with Gemini', () async {
      await registerCatalogs();
      final chat = uiAgent.chat();
      final turn1 = chat.sendStream(
        text: 'Book a table for 4 at Cymbal Bistro tonight at 7:00 PM.',
      );

      String? surfaceId;
      final envelopes1 = <Map<String, dynamic>>[];
      await for (final chunk in turn1.stream) {
        for (final env in a2uiEnvelopesFromParts(
          chunk.raw.modelChunk?.content,
        )) {
          envelopes1.add(env);
          if (env['createSurface'] != null) {
            surfaceId = env['createSurface']['surfaceId'] as String?;
          }
        }
      }
      await turn1.response;
      expect(surfaceId, isNotNull);
      expect(envelopes1, isNotEmpty);

      final action = A2uiClientAction(
        name: 'confirmReservation',
        surfaceId: surfaceId!,
        sourceComponentId: 'confirmBtn',
        timestamp: DateTime.now().toUtc().toIso8601String(),
        context: {
          'restaurant': 'Cymbal Bistro',
          'date': '2026-09-16',
          'time': ['7:30 PM'],
          'partySize': 4,
          'seatingArea': ['Heated Patio'],
          'specialRequests': 'Anniversary dinner',
        },
      );

      final turn2 = chat.sendStream(message: actionToMessage(action));
      final envelopes2 = <Map<String, dynamic>>[];
      await for (final chunk in turn2.stream) {
        for (final env in a2uiEnvelopesFromParts(
          chunk.raw.modelChunk?.content,
        )) {
          envelopes2.add(env);
        }
      }
      await turn2.response;
      expect(envelopes2, isNotEmpty);
    });
  }
}
