import { MessageData } from 'genkit/beta';

const history: Record<string, MessageData[]> = {};

export async function loadHistory(
  sessionId: string
): Promise<MessageData[] | null> {
  return history[sessionId] || null;
}

export async function saveHistory(
  sessionId: string,
  messages: MessageData[]
): Promise<void> {
  history[sessionId] = messages;
}
