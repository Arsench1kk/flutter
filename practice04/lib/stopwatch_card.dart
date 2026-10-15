import 'dart:async';

import 'package:flutter/material.dart';

class StopwatchCard extends StatefulWidget {
  const StopwatchCard({super.key});

  @override
  State<StopwatchCard> createState() => _StopwatchCardState();
}

class _StopwatchCardState extends State<StopwatchCard> {
  int _seconds = 0;
  Timer? _timer;

  String get _formattedTime {
    final minutes = _seconds ~/ 60;
    final seconds = _seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _start() {
    if (_timer != null) return;
    setState(() {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _seconds++);
      });
    });
  }

  void _stop() {
    _timer?.cancel();
    setState(() => _timer = null);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _timer = null;
      _seconds = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Stopwatch', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            _formattedTime,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                onPressed: _timer == null ? _start : null,
                child: const Text('Start'),
              ),
              OutlinedButton(
                onPressed: _timer == null ? null : _stop,
                child: const Text('Stop'),
              ),
              FilledButton(onPressed: _reset, child: const Text('Reset')),
            ],
          ),
        ],
      ),
    ),
  );
}
