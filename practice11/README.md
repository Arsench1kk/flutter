# Practice 11 — A Real Server

Open this folder in IntelliJ IDEA and run `lib/main.dart`, or select **Practice 11** from the run configurations at the repository root.

```sh
flutter pub get
flutter run -d macos
```

The app loads users from JSONPlaceholder. Tap a row for its details, pull to refresh or use the refresh icon, and tap **New user** to submit the form. JSONPlaceholder simulates creation and returns an ID. The new user appears in the current list. Refreshing reads the original server dataset.

`ApiClient` handles transport, HTTP status codes, JSON decoding, and the ten-second deadline. `UserRepository` converts JSON into typed models. `UsersModel` exposes loading, errors, and users through Provider. The screen uses an exhaustive switch over the API errors.

See [NOTES.md](NOTES.md) for the wire format and network observations.
