# ELI5 (Explain Like I'm 5)

This is a code sample demonstrating the use of [Genkit](https://firebase.google.com/docs/genkit), an open-source framework for building AI-powered applications.

ELI5 is a web application that takes a user's question and generates a simple, illustrated storybook to explain the answer. It uses Genkit to orchestrate multiple AI models to:

*   Turn a user's selfie into a cartoon character.
*   Generate a storybook from a question.
*   Illustrate the storybook with generated images.

## How it works

The application is a single-page web app with a React front-end and an Express back-end. The back-end exposes a few API endpoints that are implemented as Genkit flows.

*   **Front-end:** The front-end is built with React and Vite. It uses the `genkit/beta/client` library to call the Genkit flows on the back-end.
*   **Back-end:** The back-end is an Express server that uses the `@genkit-ai/express` library to expose the Genkit flows as API endpoints.
*   **Genkit Flows:** The core logic of the application is implemented as three Genkit flows:
    *   `cartoonify`: Takes an image of a person and uses a Google AI model to turn it into a cartoon character.
    *   `storify`: Takes a question and generates a storybook about it. It uses two prompts, `generate-lesson` and `generate-storybook`, to first generate the lesson content and then create the storybook from it.
    *   `illustrate`: Takes a user's image, a description of an illustration, and a question. It then generates an illustration for a children's storybook.

## Getting Started

### 1. Install dependencies

```bash
npm install
```

### 2. Configure your environment

This sample uses the Google AI Gemini models. To use them, you need to provide an API key.

1.  Go to [Google AI Studio](https://aistudio.google.com/) and create an API key.
2.  Set the `GOOGLE_API_KEY` environment variable:

```bash
export GOOGLE_API_KEY="your-api-key"
```

### 3. Run the application

```bash
npm start dev
```

This will start the development server on `http://localhost:3000`.

## Genkit Flows

### `cartoonify`

This flow takes an image of a person and uses a Google AI model to turn it into a cartoon character.

**Input:**

```typescript
{
  image: string; // A data URI of an image of a person to cartoonify
}
```

**Output:**

```typescript
string; // A data URI of the generated cartoon image
```

### `storify`

This flow takes a question and generates a storybook about it.

**Input:**

```typescript
{
  question: string;
}
```

**Output:**

A stream of `Storybook` objects, and a final `Storybook` object.

```typescript
type Storybook = {
  status?: string;
  bookTitle?: string;
p  pages?: {
    text: string;
    illustration: string;
  }[];
};
```

### `illustrate`

This flow takes a user's image, a description of an illustration, and a question. It then generates an illustration for a children's storybook.

**Input:**

```typescript
{
  userImage: string; // the user's image as a data URI
  illustration: string; // a description of the illustration to generate
  question: string; // the question the story is about
}
```

**Output:**

```typescript
string; // A data URI of the generated illustration
```
