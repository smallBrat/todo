# Daily Productivity Assistant

Serverpod backend + Flutter client for a daily productivity planner with analytics.

## Repo layout
- `daily_productivity_assistant_server/` – Serverpod backend (Dart) with planning endpoints and migrations.
- `daily_productivity_assistant_client/` – Generated Serverpod client package.
- `daily_productivity_assistant_flutter/` – Flutter app consuming the Serverpod API.

## Local development
1) Prereqs: Flutter SDK, Dart SDK, Docker Desktop (for Postgres & Redis).
2) Start backend deps & server:
   ```bash
   cd daily_productivity_assistant_server
   docker compose up --build --detach
   dart run bin/main.dart
   ```
   API will listen on `http://localhost:8088` (matches the Flutter debug config).
3) Run the Flutter app (debug uses localhost):
   ```bash
   cd daily_productivity_assistant_flutter
   flutter pub get
   flutter run
   ```

## Production (Serverpod Cloud)
- API base: `https://todoapp.api.serverpod.space`
- Web host: `https://todoapp.serverpod.space` (default status page unless you deploy a web UI)
- Insights: `https://todoapp.insights.serverpod.space`

The Flutter client auto-selects the base URL: debug/dev → `http://localhost:8088`; release/profile → `https://todoapp.api.serverpod.space` (see `daily_productivity_assistant_flutter/lib/serverpod.dart`).

## Testing
- Flutter: `cd daily_productivity_assistant_flutter && flutter test`
- Server: `cd daily_productivity_assistant_server && dart test`

## Deployment
- Serverpod Cloud: run `scloud deploy` from the server project after logging in and configuring your project. Ensure migrations are applied and configs (`config/production.yaml`) are set before deploying.

## License
Apache-2.0 (see `LICENSE`).
