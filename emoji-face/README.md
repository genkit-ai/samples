# Emoji Face Sample App

This is a sample app that uses the Gemini 2.5 Flash Image Preview (a.k.a nano banana) to apply emoji expressions to faces.

The Genkit code for the AI flow can be found in `emoji-face/src/ai/flows/apply-emoji-expression.ts`.

This app was built using Firebase Studio.

## Running the App

To run the app, follow these steps:

1.  Install the dependencies:
    ```bash
    npm i
    ```

2.  Set your Gemini API key as an environment variable:
    ```bash
    export GEMINI_API_KEY=...
    ```

3.  Start the development server:
    ```bash
    npm run dev
    ```

4.  Open your browser and navigate to `http://localhost:9002`.
