import 'package:flutter/material.dart';

import '../models/event.dart';
import '../routes.dart';

class EventFormScreen extends StatefulWidget {
  const EventFormScreen({super.key, required this.args});

  final FormRouteArgs args;

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _placeController;
  late final TextEditingController _limitController;
  late final TextEditingController _noteController;
  late final FocusNode _titleFocus;
  late final FocusNode _placeFocus;
  late final FocusNode _limitFocus;
  late final FocusNode _noteFocus;
  late Event _draft;
  late EventCategory _category;
  late bool _online;
  DateTime? _date;
  TimeOfDay? _time;
  bool _saving = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  Event? get _original => widget.args.event;

  @override
  void initState() {
    super.initState();
    final original = _original;
    _draft = original ?? Event.empty();
    _category = _draft.category;
    _online = _draft.mode;
    _titleController = TextEditingController(text: _draft.title);
    _placeController = TextEditingController(text: _draft.place);
    _limitController = TextEditingController(text: '${_draft.limit}');
    _noteController = TextEditingController(text: _draft.note ?? '');
    _titleFocus = FocusNode();
    _placeFocus = FocusNode();
    _limitFocus = FocusNode();
    _noteFocus = FocusNode();
    if (original != null) {
      _date = original.when;
      _time = TimeOfDay.fromDateTime(original.when);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    _limitController.dispose();
    _noteController.dispose();
    _titleFocus.dispose();
    _placeFocus.dispose();
    _limitFocus.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  bool get _dirty {
    final original = _original;
    if (original == null) {
      return _titleController.text.isNotEmpty ||
          _placeController.text.isNotEmpty ||
          _limitController.text != '${_draft.limit}' ||
          _noteController.text.isNotEmpty ||
          _date != null ||
          _time != null ||
          _category != _draft.category ||
          _online != _draft.mode;
    }
    final when = _combineDateTime();
    return _titleController.text != original.title ||
        _placeController.text != original.place ||
        _limitController.text != '${original.limit}' ||
        _noteController.text != (original.note ?? '') ||
        _category != original.category ||
        _online != original.mode ||
        when != original.when;
  }

  DateTime _combineDateTime() {
    final date = _date ?? _draft.when;
    final time = _time ?? TimeOfDay.fromDateTime(_draft.when);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _date ?? _draft.when;
    final value = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
    );
    if (value == null || !mounted) return;
    setState(() => _date = value);
  }

  Future<void> _pickTime() async {
    final value = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.fromDateTime(_draft.when),
    );
    if (value == null || !mounted) return;
    setState(() => _time = value);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    final limit = int.parse(_limitController.text.trim());
    final note = _noteController.text.trim();
    final saved = _draft.copyWith(
      title: _titleController.text.trim(),
      category: _category,
      when: _combineDateTime(),
      place: _placeController.text.trim(),
      limit: limit,
      mode: _online,
      note: note.isEmpty ? null : note,
      clearNote: note.isEmpty,
    );
    Navigator.pop(context, saved);
  }

  Future<void> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your edits have not been saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.pop(context);
  }

  String? _validateTitle(String? value) {
    final title = value?.trim() ?? '';
    if (title.isEmpty) return 'Title is required';
    if (title.length < 3) return 'Enter at least 3 characters';
    if (title.length > 60) return 'Use at most 60 characters';
    return null;
  }

  String? _validateLimit(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null) return 'Enter a whole number';
    if (parsed < 1 || parsed > 500) return 'Limit must be from 1 to 500';
    if (parsed < _draft.count) {
      return 'Limit cannot be below the ${_draft.count} current attendees';
    }
    return null;
  }

  String? _validatePlace(String? value) {
    final place = value?.trim() ?? '';
    if (place.isEmpty) return 'Place is required';
    if (_online && !place.contains('://')) {
      return 'Enter an online link containing ://';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => PopScope<Event>(
    canPop: !_dirty || _saving,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && !_saving) _confirmDiscard();
    },
    child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_original == null ? 'New event' : 'Edit event'),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth >= 700 ? 64 : 20,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    focusNode: _titleFocus,
                    decoration: const InputDecoration(labelText: 'Title'),
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: 60,
                    textInputAction: TextInputAction.next,
                    validator: _validateTitle,
                    onFieldSubmitted: (_) => _placeFocus.requestFocus(),
                  ),
                  TextFormField(
                    controller: _placeController,
                    focusNode: _placeFocus,
                    decoration: const InputDecoration(labelText: 'Place'),
                    textInputAction: TextInputAction.next,
                    validator: _validatePlace,
                    onFieldSubmitted: (_) => _limitFocus.requestFocus(),
                  ),
                  TextFormField(
                    controller: _limitController,
                    focusNode: _limitFocus,
                    decoration: const InputDecoration(
                      labelText: 'Places limit',
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: _validateLimit,
                    onFieldSubmitted: (_) => _noteFocus.requestFocus(),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<EventCategory>(
                    initialValue: _category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: [
                      for (final category in EventCategory.values)
                        DropdownMenuItem(
                          value: category,
                          child: Text(category.label),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _category = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Online event'),
                    value: _online,
                    onChanged: (value) => setState(() => _online = value),
                  ),
                  TextFormField(
                    controller: _noteController,
                    focusNode: _noteFocus,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                    ),
                    maxLines: 3,
                    textInputAction: TextInputAction.newline,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_month),
                        label: Text(
                          _date == null
                              ? 'Choose date'
                              : '${_date!.day}/${_date!.month}/${_date!.year}',
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _pickTime,
                        icon: const Icon(Icons.schedule),
                        label: Text(_time?.format(context) ?? 'Choose time'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_saving ? 'Saving…' : 'Save event'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
