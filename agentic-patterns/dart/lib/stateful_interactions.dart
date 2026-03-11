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

import 'package:genkit/genkit.dart';
import 'package:schemantic/schemantic.dart';

part 'stateful_interactions.g.dart';

@Schema()
abstract class $ChatInput {
  @Field(defaultValue: 'session123')
  String get sessionId;
  @Field(defaultValue: 'Hello!')
  String get message;
}

void defineStatefulInteractionFlows(Genkit ai) {
  // In-memory session store (simulation)
  final Map<String, List<Message>> sessionHistory = {};

  ai.defineFlow(
    name: 'statefulChatFlow',
    inputSchema: ChatInput.$schema,
    outputSchema: .string(),
    fn: (input, _) async {
      final history = sessionHistory[input.sessionId] ?? [];

      final response = await ai.generate(
        messages: [
          Message(
            role: Role.system,
            content: [TextPart(text: 'You are a helpful and friendly AI assistant.')]),
          ...history,
        ],
        prompt: input.message,
      );

      // Simple update of history (the SDK also handles history in GenerateResponse)
      sessionHistory[input.sessionId] = response.messages;

      return response.text;
    },
  );
}
