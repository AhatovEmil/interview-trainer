import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/content/question_bank.dart';
import 'presentation/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Банк читается один раз до запуска интерфейса. Иначе каждый экран, которому
  // нужен вопрос, ждал бы разбора файла и обрастал состоянием загрузки.
  final QuestionBank bank = await QuestionBank.load();

  runApp(
    ProviderScope(
      overrides: <Override>[questionBankProvider.overrideWithValue(bank)],
      child: const InterviewTrainerApp(),
    ),
  );
}

class InterviewTrainerApp extends ConsumerWidget {
  const InterviewTrainerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Подготовка к собеседованию',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
    );
  }
}
