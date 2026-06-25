import { createFileRoute } from '@tanstack/react-router';
import { fetchHandler } from '@genkit-ai/fetch';
import { bargainChefFlow } from '@/genkit/bargainChefFlow';

// fetchHandler wraps a single flow and serves it at this route's path,
// so the client can POST directly to /api/bargainChefFlow.
const handler = fetchHandler(bargainChefFlow);

export const Route = createFileRoute('/api/bargainChefFlow/$')({
  server: {
    handlers: {
      POST: ({ request }) => handler(request),
    },
  },
});
