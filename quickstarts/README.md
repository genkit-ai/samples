# Genkit quickstart samples

Working code for every framework guide at https://genkit.dev/docs/frameworks. Each sample builds **Bargain Chef**: an HTTP service (and, for full-stack frameworks, a UI) that streams a recipe field-by-field while the model calls a `getIngredientsOnSale` tool to ground the ingredients in today's grocery deals.

All samples here resolve Genkit packages **from the public registries** (npm, PyPI, pkg.go.dev, pub.dev) at their latest published versions — JS `genkit` 1.36.x, Python `genkit` 0.6.x, Go `github.com/firebase/genkit/go` v1.8.x, Dart `genkit` 0.14.x. Each sample is self-contained: clone the repo and run any one without a local Genkit checkout.

## Directory layout

The split is by **role**, since most frontends can call a backend in any language:

```
quickstarts/
├── backend-frameworks/      # standalone HTTP services, language-specific
│   ├── js/{express, fastify, hono, nestjs}
│   ├── go/{chi, echo, gin, nethttp}
│   ├── py/{fastapi, flask, django}
│   └── dart/shelf
└── app-frameworks/          # UIs — pair with any backend, or use the framework's own server
    ├── angular/{ssr, standalone}                   # self-contained npm projects
    ├── astro/{endpoint, standalone}
    ├── nextjs/{app-router, pages, standalone}
    ├── nuxt/{server-route, standalone}
    ├── remix/{server-route, standalone}            # self-contained npm projects
    ├── sveltekit/{ssr, standalone}
    ├── tanstack-start/{api-route, standalone}      # self-contained npm projects
    ├── react-vite/                                 # browser-only → any backend
    └── flutter/                                    # Flutter web → any backend
```

