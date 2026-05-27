# Astro (Server endpoint) quickstart

Full-stack Astro app running in SSR mode with the Node adapter. The Genkit flow lives in `src/genkit/bargainChefFlow.ts` and is exposed as an API endpoint at `src/pages/api/bargainChefFlow.ts` via `fetchHandler(flow)`.

Guide: https://genkit.dev/docs/frameworks/astro (Astro server endpoint tab)

## Run

```bash
cd /Users/chgill/Projects/samples/quickstarts && pnpm install   # once
cd frontends/astro/endpoint
GEMINI_API_KEY=<your-key> pnpm dev
```

Opens at `http://localhost:4321`.

## Test the API directly

```bash
curl -N -X POST http://localhost:4321/api/bargainChefFlow \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -d '{"data":{"craving":"something warm with chicken"}}'
```

The UI is rendered by Astro's server, then a single `<script>` block fetches and streams the recipe into the page — no framework island needed.
