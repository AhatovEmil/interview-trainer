import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/home/home_screen.dart';
import '../../presentation/onboarding/onboarding_screen.dart';
import '../../presentation/own/own_questions_screen.dart';
import '../../presentation/plan/plan_screen.dart';
import '../../presentation/practice/practice_screen.dart';
import '../../presentation/profile/profile_screen.dart';
import '../../presentation/questions/question_list_screen.dart';
import '../../presentation/providers.dart';
import '../../presentation/splash_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';

  /// Точка входа после онбординга: обзор, выбор специализации, переходы.
  static const String home = '/home';
  static const String practice = '/practice';
  static const String questions = '/questions';
  static const String profile = '/profile';
  static const String plan = '/plan';
  static const String ownQuestions = '/own-questions';
}

final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final _RouterRefresh refresh = _RouterRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        builder: (BuildContext context, GoRouterState state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (BuildContext context, GoRouterState state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (BuildContext context, GoRouterState state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.practice,
        builder: (BuildContext context, GoRouterState state) => const PracticeScreen(),
      ),
      GoRoute(
        path: AppRoutes.questions,
        builder: (BuildContext context, GoRouterState state) => const QuestionListScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: ':id',
            builder: (BuildContext context, GoRouterState state) =>
                PracticeScreen(questionId: state.pathParameters['id']),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.plan,
        builder: (BuildContext context, GoRouterState state) => const PlanScreen(),
      ),
      GoRoute(
        path: AppRoutes.ownQuestions,
        builder: (BuildContext context, GoRouterState state) => const OwnQuestionsScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (BuildContext context, GoRouterState state) => const ProfileScreen(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final SessionStatus status = ref.read(sessionProvider).status;
      final String location = state.matchedLocation;

      switch (status) {
        case SessionStatus.unknown:
          // Профиль ещё читается из базы: держим заставку, чтобы не мигнуть
          // онбордингом человеку, который его давно прошёл.
          return location == AppRoutes.splash ? null : AppRoutes.splash;
        case SessionStatus.needsOnboarding:
          return location == AppRoutes.onboarding ? null : AppRoutes.onboarding;
        case SessionStatus.ready:
          if (location == AppRoutes.splash || location == AppRoutes.onboarding) {
            return AppRoutes.home;
          }
          return null;
      }
    },
  );
});

/// Мост между Riverpod и go_router: перерисовать маршруты при смене сессии.
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    _subscription = ref.listen<SessionState>(
      sessionProvider,
      (SessionState? previous, SessionState next) {
        if (previous?.status != next.status) {
          notifyListeners();
        }
      },
    );
  }

  late final ProviderSubscription<SessionState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
