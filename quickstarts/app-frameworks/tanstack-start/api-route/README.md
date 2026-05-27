# TanStack Start (API route) quickstart

This directory contains only the Genkit-specific files (`app/genkit/bargainChefFlow.ts`, `app/routes/api/bargainChefFlow/$.ts`). The TanStack Start scaffold (`app.config.ts`, `app/router.tsx`, `app/routes/__root.tsx`, etc.) is best produced with the official CLI because it tracks the framework's beta API.

Guide: https://genkit.dev/docs/frameworks/tanstack-start (TanStack Start API route tab)

## Setup

```bash
# scaffold a TanStack Start app, then copy these files in
npx degit https://github.com/tanstack/router/tree/main/examples/react/start-basic my-genkit-tanstack
cd my-genkit-tanstack
cp -r /Users/chgill/Projects/samples/quickstarts/frontends/tanstack-start/api-route/app/genkit ./app/
cp -r /Users/chgill/Projects/samples/quickstarts/frontends/tanstack-start/api-route/app/routes/api ./app/routes/
# install Genkit deps
npm install genkit @genkit-ai/google-genai @genkit-ai/fetch @genkit-ai/middleware
```

Then follow the [TanStack Start quickstart guide](https://genkit.dev/docs/frameworks/tanstack-start) to build the UI route at `app/routes/index.tsx`.
