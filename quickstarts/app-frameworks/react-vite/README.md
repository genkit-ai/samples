# React (Vite) quickstart

Browser-only React app. **No flow runs inside this app** — it calls a separate Genkit backend over HTTP using `streamFlow` from `genkit/beta/client`.

Guide: https://genkit.dev/docs/js/app-frameworks/react

## Run

In two terminals:

```bash
# Terminal 1 — any standalone backend in this repo:
cd backend-frameworks/js/express && GEMINI_API_KEY=<your-key> pnpm start
# or backend-frameworks/go/chi, backend-frameworks/py/flask, backend-frameworks/dart/shelf, …

# Terminal 2 — this frontend:
cd quickstarts && pnpm install     # once, from the quickstarts root
cd app-frameworks/react-vite
pnpm dev
```

Open `http://localhost:5173`.

## Point at a different backend

The app reads `VITE_BARGAIN_CHEF_URL` at build time; defaults to `http://localhost:8080/bargainChefFlow`.

```bash
VITE_BARGAIN_CHEF_URL=http://localhost:3780/api/bargainChefFlow pnpm dev   # hono
VITE_BARGAIN_CHEF_URL=http://localhost:8000/bargainChefFlow pnpm dev       # fastapi/django
```
