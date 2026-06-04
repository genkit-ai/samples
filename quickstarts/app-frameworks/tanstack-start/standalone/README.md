# TanStack Start (Standalone backend) quickstart

TanStack Start app whose only route is a client component that calls a separate Genkit backend. **No flow runs inside this app** — there's no `app/routes/api/` directory. Only the Genkit-specific file (`app/routes/index.tsx`) lives here; scaffold the surrounding TanStack Start project with the official CLI.

Guide: https://genkit.dev/docs/js/app-frameworks/tanstack-start (standalone backend)

## Setup

```bash
# scaffold a TanStack Start app with the official CLI, then copy the index.tsx in
npx @tanstack/cli@latest create my-genkit-tanstack
cd my-genkit-tanstack
npm install genkit

# from the repo root, replace <repo> with the path to your local checkout
cp <repo>/quickstarts/app-frameworks/tanstack-start/standalone/app/routes/index.tsx ./app/routes/index.tsx
```

## Run

```bash
# Terminal 1 — any standalone backend in this repo, e.g. Express:
cd <repo>/quickstarts/backend-frameworks/js/express && GEMINI_API_KEY=<your-key> pnpm start

# Terminal 2 — your TanStack app:
cd my-genkit-tanstack
npm run dev
```

Override the backend URL with `VITE_BARGAIN_CHEF_URL`.
