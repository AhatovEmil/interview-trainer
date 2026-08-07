import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../common/async_button.dart';
import '../providers.dart';
import 'auth_form.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(sessionProvider.notifier).register(
            email: _email.text.trim(),
            password: _password.text,
          );
    } on Object catch (error) {
      if (mounted) {
        showError(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AuthForm(
          formKey: _formKey,
          title: 'Готовимся к собеседованию',
          subtitle:
              'План повторения по вашей специализации и грейду — на основе реальных пробелов, '
              'а не общего списка тем.',
          emailController: _email,
          passwordController: _password,
          primary: AsyncButton(
            label: 'Создать аккаунт',
            isLoading: _isLoading,
            onPressed: _submit,
          ),
          secondary: TextButton(
            onPressed: _isLoading ? null : () => context.go(AppRoutes.login),
            child: const Text('Уже есть аккаунт? Войти'),
          ),
        ),
      ),
    );
  }
}
