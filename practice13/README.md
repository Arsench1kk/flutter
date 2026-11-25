# Practice 13 — Where Things Go

Open the repository in IntelliJ IDEA and select **Practice 13**. The users app keeps the sign-in, persistent settings, saved list, and profile from Practice 12. Sign in with a sample email and a password of at least eight characters.

The users screen observes `UsersModel`. The model receives a `UserRepository`, and `main.dart` chooses the HTTP implementation. To run the demo locally, uncomment the fake import and repository declaration in `lib/main.dart` and comment out the HTTP declaration. The fake supplies two users without talking to a server.

Run the checks from the `practice13` directory. [NOTES.md](NOTES.md) records the move history, deliberate test failures, and annotated stack trace.

## Verification

The test process could connect only to localhost. All 12 tests completed in 4.58 seconds of wall-clock time. Paths in the output are relative to this folder.

```text
$ flutter analyze --no-pub
Analyzing practice13...
No issues found! (ran in 2.8s)

$ dart format .
Formatted 42 files (0 changed) in 0.08 seconds.

$ flutter test --no-pub --reporter expanded --concurrency=1
00:00 +0: loading test/features/users/user_test.dart
00:00 +0: test/features/users/user_test.dart: User.fromJson parses user 1, including the nested city and double latitude
00:00 +1: test/features/users/user_test.dart: User.fromJson throws TypeError when the id is a string
00:00 +2: test/features/users/user_test.dart: Geo.fromJson throws TypeError for a numeric latitude
00:00 +3: loading test/features/users/users_model_test.dart
00:00 +3: test/features/users/users_model_test.dart: UsersModel.load publishes the two fake users
00:00 +4: test/features/users/users_model_test.dart: UsersModel.load NoConnection sets error
00:00 +5: loading test/features/users/users_screen_test.dart
00:01 +5: test/features/users/users_screen_test.dart: shows the offline view and Retry
00:01 +6: test/features/users/users_screen_test.dart: shows the generic message for a bad response
00:01 +7: loading test/features/users/user_repository_test.dart
00:02 +7: test/features/users/user_repository_test.dart: HTTP response mapping 404 becomes NotFoundException
00:02 +8: test/features/users/user_repository_test.dart: HTTP response mapping 500 becomes ServerException with the original status
00:02 +9: test/features/users/user_repository_test.dart: HTTP response mapping SocketException becomes NoConnectionException
00:02 +10: test/features/users/user_repository_test.dart: getAll reports a numeric latitude as a bad response
00:02 +11: test/features/users/user_repository_test.dart: getAll falls back to its last successful response when offline
00:02 +12: All tests passed!

$ tool/check_layers.sh
```
