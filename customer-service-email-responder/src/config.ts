import { genkit } from 'genkit';
import vertexAI, { gemini10Pro, gemini15Flash, gemini15Pro, textEmbedding004 } from '@genkit-ai/vertexai';
import genkitEval, { GenkitMetric } from '@genkit-ai/evaluator';

// Configure Genkit with necessary plugins
export const ai = genkit({
  plugins: [
    vertexAI({projectId: process.env.PROJECT_ID, location: process.env.LOCATION || "us-central1"}),
  ],
  model: gemini15Flash
});

