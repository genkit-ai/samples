# Astro (Standalone backend) quickstart

Browser-only Astro page that calls a separate Genkit backend over HTTP. **No flow runs inside this app** — Astro's only role here is to bundle the inline `<script>` block that calls `streamFlow`.

Guide: https://genkit.dev/docs/frameworks/astro (Standalone backend tab)

## Run

In two terminals:

```bash
# Terminal 1 — any standalone backend in this repo:
cd backends/js/express && GEMINI_API_KEY=<your-key> pnpm start
# or backends/go/chi, backends/py/flask, backends/dart/shelf, …

# Terminal 2 — this frontend:
cd /Users/chgill/Projects/samples/quickstarts && pnpm install     # once
cd frontends/astro/standalone
pnpm dev
```

Open `http://localhost:4321`.

## Point at a different backend

The page reads `PUBLIC_BARGAIN_CHEF_URL` at build time; defaults to `http://localhost:8080/bargainChefFlow`.

```bash
PUBLIC_BARGAIN_CHEF_URL=http://localhost:3780/api/bargainChefFlow pnpm dev   # hono
PUBLIC_BARGAIN_CHEF_URL=http://localhost:8000/bargainChefFlow pnpm dev       # fastapi/django
```
