import 'package:flutter/material.dart';

/// Общая разметка входа и регистрации: поля одни и те же, различается текст.
class AuthForm extends StatelessWidget {
  const AuthForm({
    required this.formKey,
    required this.title,
    required this.subtitle,
    required this.emailController,
    required this.passwordController,
    required this.primary,
    required this.secondary,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final String title;
  final String subtitle;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final Widget primary;
  final Widget secondary;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
        children: <Widget>[
          Text(title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Почта'),
            validator: (String? value) {
              final String email = value?.trim() ?? '';
              if (email.isEmpty) {
                return 'Укажите почту';
              }
              if (!email.contains('@') || !email.contains('.')) {
                return 'Похоже, это не адрес почты';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(labelText: 'Пароль'),
            validator: (String? value) {
              if ((value ?? '').length < 8) {
                return 'Минимум 8 символов';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),
          primary,
          const SizedBox(height: 8),
          secondary,
        ],
      ),
    );
  }
}
