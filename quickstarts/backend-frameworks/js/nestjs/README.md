# NestJS quickstart

Standalone Genkit backend on NestJS. A controller (`src/genkit/genkit.controller.ts`) passes the Express `req`/`res` straight to Genkit's `expressHandler`, since NestJS runs on Express under the hood.

Guide: https://genkit.dev/docs/js/backend-frameworks/nestjs

## Run

```bash
pnpm install   # once, from quickstarts/
cd quickstarts/backend-frameworks/js/nestjs
GEMINI_API_KEY=<your-key> pnpm start          # or pnpm start:dev for watch mode
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
