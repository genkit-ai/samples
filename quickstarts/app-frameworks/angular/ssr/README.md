# Angular SSR quickstart

**Bargain Chef** in an Angular SSR app: the Genkit flow runs in Angular's
built-in Express SSR server, so the frontend and backend ship as a single
deployment with no CORS to configure. Gemini streams a recipe into the UI
field-by-field and calls a tool mid-generation to look up live grocery sale
prices.

This is the finished code for the [Angular quickstart
guide](https://genkit.dev/docs/js/app-frameworks/angular).

## Setup

```bash
npm install
export GEMINI_API_KEY=<your-key>   # https://aistudio.google.com/apikey
```

## Run

```bash
npm start
```

The Angular dev server starts on http://localhost:4200. The flow is mounted at
`POST /api/bargainChefFlow` on the same origin.

## Inspect flows in the Genkit Developer UI

In a separate terminal:

```bash
npm run genkit:start
```

The Developer UI runs at http://localhost:4000. The **Traces** tab records every
request from the Angular app — including the `getIngredientsOnSale` tool call,
the model invocation, and each streamed chunk. The **Flows** tab runs
`bargainChefFlow` directly with custom input.

## Project layout

```
src/
├── app/                       # Angular component
│   ├── app.ts                 # Component class — calls streamFlow()
│   ├── app.html               # Template — renders recipe as fields arrive
│   └── app.css                # Styles
├── genkit/
│   └── bargainChefFlow.ts     # Genkit flow, tool, and Zod schemas
└── server.ts                  # Angular SSR Express server + Genkit route
```

The Angular component imports `BargainChefInput`, `Recipe`, and `PartialRecipe`
from `bargainChefFlow.ts` with `import type`, so frontend and backend share Zod-
derived types without bundling the server code into the browser.
