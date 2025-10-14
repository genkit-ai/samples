import { z } from 'genkit';
import { googleAI } from '@genkit-ai/google-genai';
import { ai } from './genkit.js';

export const storyWriterFlow = ai.defineFlow(
  {
    name: 'storyWriterFlow',
    inputSchema: z.object({ topic: z.string() }),
    outputSchema: z.string(),
  },
  async ({ topic }) => {
    // Step 1: Generate a creative story idea
    const ideaResponse = await ai.generate({
      prompt: `Generate a unique story idea about a ${topic}.`,
      output: {
        schema: z.object({
          idea: z.string().describe('A short, compelling story concept'),
        }),
      },
    });

    const storyIdea = ideaResponse.output?.idea;
    if (!storyIdea) {
      throw new Error('Failed to generate a story idea.');
    }

    // Step 2: Use the idea to write the beginning of the story
    const storyResponse = await ai.generate({
      prompt: `Write the opening paragraph for a story based on this idea: ${storyIdea}`,
    });

    return storyResponse.text;
  }
);

export const imageGeneratorFlow = ai.defineFlow(
  {
    name: 'imageGeneratorFlow',
    inputSchema: z.object({ concept: z.string() }),
    outputSchema: z.string(),
  },
  async ({ concept }) => {
    // Step 1: Use a text model to generate a rich image prompt
    const promptResponse = await ai.generate({
      model: googleAI.model('gemini-2.5-flash'),
      prompt: `Create a detailed, artistic prompt for an image generation model. The concept is: "${concept}".`,
    });

    const imagePrompt = promptResponse.text;

    // Step 2: Use the generated prompt to create an image
    const imageResponse = await ai.generate({
      model: googleAI.model('imagen-3.0-generate-002'),
      prompt: imagePrompt,
      output: { format: 'media' },
    });

    const imageUrl = imageResponse.media?.url;
    if (!imageUrl) {
      throw new Error('Failed to generate an image.');
    }
    return imageUrl;
  }
);
