import { fetchHandlers } from '@genkit-ai/fetch';
import { serve } from '@hono/node-server';
import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { bargainChefFlow } from './genkit/bargainChefFlow.js';

const app = new Hono();
app.use('*', cors());
const handleFlow = fetchHandlers([bargainChefFlow], '/api');

app.post('/api/:flowName', async (c) => {
  return handleFlow(c.req.raw);
});

serve(
  {
    fetch: app.fetch,
    port: 3780,
  },
  (info) => {
    console.log(`Hono server listening on http://localhost:${info.port}`);
  },
);
