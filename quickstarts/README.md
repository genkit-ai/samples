# Genkit quickstart samples

Working code for every framework guide at https://genkit.dev/docs/frameworks. Each sample builds **Bargain Chef**: an HTTP service (and, for full-stack frameworks, a UI) that streams a recipe field-by-field while the model calls a `getIngredientsOnSale` tool to ground the ingredients in today's grocery deals.

All samples here resolve Genkit packages **from local source**, not from npm/PyPI/pkg.go.dev — useful when you're iterating on Genkit itself and want to verify a sample against the in-tree build.

## Directory layout

The split is by **role**, since most frontends can call a backend in any language:

```
quickstarts/
├── backends/                # standalone HTTP services, language-specific
│   ├── js/{express, fastify, hono, nestjs}
│   ├── go/{chi, echo, gin}
│   ├── py/{fastapi, flask, django}
│   └── dart/shelf
└── frontends/               # UIs — pair with any backend, or use the framework's own server
    ├── angular/{ssr, standalone}
    ├── astro/{endpoint, standalone}
    ├── nextjs/{app-router, pages, standalone}
    ├── nuxt/{server-route, standalone}
    ├── remix/{server-route, standalone}            # snippet-only — see READMEs
    ├── sveltekit/{ssr, standalone}
    ├── tanstack-start/{api-route, standalone}      # snippet-only — see READMEs
    └── react-vite/                                 # browser-only → any backend
```

