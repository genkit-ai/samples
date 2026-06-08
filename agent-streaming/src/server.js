const express = require('express');
const helmet = require('helmet');
const path = require('path');
const { streamingThoughtsFlow } = require('./index.js');

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

    // Wait for the final output and send it
    const finalResult = await responseStream.output;
    res.write(`data: ${JSON.stringify({ type: 'done', content: finalResult })}\n\n`);
    res.end();
  } catch (error) {
    console.error('Error in stream processing:', error);
    res.write(`data: ${JSON.stringify({ type: 'error', content: 'An error occurred while generating response.' })}\n\n`);
    res.end();
  }
});

// Security: Bind exclusively to 127.0.0.1 for local testing
const server = app.listen(PORT, '127.0.0.1', () => {
  console.log(`Server is running at http://127.0.0.1:${PORT}`);
});
