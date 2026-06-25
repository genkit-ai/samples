# net/http (Go) quickstart

Standalone Genkit backend built with only Go's standard library `net/http`. Because `genkit.Handler` returns a standard `http.Handler`, it mounts directly on a `net/http` mux with no router or adapter.

Guide: https://genkit.dev/docs/go/backend-frameworks/nethttp

## Run

```bash
cd quickstarts/backend-frameworks/go/nethttp
go mod tidy
GEMINI_API_KEY=<your-key> go run .
```

Listens on `http://localhost:8080`. CORS is enabled (any origin) via a small `withCORS` wrapper so browser frontends can call this backend directly.

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
