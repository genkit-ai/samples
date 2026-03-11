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

part 'conditional_routing.g.dart';

@Schema()
abstract class $RouterInput {
  @Field(defaultValue: 'How do I bake a cake?')
  String get query;
}

@Schema()
abstract class $IntentClassification {
  @Schema()
  String get intent;
}

void defineConditionalRoutingFlows(Genkit ai) {
  ai.defineFlow(
    name: 'routerFlow',
    inputSchema: RouterInput.$schema,
    outputSchema: .string(),
    fn: (input, _) async {
      // Step 1: Classify the user's intent
      final intentResponse = await ai.generate(
        prompt:
            "Classify the user's query as either a 'question' or a 'creative' request. Query: \"${input.query}\"",
        outputSchema: IntentClassification.$schema,
      );

      final intent = intentResponse.output?.intent;

      // Step 2: Route based on the intent
      if (intent == 'question') {
        // Handle as a straightforward question
        // Wrapping the call in ai.run allows us to trace the execution of this sub-flow.
        final answerResponse = await ai.run(
          'question',
          () => ai.generate(
            prompt: 'Answer the following question: ${input.query}',
          ),
        );
        return answerResponse.text;
      } else if (intent == 'creative') {
        // Handle as a creative writing prompt
        final creativeResponse = await ai.run(
          'creative',
          () => ai.generate(prompt: 'Write a short poem about: ${input.query}'),
        );
        return creativeResponse.text;
      } else {
        return "Sorry, I couldn't determine how to handle your request.";
      }
    },
  );
}
