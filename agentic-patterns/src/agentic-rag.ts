import { DocumentDataSchema, z } from 'genkit';
import { ai } from './genkit.js';
import { devLocalIndexerRef, devLocalRetrieverRef } from '@genkit-ai/dev-local-vectorstore';
import { Document } from 'genkit/retriever';

// Define the indexer and retriever references
export const menuIndexer = devLocalIndexerRef('menuQA');
export const menuRetriever = devLocalRetrieverRef('menuQA');

// 1. Define a retrieval tool
const menuRagTool = ai.defineTool(
  {
    name: 'menuRagTool',
    description: 'Use to retrieve information from the Genkit Grub Pub menu.',
    inputSchema: z.object({ query: z.string() }),
    outputSchema: z.array(DocumentDataSchema),
  },
  async ({ query }) => {
    const docs = await ai.retrieve({
      retriever: menuRetriever,
      query,
      options: { k: 3 },
    });
    return docs;
  }
);

export const indexMenu = ai.defineFlow(
  {
    name: 'indexMenu',
    inputSchema: z.null(),
    outputSchema: z.void(),
  },
  async () => {
    const menuItems = [
      'Classic Burger: A juicy beef patty with lettuce, tomato, and our special sauce.',
      'Vegetarian Burger: A delicious plant-based patty with avocado and sprouts.',
      'Fries: Crispy golden fries, lightly salted.',
      'Milkshake: A thick and creamy milkshake, available in vanilla, chocolate, and strawberry.',
      'Salad: A fresh garden salad with your choice of dressing.',
      'Chicken Sandwich: Grilled chicken breast with honey mustard on a brioche bun.',
      'Fish and Chips: Beer-battered cod with a side of tartar sauce.',
      'Onion Rings: Thick-cut onion rings, fried to perfection.',
      'Ice Cream Sundae: Two scoops of vanilla ice cream with chocolate sauce and a cherry on top.',
      'Apple Pie: A classic apple pie with a flaky crust, served warm.',
    ];

    await ai.index({
      indexer: menuIndexer,
      documents: menuItems.map(item => Document.fromText(item)),
    });
  }
);

// 2. Use the tool in a flow
export const agenticRagFlow = ai.defineFlow(
  {
    name: 'agenticRagFlow',
    inputSchema: z.object({ question: z.string() }),
    outputSchema: z.string(),
  },
  async ({ question }) => {
    const llmResponse = await ai.generate({
      prompt: question,
      tools: [menuRagTool],
      system: `You are a helpful AI assistant that can answer questions about the food available on the menu at Genkit Grub Pub.
Use the provided tool to answer questions.
If you don't know, do not make up an answer.
Do not add or change items on the menu.`,
    });
    return llmResponse.text;
  }
);
