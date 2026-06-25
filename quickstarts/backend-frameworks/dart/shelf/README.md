# Shelf (Dart) quickstart

Standalone Genkit backend on Dart [Shelf](https://pub.dev/packages/shelf). Schemas are generated from `@Schema()`-annotated classes via [`schemantic`](https://pub.dev/packages/schemantic) and `build_runner`.

Guide: https://genkit.dev/docs/dart/backend-frameworks/shelf

## Run

```bash
cd quickstarts/backend-frameworks/dart/shelf
dart pub get
dart run build_runner build       # generates bin/my_genkit_shelf.g.dart
GEMINI_API_KEY=<your-key> dart run
```

Listens on `http://localhost:8080`. While iterating on schemas, keep `dart run build_runner watch` running in a second terminal.

## Test

```bash
curl -N -X POST http://localhost:8080/bargainChefFlow \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -d '{"data":{"craving":"something warm with chicken"}}'
```

## Developer UI

```bash
genkit start -- dart run    # opens http://localhost:4000
```

## Note on a guide bug found here

The published guide called `retry(maxRetries: 3)` in `use:` but didn't register `RetryPlugin()` in the `Genkit(plugins: ...)` list — the call failed with `Middleware retry not found`. Fixed here and in the docsite guide.
