import express, { Request, Response } from 'express';
import helmet from 'helmet';
import { genkit } from 'genkit';
import { googleAI } from '@genkit-ai/google-genai';
import { fileURLToPath } from 'url';
import path from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
// Initialize Genkit AI
const ai = genkit({
  plugins: [googleAI()],
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

// Security: Bind to configurable host (defaults to 127.0.0.1 for local testing)
const HOST = process.env.HOST || '127.0.0.1';
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  app.listen(PORT, HOST, () => {
    console.log(`Server is running at http://${HOST}:${PORT}`);
  });
}

export { ai, app };
