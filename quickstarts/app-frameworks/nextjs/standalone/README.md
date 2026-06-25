# Next.js (Standalone backend) quickstart

Browser-only Next.js app that calls a separate Genkit backend over HTTP. **No flow runs inside this app** — it only ships `streamFlow` calls to whichever backend you point it at.

Guide: https://genkit.dev/docs/js/app-frameworks/nextjs (Standalone backend tab)

## Run

In two terminals:

```bash
# Terminal 1 — any standalone backend in this repo (Express, Chi, Flask, Shelf, …):
cd backend-frameworks/js/express && GEMINI_API_KEY=<your-key> pnpm start
# or:
cd backend-frameworks/go/chi && GEMINI_API_KEY=<your-key> go run .

# Terminal 2 — this frontend:
# from the repo's quickstarts directory:
pnpm install     # once
cd app-frameworks/nextjs/standalone
pnpm dev
```

Open `http://localhost:3000`.

## Point at a different backend

The page reads `NEXT_PUBLIC_BARGAIN_CHEF_URL` at build time; defaults to `http://localhost:8080/bargainChefFlow`.

```bash
NEXT_PUBLIC_BARGAIN_CHEF_URL=http://localhost:3780/api/bargainChefFlow pnpm dev   # hono
NEXT_PUBLIC_BARGAIN_CHEF_URL=http://localhost:8000/bargainChefFlow pnpm dev       # fastapi/django
```
