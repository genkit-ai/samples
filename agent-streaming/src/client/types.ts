export interface StreamChunk {
  type: 'thought' | 'text' | 'error';
  content: string;
  currentStep?: string;
}

export interface Message {
  id: string;
  role: 'user' | 'model' | 'system';
  type: 'text' | 'thought' | 'error';
  content: string;
  stepName?: string; // For thought cards
}
