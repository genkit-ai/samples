import { z } from 'genkit';
import { ai } from './genkit.js';

export const iterativeRefinementFlow = ai.defineFlow(
  {
    name: 'iterativeRefinementFlow',
    inputSchema: z.object({ topic: z.string() }),
    outputSchema: z.string(),
  },
  async ({ topic }) => {
    let content = '';
    let feedback = '';
    let attempts = 0;

    // Step 1: Generate the initial draft
    content = (
      await ai.generate({
        prompt: `Write a short, single-paragraph blog post about: ${topic}.`,
      })
    ).text;

    // Step 2: Iteratively refine the content
    while (attempts < 3) {
      attempts++;

      // The "Evaluator" provides feedback
      const evaluationResponse = await ai.generate({
        prompt: `Critique the following blog post. Is it clear, concise, and engaging? Provide specific feedback for improvement. Post: "${content}"`,
        output: {
          schema: z.object({
            critique: z.string(),
            satisfied: z.boolean(),
          }),
        },
      });

      const evaluation = evaluationResponse.output;
      if (!evaluation) {
        throw new Error('Failed to evaluate content.');
      }

      if (evaluation.satisfied) {
        break; // Exit loop if content is good enough
      }

      feedback = evaluation.critique;

      // The "Optimizer" refines the content based on feedback
      content = (
        await ai.generate({
          prompt: `Revise the following blog post based on the feedback provided.
          Post: "${content}"
          Feedback: "${feedback}"`,
        })
      ).text;
    }

    return content;
  }
);
