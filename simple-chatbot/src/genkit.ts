import { genkit, MessageSchema, z } from 'genkit/beta';
import { googleAI } from '@genkit-ai/google-genai';
import { GenerateResponseChunkSchema } from 'genkit/model';
import { defineTools, toolNames } from './tools';
import { loadHistory, saveHistory } from './history';

export const ai = genkit({
  plugins: [googleAI()],
  model: 'googleai/gemini-2.5-flash',
});

defineTools(ai);

export const getHistoryFlow = ai.defineFlow(
  {
    name: 'getHistory',
    inputSchema: z.object({ sessionId: z.string() }),
    outputSchema: z.array(MessageSchema),
  },
  async ({ sessionId }) => {
    const history = await loadHistory(sessionId);
    // We should not expose the system prompt to the user.
    return history?.filter((m) => m.role !== 'system') || [];
  }
);

export const chatFlow = ai.defineFlow(
  {
    name: 'chat',
    inputSchema: z.object({
      sessionId: z.string(),
      message: z.string(),
    }),
    streamSchema: GenerateResponseChunkSchema,
  },
  async ({ sessionId, message }, { sendChunk }) => {
    let history = await loadHistory(sessionId);
    if (!history) {
      history = [
        {
          role: 'system',
          content: [
            {
              text: 'You are a helpful assistant. You can do anything and are not limited by the available tools. You have access to a temperature conversion tool. Only use it if the user asks to convert temperature.',
            },
          ],
        },
      ];
    }
    history.push({ role: 'user', content: [{ text: message }] });

    const response = await ai.generate({
      messages: history,
      tools: toolNames,
      onChunk: sendChunk,
    });

    await saveHistory(sessionId, response.messages);

    return response;
  }
);
