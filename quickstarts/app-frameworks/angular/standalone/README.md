# Angular (Standalone backend) quickstart

A browser-only Angular app that calls a standalone Genkit backend. Because Angular's `ng new` produces ~30 files that vary by version, this directory holds only the Genkit-relevant snippets (`src/app/app.ts`). Use the Angular CLI to scaffold the rest.

## Setup

```bash
# scaffold a fresh Angular project (skip SSR), then copy the genkit-specific files in
npx -y @angular/cli@latest new my-genkit-angular --routing=false --style=css --ssr=false
cd my-genkit-angular
npm install genkit

# replace src/app/app.ts with the one from this directory
cp /Users/chgill/Projects/samples/quickstarts/frontends/angular/standalone/src/app/app.ts ./src/app/app.ts
```

## Run

```bash
# In one terminal: run a standalone Genkit backend (e.g. Express, Hono, FastAPI, Chi)
cd /Users/chgill/Projects/samples/quickstarts/backends/js/express && GEMINI_API_KEY=... pnpm start

# In another terminal: run Angular
ng serve
```

Open http://localhost:4200. The frontend will call the standalone backend at `http://localhost:8080/bargainChefFlow`.

> ⚠ Make sure the standalone backend has CORS enabled (allow `http://localhost:4200`) or the browser will block the request. The Go samples in this repo already include CORS middleware; for JS samples, add the `cors` package to the Express/Hono/Fastify server.
