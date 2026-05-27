# Remix (Server route) quickstart

This sample is scaffolded with the Remix Vite template. Because Remix's `create-remix` scaffolds many tightly-coupled files (`root.tsx`, `entry.client.tsx`, `entry.server.tsx`, `vite.config.ts`, etc.) that depend on the Remix version, this directory only contains the Genkit-specific files (`app/genkit/`, `app/routes/api.bargainChefFlow.$.ts`, `app/routes/_index.tsx`).

Guide: https://genkit.dev/docs/frameworks/remix (Remix server route tab)

## Setup

```bash
# scaffold a fresh Remix app in a temp dir, then copy the genkit files in
cd /tmp && npx create-remix@latest remix-temp -y && cd remix-temp
npm install genkit @genkit-ai/google-genai @genkit-ai/fetch @genkit-ai/middleware
npm install -D genkit-cli tsx
cp -r /Users/chgill/Projects/samples/quickstarts/frontends/remix/server-route/app/genkit ./app/
cp /Users/chgill/Projects/samples/quickstarts/frontends/remix/server-route/app/routes/api.bargainChefFlow.\$.ts ./app/routes/
cp /Users/chgill/Projects/samples/quickstarts/frontends/remix/server-route/app/routes/_index.tsx ./app/routes/_index.tsx
```

Then start the dev server with `GEMINI_API_KEY=<your-key> npm run dev` and open the URL it prints.
