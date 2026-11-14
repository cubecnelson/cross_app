import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/ontherack_constants.dart';
import '../../../providers/catalog_provider.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

class LocalRegisterScreen extends ConsumerStatefulWidget {
  const LocalRegisterScreen({super.key});

  @override
  ConsumerState<LocalRegisterScreen> createState() =>
      _LocalRegisterScreenState();
}

class _LocalRegisterScreenState extends ConsumerState<LocalRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Username is required';
    if (!OnTheRackConstants.usernamePattern.hasMatch(v)) {
      return 'Username must be 3–24 letters, numbers, or underscores';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < OnTheRackConstants.minPasswordLength) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(sessionProvider.notifier).register(
            username: _username.text,
            password: _password.text,
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create an account')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Accounts are stored on this device in this first version. Use a unique password you do not reuse elsewhere.',
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _username,
              label: 'Username',
              hint: '3–24 letters, numbers, or underscores',
              validator: _validateUsername,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _password,
              label: 'Password',
              obscureText: _obscure,
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
              ),
              validator: _validatePassword,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _confirm,
              label: 'Confirm password',
              obscureText: _obscure,
              validator: (v) =>
                  v != _password.text ? 'Passwords do not match' : null,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Create account',
              isLoading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
