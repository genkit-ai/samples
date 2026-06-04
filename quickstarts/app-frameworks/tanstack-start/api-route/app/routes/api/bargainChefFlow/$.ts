import { createFileRoute } from '@tanstack/react-router';
import { fetchHandlers } from '@genkit-ai/fetch';
import { bargainChefFlow } from '~/genkit/bargainChefFlow';

const handleFlow = fetchHandlers([bargainChefFlow], '/api/bargainChefFlow');

export const Route = createFileRoute('/api/bargainChefFlow/$')({
  server: {
    handlers: {
      POST: ({ request }) => handleFlow(request),
    },
  },
});
