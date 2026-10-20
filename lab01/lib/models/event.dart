import 'package:flutter/material.dart';

enum EventCategory {
  technology('Technology', Icons.code),
  arts('Arts', Icons.palette_outlined),
  sport('Sport', Icons.sports_basketball_outlined),
  career('Career', Icons.work_outline),
  community('Community', Icons.groups_outlined);

  const EventCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}

extension EventCategoryColors on EventCategory {
  Color colorFrom(ColorScheme colorScheme) => switch (this) {
    EventCategory.technology => colorScheme.primary,
    EventCategory.arts => colorScheme.tertiary,
    EventCategory.sport => colorScheme.secondary,
    EventCategory.career => colorScheme.error,
    EventCategory.community => colorScheme.primaryContainer,
  };

  Color foregroundFrom(ColorScheme colorScheme) => switch (this) {
    EventCategory.technology => colorScheme.onPrimary,
    EventCategory.arts => colorScheme.onTertiary,
    EventCategory.sport => colorScheme.onSecondary,
    EventCategory.career => colorScheme.onError,
    EventCategory.community => colorScheme.onPrimaryContainer,
  };
}

class Event {
  Event({
    required this.id,
    required this.title,
    required this.category,
    required this.when,
    required this.place,
    required this.limit,
    List<String> names = const [],
    this.mode = false,
    this.note,
    this.favorite = false,
  }) : _names = List.unmodifiable(names);

  Event.empty()
    : this._fromList(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: '',
        category: EventCategory.technology,
        when: DateTime.now().add(const Duration(days: 1)),
        place: '',
        limit: 20,
      );

  Event._fromList({
    required this.id,
    required this.title,
    required this.category,
    required this.when,
    required this.place,
    required this.limit,
    List<String> names = const [],
    this.mode = false,
    this.note,
    this.favorite = false,
  }) : _names = List.unmodifiable(names);

  final String id;
  final String title;
  final EventCategory category;
  final DateTime when;
  final String place;
  final int limit;
  final List<String> _names;
  final bool mode;
  final String? note;
  final bool favorite;

  List<String> get names => List.unmodifiable(_names);

  int get count => _names.length;
  int get freePlaces => (limit - count).clamp(0, limit).toInt();
  bool get isFull => count >= limit;
  bool get isPast => when.isBefore(DateTime.now());
  bool contains(String name) => _names.contains(name);
  ({int taken, int free}) get places => (taken: count, free: freePlaces);

  Event copyWith({
    String? id,
    String? title,
    EventCategory? category,
    DateTime? when,
    String? place,
    int? limit,
    List<String>? names,
    bool? mode,
    String? note,
    bool clearNote = false,
    bool? favorite,
  }) => Event._fromList(
    id: id ?? this.id,
    title: title ?? this.title,
    category: category ?? this.category,
    when: when ?? this.when,
    place: place ?? this.place,
    limit: limit ?? this.limit,
    names: names ?? _names,
    mode: mode ?? this.mode,
    note: clearNote ? null : note ?? this.note,
    favorite: favorite ?? this.favorite,
  );
}
