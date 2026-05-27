# Hono quickstart

Standalone Genkit backend on Hono. Hono is fetch-native, so `fetchHandlers` plugs in directly with no adapter.

Guide: https://genkit.dev/docs/frameworks/hono

## Run

```bash
cd /Users/chgill/Projects/samples/quickstarts && pnpm install   # once
cd backends/js/hono
GEMINI_API_KEY=<your-key> pnpm start
```

Listens on `http://localhost:3780`. The flow is mounted at `/api/bargainChefFlow`.

## Test

```bash
curl -N -X POST http://localhost:3780/api/bargainChefFlow \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -d '{"data":{"craving":"something warm with chicken"}}'
```

## Developer UI

```bash
pnpm genkit:start    # opens http://localhost:4000
```
