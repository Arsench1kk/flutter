# Practice 10 notes

## Level 1 — event loop and fake API

Before running, I predicted this order. `main()` prints `A`, schedules `B`, starts `fetchStudents()` and prints `C` without waiting. Flutter draws its first frame while the futures are pending. After about two seconds the delayed callbacks complete:

```text
A
C
first frame
B
6 students
```

I ran the event-order experiment in Flutter. The actual console order was:

```text
A
C
fetchStudents #1
first frame
B
6 students
```

The API's request log appears between `C` and the first frame because the fake request starts immediately and prints before its first `await`. The timers do not block `main()` or the frame; their continuations run later through the event loop.

Every third API request throws `NoConnectionException` after the delay. The deliberate three-request experiment is expected to print:

```text
Unhandled Exception: Instance of 'NoConnectionException'
```

The app screens catch that exception and render a retry state. Replacing the asynchronous delay with blocking `sleep` blocks the Dart isolate: the first frame and pending continuations cannot run until `sleep` returns. Restore the delay after the experiment.

## Level 2 — explicit loading states

`StudentsScreen` holds nullable student data and error state. `_load()` clears the old state, awaits the API, then calls `setState` only while `mounted`. `initState()` starts the initial load without awaiting it. The third request demonstrates the error view; Retry starts another request. The group icon toggles the fake API's empty response. Four small stateless widgets in `lib/widgets/` render loading, error, empty, and data states. Missing GPA is displayed as an em dash.

If the two `mounted` guards are removed and Back is pressed during loading, Flutter reports a line of this form:

```text
setState() called after dispose(): _StudentsScreenState#…
```

The state identity suffix varies per run. The stable error prefix is `setState() called after dispose()`. The guards after asynchronous gaps prevent this lifecycle error.

## Level 3 — `FutureBuilder`

`StudentsFutureScreen` creates and stores its `Future` in `initState`. The `FutureBuilder` branches on `hasError`, `connectionState`, and `data`; an empty result has its own view. The compact-layout switch rebuilds the presentation without requesting the API again. Retry is the only control that assigns a new future, so it intentionally starts a new request.

## Level 4 — streams and disposal

`countdown()` is an `async*` generator. It waits one second and yields each remaining integer. The screen offers two listeners:

- **StreamBuilder** lets Flutter subscribe and cancel when that child is removed.
- **listen + cancel** stores a `StreamSubscription`, updates the displayed count in `onData`, and cancels the subscription in `dispose()` (and when switching modes).

Leaving the countdown screen mid-run disposes its listener. For the manual version, cancellation stops further `onData` output; for the `StreamBuilder` version, Flutter manages the subscription lifetime.

At 7, leaving the manual version with `cancel()` enabled should leave the console ending at `tick 7`; there should be no later ticks. With `_sub.cancel()` deliberately removed, the disposed state should report `setState() called after dispose()` and the generator should continue with `tick 6`, `tick 5`, down to `tick 0`. Leaving the StreamBuilder version at 7 should stop its stream without an explicit cancellation call in our code; StreamBuilder cancels its own subscription.

## Level 5 — awaiting a save

The fake save takes one second and every even save throws `StateError('server rejected $value')`. An unawaited save followed by an immediate `Navigator.pop` can close the form before the failure arrives, leaving an unhandled error and no useful feedback. The implemented save awaits the future, catches the `StateError`, checks `context.mounted` before using the context, and pops only on success. On failure it keeps the form open and displays a `SnackBar`; `_saving` disables repeat taps and shows progress. `unawaited_futures: true` makes forgotten futures an analyzer warning.

The required failure message is:

```text
Unhandled Exception: Bad state: server rejected 6
```

In this finished implementation that exception is caught and shown to the user instead of escaping as unhandled.

## Evidence

- `screenshot_error.png` shows the third-request error state and Retry action.
- `screenshot_countdown.png` shows the running countdown with the manual subscription option selected.
