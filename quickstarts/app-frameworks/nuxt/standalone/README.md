# Nuxt (Standalone backend) quickstart

Nuxt app that calls a separate Genkit backend over HTTP. **No flow runs inside this app** — there's no `server/` directory.

Guide: https://genkit.dev/docs/js/app-frameworks/nuxt (or the dart / python variant — standalone backend)

## Run

In two terminals:

```bash
# Terminal 1 — any standalone backend in this repo:
cd ../../../backend-frameworks/js/express && GEMINI_API_KEY=<your-key> pnpm start
# or backend-frameworks/go/chi, backend-frameworks/py/flask, backend-frameworks/dart/shelf, …

# Terminal 2 — this frontend:
cd ../../.. && pnpm install     # once, from samples/quickstarts
cd app-frameworks/nuxt/standalone
pnpm dev
```

Open `http://localhost:3000`.

## Point at a different backend

The page reads `VITE_BARGAIN_CHEF_URL` at build time; defaults to `http://localhost:8080/bargainChefFlow`.

```bash
VITE_BARGAIN_CHEF_URL=http://localhost:3780/api/bargainChefFlow pnpm dev   # hono
VITE_BARGAIN_CHEF_URL=http://localhost:8000/bargainChefFlow pnpm dev       # fastapi/django
```
