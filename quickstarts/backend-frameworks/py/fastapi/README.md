# FastAPI quickstart

Standalone Genkit backend on FastAPI. The `@genkit_fastapi_handler` decorator turns the flow into an async route that handles both JSON and SSE responses.

Guide: https://genkit.dev/docs/python/backend-frameworks/fastapi

## Run

```bash
cd quickstarts/backend-frameworks/py/fastapi
uv sync
GEMINI_API_KEY=<your-key> uv run uvicorn main:app --port 8000
```

Listens on `http://localhost:8000`. The flow is mounted at `/bargainChefFlow`.

## Test

```bash
curl -N -X POST http://localhost:8000/bargainChefFlow \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -d '{"data":{"craving":"something warm with chicken"}}'
```

## Developer UI

```bash
genkit start -- uv run uvicorn main:app --reload    # opens http://localhost:4000
```

## Local Genkit packages

`pyproject.toml` uses `[tool.uv.sources]` to point at editable installs of the local genkit packages. Edit the paths if your checkout lives elsewhere.
