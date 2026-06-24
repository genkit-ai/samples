import { fastifyHandler } from '@genkit-ai/fastify';
import cors from '@fastify/cors';
import Fastify from 'fastify';
import { bargainChefFlow } from './genkit/bargainChefFlow.js';

const app = Fastify({ logger: true });
await app.register(cors, { origin: true });
app.post('/bargainChefFlow', fastifyHandler(bargainChefFlow));

await app.listen({ port: 3000, host: '0.0.0.0' });
