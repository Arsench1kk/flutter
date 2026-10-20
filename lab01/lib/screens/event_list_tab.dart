import 'package:flutter/material.dart';

import '../models/event.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';
import '../widgets/event_card.dart';

class EventListTab extends StatefulWidget {
  const EventListTab({
    super.key,
    required this.events,
    required this.onOpen,
    required this.onCreate,
    required this.onToggleFavorite,
  });

  final List<Event> events;
  final ValueChanged<Event> onOpen;
  final VoidCallback onCreate;
  final ValueChanged<Event> onToggleFavorite;

  @override
  State<EventListTab> createState() => _EventListTabState();
}

class _EventListTabState extends State<EventListTab> {
  final _searchController = TextEditingController();
  EventCategory? _category;
  bool _showPast = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Event> get _visibleEvents {
    final query = _searchController.text.trim().toLowerCase();
    final visible = widget.events.where((event) {
      final matchesText =
          query.isEmpty ||
          event.title.toLowerCase().contains(query) ||
          event.place.toLowerCase().contains(query);
      final matchesCategory = _category == null || event.category == _category;
      final matchesDate = _showPast || !event.isPast;
      return matchesText && matchesCategory && matchesDate;
    }).toList();
    visible.sort((first, second) {
      if (first.isPast != second.isPast) return first.isPast ? 1 : -1;
      return first.when.compareTo(second.when);
    });
    return visible;
  }

  @override
  Widget build(BuildContext context) {
    final events = _visibleEvents;
    final hasAnyEvents = widget.events.any((event) => !event.isPast);
    final emptyMessage = widget.events.isEmpty
        ? 'There are no events yet.'
        : !hasAnyEvents && !_showPast
        ? 'There are no upcoming events.'
        : 'No events match these filters.';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Search events',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.clear),
                    ),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _category == null,
                  onSelected: (_) => setState(() => _category = null),
                ),
                for (final category in EventCategory.values)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      avatar: Icon(category.icon),
                      label: Text(category.label),
                      selected: _category == category,
                      onSelected: (_) => setState(() => _category = category),
                    ),
                  ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: FilterChip(
              label: const Text('Include past events'),
              selected: _showPast,
              onSelected: (value) => setState(() => _showPast = value),
            ),
          ),
          Expanded(
            child: events.isEmpty
                ? EmptyState(
                    icon: Icons.event_busy_outlined,
                    message: emptyMessage,
                    buttonLabel: widget.events.isEmpty ? 'Add an event' : null,
                    onPressed: widget.events.isEmpty ? widget.onCreate : null,
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth >= 600) {
                        final columns = (constraints.maxWidth / 360).ceil();
                        return GridView.builder(
                          itemCount: events.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1.8,
                              ),
                          itemBuilder: (context, index) {
                            final event = events[index];
                            return EventCard(
                              event: event,
                              onTap: () => widget.onOpen(event),
                              onToggleFavorite: () =>
                                  widget.onToggleFavorite(event),
                            );
                          },
                        );
                      }
                      return ListView.separated(
                        itemCount: events.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 4),
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return EventCard(
                            event: event,
                            onTap: () => widget.onOpen(event),
                            onToggleFavorite: () =>
                                widget.onToggleFavorite(event),
                          );
                        },
                      );
                    },
                  ),
          ),
          if (events.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${events.length} events · next: ${formatEventDate(events.first.when)}',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
        ],
      ),
    );
  }
}
