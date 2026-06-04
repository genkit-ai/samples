# Angular (Standalone backend) quickstart

A browser-only Angular app that calls a standalone Genkit backend. Because Angular's `ng new` produces ~30 files that vary by version, this directory holds only the Genkit-relevant snippets (`src/app/app.ts`). Use the Angular CLI to scaffold the rest.

Guide: https://genkit.dev/docs/js/app-frameworks/angular (standalone backend)

## Setup

```bash
# scaffold a fresh Angular project (skip SSR), then copy the genkit-specific files in
npx -y @angular/cli@latest new my-genkit-angular --routing=false --style=css --ssr=false
cd my-genkit-angular
npm install genkit

# replace src/app/app.ts with the one from this directory
# from the repo root, replace <repo> with the path to your local checkout
cp <repo>/quickstarts/app-frameworks/angular/standalone/src/app/app.ts ./src/app/app.ts
```

## Run

```bash
# In one terminal: run a standalone Genkit backend (e.g. Express, Hono, FastAPI, Chi)
cd <repo>/quickstarts/backend-frameworks/js/express && GEMINI_API_KEY=<your-key> pnpm start

# In another terminal: run Angular
ng serve
```

Open http://localhost:4200. The frontend will call the standalone backend at `http://localhost:8080/bargainChefFlow`.

> ⚠ Make sure the standalone backend has CORS enabled (allow `http://localhost:4200`) or the browser will block the request. The Go samples in this repo already include CORS middleware; for JS samples, add the `cors` package to the Express/Hono/Fastify server.
