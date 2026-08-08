import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

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
    final AppColors colors = context.colors;

    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
        children: <Widget>[
          // Знак приложения: одна фигура, никакой иллюстрации. Экран входа
          // должен выглядеть как вход в инструмент, а не как обложка курса.
          // Align обязателен: прямой потомок ListView иначе растянется по ширине.
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.inkPrimary,
                borderRadius: BorderRadius.circular(AppTypography.radiusMedium),
              ),
              child: Icon(Icons.bolt_rounded, color: colors.surface, size: 26),
            ),
          ),
          const SizedBox(height: 28),
          Text(title, style: theme.textTheme.displaySmall),
          const SizedBox(height: 10),
          Text(subtitle, style: theme.textTheme.bodyLarge?.copyWith(color: colors.inkSecondary)),
          const SizedBox(height: 36),
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
          const SizedBox(height: 12),
          Center(child: secondary),
        ],
      ),
    );
  }
}
