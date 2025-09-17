<dotguides>
This workspace uses the *Dotguides* system for providing context-aware coding guidance for open source packages it uses. Use the `read_docs` tool to load documentation files relevant to specific tasks.

## Detected Languages

Language: typescript
Runtime: nodejs
Package Manager: pnpm

## Package Usage Guides

The following are the discovered package usage guides for this workspace. FOLLOW THEIR GUIDANCE CAREFULLY. Not all packages have discoverable guidance files.

<package name="genkit">
<usage_guide>
## Basic Example

```ts
import { ai, z } from "@/ai/genkit"; // or wherever genkit is initialized

const myTool = ai.defineTool({name, description, inputSchema: z.object(...)}, (input) => {...});

const {text} = await ai.generate({
  model: googleAI.model('gemini-2.5-flash'), // optional if default model is configured
  system: "the system instructions", // optional
  prompt: "the content of the prompt",
  // OR, for multi-modal content
  prompt: [{text: "what is this image?"}, {media: {url: "data:image/png;base64,..."}}],
  tools: [myTool],
});

// structured output
const CharacterSchema = z.object({...}); // make sure to use .describe() on fields
const {output} = await ai.generate({
  prompt: "generate an RPG character",
  output: {schema: CharacterSchema},
});
```

## Important API Clarifications

**IMPORTANT:** This app uses Genkit v1.16 which has changed significantly from pre-1.0 versions. Important changes include:

```ts
const response = await ai.generate(...);

response.text // CORRECT 1.x syntax
response.text() // INCORRECT pre-1.0 syntax

response.output // CORRECT 1.x syntax
response.output() // INCORRECT pre-1.0 syntax

const {stream, response} = ai.generateStream(...); // IMPORTANT: no `await` needed
for await (const chunk of stream) { } // CORRECT 1.x syntax
for await (const chunk of stream()) { } // INCORRECT pre-1.0 syntax
await response; // CORRECT 1.x syntax
await response(); // INCORRECT pre-1.0 syntax
await ai.generate({..., model: googleAI.model('gemini-2.5-flash')}); // CORRECT 1.x syntax
await ai.generate({..., model: gemini15Pro}); // INCORRECT pre-1.0 syntax
```

- Use `import {z} from "genkit"` when you need Zod to get an implementation consistent with Genkit.
- When defining Zod schemas, ONLY use basic scalar, object, and array types. Use `.optional()` when needed and `.describe('...')` to add descriptions for output schemas.
- Genkit has many capabilities, make sure to read docs when you need to use them.
</usage_guide>
<style_guide>
- Prefer destructuring generate calls e.g. `const {text} = await ai.generate(...)`
</style_guide>
<docs>
- [generate-content](docs:genkit:generate-content): how to generate content (text, structured data, images, videos) with Genkit.
- [flows](docs:genkit:flows): how to construct strongly typed AI workflows with Genkit.
- [tool-calling](docs:genkit:tool-calling): an in-depth guide to providing tools/functions to Genkit for GenAI
- [context](docs:genkit:context): how to pass context to tools and flows without exposing sensitive data to the LLM
</docs>
</package>

<package name="@genkit-ai/express">
<usage_guide>
Genkit's Express integration makes it easy to expose Genkit flows as Express API endpoints:

```ts
import express from 'express';
import { expressHandler } from '@genkit-ai/express';
import { simpleFlow } from './flows/simple-flow.js';

const app = express();
app.use(express.json());

app.post('/simpleFlow', expressHandler(simpleFlow));

app.listen(8080);
```

You can also handle auth using context providers:

```ts
import { UserFacingError } from 'genkit';
import { ContextProvider, RequestData } from 'genkit/context';

const context: ContextProvider<Context> = (req: RequestData) => {
  if (req.headers['authorization'] !== 'open sesame') {
    throw new UserFacingError('PERMISSION_DENIED', 'not authorized');
  }
  return {
    auth: {
      user: 'Ali Baba',
    },
  };
};

app.post(
  '/simpleFlow',
  authMiddleware,
  expressHandler(simpleFlow, { context })
);
```

Flows and actions exposed using the `expressHandler` function can be accessed using `genkit/beta/client` library:

```ts
import { runFlow, streamFlow } from 'genkit/beta/client';

const result = await runFlow({
  url: `http://localhost:${port}/simpleFlow`,
  input: 'say hello',
});

console.log(result); // hello
```

```ts
// set auth headers (when using auth policies)
const result = await runFlow({
  url: `http://localhost:${port}/simpleFlow`,
  headers: {
    Authorization: 'open sesame',
  },
  input: 'say hello',
});

console.log(result); // hello
```

```ts
// and streamed
const result = streamFlow({
  url: `http://localhost:${port}/simpleFlow`,
  input: 'say hello',
});
for await (const chunk of result.stream) {
  console.log(chunk);
}
console.log(await result.output);
```

You can use `startFlowServer` to quickly expose multiple flows and actions:

```ts
import { startFlowServer } from '@genkit-ai/express';
import { genkit } from 'genkit';

const ai = genkit({});

export const menuSuggestionFlow = ai.defineFlow(
  {
    name: 'menuSuggestionFlow',
  },
  async (restaurantTheme) => {
    // ...
  }
);

startFlowServer({
  flows: [menuSuggestionFlow],
});
```

You can also configure the server:

```ts
startFlowServer({
  flows: [menuSuggestionFlow],
  port: 4567,
  cors: {
    origin: '*',
  },
});
```
</usage_guide>
</package>

<package name="@genkit-ai/google-genai">
<docs>
- [Edit images with `gemini-2.5-flash-image-preview` (aka "Nano Banana")](docs:@genkit-ai/google-genai:editing-images): read this if you need to perform sophisticated image edits such as background removal, post matching, character replacement, relighting, on an existing image
</docs>
</package>
</dotguides>