import type { ActionFunctionArgs } from 'react-router';
import { fetchHandlers } from '@genkit-ai/fetch';
import { bargainChefFlow } from '~/genkit/bargainChefFlow';

const handleFlow = fetchHandlers([bargainChefFlow], '/api/bargainChefFlow');

export async function action({ request }: ActionFunctionArgs) {
  return handleFlow(request);
}
