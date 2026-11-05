import 'dart:async';

import 'package:flutter/material.dart';

import 'api/countdown.dart';

enum CountdownMode { streamBuilder, subscription }

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  CountdownMode _mode = CountdownMode.subscription;
  int _left = 10;
  StreamSubscription<int>? _sub;

  @override
  void initState() {
    super.initState();
    _listenToCountdown();
  }

  void _listenToCountdown() {
    _left = 10;
    _sub = countdown(10).listen((value) {
      if (!mounted) return;
      setState(() => _left = value);
    });
  }

  void _selectMode(CountdownMode mode) {
    if (_mode == mode) return;
    if (_mode == CountdownMode.subscription) {
      unawaited(_sub?.cancel() ?? Future<void>.value());
      _sub = null;
    }
    setState(() => _mode = mode);
    if (mode == CountdownMode.subscription) _listenToCountdown();
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel() ?? Future<void>.value());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Countdown')),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SegmentedButton<CountdownMode>(
            segments: const [
              ButtonSegment(
                value: CountdownMode.streamBuilder,
                label: Text('StreamBuilder'),
              ),
              ButtonSegment(
                value: CountdownMode.subscription,
                label: Text('listen + cancel'),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (selection) => _selectMode(selection.first),
          ),
          const SizedBox(height: 40),
          if (_mode == CountdownMode.streamBuilder)
            const StreamCountdownView()
          else
            Text('$_left', style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: 12),
          Text(
            _mode == CountdownMode.streamBuilder
                ? 'StreamBuilder manages its subscription.'
                : 'This screen cancels its subscription in dispose().',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class StreamCountdownView extends StatefulWidget {
  const StreamCountdownView({super.key});

  @override
  State<StreamCountdownView> createState() => _StreamCountdownViewState();
}

class _StreamCountdownViewState extends State<StreamCountdownView> {
  late final Stream<int> _stream = countdown(10);

  @override
  Widget build(BuildContext context) => StreamBuilder<int>(
    stream: _stream,
    builder: (context, snapshot) => Text(
      '${snapshot.data ?? 10}',
      style: Theme.of(context).textTheme.displayLarge,
    ),
  );
}
