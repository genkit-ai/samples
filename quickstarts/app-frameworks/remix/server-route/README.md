# Remix (Server route) quickstart

**Bargain Chef** as a full-stack Remix (React Router v7) app: the Genkit flow runs in a Remix resource route (`app/routes/api.bargainChefFlow.$.ts`) in the same project as the UI, so there's no separate backend and no CORS to configure. Gemini streams a recipe into the UI field-by-field and calls a tool mid-generation to look up grocery sale prices.

This is a full, runnable project (scaffolded with `create-react-router`, default config-based routing in `app/routes.ts`), not a snippet.

Guide: https://genkit.dev/docs/js/app-frameworks/remix (full-stack server route)

## Run

```bash
npm install
GEMINI_API_KEY=<your-key> npm run dev    # http://localhost:5173
```

Open the printed URL, type a craving, and submit. The recipe streams in field-by-field. The flow is served in-process at `POST /api/bargainChefFlow`.

Get a Gemini API key at https://aistudio.google.com/apikey.
