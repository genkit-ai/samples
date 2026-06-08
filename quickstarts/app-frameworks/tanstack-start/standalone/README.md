# TanStack Start (Standalone backend) quickstart

A complete TanStack Start app whose only route is a client component that calls a separate Genkit backend over HTTP via `streamFlow`. **No flow runs inside this app** — there's no `api/` route. This is a full, runnable project (scaffolded with `@tanstack/cli create`), not a snippet.

> The current TanStack CLI scaffolds routes under `src/routes/` (older versions used `app/routes/`). This project uses `src/routes/index.tsx`.

Guide: https://genkit.dev/docs/js/app-frameworks/tanstack-start (standalone backend)

## Run

```bash
# Terminal 1 — any standalone backend in this repo, e.g. Express:
cd <repo>/quickstarts/backend-frameworks/js/express && GEMINI_API_KEY=<your-key> pnpm start

# Terminal 2 — this TanStack Start app:
npm install
npm run dev          # http://localhost:3000
```

Open the printed URL. The frontend calls the standalone backend at `http://localhost:8080/bargainChefFlow` by default. Override it with `VITE_BARGAIN_CHEF_URL`.

> The standalone backend must allow this origin (CORS). Every backend in this repo enables CORS by default.
