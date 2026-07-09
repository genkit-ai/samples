import express, { Request, Response } from 'express';
import helmet from 'helmet';
import { z } from 'genkit';
import { genkit, InMemorySessionStore } from 'genkit/beta';
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
  async ({ drink }, ctx) => {
    const session = ai.currentSession<{ autoApprovedTools?: string[] }>();
    const isAutoApproved = session?.getCustom()?.autoApprovedTools?.includes('orderCoffee');
    // `ctx.resumed` contains the payload sent by the client when it resumes an interrupted stream.
    // When the user approves the tool call, the client passes this metadata to bypass the interrupt.
    // The `autoApprove` flag is also passed here if the user opted to remember their decision.
    const resumed = ctx.resumed as { toolApproved?: boolean, autoApprove?: boolean } | undefined;

    if (!isAutoApproved && !resumed?.toolApproved) {
      // Note: ctx.interrupt() throws a ToolInterruptError to suspend execution,
      // so it never reaches the success return statement at the end.
      ctx.interrupt({ reason: 'User approval is required to order coffee.' });
    }

    if (resumed?.autoApprove && !isAutoApproved) {
      await session?.updateCustom((prev) => {
        const autoApprovedTools = [...(prev?.autoApprovedTools || [])];
        if (!autoApprovedTools.includes('orderCoffee')) {
          autoApprovedTools.push('orderCoffee');
        }
        return { ...prev, autoApprovedTools };
      });
    }

    // Simulate API delay like a real coffee ordering system would have
    await new Promise((resolve) => setTimeout(resolve, 1000));

    return `Successfully ordered a ${drink}!`;
  }
);
// IMPORTANT: For local testing, we use InMemorySessionStore to store agent memory
// If deploying to production, you must use a persistent database plugin (like Firestore) instead
// to ensure agent state is not lost between chat messages.
const store = new InMemorySessionStore();

// Note: `defineAgent` requires a Genkit version of v1.39.0 or higher
export const coffeeAgent = ai.defineAgent({
  name: 'coffeeAgent',
  model: googleAI.model('gemini-3.5-flash'),
  tools: [readCoffeeMenu, orderCoffee],
  store: store,
});

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



// POST /api/agent native genkit agent route
app.post('/api/agent', expressHandler(coffeeAgent));

// Security: Bind to configurable host (defaults to 127.0.0.1 for local testing)
const HOST = process.env.HOST || '127.0.0.1';
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  app.listen(PORT, HOST, () => {
    console.log(`Server is running at http://${HOST}:${PORT}`);
  });
}

export { ai, app };
