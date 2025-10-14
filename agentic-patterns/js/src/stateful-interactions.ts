import { z } from 'genkit';
import { MessageData } from 'genkit/beta';
import { ai } from './genkit.js';

// A simple in-memory store for conversation history.
// In a real app, you would use a database like Firestore or Redis.
const historyStore: Record<string, MessageData[]> = {};

async function loadHistory(sessionId: string): Promise<MessageData[]> {
  return historyStore[sessionId] || [];
}

async function saveHistory(sessionId: string, history: MessageData[]) {
  historyStore[sessionId] = history;
}

export const statefulChatFlow = ai.defineFlow(
  {
    name: 'statefulChatFlow',
    inputSchema: z.object({
      sessionId: z.string(),
      message: z.string(),
    }),
    outputSchema: z.string(),
  },
  async ({ sessionId, message }) => {
    // 1. Load history
    const history = await loadHistory(sessionId);

    // 2. Append new message
    history.push({ role: 'user', content: [{ text: message }] });

    // 3. Generate response with history
    const response = await ai.generate({
      messages: history,
    });

    // 4. Save updated history
    await saveHistory(sessionId, response.messages);

    return response.text;
  }
);
