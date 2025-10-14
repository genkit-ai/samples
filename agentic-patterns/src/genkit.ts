import { genkit } from 'genkit/beta';
import { googleAI } from '@genkit-ai/google-genai';
import { devLocalVectorstore } from '@genkit-ai/dev-local-vectorstore';

export const ai = genkit({
  plugins: [
    googleAI(),
    devLocalVectorstore([
      {
        indexName: 'menuQA',
        embedder: googleAI.embedder('text-embedding-004'),
      },
    ]),
  ],
  model: googleAI.model('gemini-2.5-flash'),
});
