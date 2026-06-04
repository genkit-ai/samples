# TanStack Start (API route) quickstart

This directory contains only the Genkit-specific files (`app/genkit/bargainChefFlow.ts`, `app/routes/api/bargainChefFlow/$.ts`, `app/routes/index.tsx`). The TanStack Start scaffold (`app.config.ts`, `app/router.tsx`, `app/routes/__root.tsx`, etc.) is best produced with the official CLI because it tracks the framework's API.

Guide: https://genkit.dev/docs/js/app-frameworks/tanstack-start (full-stack API route)

## Setup

```bash
# scaffold a TanStack Start app with the official CLI, then copy these files in
npx @tanstack/cli@latest create my-genkit-tanstack
cd my-genkit-tanstack
# install Genkit deps
npm install genkit @genkit-ai/google-genai @genkit-ai/fetch
npm install -D genkit-cli tsx

# from the repo root, replace <repo> with the path to your local checkout
SRC=<repo>/quickstarts/app-frameworks/tanstack-start/api-route
cp -r "$SRC/app/genkit" ./app/
cp -r "$SRC/app/routes/api" ./app/routes/
cp "$SRC/app/routes/index.tsx" ./app/routes/index.tsx
```

Then start the dev server with `GEMINI_API_KEY=<your-key> npm run dev` and open the URL it prints.
