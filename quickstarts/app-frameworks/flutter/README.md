# Flutter web quickstart

Browser-only Flutter web app. **No flow runs inside this app** — it calls a separate Genkit backend over HTTP using `defineRemoteAction` from `package:genkit/client.dart`.

Guide: https://genkit.dev/docs/dart/frontend/flutter

## Run

In two terminals:

```bash
# Terminal 1 — any standalone backend in this repo:
cd backend-frameworks/js/express && GEMINI_API_KEY=<your-key> pnpm start
# or backend-frameworks/go/chi, backend-frameworks/py/flask, backend-frameworks/dart/shelf, …

# Terminal 2 — this frontend:
cd quickstarts/app-frameworks/flutter
flutter pub get
flutter run -d chrome
```

The app opens in Chrome. The frontend calls the standalone backend at `http://localhost:8080/bargainChefFlow` by default.

## Point at a different backend

The app reads `BARGAIN_CHEF_URL` from a Dart define at build time; defaults to `http://localhost:8080/bargainChefFlow`.

```bash
flutter run -d chrome --dart-define=BARGAIN_CHEF_URL=http://localhost:3780/api/bargainChefFlow   # hono
flutter run -d chrome --dart-define=BARGAIN_CHEF_URL=http://localhost:8000/bargainChefFlow       # fastapi/django
```
