# SvelteKit (Standalone backend) quickstart

SvelteKit app whose only page is a client component that calls a separate Genkit backend over HTTP. **No flow runs inside this app.**

Guide: https://genkit.dev/docs/js/app-frameworks/sveltekit (Standalone backend tab)

## Run

In two terminals:

```bash
# Terminal 1 — any standalone backend in this repo:
cd backend-frameworks/js/express && GEMINI_API_KEY=<your-key> pnpm start
# or backend-frameworks/go/chi, backend-frameworks/py/flask, backend-frameworks/dart/shelf, …

# Terminal 2 — this frontend:
cd quickstarts && pnpm install     # once, from the repo root
cd app-frameworks/sveltekit/standalone
pnpm dev
```

Open `http://localhost:5173`.

## Point at a different backend

The page reads `VITE_BARGAIN_CHEF_URL` at build time; defaults to `http://localhost:8080/bargainChefFlow`.

```bash
VITE_BARGAIN_CHEF_URL=http://localhost:3780/api/bargainChefFlow pnpm dev   # hono
```
