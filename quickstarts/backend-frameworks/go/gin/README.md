# Gin (Go) quickstart

Standalone Genkit backend on [Gin](https://gin-gonic.com/). `gin.WrapH(genkit.Handler(flow))` adapts the standard `http.Handler` to a `gin.HandlerFunc`.

Guide: https://genkit.dev/docs/frameworks/gin

## Run

```bash
cd backends/go/gin
go mod tidy
GEMINI_API_KEY=<your-key> go run .
```

Listens on `http://localhost:8080`. CORS is enabled (any origin).

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

`go.mod` uses a `replace` directive pointing at `/Users/chgill/Projects/genkit/go`. Edit if your checkout lives elsewhere.
