'use server';

import {
  applyEmojiExpression,
  type ApplyEmojiExpressionInput,
} from '@/ai/flows/apply-emoji-expression';

type ActionResult = {
    modifiedImageDataUri?: string;
    error?: string;
}

export async function applyEmojiExpressionAction(
  input: ApplyEmojiExpressionInput
): Promise<ActionResult> {
  try {
    const result = await applyEmojiExpression(input);
    return { modifiedImageDataUri: result.modifiedImageDataUri };
  } catch (error) {
    console.error(error);
    const errorMessage = error instanceof Error ? error.message : 'An unknown error occurred.';
    return { error: `Failed to apply expression: ${errorMessage}` };
  }
}
