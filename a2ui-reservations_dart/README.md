# A2UI Dining Reservations (Dart + Flutter Workspace)

A complete, runnable full-stack sample of [A2UI](https://a2ui.org/) (Agent-to-User Interface) with Genkit Dart and Flutter, demonstrating an interactive dining reservation concierge for **Cymbal Bistro**.

Organized as a canonical **Dart Pub Workspace** (`pubspec.yaml` `workspace:`):

- **`packages/shared`** (`lib/shared.dart`): Pure Dart package defining the shared A2UI catalog identifier (`bistroCatalogId = 'com.example.a2ui.bistro'`) with zero `dart:io` or `package:flutter` dependencies.
- **`packages/server`** (`bin/server.dart` + `lib/agent.dart`): Pure Dart VM Shelf HTTP server hosting an A2UI-enabled Genkit agent with two typed tools (`checkAvailability` and `confirmReservation`). The server-side A2UI integration is a single model middleware: `a2ui()` in the agent's `use` list.
- **`packages/app`** (`lib/main.dart` + `lib/src/`): Modular Flutter Web client that connects to the agent with `remoteAgent`, extracts A2UI envelopes off streamed chunks using `a2uiEnvelopesFromParts` in `ChatController`, and renders surfaces incrementally with [`genui`](https://pub.dev/packages/genui) (`SurfaceController` + `Surface`). User interactions (such as selecting time slot chips and pressing "Confirm Reservation") are sent back to the agent as subsequent turns with `actionToMessage`.

It also demonstrates a **custom catalog** (`bistroCatalog`) that extends the bundled basic catalog with dining-specific components (`DateTimeInput` and `ChoicePicker`).

## Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.10+ / Dart 3.10+)
- A Gemini API key in `GEMINI_API_KEY`

## Run

1. Install workspace dependencies and generate tool schemas (from the workspace root):

   ```sh
   flutter pub get
   (cd packages/server && dart run build_runner build)
   ```

2. Start the agent server (terminal 1):

   ```sh
   export GEMINI_API_KEY=your-gemini-api-key
   dart run packages/server/bin/server.dart
   ```

   You can also start it with the Genkit Developer UI to inspect traces and A2UI envelopes step-by-step:

   ```sh
   export GEMINI_API_KEY=your-gemini-api-key
   genkit start -- dart run packages/server/bin/server.dart
   ```

   The server listens on `http://localhost:8080` and mounts the agent at `/api/uiAgent`.

3. Run the Flutter client (terminal 2):

   ```sh
   cd packages/app
   flutter run -d chrome
   ```

   To point the client at a custom server address:
   ```sh
   cd packages/app
   flutter run -d chrome --dart-define=AGENT_BASE_URL=http://host:port
   ```

## Test

Run the server unit tests (and optional live Gemini E2E booking test when `GEMINI_API_KEY` is set):

```sh
(cd packages/server && dart test)
```

Run the Flutter client widget and A2UI surface rendering tests:

```sh
(cd packages/app && flutter test)
```

## Try it

- *"Book a table for 4 at Cymbal Bistro tonight at 7:00 PM."* — calls `checkAvailability` and renders an interactive reservation card with a calendar date picker, time slot chips, party size slider, seating preference chips, and a confirmation button.
- Adjust your preferred time slot or seating area on the card and click **Confirm Reservation** — the client sends the bound form data via `actionToMessage` to the agent, which calls `confirmReservation` and renders a confirmed reservation card with your confirmation code (`#CB-xxxx`).

## Custom catalog

By default the `a2ui()` middleware uses the bundled **basic catalog** (`Text`, `Card`, `Column`, `Row`, `Button`, `Slider`, ...). This sample registers its own catalog for Cymbal Bistro (`com.example.a2ui.bistro`, defined in `packages/shared/lib/shared.dart`):

- **Server** (`packages/server/lib/agent.dart`): `bistroCatalog` extends `basicCatalog.components` with `DateTimeInput` and `ChoicePicker`. `registerCatalogs()` registers it via `loadCatalog(ai, id: bistroCatalogId, catalog: bistroCatalog)`, and the agent enables it with `a2ui(catalog: bistroCatalogId, validate: 'strict')`.
- **Client** (`packages/app/lib/src/catalog.dart`): `genui`'s catalog is tagged with the same catalog ID (`BasicCatalogItems.asCatalog().copyWith(catalogId: bistroCatalogId, newItems: [bistroCardItem])`).
