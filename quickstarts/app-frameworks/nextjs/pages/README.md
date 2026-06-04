# Next.js (Pages Router) quickstart

Full-stack Next.js app using the Pages Router. The Genkit flow lives in `src/genkit/bargainChefFlow.ts` and is exposed via a Pages API handler at `src/pages/api/bargainChefFlow.ts` that adapts `req`/`res` to a fetch `Request`/`Response` and delegates to `fetchHandlers`.

Guide: https://genkit.dev/docs/js/app-frameworks/nextjs (Pages Router tab)

## Run

```bash
# from the repo's quickstarts directory:
pnpm install   # once
cd app-frameworks/nextjs/pages
GEMINI_API_KEY=<your-key> pnpm dev
```

Opens at `http://localhost:3000`.

## Test the API directly

```bash
curl -N -X POST http://localhost:3000/api/bargainChefFlow \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -d '{"data":{"craving":"something warm with chicken"}}'
```

## Developer UI

```bash
pnpm genkit:start    # opens http://localhost:4000
```

## Note on a guide bug found here

The published guide had `export default expressHandler(bargainChefFlow)` as the Pages API handler, which throws `request.get is not a function` because Next's `req` has no `.get()` method. This sample uses a small `req`/`res` → fetch `Request`/`Response` adapter instead and the docsite guide has been updated to match.
