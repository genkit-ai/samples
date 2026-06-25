# Angular (Standalone backend) quickstart

A complete, browser-only Angular app that calls a standalone Genkit backend over HTTP via `streamFlow`. This is a full, runnable project (scaffolded with `ng new --ssr=false`), not a snippet.

Guide: https://genkit.dev/docs/js/app-frameworks/angular (standalone backend)

## Run

```bash
# Terminal 1 — any standalone backend in this repo, e.g. Express:
cd <repo>/quickstarts/backend-frameworks/js/express && GEMINI_API_KEY=<your-key> pnpm start

# Terminal 2 — this Angular app:
npm install
npm start            # http://localhost:4200
```

Open http://localhost:4200. The frontend calls the standalone backend at `http://localhost:8080/bargainChefFlow` (set in `src/app/app.ts`).

> The standalone backend must allow `http://localhost:4200` (CORS). Every backend in this repo enables CORS by default.
