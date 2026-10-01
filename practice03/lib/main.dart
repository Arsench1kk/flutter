import 'package:flutter/material.dart';

import 'data.dart';
import 'info_row.dart';
import 'profile_header.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('My profile')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ProfileHeader(name: myName, university: myUniversity),
              const SizedBox(height: 32),
              ...[
                for (final fact in facts)
                  InfoRow(label: fact.label, value: fact.value),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
