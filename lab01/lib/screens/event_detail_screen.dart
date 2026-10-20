import 'dart:async';

import 'package:flutter/material.dart';

import '../models/countdown.dart';
import '../models/event.dart';
import '../routes.dart';
import '../utils/format.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key, required this.args});

  final DetailRouteArgs args;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late Event _event;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _event = widget.args.event;
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _edit() async {
    final result = await Navigator.pushNamed<Event>(
      context,
      Routes.form,
      arguments: FormRouteArgs(event: _event, profile: widget.args.profile),
    );
    if (result == null || !mounted) return;
    setState(() => _event = result);
    widget.args.onEventChanged(result);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this event?'),
        content: const Text(
          'This event and its registrations will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    widget.args.onDelete(_event.id);
    Navigator.pop(context);
  }

  Future<void> _toggleRegistration() async {
    final name = widget.args.profile.name.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add your name in Profile before registering.'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: () => widget.args.onSwitchTab(2),
          ),
        ),
      );
      return;
    }
    final joining = !_event.contains(name);
    if (joining && _event.isFull) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(joining ? 'Register for event?' : 'Cancel registration?'),
        content: Text(
          joining
              ? 'Your name will be added to the attendee list.'
              : 'Your name will be removed from the attendee list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(joining ? 'Register' : 'Unregister'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final names = _event.names;
    final changed = _event.copyWith(
      names: joining
          ? [...names, name]
          : names.where((attendee) => attendee != name).toList(),
    );
    setState(() => _event = changed);
    widget.args.onEventChanged(changed);
  }

  String _countdownLabel() => switch (Countdown.forEvent(_event.when)) {
    Upcoming(:final remaining) => 'Starts in ${formatCountdown(remaining)}',
    Started(:final elapsed) => 'Started ${formatCountdown(elapsed)} ago',
    Ended() => 'Event ended',
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final places = _event.places;
    final isRegistered = _event.contains(widget.args.profile.name.trim());
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Event details'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (choice) {
                if (choice == 'edit') _edit();
                if (choice == 'delete') _delete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit event')),
                PopupMenuItem(value: 'delete', child: Text('Delete event')),
              ],
            ),
          ],
          bottom: TabBar(
            tabs: [
              const Tab(text: 'About'),
              Tab(text: 'Attendees (${_event.count})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                Stack(
                  children: [
                    Image.asset(
                      'assets/images/campus_event_header.png',
                      width: double.infinity,
                      height: 210,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Chip(
                        avatar: Icon(
                          _event.category.icon,
                          color: _event.category.colorFrom(colors),
                        ),
                        label: Text(_event.category.label),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Chip(label: Text(_countdownLabel())),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _event.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 18),
                      _FactLine(
                        icon: Icons.calendar_month,
                        label: formatEventDate(_event.when),
                      ),
                      _FactLine(
                        icon: Icons.place_outlined,
                        label: _event.place,
                      ),
                      _FactLine(
                        icon: Icons.people_outline,
                        label:
                            '${places.taken} registered · ${places.free} places left',
                      ),
                      if (_event.mode)
                        const _FactLine(
                          icon: Icons.link,
                          label: 'Online event',
                        ),
                      if (_event.note case final note?) ...[
                        const SizedBox(height: 12),
                        Text(note),
                      ],
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: _event.isFull && !isRegistered
                            ? null
                            : _toggleRegistration,
                        icon: Icon(
                          isRegistered
                              ? Icons.event_busy
                              : Icons.event_available,
                        ),
                        label: Text(
                          isRegistered ? 'Cancel registration' : 'Register',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_event.names.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No attendees yet.'),
                    ),
                  ),
                for (final attendee in _event.names)
                  ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        attendee.isEmpty ? '?' : attendee[0].toUpperCase(),
                      ),
                    ),
                    title: Text(attendee),
                    subtitle: attendee == widget.args.profile.name
                        ? const Text('You')
                        : null,
                    tileColor: attendee == widget.args.profile.name
                        ? colors.primaryContainer
                        : null,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FactLine extends StatelessWidget {
  const _FactLine({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
      ],
    ),
  );
}
