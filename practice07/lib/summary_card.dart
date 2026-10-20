import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.name,
    required this.email,
    required this.group,
    required this.birthDate,
  });

  final String name;
  final String email;
  final String group;
  final String birthDate;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tiles = [
            ListTile(leading: const Icon(Icons.person), title: Text(name)),
            ListTile(leading: const Icon(Icons.email), title: Text(email)),
            ListTile(leading: const Icon(Icons.groups), title: Text(group)),
            ListTile(leading: const Icon(Icons.cake), title: Text(birthDate)),
          ];

          if (constraints.maxWidth >= 600) {
            return GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 4,
              children: tiles,
            );
          }
          return Column(children: tiles);
        },
      ),
    ),
  );
}
