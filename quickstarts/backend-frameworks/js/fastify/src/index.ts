import { Readable } from 'node:stream';
import { fetchHandlers } from '@genkit-ai/fetch';
import Fastify from 'fastify';
import cors from '@fastify/cors';
import type { FastifyReply, FastifyRequest } from 'fastify';
import { bargainChefFlow } from './genkit/bargainChefFlow.js';

function toWebRequest(request: FastifyRequest): Request {
  const protocol = request.protocol || 'http';
  const host = request.headers.host || 'localhost:3000';
  const url = new URL(request.raw.url || '/', `${protocol}://${host}`);
  const headers = new Headers();

  for (const [key, value] of Object.entries(request.headers)) {
    if (value === undefined) continue;
    if (Array.isArray(value)) {
      value.forEach((entry) => headers.append(key, entry));
    } else {
      headers.set(key, String(value));
    }
  }

  const body =
    request.method === 'GET' || request.method === 'HEAD'
      ? undefined
      : JSON.stringify(request.body ?? {});

  const controller = new AbortController();
  request.raw.on('close', () => controller.abort());

  return new Request(url, {
    method: request.method,
    headers,
    body,
    duplex: 'half',
    signal: controller.signal,
  } as RequestInit);
}

async function sendWebResponse(reply: FastifyReply, response: Response) {
  reply.hijack();
  reply.raw.statusCode = response.status;

  // Headers set by earlier hooks/plugins (like @fastify/cors) live on the
  // Fastify reply. hijack() stops Fastify from flushing them, so copy them
  // onto the raw response first, or the browser rejects the streamed response
  // for missing CORS headers even though the preflight passed.
  for (const [key, value] of Object.entries(reply.getHeaders())) {
    if (value !== undefined) reply.raw.setHeader(key, value);
  }

  response.headers.forEach((value, key) => {
    reply.raw.setHeader(key, value);
  });

  if (!response.body) {
    reply.raw.end();
    return;
  }

  Readable.fromWeb(response.body as any).pipe(reply.raw);
}

const app = Fastify({ logger: true });
await app.register(cors, { origin: true });
const handleFlowRequest = fetchHandlers([bargainChefFlow], '/api');

app.post('/api/:flowName', async (request, reply) => {
  const response = await handleFlowRequest(toWebRequest(request));
  await sendWebResponse(reply, response);
});

await app.listen({ port: 3000, host: '0.0.0.0' });
