import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/student_list.dart';

class StudentsFutureScreen extends StatefulWidget {
  const StudentsFutureScreen({super.key});

  @override
  State<StudentsFutureScreen> createState() => _StudentsFutureScreenState();
}

class _StudentsFutureScreenState extends State<StudentsFutureScreen> {
  final FakeApi _api = FakeApi();
  late Future<List<Student>> _future;
  bool _compact = false;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchStudents();
  }

  // Retry is the only place besides initState that creates a new Future.
  void _retry() {
    setState(() => _future = _api.fetchStudents());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('FutureBuilder'),
      actions: [
        const Text('Compact'),
        Switch(
          value: _compact,
          onChanged: (value) => setState(() => _compact = value),
        ),
        const SizedBox(width: 12),
      ],
    ),
    body: FutureBuilder<List<Student>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) return ErrorView(onRetry: _retry);
        if (snapshot.connectionState != ConnectionState.done) {
          return const LoadingView();
        }
        final list = snapshot.data ?? const <Student>[];
        if (list.isEmpty) return const EmptyView();
        return StudentList(students: list, compact: _compact);
      },
    ),
  );
}
