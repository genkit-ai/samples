import { genkit } from 'genkit';
import { gemini20Flash, googleAI } from '@genkit-ai/googleai';

// Configure Genkit with necessary plugins
export const ai = genkit({
  plugins: [googleAI()],
  model: gemini20Flash
});

