import type { APIRoute } from 'astro';
import { fetchHandler } from '@genkit-ai/fetch';
import { bargainChefFlow } from '../../genkit/bargainChefFlow';

export const prerender = false;

const handler = fetchHandler(bargainChefFlow);

export const POST: APIRoute = ({ request }) => handler(request);
