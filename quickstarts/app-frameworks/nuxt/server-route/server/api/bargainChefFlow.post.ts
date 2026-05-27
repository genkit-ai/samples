import { fetchHandlers } from '@genkit-ai/fetch';
import { bargainChefFlow } from '../utils/bargainChefFlow';

const handleFlow = fetchHandlers([bargainChefFlow], '/api');

export default defineEventHandler(async (event) => {
  const request = toWebRequest(event);
  return await handleFlow(request);
});
