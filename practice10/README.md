# Practice 10 — Async patterns

This Flutter app demonstrates asynchronous work with a fake student API, two approaches to loading UI, stream subscriptions, countdowns, and safe handling of an asynchronous save.

## Run

Open the `practice10` folder (the one containing `pubspec.yaml`) in IntelliJ IDEA and run `lib/main.dart`. The home screen links to the hand-managed loading screen, the `FutureBuilder` screen, and the countdown screen.

See [NOTES.md](NOTES.md) for the required event-order notes and behavior to demonstrate.

## Screenshots

- `screenshot_error.png` — the third API request fails and shows the retry state.
- `screenshot_countdown.png` — countdown running with a manually managed stream subscription.
