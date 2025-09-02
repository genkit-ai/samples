'use server';

/**
 * @fileOverview Applies the expression of a selected emoji to a user's selfie using the Gemini 2.5 Flash image model.
 *
 * - applyEmojiExpression - A function that handles the emoji expression application process.
 * - ApplyEmojiExpressionInput - The input type for the applyEmojiExpression function.
 * - ApplyEmojiExpressionOutput - The return type for the applyEmojiExpression function.
 */

import {ai} from '@/ai/genkit';
import {z} from 'genkit';

const ApplyEmojiExpressionInputSchema = z.object({
  selfieDataUri: z
    .string()
    .describe(
      'A selfie of the user as a data URI that must include a MIME type and use Base64 encoding. Expected format: \'data:<mimetype>;base64,<encoded_data>\'.'  ),
  emoji: z.string().describe('The selected emoji to apply to the selfie.'),
  transformationMode: z.enum(['realistic', 'silly']).default('silly').describe('The transformation mode. "realistic" keeps the original face, "silly" allows for more creative transformations.'),
});
export type ApplyEmojiExpressionInput = z.infer<typeof ApplyEmojiExpressionInputSchema>;

const ApplyEmojiExpressionOutputSchema = z.object({
  modifiedImageDataUri: z
    .string()
    .describe('The modified image with the emoji expression applied, as a data URI.'),
});
export type ApplyEmojiExpressionOutput = z.infer<typeof ApplyEmojiExpressionOutputSchema>;

export async function applyEmojiExpression(input: ApplyEmojiExpressionInput): Promise<ApplyEmojiExpressionOutput> {
  return applyEmojiExpressionFlow(input);
}

const applyEmojiExpressionFlow = ai.defineFlow(
  {
    name: 'applyEmojiExpressionFlow',
    inputSchema: ApplyEmojiExpressionInputSchema,
    outputSchema: ApplyEmojiExpressionOutputSchema,
  },
  async input => {
    
    let promptText = '';
    if (input.transformationMode === 'silly') {
        promptText = `Transform the user's face in a silly, fun, and exaggerated way based on this emoji: ${input.emoji}. Be very literal. For example, if the emoji is a piece of broccoli, you could replace the person's head with broccoli. If it's a crying face, make tears stream like a waterfall. Go overboard and be creative!`;
    } else {
        promptText = `Subtly modify the user's facial expression to match the emotion of this emoji: ${input.emoji}. It is very important to keep the original person's face and features mostly intact, but change their expression (mouth, eyes, eyebrows) to look like the emoji. The result should look like a real photo of the person making that face. If the emoji has additional objects on the face, add a realistic version of those objects. For example the emoji of a cowboy with hat face should add a realistic cowboy hat to the person's head.`;
    }

    const {media} = await ai.generate({
      model: 'googleai/gemini-2.5-flash-image-preview',
      prompt: [
        {media: {url: input.selfieDataUri}},
        {text: promptText},
      ],
      config: {
        responseModalities: ['TEXT', 'IMAGE'], // MUST provide both TEXT and IMAGE, IMAGE only won't work
      },
    });

    if (!media) {
      throw new Error('No media returned from the image generation model.');
    }

    return {modifiedImageDataUri: media.url!};
  }
);
