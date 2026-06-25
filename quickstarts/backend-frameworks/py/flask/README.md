# Flask quickstart

Standalone Genkit backend on Flask. Three stacked decorators wire it up:

```python
@app.post('/bargainChefFlow')   # mount the route
@genkit_flask_handler(ai)       # adapt the flow into a Flask view (JSON + SSE)
@ai.flow(name='bargainChefFlow', chunk_type=Recipe)   # register as a Genkit flow
async def bargain_chef_flow(input, ctx): ...
```

Guide: https://genkit.dev/docs/python/backend-frameworks/flask

## Run

```bash
cd quickstarts/backend-frameworks/py/flask
uv sync
GEMINI_API_KEY=<your-key> uv run python main.py
```

Listens on `http://127.0.0.1:8080`. The flow is mounted at `/bargainChefFlow`.

## Test

```bash
curl -N -X POST http://127.0.0.1:8080/bargainChefFlow \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -d '{"data":{"craving":"something warm with chicken"}}'
```

## Developer UI

```bash
genkit start -- uv run python main.py    # opens http://localhost:4000
```

## Local Genkit packages

`pyproject.toml` uses `[tool.uv.sources]` to point at editable installs of the local genkit packages. Edit the paths if your checkout lives elsewhere.
