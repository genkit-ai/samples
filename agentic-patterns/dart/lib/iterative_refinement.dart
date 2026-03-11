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

part 'iterative_refinement.g.dart';

@Schema()
abstract class $IterativeRefinementInput {
  @Field(defaultValue: 'the benefits of agentic AI')
  String get topic;
}

@Schema()
abstract class $ReviewResult {
  String get feedback;
  bool get isApproved;
}

void defineIterativeRefinementFlows(Genkit ai) {
  ai.defineFlow(
    name: 'iterativeRefinementFlow',
    inputSchema: IterativeRefinementInput.$schema,
    outputSchema: .string(),
    fn: (input, _) async {
      String currentDraft = '';
      int iterations = 0;
      const maxIterations = 3;

      while (iterations < maxIterations) {
        iterations++;

        // Step 1: Generate or refine the draft
        final generatePrompt = currentDraft.isEmpty
            ? 'Write a short article about ${input.topic}.'
            : 'Refine the following article based on the feedback: $currentDraft';

        final generateResponse = await ai.generate(prompt: generatePrompt);
        currentDraft = generateResponse.text;

        // Step 2: Review the draft
        final reviewResponse = await ai.generate(
          prompt: 'Review the following article and provide feedback. '
              'If the article is good, set isApproved to true. '
              'Article: $currentDraft',
          outputSchema: ReviewResult.$schema,
        );

        final review = reviewResponse.output;
        if (review != null && review.isApproved) {
          break;
        }
      }

      return currentDraft;
    },
  );
}
