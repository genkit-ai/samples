import express, { Request, Response } from 'express';
import helmet from 'helmet';
import { genkit, z } from 'genkit';
import { googleAI } from '@genkit-ai/google-genai';
import { fileURLToPath } from 'url';
import path from 'path';
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
// Initialize Genkit AI
const ai = genkit({
  plugins: [googleAI()],
});

// Define mock tools
const readCoffeeMenu = ai.defineTool(
  {
    name: 'readCoffeeMenu',
    description: 'Read the coffee menu to see available drinks and prices',
    inputSchema: z.object({}),
    outputSchema: z.string(),
  },
  async () => {
    return 'Menu: Espresso ($3.99), Latte ($4.99), Kopi Luwak Pour-Over ($99.99)';
  }
);

const orderCoffee = ai.defineTool(
  {
    name: 'orderCoffee',
    description: 'Order a coffee drink',
    inputSchema: z.object({ drink: z.string() }),
    outputSchema: z.string(),
  },
  async (input) => {
    return `Successfully ordered a ${input.drink}!`;
  }
);

const app = express();
const PORT = Number(process.env.PORT) || 3000;

// Security: Enable Helmet with standard CSP directives
app.use(
  helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        scriptSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'", "https://fonts.googleapis.com"],
        fontSrc: ["'self'", "https://fonts.gstatic.com"],
        connectSrc: ["'self'"],
      },
    },
  })
);

app.use(express.json());

if (process.env.NODE_ENV === 'production') {
  app.use(express.static(path.join(__dirname, '../../dist')));
  app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, '../../dist/index.html'));
  });
}

app.get('/api/health', (req: Request, res: Response) => {
  res.json({ status: 'ok', message: 'Express + Genkit server initialized successfully' });
});

import { expressHandler } from '@genkit-ai/express';

export const chatFlow = ai.defineFlow({
  name: 'chatFlow',
  inputSchema: z.object({
    messages: z.array(z.any()),
  }),
  streamSchema: z.object({
    text: z.string().optional(),
    toolRequest: z.any().optional(),
    toolResponse: z.any().optional(),
  }),
}, async (input, { sendChunk }) => {
  const { stream, response } = await ai.generateStream({
    model: googleAI.model('gemini-3.5-flash'),
    messages: input.messages,
    tools: [readCoffeeMenu, orderCoffee], // Register tools
    config: {
      thinkingConfig: {
        thinkingLevel: 'MINIMAL',
      },
    },
  });

  for await (const chunk of stream) {
    for (const part of chunk.content || []) {
      sendChunk(part);
    }
  }

  const finalResponse = await response;
  return finalResponse.text;
});

// POST /api/chat generation route
app.post('/api/chat', expressHandler(chatFlow));

// Security: Bind to configurable host (defaults to 127.0.0.1 for local testing)
const HOST = process.env.HOST || '127.0.0.1';
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  app.listen(PORT, HOST, () => {
    console.log(`Server is running at http://${HOST}:${PORT}`);
  });
}

export { ai, app };
