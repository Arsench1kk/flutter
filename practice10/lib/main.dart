import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'countdown_screen.dart';
import 'students_future_screen.dart';
import 'students_screen.dart';

void main() => runApp(const AsyncPracticeApp());

class AsyncPracticeApp extends StatelessWidget {
  const AsyncPracticeApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'The Data Arrives Later',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      useMaterial3: true,
    ),
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
  );
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final FakeApi _studentsApi = FakeApi();

  Future<void> _open(BuildContext context, Widget screen) async {
    await Navigator.of(context)
        .push<void>(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('The Data Arrives Later')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.hourglass_top_rounded, size: 72),
              const SizedBox(height: 12),
              Text(
                'Async patterns',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () async =>
                    _open(context, StudentsScreen(api: _studentsApi)),
                icon: const Icon(Icons.tune),
                label: const Text('By hand'),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () async =>
                    _open(context, const StudentsFutureScreen()),
                icon: const Icon(Icons.auto_awesome),
                label: const Text('FutureBuilder'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async => _open(context, const CountdownScreen()),
                icon: const Icon(Icons.timer_outlined),
                label: const Text('Countdown'),
              ),
              const SizedBox(height: 24),
              const Text(
                'A fake API takes two seconds. It fails every third request.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
