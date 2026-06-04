# Echo (Go) quickstart

Standalone Genkit backend on [Echo](https://echo.labstack.com/). `genkit.Handler` returns a standard `http.Handler`; `echo.WrapHandler` adapts it to Echo's signature.

Guide: https://genkit.dev/docs/go/backend-frameworks/echo

## Run

```bash
cd quickstarts/backend-frameworks/go/echo
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

`go.mod` uses a `replace` directive pointing at a local Genkit Go checkout. Edit the path if your checkout lives elsewhere.
