const express = require('express');
const helmet = require('helmet');
const path = require('path');
const { genkit, z } = require('genkit');
const { googleAI } = require('@genkit-ai/google-genai');

// Initialize Genkit AI
const ai = genkit({
  plugins: [googleAI()],
});

// Define the schema for the streaming chunks
const StreamChunkSchema = z.object({
  type: z.enum(['thought', 'text']),
  content: z.string(),
  currentStep: z.string().optional(),
});


const streamingThoughtsFlow = ai.defineFlow(
  {
    name: 'streamingThoughtsFlow',
    inputSchema: z.string().describe('The prompt for the agent'),
    outputSchema: z.string().describe('The final text response'),
    streamSchema: StreamChunkSchema,
  },
  async (prompt, { sendChunk }) => {
    // Generate a stream using the Google AI plugin.
    // We use gemini-3.5-flash which natively supports thinkingConfig and provides deeper reasoning.
    const { stream, response } = await ai.generateStream({
      model: googleAI.model('gemini-3.5-flash'),
      prompt,
      config: {
        thinkingConfig: {
          includeThoughts: true,
          thinkingBudget: -1, // Default thinking budget
        },
      },
    });

    let accumulatedThoughts = "";

    // Consume the stream as it arrives
    for await (const chunk of stream) {
      // Process Thoughts
      // Gemini 3.5/2.5 models populate thoughts in `chunk.reasoning`. If using other
      // model providers or custom adapters, you may need to change this to chunk.thought,
      // chunk.custom?.thought, or manually iterate over `chunk.content` parts.
      const thoughtText = chunk.reasoning || '';

      if (thoughtText) {
        accumulatedThoughts += thoughtText;

        // Extract the most recent thought title wrapped in ** **
        const matches = [...accumulatedThoughts.matchAll(/\*\*(.*?)\*\*/g)];
        const lastStep = matches.length > 0 ? matches[matches.length - 1][1] : undefined;

        sendChunk({
          type: 'thought',
          content: thoughtText,
          currentStep: lastStep,
        });
      }

      const text = chunk.text;
      if (text) {
        sendChunk({
          type: 'text',
          content: text,
        });
      }
    }

    // Wait for the full response and return the complete text
    const finalResponse = await response;
    return finalResponse.text;
  }
);

const app = express();
const PORT = process.env.PORT || 3000;

// Security: Enable Helmet for strict security headers, including CSP.
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
app.use(express.static(path.join(__dirname, '../public')));

// API Endpoint to stream the chat response (Server-Sent Events)
app.post('/api/chat', async (req, res) => {
  const { prompt } = req.body;

  if (typeof prompt !== 'string' || prompt.trim() === '') {
    return res.status(400).json({ error: 'Prompt must be a non-empty string' });
  }

  // Set SSE headers
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');

  try {
    const responseStream = streamingThoughtsFlow.stream(prompt);

    // Stream the chunks as they arrive
    for await (const chunk of responseStream.stream) {
      res.write(`data: ${JSON.stringify(chunk)}\n\n`);
    }

    res.end();
  } catch (error) {
    console.error('Error in stream processing:', error);
    res.write(`data: ${JSON.stringify({ type: 'error', content: 'An error occurred while generating response.' })}\n\n`);
    res.end();
  }
});

// Security: Bind exclusively to 127.0.0.1 for local testing
if (require.main === module) {
  app.listen(PORT, '127.0.0.1', () => {
    console.log(`Server is running at http://127.0.0.1:${PORT}`);
  });
}

module.exports = { ai, streamingThoughtsFlow, app };
