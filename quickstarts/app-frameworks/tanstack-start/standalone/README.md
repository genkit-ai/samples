# TanStack Start (Standalone backend) quickstart

TanStack Start app whose only route is a client component that calls a separate Genkit backend. **No flow runs inside this app** — there's no `app/routes/api/` directory. Only the Genkit-specific file (`app/routes/index.tsx`) lives here; scaffold the surrounding TanStack Start project with the official examples.

Guide: https://genkit.dev/docs/frameworks/tanstack-start (Standalone backend tab)

## Setup

```bash
# scaffold a TanStack Start app, then copy the index.tsx in
npx degit https://github.com/tanstack/router/tree/main/examples/react/start-basic my-genkit-tanstack
cd my-genkit-tanstack
npm install genkit
cp /Users/chgill/Projects/samples/quickstarts/frontends/tanstack-start/standalone/app/routes/index.tsx ./app/routes/index.tsx
```

## Run

```bash
# Terminal 1 — any standalone backend in this repo:
cd /Users/chgill/Projects/samples/quickstarts/backends/js/express && GEMINI_API_KEY=<your-key> pnpm start

# Terminal 2 — your TanStack app:
cd /tmp/my-genkit-tanstack
npm run dev
```

Override the backend URL with `VITE_BARGAIN_CHEF_URL`.
