import { type RouteConfig, index, route } from '@react-router/dev/routes';

export default [
  index('routes/home.tsx'),
  // The genkit flow is served from this resource route. The splat (`*`) lets
  // it also match any streaming sub-path the Genkit client may request.
  route('api/bargainChefFlow/*', 'routes/api.bargainChefFlow.ts'),
] satisfies RouteConfig;
