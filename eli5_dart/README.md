# ELI5 (Explain Like I'm 5) - Dart Edition

This is a code sample demonstrating the use of [Genkit](https://genkit.dev), an open-source framework for building AI-powered applications.

ELI5 is an application that takes a user's question and generates a simple, illustrated storybook to explain the answer. It uses Genkit to orchestrate multiple AI models to:

*   Turn a user's selfie into a cartoon character.
*   Generate a storybook from a question.
*   Illustrate the storybook with generated images.

## How it works

The application consists of a Flutter front-end and a Dart back-end. The back-end exposes a few API endpoints that are implemented as Genkit flows.

*   **Front-end:** The front-end is built with Flutter (`app/` directory) and uses the Genkit Dart client to call flows.
*   **Back-end:** The back-end is a Dart server (`backend/` directory) that uses Genkit for Dart to expose the Genkit flows as API endpoints.
*   **Genkit Flows:** The core logic of the application is implemented as three Genkit flows:
    *   `cartoonify`: Takes an image of a person and uses a Google AI model to turn it into a cartoon character.
    *   `storify`: Takes a question and generates a storybook about it. It uses prompts to first generate the lesson content and then create the storybook from it.
    *   `illustrate`: Takes a user's image, a description of an illustration, and a question. It then generates an illustration for a children's storybook.

## Getting Started

### 1. Install dependencies

Since this project uses Dart Workspaces, you can install dependencies from the root directory:

```bash
dart pub get
```

### 2. Configure your environment

This sample uses the Google AI Gemini models. To use them, you need to provide an API key.

1.  Go to [Google AI Studio](https://aistudio.google.com/) and create an API key.
2.  Set the `GEMINI_API_KEY` environment variable:

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

### `cartoonify`

This flow takes an image of a person and uses a Google AI model to turn it into a cartoon character.

**Input:**

```dart
class CartoonifyInput {
  final String image; // A data URI of an image of a person to cartoonify
}
```

**Output:**

```dart
String // A data URI of the generated cartoon image
```

### `generateLesson`

This flow takes a question and generates a lesson plan that explains the core concepts of the subject using grounded search results.

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

### `storify`

This flow takes a question and generates a storybook about it.

**Input:**

```dart
class StorifyInput {
  final String question;
}
```

**Output:**

A stream of `Storybook` objects, and a final `Storybook` object.

```dart
class Storybook {
  final String? status;
  final String? bookTitle;
  final List<Page>? pages;
}

class Page {
  final String text;
  final String illustration;
}
```

### `illustrate`

This flow takes a user's image, a description of an illustration, and a question. It then generates an illustration for a children's storybook.

**Input:**

```dart
class IllustrateInput {
  final String userImage; // the user's image as a data URI
  final String illustration; // a description of the illustration to generate
  final String question; // the question the story is about
}
```

**Output:**

```dart
String // A data URI of the generated illustration
```