import type { RequestHandler } from './$types';
import { fetchHandler } from '@genkit-ai/fetch';
import { bargainChefFlow } from '$lib/genkit/bargainChefFlow';

const handle = fetchHandler(bargainChefFlow);

export const POST: RequestHandler = ({ request }) => handle(request);
