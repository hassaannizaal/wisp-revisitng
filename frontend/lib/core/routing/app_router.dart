import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../src/features/auth/data/firebase_auth_repository.dart';
import '../../src/features/auth/presentation/sign_in/sign_in_screen.dart';
import '../../src/features/auth/presentation/sign_up/sign_up_screen.dart';
import '../../src/features/auth/presentation/splash/splash_screen.dart';
import '../../src/features/auth/presentation/welcome/welcome_screen.dart';
import '../../src/features/home/presentation/home_screen.dart';
import '../../src/features/moods/presentation/mood_check_in_screen.dart';
import '../widgets/placeholder_screen.dart';
import '../theme/app_metrics.dart';
import 'app_routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authStateChangesProvider);
      final path = state.uri.path;

      // Session not restored yet: hold on the splash, never flash the welcome
      // screen at someone who is already signed in.
      if (auth.isLoading) return path == AppRoutes.splash ? null : AppRoutes.splash;

      final signedIn = auth.valueOrNull != null;
      if (path == AppRoutes.splash) return signedIn ? AppRoutes.home : AppRoutes.welcome;
      if (!signedIn && !AppRoutes.public.contains(path)) return AppRoutes.welcome;
      if (signedIn && AppRoutes.public.contains(path)) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: AppRoutes.welcome, pageBuilder: (context, state) => _fade(state, const WelcomeScreen())),
      GoRoute(path: AppRoutes.signIn, pageBuilder: (context, state) => _fade(state, const SignInScreen())),
      GoRoute(path: AppRoutes.signUp, pageBuilder: (context, state) => _fade(state, const SignUpScreen())),
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(path: AppRoutes.moodNew, builder: (context, state) => const MoodCheckInScreen()),
      GoRoute(
        path: AppRoutes.journalNew,
        builder: (context, state) => const PlaceholderScreen(title: 'Journal'),
      ),
    ],
  );
});

CustomTransitionPage<void> _fade(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: Motion.settle,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Motion.settleCurve),
        child: child,
      );
    },
  );
}

/// Re-runs the redirect whenever the auth state changes.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authStateChangesProvider, (_, _) => notifyListeners());
  }
}
