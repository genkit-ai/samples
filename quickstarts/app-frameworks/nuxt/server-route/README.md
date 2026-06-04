# Nuxt (Server route) quickstart

Full-stack Nuxt app. The Genkit flow lives in `server/utils/bargainChefFlow.ts` and is exposed as a Nitro server route at `server/api/bargainChefFlow.post.ts`. `toWebRequest(event)` (Nitro's built-in H3 helper) converts the event to a fetch `Request`.

Guide: https://genkit.dev/docs/js/app-frameworks/nuxt (JS / server route)

## Run

```bash
cd ../../.. && pnpm install   # once, from samples/quickstarts
cd app-frameworks/nuxt/server-route
GEMINI_API_KEY=<your-key> pnpm dev
```

Opens at `http://localhost:3000`.

## Test the API directly

```bash
curl -N -X POST http://localhost:3000/api/bargainChefFlow \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -d '{"data":{"craving":"something warm with chicken"}}'
```