Each framework with a `standalone` variant has a paired bundled variant (the framework's own server hosts the flow in-process). The `standalone` variants and `react-vite` are browser-only and call an external backend over HTTP — pair them with any backend in this repo.

The pnpm workspace is at the root, so a single `pnpm install` covers every JS sample.

## Prerequisites

- **All samples**: a Gemini API key (https://aistudio.google.com/apikey) exported as `GEMINI_API_KEY`.
- **JS**: Node.js ≥ 20, pnpm.
- **Go**: Go ≥ 1.25.
- **Python**: Python ≥ 3.11, [`uv`](https://docs.astral.sh/uv/).
- **Dart**: Dart SDK ≥ 3.10.

The samples expect this repo to live next to the Genkit source so local-package overrides resolve. If you cloned `genkit` to a different path, edit:
- JS: top-level `package.json` (`pnpm.overrides`)
- Go: each `backends/go/*/go.mod` (`replace github.com/firebase/genkit/go => ...`)
- Python: each `backends/py/*/pyproject.toml` (`[tool.uv.sources]`)
- Dart: `backends/dart/shelf/pubspec.yaml` (`dependency_overrides`)

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
cd backends/js/express  && GEMINI_API_KEY=... pnpm start    # http://localhost:8080
cd backends/js/fastify  && GEMINI_API_KEY=... pnpm start    # http://localhost:3000
cd backends/js/hono     && GEMINI_API_KEY=... pnpm start    # http://localhost:3780
cd backends/js/nestjs   && GEMINI_API_KEY=... pnpm start    # http://localhost:3000
```

### Go backends

```bash
cd backends/go/chi    # or echo, or gin
GEMINI_API_KEY=... go run .       # http://localhost:8080
```

### Python backends

```bash
cd backends/py/fastapi
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
cd backends/dart/shelf
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
cd frontends/nextjs/app-router    # or nextjs/pages, sveltekit/ssr, nuxt/server-route, astro/endpoint
GEMINI_API_KEY=... pnpm dev
# open the URL printed by the dev server
```

## Mixing a standalone frontend with any standalone backend

Every full-stack frontend also has a `standalone` variant that calls a separate backend over HTTP:

- `frontends/angular/standalone`
- `frontends/astro/standalone`
- `frontends/nextjs/standalone`
- `frontends/nuxt/standalone`
- `frontends/remix/standalone`
- `frontends/sveltekit/standalone`
- `frontends/tanstack-start/standalone`
- `frontends/react-vite` (always standalone)

**Any** backend in this repo works as the target: the JS, Go, Python, and Dart standalone backends all speak the same Genkit HTTP protocol and expose `POST /bargainChefFlow`.

**Every backend in this repo allows any origin by default** (CORS middleware is wired in), so no extra setup is needed for the standalone frontends to call them.

### Step 1 — Start a backend on port 8080

The frontends default to `http://localhost:8080/bargainChefFlow`. Pick a backend that runs on that port (Express, Chi, Echo, Gin, Flask, Shelf) or override the URL.

```bash
# Any of these works:
cd backends/js/express && GEMINI_API_KEY=... pnpm start
cd backends/go/chi      && GEMINI_API_KEY=... go run .
cd backends/py/flask    && GEMINI_API_KEY=... uv run python main.py
cd backends/dart/shelf  && GEMINI_API_KEY=... dart run
```

### Step 2 — Start a standalone frontend

```bash
# React (Vite)
cd frontends/react-vite
VITE_BARGAIN_CHEF_URL=http://localhost:8080/bargainChefFlow pnpm dev   # http://localhost:5173

# Next.js standalone
cd frontends/nextjs/standalone
NEXT_PUBLIC_BARGAIN_CHEF_URL=http://localhost:8080/bargainChefFlow pnpm dev   # http://localhost:3000

# Astro standalone
cd frontends/astro/standalone
PUBLIC_BARGAIN_CHEF_URL=http://localhost:8080/bargainChefFlow pnpm dev   # http://localhost:4321

# SvelteKit standalone
cd frontends/sveltekit/standalone
VITE_BARGAIN_CHEF_URL=http://localhost:8080/bargainChefFlow pnpm dev   # http://localhost:5173

# Nuxt standalone
cd frontends/nuxt/standalone
NUXT_PUBLIC_BARGAIN_CHEF_URL=http://localhost:8080/bargainChefFlow pnpm dev   # http://localhost:3000

# Angular / Remix / TanStack Start standalone — see each sample's README (needs CLI scaffolding)
```

The env-var name follows the framework's own convention for public/client-visible variables: Vite uses `VITE_*`, Next.js uses `NEXT_PUBLIC_*`, Astro uses `PUBLIC_*`, Nuxt uses `NUXT_PUBLIC_*`.

## Developer UI / traces

Wherever the sample has a `genkit:start` script, you can launch the Genkit Developer UI alongside the app to inspect traces, run flows manually, and debug tool calls:

```bash
cd backends/js/express     # any JS sample with a genkit:start script
pnpm genkit:start          # opens http://localhost:4000
```

For Go: `genkit start -- go run .`. For Python: `genkit start -- uv run uvicorn main:app --reload`. For Dart: `genkit start -- dart run`.

## What was tested

| Sample | Status |
| --- | --- |
| backends/js/express | ✅ run + streaming curl |
| backends/js/fastify | ✅ run + curl |
| backends/js/hono | ✅ run + curl |
| backends/js/nestjs | ✅ run + curl |
| backends/go/chi | ✅ build + run + curl |
| backends/go/echo | ✅ build + run + curl |
| backends/go/gin | ✅ build + run + curl |
| backends/py/fastapi | ✅ run + curl |
| backends/py/flask | ✅ run + curl |
| backends/py/django | ✅ run + curl |
| backends/dart/shelf | ✅ build + run + curl |
| frontends/nextjs/app-router | ✅ dev server + curl |
| frontends/nextjs/pages | ✅ dev server + curl (after fix — see below) |
| frontends/nextjs/standalone | scaffolded (works against any backend) |
| frontends/sveltekit/ssr | ✅ dev server + curl |
| frontends/sveltekit/standalone | scaffolded (works against any backend) |
| frontends/nuxt/server-route | scaffolded |
| frontends/nuxt/standalone | scaffolded (works against any backend) |
| frontends/astro/endpoint | scaffolded |
| frontends/astro/standalone | scaffolded (works against any backend) |
| frontends/react-vite | scaffolded (works against any backend) |
| frontends/remix/server-route | snippet-only — needs CLI scaffold (see its README) |
| frontends/remix/standalone | snippet-only — needs CLI scaffold (see its README) |
| frontends/tanstack-start/api-route | snippet-only — needs CLI scaffold (see its README) |
| frontends/tanstack-start/standalone | snippet-only — needs CLI scaffold (see its README) |
| frontends/angular/ssr | snippet-only — needs `ng new` (see its README) |
| frontends/angular/standalone | snippet-only — needs `ng new` (see its README) |

## Guide fixes uncovered while building these samples

- **Chi (Go).** The published flow did `if (final == Recipe{})` — that doesn't compile because `Recipe` contains slice fields. Changed to `if final.Title == ""`. Docsite [chi.mdx](../../docsite/src/content/docs/docs/frameworks/chi.mdx) updated.
- **Shelf (Dart).** The published flow used `retry(...)` middleware but the `Genkit()` constructor didn't include `RetryPlugin()`, so calls failed with `Middleware retry not found`. Plugins list updated to `[googleAI(), RetryPlugin()]`. Docsite [shelf.mdx](../../docsite/src/content/docs/docs/frameworks/shelf.mdx) updated.
- **Next.js Pages Router.** The published guide used `expressHandler(bargainChefFlow)` directly as the Pages API handler, but it calls `req.get('Accept')` which doesn't exist on Next's `NextApiRequest`. Rewrote the handler as a small adapter that maps `req`/`res` to fetch `Request`/`Response` and delegates to `fetchHandlers`. Docsite [nextjs.mdx](../../docsite/src/content/docs/docs/frameworks/nextjs.mdx) updated.

## Troubleshooting

- **JS install fails with `ERR_PNPM_WORKSPACE_PKG_NOT_FOUND`**: a transitive Genkit package uses `workspace:*` and isn't overridden. Edit the top-level `package.json` and add the missing package to `pnpm.overrides`.
- **Go: `replace` directive ignored**: confirm `go.mod` points to the correct absolute path to `/Users/chgill/Projects/genkit/go`, then `go mod tidy`.
- **Python: `ModuleNotFoundError: genkit`**: run `uv sync` in the sample directory. If you see the wrong genkit version, check `[tool.uv.sources]` paths.
- **Dart: `genkit_shelf from path is forbidden`**: add the conflicting packages to `dependency_overrides` so all `genkit*` packages resolve from local paths together.
- **Browser frontend hits CORS error**: the standalone backend isn't allowing the frontend's origin. Add CORS (see Step 2 above).
- **Port already in use**: kill any straggler process with `lsof -ti :<port> | xargs kill -9`. The Go backends all default to 8080, so don't run them in parallel without changing the port.
