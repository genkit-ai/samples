# Chi (Go) quickstart

Standalone Genkit backend on a [go-chi](https://github.com/go-chi/chi) router. Chi uses `net/http`, so `genkit.Handler` mounts directly.

Guide: https://genkit.dev/docs/go/backend-frameworks/chi

## Run

```bash
cd quickstarts/backend-frameworks/go/chi
go mod tidy
GEMINI_API_KEY=<your-key> go run .
```

Listens on `http://localhost:8080`. CORS is enabled (any origin) so browser frontends can call this backend directly.

## Test

```bash
curl -N -X POST http://localhost:8080/bargainChefFlow \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -d '{"data":{"craving":"something warm with chicken"}}'
```

## Developer UI

```bash
genkit start -- go run .    # opens http://localhost:4000
```

## Local Genkit packages

`go.mod` uses a `replace` directive pointing at a local Genkit Go checkout. Edit the path if your checkout lives elsewhere.

## Note on a guide bug found here

The published flow ended with `if (final == Recipe{}) { ... }`, which doesn't compile because `Recipe` has slice fields. Fixed to `if final.Title == ""` — both in this sample and the docsite guide.
