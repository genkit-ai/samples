import { createAPIFileRoute } from '@tanstack/start/api';
import { fetchHandlers } from '@genkit-ai/fetch';
import { bargainChefFlow } from '~/genkit/bargainChefFlow';

const handleFlow = fetchHandlers([bargainChefFlow], '/api/bargainChefFlow');

export const APIRoute = createAPIFileRoute('/api/bargainChefFlow/$')({
  POST: async ({ request }) => handleFlow(request),
});
