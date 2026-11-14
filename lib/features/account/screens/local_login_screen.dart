import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/ontherack_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/catalog_provider.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import 'local_register_screen.dart';

class LocalLoginScreen extends ConsumerStatefulWidget {
  const LocalLoginScreen({super.key});

  @override
  ConsumerState<LocalLoginScreen> createState() => _LocalLoginScreenState();
}

class _LocalLoginScreenState extends ConsumerState<LocalLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(sessionProvider.notifier).signIn(
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
      appBar: AppBar(title: const Text('Log in')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              OnTheRackConstants.appName,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'You can browse gyms and reviews without an account. Log in to add a gym, add equipment, or write a review.',
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _username,
              label: 'Username',
              validator: (v) => Validators.validateRequired(v, 'Username'),
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
              validator: (v) => Validators.validateRequired(v, 'Password'),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Log in',
              isLoading: _loading,
              onPressed: _submit,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                final nav = Navigator.of(context);
                final created = await nav.push<bool>(
                  MaterialPageRoute(
                    builder: (_) => const LocalRegisterScreen(),
                  ),
                );
                if (created == true && mounted) {
                  nav.pop(true);
                }
              },
              child: const Text('Create an account'),
            ),
            const SizedBox(height: 16),
            Text(
              'Sample accounts (password: ${OnTheRackConstants.demoPassword}): mei, alex, kwok. These are labelled sample data accounts.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
