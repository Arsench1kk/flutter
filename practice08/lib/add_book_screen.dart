import 'package:flutter/material.dart';

import 'models/book.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _pages = TextEditingController();
  final _year = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _pages.dispose();
    _year.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final book = Book(
      title: _title.text.trim(),
      author: _author.text.trim(),
      pages: int.parse(_pages.text),
      year: int.tryParse(_year.text.trim()),
    );
    Navigator.of(context).pop(book);
  }

  void _dismissKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Add a book')),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _title,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) => (value ?? '').trim().length < 2
                        ? 'Title must be at least 2 characters'
                        : null,
                    onTapOutside: (_) => _dismissKeyboard(),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _author,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Author'),
                    validator: (value) =>
                        (value ?? '').trim().isEmpty ? 'Enter an author' : null,
                    onTapOutside: (_) => _dismissKeyboard(),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pages,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Pages'),
                    validator: (value) {
                      final pages = int.tryParse(value ?? '');
                      if (pages == null || pages <= 0) {
                        return 'A whole number above 0';
                      }
                      return null;
                    },
                    onTapOutside: (_) => _dismissKeyboard(),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _year,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Year (optional)',
                    ),
                    validator: (value) {
                      final input = (value ?? '').trim();
                      if (input.isEmpty) return null;
                      final year = int.tryParse(input);
                      if (year == null ||
                          year < 1450 ||
                          year > DateTime.now().year) {
                        return 'Enter a year from 1450 to ${DateTime.now().year}';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _save(),
                    onTapOutside: (_) => _dismissKeyboard(),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(onPressed: _save, child: const Text('Save')),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
