# Django quickstart

Standalone Genkit backend on Django, with the [`genkit-plugin-django`](https://pypi.org/project/genkit-plugin-django/) handler exposing the flow as a JSON/SSE endpoint. Database and admin middleware are turned off so the app runs without migrations.

Guide: https://genkit.dev/docs/python/backend-frameworks/django

## Run

```bash
cd backend-frameworks/py/django
uv sync
GEMINI_API_KEY=<your-key> uv run uvicorn myproject.asgi:application --port 8000
```

Uvicorn is required because the streaming response uses `async def`. Listens on `http://localhost:8000`. The flow is mounted at `/bargainChefFlow`.

## Test

```bash
curl -N -X POST http://localhost:8000/bargainChefFlow \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -d '{"data":{"craving":"something warm with chicken"}}'
```

## Developer UI

```bash
genkit start -- uv run uvicorn myproject.asgi:application --reload    # opens http://localhost:4000
```

## Project layout

```
myproject/    Django project (settings.py, urls.py, asgi.py)
recipes/      Django app — contains the flow + Genkit handler in views.py
```

## Local Genkit packages

`pyproject.toml` uses `[tool.uv.sources]` to point at editable installs of the local genkit packages. Edit the paths if your checkout lives elsewhere.
