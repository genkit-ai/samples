# Next.js (App Router) quickstart

Full-stack Next.js app. The Genkit flow lives in `src/genkit/bargainChefFlow.ts` and is mounted as an App Router route handler at `src/app/api/bargainChefFlow/route.ts` via `appRoute(flow)` from `@genkit-ai/next`.

Guide: https://genkit.dev/docs/frameworks/nextjs (App Router tab)

## Run

```bash
cd /Users/chgill/Projects/samples/quickstarts && pnpm install   # once
cd frontends/nextjs/app-router
GEMINI_API_KEY=<your-key> pnpm dev
```

Opens at `http://localhost:3000`. Type a craving and watch the recipe stream in.

## Test the API directly

```bash
curl -N -X POST http://localhost:3000/api/bargainChefFlow \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -d '{"data":{"craving":"something warm with chicken"}}'
```

## Developer UI

```bash
pnpm genkit:start    # opens http://localhost:4000 (runs the flow under genkit start)
```
