# TanStack Start (API route) quickstart

**Bargain Chef** as a full-stack TanStack Start app: the Genkit flow runs in a server route (`src/routes/api/bargainChefFlow/$.ts`) in the same project as the UI, so there's no separate backend and no CORS to configure. Gemini streams a recipe into the UI field-by-field and calls a tool mid-generation to look up grocery sale prices.

This is a full, runnable project (scaffolded with `@tanstack/cli create`), not a snippet.

> The current TanStack CLI scaffolds routes under `src/routes/` (older versions used `app/routes/`). This project uses `src/routes/`.

Guide: https://genkit.dev/docs/js/app-frameworks/tanstack-start (full-stack API route)

## Run

```bash
npm install
GEMINI_API_KEY=<your-key> npm run dev    # http://localhost:3000
```

Open the printed URL, type a craving, and submit. The recipe streams in field-by-field. The flow is served in-process at `POST /api/bargainChefFlow`.

Get a Gemini API key at https://aistudio.google.com/apikey.
