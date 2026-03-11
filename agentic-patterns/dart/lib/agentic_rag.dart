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

part 'agentic_rag.g.dart';

@Schema()
abstract class $AgenticRagRequest {
  @Field(defaultValue: 'What kind of burgers do you have?')
  String get question;
}

@Schema()
abstract class $MenuRagToolRequest {
  @Field(
    description:
        'Basic keyword search query that does simple word matching. '
        'Allows multiple space separated words, e.g.: burger milkshake',
  )
  String get query;
}

// Setup RAG (Naive implementation)
const menuItems = [
  'Main: Cheeseburger - \$10.99',
  'Main: Veggie Burger - \$9.99',
  'Side: French Fries - \$3.99',
  'Side: Onion Rings - \$4.49',
  'Drink: Chocolate Milkshake - \$5.49',
  'Drink: Vanilla Milkshake - \$5.49',
  'Drink: Soda - \$2.49',
];

void defineAgenticRagFlows(Genkit ai) {
  // 1. Retrieval tool (Naive substring search)
  final menuRagTool = ai.defineTool(
    name: 'menuRagTool',
    description: 'Use to retrieve information from the Genkit Grub Pub menu.',
    inputSchema: MenuRagToolRequest.$schema,
    outputSchema: .list(DocumentData.$schema),
    fn: (input, _) async {
      final queryWords = input.query
          .toLowerCase()
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .map((w) {
            // Remove common plural and verb endings to improve matching
            if (w.endsWith('s') && w.length > 3)
              return w.substring(0, w.length - 1);
            if (w.endsWith('ing') && w.length > 5)
              return w.substring(0, w.length - 3);
            return w;
          })
          .toList();

      if (queryWords.isEmpty) return [];

      final docs = menuItems
          .where((item) {
            final lowerItem = item.toLowerCase();
            // Return true if any of the query word stems are found in the item.
            return queryWords.any((word) => lowerItem.contains(word));
          })
          .map((item) => DocumentData(content: [TextPart(text: item)]))
          .toList();

      return docs;
    },
  );

  // 2. Agentic RAG flow
  ai.defineFlow(
    name: 'agenticRagFlow',
    inputSchema: AgenticRagRequest.$schema,
    outputSchema: .string(),
    fn: (input, _) async {
      final response = await ai.generate(
        messages: [
          Message(
            role: Role.system,
            content: [
              TextPart(
                text:
                    'You are a helpful AI assistant that can answer questions about the food available on the menu at Genkit Grub Pub. '
                    'Use the provided tool to answer questions. '
                    'If you don\'t know, do not make up an answer. '
                    'Do not add or change items on the menu.',
              ),
            ],
          ),
        ],
        prompt: input.question,
        toolNames: [menuRagTool.name],
      );
      return response.text;
    },
  );
}
