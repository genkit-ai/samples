# Remix (Server route) quickstart

This sample is scaffolded with the React Router v7 (Remix) framework template. Because the scaffolder generates many tightly-coupled files (`root.tsx`, `entry.client.tsx`, `entry.server.tsx`, `vite.config.ts`, etc.) that depend on the framework version, this directory only contains the Genkit-specific files (`app/genkit/`, `app/routes/api.bargainChefFlow.$.ts`, `app/routes/_index.tsx`).

Guide: https://genkit.dev/docs/js/app-frameworks/remix (full-stack server route)

## Setup

```bash
# scaffold a fresh Remix (React Router v7) app in a temp dir, then copy the genkit files in
cd /tmp && npx create-react-router@latest remix-temp && cd remix-temp
npm install genkit @genkit-ai/google-genai @genkit-ai/fetch
npm install -D genkit-cli tsx

# from the repo root, replace <repo> with the path to your local checkout
SRC=<repo>/quickstarts/app-frameworks/remix/server-route
cp -r "$SRC/app/genkit" ./app/
cp "$SRC/app/routes/api.bargainChefFlow.\$.ts" ./app/routes/
cp "$SRC/app/routes/_index.tsx" ./app/routes/_index.tsx
```

Then start the dev server with `GEMINI_API_KEY=<your-key> npm run dev` and open the URL it prints.
