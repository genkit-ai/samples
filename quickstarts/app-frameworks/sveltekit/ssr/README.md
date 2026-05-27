# SvelteKit (SSR) quickstart

Full-stack SvelteKit app. The Genkit flow lives in `src/lib/genkit/bargainChefFlow.ts` and is exposed as a POST endpoint at `src/routes/api/bargainChefFlow/+server.ts` via `fetchHandler(flow)`. SvelteKit endpoints receive a standard Web `Request`, so no adapter is needed.

Guide: https://genkit.dev/docs/frameworks/sveltekit (SvelteKit SSR tab)

## Run

```bash
cd /Users/chgill/Projects/samples/quickstarts && pnpm install   # once
cd frontends/sveltekit/ssr
GEMINI_API_KEY=<your-key> pnpm dev
```

Opens at `http://localhost:5173`.

## Test the API directly

```bash
curl -N -X POST http://localhost:5173/api/bargainChefFlow \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -d '{"data":{"craving":"something warm with chicken"}}'
```

## Developer UI

```bash
pnpm genkit:start    # opens http://localhost:4000
```
