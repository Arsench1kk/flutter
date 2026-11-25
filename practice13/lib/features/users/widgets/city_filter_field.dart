import 'package:flutter/material.dart';

class CityFilterField extends StatelessWidget {
  const CityFilterField({
    super.key,
    required this.cities,
    required this.selectedCity,
    required this.onChanged,
  });

  final List<String> cities;
  final String? selectedCity;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    child: DropdownButtonFormField<String>(
      initialValue: selectedCity ?? '',
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'City filter'),
      items: [
        const DropdownMenuItem(value: '', child: Text('All cities')),
        for (final city in cities)
          DropdownMenuItem(value: city, child: Text(city)),
      ],
      onChanged: (value) => onChanged(value == '' ? null : value),
    ),
  );
}
