import 'package:flutter/material.dart';

import '../models/event.dart';
import '../utils/format.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onToggleFavorite,
  });

  final Event event;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  String? get _capacityBadge {
    if (event.isFull) return 'FULL';
    if (event.freePlaces <= 5) return '${event.freePlaces} left';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (taken: taken, free: free) = event.places;
    final badge = _capacityBadge;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    backgroundColor: event.category.colorFrom(colorScheme),
                    foregroundColor: event.category.foregroundFrom(colorScheme),
                    child: Icon(event.category.icon),
                  ),
                  if (badge != null)
                    Positioned(
                      right: -14,
                      bottom: -8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: event.isFull
                              ? colorScheme.error
                              : colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              color: event.isFull
                                  ? colorScheme.onError
                                  : colorScheme.onTertiary,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatEventDate(event.when)} · ${event.place}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    Text(
                      '$taken / ${taken + free} places',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: event.favorite
                    ? 'Remove from favourites'
                    : 'Add to favourites',
                onPressed: onToggleFavorite,
                icon: Icon(
                  event.favorite ? Icons.favorite : Icons.favorite_border,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
