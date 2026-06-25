# Fastify quickstart

Standalone Genkit backend on Fastify. Uses the `@genkit-ai/fastify` plugin's `fastifyHandler` to mount the flow as a Fastify route with one line, including server-sent events for streaming.

Guide: https://genkit.dev/docs/js/backend-frameworks/fastify

## Run

```bash
pnpm install   # once, from quickstarts/
cd quickstarts/backend-frameworks/js/fastify
GEMINI_API_KEY=<your-key> pnpm start
```

Listens on `http://localhost:3000`. The flow is mounted at `/bargainChefFlow`.

## Test

```bash
curl -N -X POST http://localhost:3000/bargainChefFlow \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -d '{"data":{"craving":"something warm with chicken"}}'
```

## Developer UI

```bash
pnpm genkit:start    # opens http://localhost:4000
```
