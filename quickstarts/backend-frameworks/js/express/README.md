# Express quickstart

Standalone Genkit backend on Express. Streams a recipe field-by-field via Server-Sent Events; the model calls a `getIngredientsOnSale` tool to ground the recipe in mock grocery deals.

Guide: https://genkit.dev/docs/js/backend-frameworks/express

## Run

```bash
# from quickstarts/, once: install all JS samples
pnpm install

# then start the server
cd backend-frameworks/js/express
GEMINI_API_KEY=<your-key> pnpm start
```

Listens on `http://localhost:8080`.

## Test

```bash
# streaming
curl -N -X POST http://localhost:8080/bargainChefFlow \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -d '{"data":{"craving":"something warm with chicken"}}'

# non-streaming
curl -X POST http://localhost:8080/bargainChefFlow \
  -H "Content-Type: application/json" \
  -d '{"data":{"craving":"something warm with chicken"}}'
```

## Developer UI

```bash
pnpm genkit:start    # opens http://localhost:4000
```

## Pair with a browser frontend

This backend serves any standalone frontend in `app-frameworks/`. Add CORS first:

```ts
// src/index.ts
import cors from 'cors';   // pnpm add cors @types/cors
app.use(cors());
app.use(express.json());
app.post('/bargainChefFlow', expressHandler(bargainChefFlow));
```
