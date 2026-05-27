# Fastify quickstart

Standalone Genkit backend on Fastify. Uses `@genkit-ai/fetch` with a small adapter that converts Fastify's request to a fetch `Request` and pipes the streamed response back through Fastify.

Guide: https://genkit.dev/docs/frameworks/fastify

## Run

```bash
cd /Users/chgill/Projects/samples/quickstarts && pnpm install   # once
cd backends/js/fastify
GEMINI_API_KEY=<your-key> pnpm start
```

Listens on `http://localhost:3000`. The flow is mounted at `/api/bargainChefFlow`.

## Test

```bash
curl -N -X POST http://localhost:3000/api/bargainChefFlow \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -d '{"data":{"craving":"something warm with chicken"}}'
```

## Developer UI

```bash
pnpm genkit:start    # opens http://localhost:4000
```