Each framework with a `standalone` variant has a paired bundled variant (the framework's own server hosts the flow in-process). The `standalone` variants and `react-vite` are browser-only and call an external backend over HTTP — pair them with any backend in this repo.

The pnpm workspace is at the root, so a single `pnpm install` covers every JS sample.

## Prerequisites

- **All samples**: a Gemini API key (https://aistudio.google.com/apikey) exported as `GEMINI_API_KEY`.
- **JS**: Node.js ≥ 20, pnpm.
- **Go**: Go ≥ 1.25.
- **Python**: Python ≥ 3.11, [`uv`](https://docs.astral.sh/uv/).
- **Dart / Flutter**: Dart SDK ≥ 3.10. The Flutter web sample also requires Flutter.

Every sample installs Genkit from the public registries, so no local Genkit checkout is required. The JS backends and the Vite/Next/Nuxt/Astro/SvelteKit frontends are a single pnpm workspace (`pnpm install` at this directory covers them all). The CLI-scaffolded frameworks — **Angular, Remix, and TanStack Start** — are self-contained npm projects with their own lockfiles; install and run those with `npm install && npm run dev` (or `npm start`) inside each project directory.

## How the flow works (every sample)

1. The flow `bargainChefFlow` accepts `{ craving: string }`.
2. It builds a prompt with today's weekday.
3. The model decides to call the `getIngredientsOnSale(dayType)` tool (mock data — weekday vs weekend lists).
4. The model returns a structured `Recipe` (`title`, `description`, `servings`, `ingredients[]`, `steps[]`).
5. While the model writes, each partial recipe is streamed as Server-Sent Events; the final event carries the validated `result`.

Every backend exposes `POST /bargainChefFlow` (or, for full-stack frameworks, `POST /api/bargainChefFlow`).

## Running a backend

### JS backends

```bash
cd quickstarts
pnpm install     # one install for every JS sample

# Pick one:
cd backend-frameworks/js/express  && GEMINI_API_KEY=... pnpm start    # http://localhost:8080
cd backend-frameworks/js/fastify  && GEMINI_API_KEY=... pnpm start    # http://localhost:3000
cd backend-frameworks/js/hono     && GEMINI_API_KEY=... pnpm start    # http://localhost:3780
cd backend-frameworks/js/nestjs   && GEMINI_API_KEY=... pnpm start    # http://localhost:3000
```

### Go backends

```bash
cd backend-frameworks/go/chi    # or echo, or gin
GEMINI_API_KEY=... go run .       # http://localhost:8080
```

### Python backends

```bash
cd backend-frameworks/py/fastapi
uv sync
GEMINI_API_KEY=... uv run uvicorn main:app --port 8000

cd ../flask
uv sync
GEMINI_API_KEY=... uv run python main.py    # http://127.0.0.1:8080

cd ../django
uv sync
GEMINI_API_KEY=... uv run uvicorn myproject.asgi:application --port 8000
```

### Dart backend

```bash
cd backend-frameworks/dart/shelf
dart pub get
dart run build_runner build        # generate schema code from @Schema() classes
GEMINI_API_KEY=... dart run        # http://localhost:8080
```

## Sending a request

Every backend uses the Genkit HTTP envelope. The body wraps your input in `{ "data": ... }`:

```bash
# Streaming (Server-Sent Events)
curl -N -X POST http://localhost:8080/bargainChefFlow \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -d '{"data":{"craving":"something warm with chicken"}}'

# Non-streaming (one JSON response)
curl -X POST http://localhost:8080/bargainChefFlow \
  -H "Content-Type: application/json" \
  -d '{"data":{"craving":"something warm with chicken"}}'
```

Adjust the port and (for full-stack frameworks) the path:
- Hono uses `/api/bargainChefFlow` on port `3780`.
- Fastify uses `/api/bargainChefFlow` on port `3000`.
- NestJS uses `/genkit/bargainChefFlow` on port `3000`.
- Next.js / SvelteKit / Nuxt / Astro / Remix / TanStack use `/api/bargainChefFlow` on their dev port.
- FastAPI uses `/bargainChefFlow` on port `8000`.
- Django uses `/bargainChefFlow` on port `8000`.
- Flask uses `/bargainChefFlow` on port `8080`.
- Angular SSR uses `/api/bargainChefFlow` on port `4200`.

## Running a full-stack frontend (bundled backend)

These bundle their own server route, so you only run one process:

```bash
cd quickstarts
pnpm install
cd app-frameworks/nextjs/app-router    # or nextjs/pages, sveltekit/ssr, nuxt/server-route, astro/endpoint
GEMINI_API_KEY=... pnpm dev
# open the URL printed by the dev server
```

## Mixing a standalone frontend with any standalone backend

Every full-stack frontend also has a `standalone` variant that calls a separate backend over HTTP:

- `app-frameworks/angular/standalone`
- `app-frameworks/astro/standalone`
- `app-frameworks/nextjs/standalone`
- `app-frameworks/nuxt/standalone`
- `app-frameworks/remix/standalone`
- `app-frameworks/sveltekit/standalone`
- `app-frameworks/tanstack-start/standalone`
- `app-frameworks/react-vite` (always standalone)

**Any** backend in this repo works as the target: the JS, Go, Python, and Dart standalone backends all speak the same Genkit HTTP protocol and expose `POST /bargainChefFlow`.

**Every backend in this repo allows any origin by default** (CORS middleware is wired in), so no extra setup is needed for the standalone frontends to call them.

### Step 1 — Start a backend on port 8080

The frontends default to `http://localhost:8080/bargainChefFlow`. Pick a backend that runs on that port (Express, Chi, Echo, Gin, Flask, Shelf) or override the URL.

```bash
# Any of these works:
cd backend-frameworks/js/express && GEMINI_API_KEY=... pnpm start
cd backend-frameworks/go/chi      && GEMINI_API_KEY=... go run .
cd backend-frameworks/py/flask    && GEMINI_API_KEY=... uv run python main.py
cd backend-frameworks/dart/shelf  && GEMINI_API_KEY=... dart run
```

### Step 2 — Start a standalone frontend

```bash
# React (Vite)
cd app-frameworks/react-vite
VITE_BARGAIN_CHEF_URL=http://localhost:8080/bargainChefFlow pnpm dev   # http://localhost:5173

# Next.js standalone
cd app-frameworks/nextjs/standalone
NEXT_PUBLIC_BARGAIN_CHEF_URL=http://localhost:8080/bargainChefFlow pnpm dev   # http://localhost:3000

# Astro standalone
cd app-frameworks/astro/standalone
PUBLIC_BARGAIN_CHEF_URL=http://localhost:8080/bargainChefFlow pnpm dev   # http://localhost:4321

# SvelteKit standalone
cd app-frameworks/sveltekit/standalone
VITE_BARGAIN_CHEF_URL=http://localhost:8080/bargainChefFlow pnpm dev   # http://localhost:5173

# Nuxt standalone
cd app-frameworks/nuxt/standalone
NUXT_PUBLIC_BARGAIN_CHEF_URL=http://localhost:8080/bargainChefFlow pnpm dev   # http://localhost:3000

# Angular / Remix / TanStack Start standalone — see each sample's README (needs CLI scaffolding)
```

The env-var name follows the framework's own convention for public/client-visible variables: Vite uses `VITE_*`, Next.js uses `NEXT_PUBLIC_*`, Astro uses `PUBLIC_*`, Nuxt uses `NUXT_PUBLIC_*`.

## Developer UI / traces

Wherever the sample has a `genkit:start` script, you can launch the Genkit Developer UI alongside the app to inspect traces, run flows manually, and debug tool calls:

```bash
cd backend-frameworks/js/express     # any JS sample with a genkit:start script
pnpm genkit:start          # opens http://localhost:4000
```

For Go: `genkit start -- go run .`. For Python: `genkit start -- uv run uvicorn main:app --reload`. For Dart: `genkit start -- dart run`.

## What was tested

All samples below resolve Genkit from the public registries (no local checkout) and have been built/run against the latest published versions.

| Sample | Status |
| --- | --- |
| backend-frameworks/js/express | ✅ run + streaming curl |
| backend-frameworks/js/fastify | ✅ run + curl |
| backend-frameworks/js/hono | ✅ run + curl |
| backend-frameworks/js/nestjs | ✅ run + curl |
| backend-frameworks/go/chi | ✅ build + run + curl |
| backend-frameworks/go/echo | ✅ build + run + curl |
| backend-frameworks/go/gin | ✅ build + run + curl |
| backend-frameworks/go/nethttp | ✅ build |
| backend-frameworks/py/fastapi | ✅ run + import-check |
| backend-frameworks/py/flask | ✅ run + import-check |
| backend-frameworks/py/django | ✅ run + check |
| backend-frameworks/dart/shelf | ✅ build + analyze |
| app-frameworks/nextjs/app-router | ✅ dev server + curl |
| app-frameworks/nextjs/pages | ✅ dev server + curl |
| app-frameworks/nextjs/standalone | ✅ dev server (works against any backend) |
| app-frameworks/sveltekit/ssr | ✅ dev server + curl |
| app-frameworks/sveltekit/standalone | ✅ dev server (works against any backend) |
| app-frameworks/nuxt/server-route | ✅ dev server |
| app-frameworks/nuxt/standalone | ✅ dev server (works against any backend) |
| app-frameworks/astro/endpoint | ✅ dev server |
| app-frameworks/astro/standalone | ✅ dev server + streaming (works against any backend) |
| app-frameworks/react-vite | ✅ dev server (works against any backend) |
| app-frameworks/remix/server-route | ✅ full project + in-process streaming |
| app-frameworks/remix/standalone | ✅ full project (works against any backend) |
| app-frameworks/tanstack-start/api-route | ✅ full project + in-process streaming |
| app-frameworks/tanstack-start/standalone | ✅ full project (works against any backend) |
| app-frameworks/angular/ssr | ✅ full project + in-process streaming |
| app-frameworks/angular/standalone | ✅ full project (works against any backend) |

## Guide fixes uncovered while building these samples

- **Chi (Go).** The published flow did `if (final == Recipe{})` — that doesn't compile because `Recipe` contains slice fields. Changed to `if final.Title == ""`. Docsite [chi.mdx](../../docsite/src/content/docs/docs/frameworks/chi.mdx) updated.
- **Shelf (Dart).** The published flow used `retry(...)` middleware but the `Genkit()` constructor didn't include `RetryPlugin()`, so calls failed with `Middleware retry not found`. Plugins list updated to `[googleAI(), RetryPlugin()]`. Docsite [shelf.mdx](../../docsite/src/content/docs/docs/frameworks/shelf.mdx) updated.
- **Next.js Pages Router.** The published guide used `expressHandler(bargainChefFlow)` directly as the Pages API handler, but it calls `req.get('Accept')` which doesn't exist on Next's `NextApiRequest`. Rewrote the handler as a small adapter that maps `req`/`res` to fetch `Request`/`Response` and delegates to `fetchHandlers`. Docsite [nextjs.mdx](../../docsite/src/content/docs/docs/frameworks/nextjs.mdx) updated.

## Troubleshooting

- **Angular / Remix / TanStack Start: `Cannot find module 'genkit'`**: these are self-contained npm projects, not part of the pnpm workspace. Run `npm install` inside the project directory (not `pnpm install` at the repo root).
- **Go: `cannot find module`**: run `go mod tidy` in the sample directory to fetch `github.com/firebase/genkit/go` from the module proxy.
- **Python: `ModuleNotFoundError: genkit`**: run `uv sync` in the sample directory to install from PyPI.
- **Dart: dependency resolution fails**: run `dart pub get` in `backend-frameworks/dart/shelf`, then `dart run build_runner build` to regenerate `*.g.dart` from the `@Schema()` classes.
- **Browser frontend hits CORS error**: the standalone backend isn't allowing the frontend's origin. Add CORS (see Step 2 above).
- **Port already in use**: kill any straggler process with `lsof -ti :<port> | xargs kill -9`. The Go backends all default to 8080, so don't run them in parallel without changing the port.
