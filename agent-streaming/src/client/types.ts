export interface StreamChunk {
  messageId: string;
  type: 'thought' | 'text' | 'error';
  content: string;
  currentStep?: string;
}

export interface BaseMessage {
  id: string;
}

export interface TextMessage extends BaseMessage {
  type: 'text';
  role: 'user' | 'model' | 'system';
  content: string;
}

export interface ThoughtMessage extends BaseMessage {
  type: 'thought';
  role: 'model';
  content: string;
  stepName?: string; // For thought cards
}

export interface ErrorMessage extends BaseMessage {
  type: 'error';
  role: 'system';
  content: string;
}

export type Message = TextMessage | ThoughtMessage | ErrorMessage;

