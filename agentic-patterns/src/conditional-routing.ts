import { z } from 'genkit';
import { ai } from './genkit.js';

export const routerFlow = ai.defineFlow(
  {
    name: 'routerFlow',
    inputSchema: z.object({ query: z.string() }),
    outputSchema: z.string(),
  },
  async ({ query }) => {
    // Step 1: Classify the user's intent
    const intentResponse = await ai.generate({
      prompt: `Classify the user's query as either a 'question' or a 'creative' request. Query: "${query}"`,
      output: {
        schema: z.object({
          intent: z.enum(['question', 'creative']),
        }),
      },
    });

    const intent = intentResponse.output?.intent;

    // Step 2: Route based on the intent
    if (intent === 'question') {
      // Handle as a straightforward question
      const answerResponse = await ai.generate({
        prompt: `Answer the following question: ${query}`,
      });
      return answerResponse.text;
    } else if (intent === 'creative') {
      // Handle as a creative writing prompt
      const creativeResponse = await ai.generate({
        prompt: `Write a short poem about: ${query}`,
      });
      return creativeResponse.text;
    } else {
      return "Sorry, I couldn't determine how to handle your request.";
    }
  }
);
