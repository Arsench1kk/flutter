import 'package:flutter/material.dart';

import '../models/event.dart';
import '../widgets/empty_state.dart';
import '../widgets/event_card.dart';

class FavoritesTab extends StatelessWidget {
  const FavoritesTab({
    super.key,
    required this.events,
    required this.onOpen,
    required this.onToggleFavorite,
  });

  final List<Event> events;
  final ValueChanged<Event> onOpen;
  final ValueChanged<Event> onToggleFavorite;

  @override
  Widget build(BuildContext context) => events.isEmpty
      ? const EmptyState(
          icon: Icons.favorite_border,
          message: 'Your favourite events will appear here.',
        )
      : ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          separatorBuilder: (_, _) => const SizedBox(height: 4),
          itemBuilder: (context, index) {
            final event = events[index];
            return EventCard(
              event: event,
              onTap: () => onOpen(event),
              onToggleFavorite: () => onToggleFavorite(event),
            );
          },
        );
}
