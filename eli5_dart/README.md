# ELI5 (Explain Like I'm 5) - Dart Edition

This is a code sample demonstrating the use of [Genkit](https://genkit.dev), an open-source framework for building AI-powered applications.

ELI5 is an application that takes a user's question and generates a simple, illustrated storybook to explain the answer. It uses Genkit to orchestrate multiple AI models to:

*   Turn a user's selfie into a cartoon character (optional).
*   Generate a storybook from a question.
*   Illustrate the storybook with generated images.

## How it works

The application consists of a Flutter front-end and a Dart back-end. The back-end exposes a few API endpoints that are implemented as Genkit flows.

*   **Front-end:** The front-end is built with Flutter (`app/` directory) and uses the Genkit Dart client to call flows. It features a bottom navigation bar with three tabs: Explore (ask questions), Library (view past stories), and Profile (manage your avatar selfie). Stories are displayed in a swipeable storybook format with tap-to-zoom illustrations.
*   **Back-end:** The back-end is a Dart server (`backend/` directory) that uses Genkit for Dart to expose the Genkit flows as API endpoints.
*   **Genkit Flows:** The core logic of the application is implemented as four Genkit flows:
    *   `generateLesson`: Takes a question and uses Gemini with Google Search grounding to research the topic and generate a structured lesson plan.
    *   `cartoonify`: Takes an image of a person and uses Gemini's image model to turn it into a cartoon character.
    *   `storify`: Orchestrates the full pipeline — calls `generateLesson`, then generates a storybook from the lesson plan. Uses streaming to report progress.
    *   `illustrate`: Takes an illustration description (and optionally a user's cartoon image) and generates a storybook illustration.

## Getting Started

### 1. Install dependencies

Since this project uses Dart Workspaces, you can install dependencies from the root directory:

```bash
dart pub get
```

### 2. Configure your environment

This sample uses the Google AI Gemini models. To use them, you need to provide an API key.

1.  Go to [Google AI Studio](https://aistudio.google.com/) and create an API key.
2.  Create a `.env` file in the project root:

```bash
echo "GEMINI_API_KEY=your-api-key" > .env
```

Or set the environment variable directly:

```bash
export GEMINI_API_KEY="your-api-key"
```

### 3. Run the application

To run the back-end server and enable the Genkit DevUI, open a terminal and run:

```bash
cd backend
genkit start -- dart run bin/server.dart
```

This will start the back-end Genkit flows and expose the Genkit Developer UI in your browser on `http://localhost:4000`, allowing you to inspect and manually run flows.

In a separate terminal, start the Flutter front-end:

```bash
cd app
flutter run -d chrome
```

## Genkit Flows

### `generateLesson`

This flow takes a question and generates a lesson plan that explains the core concepts of the subject using grounded search results. It uses Gemini with Google Search grounding enabled via `GeminiOptions(googleSearch: GoogleSearch())`.

**Input:**

```dart
class GenerateLessonRequest {
  final String question;
}
```

**Output:**

```dart
String // The generated lesson plan
```

### `cartoonify`

This flow takes an image of a person and uses Gemini's image generation model (`gemini-2.5-flash-image`) to turn it into a cartoon character.

**Input:**

```dart
class CartoonifyRequest {
  final String image; // A data URI of an image of a person to cartoonify
}
```

**Output:**

```dart
String // A data URI of the generated cartoon image
```

### `storify`

This flow orchestrates the full storybook generation pipeline. It first calls `generateLesson` to create a lesson plan, then sends that plan to Gemini to generate a structured storybook. It uses `context.sendChunk()` to stream progress updates and `outputSchema` to get structured JSON output.

**Input:**

```dart
class StorifyRequest {
  final String question;
}
```

**Output:**

A stream of `Storybook` objects (progress updates), and a final `Storybook` object.

```dart
class Storybook {
  final String? status;
  final String? bookTitle;
  final List<BookPage>? pages;
}

class BookPage {
  final String text;
  final String illustration;
}
```

### `illustrate`

This flow takes an illustration description and a question, and optionally a user's cartoon image. It generates a storybook illustration using Gemini's image model. When a user image is provided, the model can incorporate the user as a character in the scene.

**Input:**

```dart
class IllustrationRequest {
  final String? userImage;    // optional — the user's image as a data URI
  final String illustration;  // a description of the illustration to generate
  final String question;      // the question the story is about
}
```

**Output:**

```dart
String // A data URI of the generated illustration
```
