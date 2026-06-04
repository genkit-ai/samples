# Remix (Standalone backend) quickstart

Remix app whose only route is a client component that calls a separate Genkit backend. **No flow runs inside this app** — there's no `api.bargainChefFlow.$.ts` route. Only the Genkit-specific file (`app/routes/_index.tsx`) lives here; scaffold the surrounding Remix project with the React Router CLI.

Guide: https://genkit.dev/docs/js/app-frameworks/remix (standalone backend)

## Setup

```bash
# scaffold a fresh Remix (React Router v7) app in a temp dir, then copy this _index.tsx in
cd /tmp && npx create-react-router@latest remix-temp && cd remix-temp
npm install genkit

# from the repo root, replace <repo> with the path to your local checkout
cp <repo>/quickstarts/app-frameworks/remix/standalone/app/routes/_index.tsx ./app/routes/_index.tsx
```

## Run

```bash
# Terminal 1 — any standalone backend in this repo, e.g. Express:
cd <repo>/quickstarts/backend-frameworks/js/express && GEMINI_API_KEY=<your-key> pnpm start

# Terminal 2 — your Remix app:
cd /tmp/remix-temp
npm run dev
```

Override the backend URL with `VITE_BARGAIN_CHEF_URL`.
