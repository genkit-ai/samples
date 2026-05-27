# NestJS quickstart

Standalone Genkit backend on NestJS. A controller (`src/genkit/genkit.controller.ts`) adapts each Express `req`/`res` to a fetch `Request`/`Response` and forwards it to `fetchHandlers`.

Guide: https://genkit.dev/docs/frameworks/nestjs

## Run

```bash
cd /Users/chgill/Projects/samples/quickstarts && pnpm install   # once
cd backends/js/nestjs
GEMINI_API_KEY=<your-key> pnpm start          # or pnpm start:dev for watch mode
```

Listens on `http://localhost:3000`. The flow is mounted at `/genkit/bargainChefFlow`.

## Test

```bash
curl -N -X POST http://localhost:3000/genkit/bargainChefFlow \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -d '{"data":{"craving":"something warm with chicken"}}'
```

## Developer UI

```bash
pnpm genkit:start    # opens http://localhost:4000
```
