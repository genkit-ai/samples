# Remix (Standalone backend) quickstart

Remix app whose only route is a client component that calls a separate Genkit backend. **No flow runs inside this app** — there's no `api.bargainChefFlow.$.ts` route. Only the Genkit-specific file (`app/routes/_index.tsx`) lives here; scaffold the surrounding Remix project with the official CLI.

Guide: https://genkit.dev/docs/frameworks/remix (Standalone backend tab)

## Setup

```bash
# scaffold a fresh Remix app in a temp dir, then copy this _index.tsx in
cd /tmp && npx create-remix@latest remix-temp -y && cd remix-temp
npm install genkit
cp /Users/chgill/Projects/samples/quickstarts/frontends/remix/standalone/app/routes/_index.tsx ./app/routes/_index.tsx
```

## Run

```bash
# Terminal 1 — any standalone backend in this repo:
cd /Users/chgill/Projects/samples/quickstarts/backends/js/express && GEMINI_API_KEY=<your-key> pnpm start

# Terminal 2 — your Remix app:
cd /tmp/remix-temp
npm run dev
```

Override the backend URL with `VITE_BARGAIN_CHEF_URL`.
