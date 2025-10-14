import { z } from 'genkit';
import { ai } from './genkit.js';

export const marketingCopyFlow = ai.defineFlow(
  {
    name: 'marketingCopyFlow',
    inputSchema: z.object({ product: z.string() }),
    outputSchema: z.object({
      name: z.string(),
      tagline: z.string(),
    }),
  },
  async ({ product }) => {
    const [nameResponse, taglineResponse] = await Promise.all([
      // Task 1: Generate a creative name
      ai.generate({
        prompt: `Generate a creative name for a new product: ${product}.`,
      }),
      // Task 2: Generate a catchy tagline
      ai.generate({
        prompt: `Generate a catchy tagline for a new product: ${product}.`,
      }),
    ]);

    return {
      name: nameResponse.text,
      tagline: taglineResponse.text,
    };
  }
);
