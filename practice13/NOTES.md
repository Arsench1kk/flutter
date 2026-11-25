# Practice 13 notes

## Moves and layer checks

Practice 12 already grouped its files by feature. I made a separate flat starter in Practice 13 so the lab could record the moves without altering the previous submission. The 14 commits from `c5aeb4b` through `9b3163a` each move one file and update its imports. I ran the layer check and hot-restarted the macOS app before each move commit.

The four inherited Practice 12 tests and its analyzer passed. Before adding tests to the new starter, `flutter test` reported `Test directory "test" not found.` and returned exit code 1 with this Flutter version. The new starter analyzed cleanly.

I added an HTTP import temporarily to `users_screen.dart`. The layer script printed `lib/features/users/users_screen.dart` and returned 1. With the import removed, both checks produced no output. The current code creates the HTTP repository once, in `main.dart`.

## Dependencies and test failures

The arrange step for a model that creates its own repository is where I get stuck. I cannot write `UsersModel(FakeUserRepository(fail: true))` because that constructor has no dependency parameter. The Practice 12 version already accepted a repository, but its parameter named the concrete class. Practice 13 gives the model a contract implemented by both the HTTP and fake repositories.

Removing the error assignment from `UsersModel.load()` made **NoConnection sets error** fail with an expected `NoConnectionException` and an actual value of `null`. Renaming **Retry** to **Try again** made **shows the offline view and Retry** report one expected match and zero actual matches. Restoring the assignment and label restored both tests.

The extracted widgets can have const constructors and their own rebuild boundaries. They appear by name in DevTools and can be pumped independently in a widget test. The city dropdown stays in Settings, where Practice 12 placed it. The longest `build()` is 53 lines.

The JSON fixture comes from the sample endpoint. Repository tests inject `MockClient` and use an in-memory cache. [Sample user 1](https://jsonplaceholder.typicode.com/users/1) · [MockClient documentation](https://pub.dev/documentation/http/latest/testing/MockClient-class.html)

## Numeric latitude stack trace

I ran the app on macOS with a temporary fake that parsed the JSONPlaceholder record for user 1, Leanne Graham. I changed `address.geo.lat` from the string `"-37.3159"` to the number `-37.3159`. The full unhandled exception was:

```text
[ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: type 'double' is not a subtype of type 'String' in type cast
#0      new Geo.fromJson (package:where_things_go/features/users/geo.dart:8:29)
#1      new Address.fromJson (package:where_things_go/features/users/address.dart:23:14)
#2      new User.fromJson (package:where_things_go/features/users/user.dart:57:24)
#3      FakeUserRepository.getAll (package:where_things_go/features/users/fake_user_repository.dart:21:26)
<asynchronous suspension>
#4      UsersModel.load (package:where_things_go/features/users/users_model.dart:42:22)
<asynchronous suspension>
```

1. **Message.** The input was a `double` where the Dart cast required a `String`.
2. **First app frame.** Frame #0 points to `Geo.fromJson` in [geo.dart](lib/features/users/geo.dart#L8), line 8, column 29. That cast enforces the JSON contract. The repository is the right place to convert the failure into an application error the screen understands.
3. **Path.** `UsersModel.load()` awaited `FakeUserRepository.getAll()`, which called `User.fromJson()`, `Address.fromJson()`, then `Geo.fromJson()`. The suspension markers show the asynchronous gaps across which the exception reached `load()`.

The Geo test preserves the direct `TypeError`. The repository regression first failed with the generic cast message and now passes with `BadResponseException('users: lat is not a String')`. The widget test checks that the user sees the generic unexpected-response message.

## Native demo and build profiling

I switched the composition root to the fake in an isolated copy and confirmed both sample users in the macOS widget tree. The VM timeline recorded builds for `UsersScreen`, `UsersHeader`, `UsersBody` and `UserTile`. The submitted entry point selects the HTTP repository.
The HTTP implementation also loaded and rendered the real JSONPlaceholder users in the macOS smoke test. The final test suite ran with outbound connections limited to localhost.
