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

part 'autonomous_operation.g.dart';

@Schema()
abstract class $AutonomousOperationInput {
  @Field(defaultValue: 'Research the current state of Genkit Dart support.')
  String get goal;
}

@Schema()
abstract class $AgentSearchInput {
  String get query;
}

@Schema()
abstract class $AgentAskUserInput {
  String get question;
}

void defineAutonomousOperationFlows(Genkit ai) {
  // 1. Define tools for the agent
  final webSearch = ai.defineTool(
    name: 'webSearch',
    description: 'Search the web for information.',
    inputSchema: AgentSearchInput.$schema,
    outputSchema: .string(),
    fn: (input, _) async {
      // In a real app, you would call a search API here.
      return 'Search results for "${input.query}": Genkit is a powerful AI framework from Firebase. '
          'This tool is mocked for demonstration purposes. In a real app, you would call a search API here. '
          'For now, pretend you found relevant information.';
    },
  );

  final askUser = ai.defineTool(
    name: 'askUser',
    description: 'Ask the user for clarification or more information.',
    inputSchema: AgentAskUserInput.$schema,
    outputSchema: .string(),
    fn: (input, context) async {
      // This tool interrupts the flow to ask the user a question.
      context.interrupt(input.question);
    },
  );

  // 2. Define the autonomous agent flow
  ai.defineFlow(
    name: 'researchAgent',
    inputSchema: AutonomousOperationInput.$schema,
    outputSchema: .string(),
    fn: (input, _) async {
      var response = await ai.generate(
        messages: [
          Message(
            role: Role.system,
            content: [
              TextPart(
                text:
                    'You are a research agent. Your goal is to help the user with their research goal. '
                    'Use the provided tools to search the web and ask the user for more information if needed. '
                    'Plan your steps and execute them autonomously.',
              ),
            ],
          ),
        ],
        prompt: input.goal,
        toolNames: [webSearch.name, askUser.name],
      );

      // Handle potential interrupts (human-in-the-loop)
      while (response.finishReason == FinishReason.interrupted) {
        final interrupts = response.interrupts;
        if (interrupts.isEmpty) break;

        final resumeResponses = <InterruptResponse>[];
        for (final interrupt in interrupts) {
          if (interrupt.toolRequest.name == 'askUser') {
            final question = interrupt.metadata?['interrupt'] as String?;
            // In a real app, you'd prompt the user here. For this sample:
            final simulatedAnswer =
                'The user answered: "Sample answer for \'$question\'"';
            resumeResponses.add(
              InterruptResponse(interrupt.toolRequestPart!, simulatedAnswer),
            );
          }
        }

        response = await ai.generate(
          messages: response.messages,
          toolNames: [webSearch.name, askUser.name],
          interruptRespond: resumeResponses,
        );
      }

      return response.text;
    },
  );
}
