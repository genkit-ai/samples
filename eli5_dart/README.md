# ELI5 Dart (Explain Like I'm 5)

This is a Dart adaptation of the Genkit sample ELI5. It features a Dart Shelf backend and a Flutter frontend that generates a simple, illustrated storybook to explain an answer to a 5 year old.

## How it works
This sample uses `genkit_dart` to run generative flows.
*   **Front-end:** A Flutter Single Page Application (Web/Mobile) using the `genkit` Dart plugin to connect to flow services.
*   **Back-end:** A Dart Shelf server that serves Genkit workflows via `genkit_shelf`.
*   **Genkit Flows:** Core logic:
    *   `cartoonify`: Uses a Google AI vision model to turn an image into a cartoon.
    *   `storify`: Takes a question and generates a multi-page Storybook response using Gemini models.
    *   `illustrate`: Generates an image representation of a storybook page, starring the user.

## Getting Started

### 1. Configure API Keys
This sample relies on Google AI.
1. Get an API key from Google AI Studio.
2. `export GOOGLE_API_KEY="your-api-key"`

### 2. Run the Genkit Flow Backend
The backend powers the intelligence behind ELI5.
```bash
cd eli5_dart
dart pub get
dart run bin/server.dart
```

### 3. Run the Flutter App
In a new terminal, launch the Flutter Web App:
```bash
cd eli5_dart/flutter
flutter pub get
flutter run -d chrome
```
