# Remix (Standalone backend) quickstart

A complete Remix (React Router v7) app whose only route is a client component that calls a separate Genkit backend. **No flow runs inside this app** — there's no `api.bargainChefFlow.$.ts` route. The browser calls the standalone backend over HTTP via `streamFlow`.

This is a full, runnable project (scaffolded with `create-react-router`, default config-based routing), not a snippet.

Guide: https://genkit.dev/docs/js/app-frameworks/remix (standalone backend)

## Run

```bash
# Terminal 1 — any standalone backend in this repo, e.g. Express:
cd <repo>/quickstarts/backend-frameworks/js/express && GEMINI_API_KEY=<your-key> pnpm start

# Terminal 2 — this Remix app:
npm install
npm run dev          # http://localhost:5173
```

Open the printed URL. The frontend calls the standalone backend at `http://localhost:8080/bargainChefFlow` by default. Override it with `VITE_BARGAIN_CHEF_URL`.

> The standalone backend must allow this origin (CORS). Every backend in this repo enables CORS by default.
