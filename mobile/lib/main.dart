import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/config/app_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Раньше любого запроса: релизная сборка без боевого адреса или с http
  // должна падать здесь, а не молча уехать в магазин.
  AppConfig.assertConfigured();
  runApp(const ProviderScope(child: InterviewTrainerApp()));
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
