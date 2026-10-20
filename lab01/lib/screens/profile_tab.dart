import 'package:flutter/material.dart';

import '../models/event.dart';
import '../models/profile.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.events,
    required this.onSave,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final Profile profile;
  final List<Event> events;
  final ValueChanged<Profile> onSave;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late final TextEditingController _nameController;
  late final TextEditingController _groupController;
  final _formKey = GlobalKey<FormState>();

  static final RegExp _groupPattern = RegExp(r'^[A-Z]{2}-\d{4}$');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _groupController = TextEditingController(text: widget.profile.group);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  void _save() {
    final group = _groupController.text.trim();
    if (group.isNotEmpty && !_groupPattern.hasMatch(group)) return;
    widget.onSave(Profile(name: _nameController.text.trim(), group: group));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = _nameController.text.trim();
    final matchingEvents = name.isEmpty
        ? 0
        : widget.events.where((event) => event.contains(name)).length;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(
              Icons.person,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Your name'),
            textCapitalization: TextCapitalization.words,
            onChanged: (_) {
              setState(() {});
              _save();
            },
            onFieldSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _groupController,
            decoration: const InputDecoration(
              labelText: 'Group',
              hintText: 'e.g. SE-2301',
            ),
            textCapitalization: TextCapitalization.characters,
            validator: (value) {
              final group = value?.trim() ?? '';
              if (group.isEmpty || _groupPattern.hasMatch(group)) return null;
              return 'Use two capital letters, a hyphen and four digits';
            },
            onChanged: (_) => _save(),
            onFieldSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.event_available_outlined),
              title: Text('You are on $matchingEvents event lists'),
              subtitle: const Text(
                'This number is calculated from your registrations.',
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Appearance', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final option in const [
                (mode: ThemeMode.system, label: 'System'),
                (mode: ThemeMode.light, label: 'Light'),
                (mode: ThemeMode.dark, label: 'Dark'),
              ])
                ChoiceChip(
                  label: Text(option.label),
                  selected: widget.themeMode == option.mode,
                  onSelected: (_) => widget.onThemeModeChanged(option.mode),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
