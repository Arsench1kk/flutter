import 'dart:async';

import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/student_list.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key, required this.api});

  final FakeApi api;

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Student>? _students;
  Object? _error;
  late FakeApi _api;
  bool _saving = false;
  bool _emptyMode = false;

  @override
  void initState() {
    super.initState();
    _api = widget.api;
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _students = null;
      _error = null;
    });
    try {
      final list = await _api.fetchStudents();
      if (!mounted) return;
      setState(() => _students = list);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    }
  }

  void _toggleEmptyMode() {
    setState(() {
      _emptyMode = !_emptyMode;
      _api = _emptyMode ? FakeApi(empty: true) : widget.api;
    });
    unawaited(_load());
  }

  Future<void> _save(BuildContext context) async {
    final count = _students!.length;
    setState(() => _saving = true);
    try {
      await _api.save(count);
      if (!context.mounted) return;
      Navigator.pop(context);
    } on StateError catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget body;
    if (_error != null) {
      body = ErrorView(onRetry: _load);
    } else if (_students == null) {
      body = const LoadingView();
    } else if (_students!.isEmpty) {
      body = const EmptyView();
    } else {
      body = StudentList(students: _students!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('By hand'),
        actions: [
          IconButton(
            tooltip: _emptyMode ? 'Use sample data' : 'Show empty response',
            onPressed: _toggleEmptyMode,
            icon: Icon(_emptyMode ? Icons.people : Icons.people_outline),
          ),
          IconButton(
            tooltip: 'Retry loading students',
            onPressed: () => unawaited(_load()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: body,
      floatingActionButton: _students == null || _students!.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _saving ? null : () => _save(context),
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? 'Saving' : 'Save'),
            ),
    );
  }
}
