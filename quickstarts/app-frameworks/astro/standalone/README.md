# Astro (Standalone backend) quickstart

Browser-only Astro page that calls a separate Genkit backend over HTTP. **No flow runs inside this app** — Astro's only role here is to bundle the inline `<script>` block that calls `streamFlow`.

Guide: https://genkit.dev/docs/js/app-frameworks/astro (Standalone backend tab)

## Run

In two terminals, from the repo's `quickstarts/` directory:

```bash
# Terminal 1 — any standalone backend in this repo:
cd backend-frameworks/js/express && GEMINI_API_KEY=<your-key> pnpm start
# or backend-frameworks/go/chi, backend-frameworks/py/flask, backend-frameworks/dart/shelf, …

# Terminal 2 — this frontend:
pnpm install     # once
cd app-frameworks/astro/standalone
pnpm dev
```

Open `http://localhost:4321`.

## Point at a different backend

The page reads `PUBLIC_BARGAIN_CHEF_URL` at build time; defaults to `http://localhost:8080/bargainChefFlow`. (Astro exposes only `PUBLIC_`-prefixed variables to client code.)

```bash
PUBLIC_BARGAIN_CHEF_URL=http://localhost:3780/api/bargainChefFlow pnpm dev   # hono
PUBLIC_BARGAIN_CHEF_URL=http://localhost:8000/bargainChefFlow pnpm dev       # fastapi/django
```
