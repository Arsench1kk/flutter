sealed class Countdown {
  const Countdown();

  factory Countdown.forEvent(DateTime startsAt, {DateTime? now}) {
    final current = now ?? DateTime.now();
    if (current.isBefore(startsAt)) {
      return Upcoming(startsAt.difference(current));
    }
    final elapsed = current.difference(startsAt);
    if (elapsed < const Duration(hours: 2)) return Started(elapsed);
    return const Ended();
  }
}

final class Upcoming extends Countdown {
  const Upcoming(this.remaining);

  final Duration remaining;
}

final class Started extends Countdown {
  const Started(this.elapsed);

  final Duration elapsed;
}

final class Ended extends Countdown {
  const Ended();
}
