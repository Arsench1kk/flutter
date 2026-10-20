import 'package:flutter/material.dart';

import 'summary_card.dart';

void main() => runApp(const MyApp());

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Sign up',
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
    home: const SignUpScreen(),
  );
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthDateController = TextEditingController();
  final _emailFocus = FocusNode();

  String? _group;
  DateTime? _birth;
  bool _agreed = false;
  bool _done = false;
  int _passwordLength = 0;

  @override
  void dispose() {
    for (final controller in [
      _name,
      _email,
      _password,
      _confirm,
      _birthDateController,
    ]) {
      controller.dispose();
    }
    _emailFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_agreed) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _done = true);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Account created')));
  }

  Future<void> _pickBirthDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (selected == null) return;
    if (!mounted) return;

    setState(() {
      _birth = selected;
      _birthDateController.text =
          '${selected.day.toString().padLeft(2, '0')}.'
          '${selected.month.toString().padLeft(2, '0')}.'
          '${selected.year}';
    });
  }

  void _startOver() {
    setState(() {
      _name.clear();
      _email.clear();
      _password.clear();
      _confirm.clear();
      _birthDateController.clear();
      _group = null;
      _birth = null;
      _agreed = false;
      _passwordLength = 0;
      _done = false;
    });
  }

  void _dismissKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign up')),
    body: _done ? _buildSummary() : _buildForm(),
  );

  Widget _buildForm() => SafeArea(
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
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) => (value ?? '').trim().length < 2
                      ? 'Name must be at least 2 characters'
                      : null,
                  onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                  onTapOutside: (_) => _dismissKeyboard(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'name@kbtu.kz',
                  ),
                  validator: (value) {
                    final email = (value ?? '').trim();
                    final at = email.indexOf('@');
                    return at < 1 || email.indexOf('.', at) < at + 2
                        ? 'Enter a valid email address'
                        : null;
                  },
                  onTapOutside: (_) => _dismissKeyboard(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    helperText: 'At least 8 characters',
                  ),
                  validator: (value) => (value ?? '').length < 8
                      ? 'Password must be at least 8 characters'
                      : null,
                  onChanged: (value) =>
                      setState(() => _passwordLength = value.length),
                  onTapOutside: (_) => _dismissKeyboard(),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('$_passwordLength of 8'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirm,
                  obscureText: true,
                  autocorrect: false,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Confirm password',
                  ),
                  validator: (value) =>
                      value != _password.text ? 'Passwords do not match' : null,
                  onFieldSubmitted: (_) => _submit(),
                  onTapOutside: (_) => _dismissKeyboard(),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _group,
                  decoration: const InputDecoration(labelText: 'Group'),
                  items: [
                    for (final group in groups)
                      DropdownMenuItem(value: group, child: Text(group)),
                  ],
                  onChanged: (value) => setState(() => _group = value),
                  validator: (value) => value == null ? 'Choose a group' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _birthDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Date of birth',
                    suffixIcon: Icon(Icons.calendar_month),
                  ),
                  validator: (_) =>
                      _birth == null ? 'Choose your date of birth' : null,
                  onTap: _pickBirthDate,
                  onTapOutside: (_) => _dismissKeyboard(),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('I agree to the rules'),
                  value: _agreed,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (value) =>
                      setState(() => _agreed = value ?? false),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _agreed ? _submit : null,
                  child: const Text('Sign up'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildSummary() => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SummaryCard(
                name: _name.text.trim(),
                email: _email.text.trim(),
                group: _group ?? '',
                birthDate: _birthDateController.text,
              ),
              TextButton(
                onPressed: _startOver,
                child: const Text('Start over'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
