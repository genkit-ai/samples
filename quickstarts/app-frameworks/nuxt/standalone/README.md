# Nuxt (Standalone backend) quickstart

Nuxt app that calls a separate Genkit backend over HTTP. **No flow runs inside this app** — there's no `server/` directory.

Guide: https://genkit.dev/docs/frameworks/nuxt (Standalone backend tab)

## Run

In two terminals:

```bash
# Terminal 1 — any standalone backend in this repo:
cd backends/js/express && GEMINI_API_KEY=<your-key> pnpm start
# or backends/go/chi, backends/py/flask, backends/dart/shelf, …

# Terminal 2 — this frontend:
cd /Users/chgill/Projects/samples/quickstarts && pnpm install     # once
cd frontends/nuxt/standalone
pnpm dev
```

Open `http://localhost:3000`.

## Point at a different backend

The page reads `runtimeConfig.public.bargainChefUrl`; override with the `NUXT_PUBLIC_BARGAIN_CHEF_URL` env var:

```bash
NUXT_PUBLIC_BARGAIN_CHEF_URL=http://localhost:3780/api/bargainChefFlow pnpm dev   # hono
```
