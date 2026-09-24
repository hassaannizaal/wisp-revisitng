import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wisp_mental_health/core/routing/app_router.dart';
import 'package:wisp_mental_health/core/routing/app_routes.dart';
import 'package:wisp_mental_health/core/theme/app_theme.dart';
import 'package:wisp_mental_health/features/auth/data/auth_repository.dart';
import 'package:wisp_mental_health/features/auth/domain/app_user.dart';

import '../../support/fake_auth_repository.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<(ProviderContainer, GoRouter)> pumpApp(WidgetTester tester, FakeAuthRepository auth) async {
    final container = ProviderContainer(overrides: [authRepositoryProvider.overrideWithValue(auth)]);
    addTearDown(container.dispose);
    final router = container.read(routerProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(theme: AppTheme.dark, routerConfig: router),
      ),
    );
    return (container, router);
  }

  String location(GoRouter router) => router.routerDelegate.currentConfiguration.uri.path;

  // The welcome orb animates forever, so pumpAndSettle would never return.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  testWidgets('holds on the splash until the session is known, then goes to welcome', (tester) async {
    final auth = FakeAuthRepository();
    final (_, router) = await pumpApp(tester, auth);
    expect(location(router), AppRoutes.splash);

    auth.emitInitial(null);
    await settle(tester);
    expect(location(router), AppRoutes.welcome);
  });

  testWidgets('a restored session skips the welcome screen entirely', (tester) async {
    const user = AppUser(uid: 'u1', email: 'me@example.com');
    final auth = FakeAuthRepository(user: user);
    final (_, router) = await pumpApp(tester, auth);

    auth.emitInitial(user);
    await settle(tester);
    expect(location(router), AppRoutes.home);
  });

  testWidgets('signing in from the sign-in screen lands on home', (tester) async {
    final auth = FakeAuthRepository();
    final (_, router) = await pumpApp(tester, auth);
    auth.emitInitial(null);
    await settle(tester);

    router.go(AppRoutes.signIn);
    await settle(tester);
    expect(location(router), AppRoutes.signIn);

    await auth.signInWithEmailAndPassword('me@example.com', 'secret1');
    await settle(tester);
    expect(location(router), AppRoutes.home);
  });

  testWidgets('signing out returns to welcome', (tester) async {
    const user = AppUser(uid: 'u1', email: 'me@example.com');
    final auth = FakeAuthRepository(user: user);
    final (_, router) = await pumpApp(tester, auth);
    auth.emitInitial(user);
    await settle(tester);
    expect(location(router), AppRoutes.home);

    await auth.signOut();
    await settle(tester);
    expect(location(router), AppRoutes.welcome);
  });
}
