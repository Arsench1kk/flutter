import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api/api_exception.dart';
import 'features/users/user.dart';
import 'users_model.dart';

class NewUserScreen extends StatefulWidget {
  const NewUserScreen({super.key});

  @override
  State<NewUserScreen> createState() => _NewUserScreenState();
}

class _NewUserScreenState extends State<NewUserScreen> {
  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  bool _saving = false;

  String? _requiredValue(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

  String? _validEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Required';
    return _emailPattern.hasMatch(text) ? null : 'Enter a valid email';
  }

  Future<void> _save() async {
    if (_saving || _form.currentState?.validate() != true) return;
    final model = context.read<UsersModel>();
    final draft = User.draft(
      name: _name.text.trim(),
      username: _username.text.trim(),
      email: _email.text.trim(),
    );

    setState(() => _saving = true);
    try {
      await model.create(draft);
      if (!mounted) return;
      Navigator.of(context).pop();
    } on ApiException catch (error) {
      if (!mounted) return;
      final message = switch (error) {
        NoConnectionException() => 'You appear to be offline. Try again.',
        ServerException() => 'The server could not save this user.',
        BadResponseException() => 'The server returned an unexpected response.',
        UnauthorizedException() => 'This request is not authorized.',
        NotFoundException() => 'The save endpoint was not found.',
      };
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('New user')),
    body: Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextFormField(
            controller: _name,
            enabled: !_saving,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: _requiredValue,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _username,
            enabled: !_saving,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Username'),
            validator: _requiredValue,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _email,
            enabled: !_saving,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: _validEmail,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
    ),
  );
}
