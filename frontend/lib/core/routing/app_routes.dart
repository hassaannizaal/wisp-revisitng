/// Route paths, as named in docs/screens/00-overview.md.
class AppRoutes {
  const AppRoutes._();

  static const splash = '/splash';
  static const welcome = '/welcome';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const onboardingMode = '/onboarding/mode';
  static const home = '/';
  static const moodNew = '/mood/new';
  static const journalNew = '/journal/new';
  static const water = '/water';
  static const dashboard = '/dashboard';
  static const sedona = '/sedona';
  static const breathe = '/breathe';

  /// Screens reachable without a session.
  static const public = {welcome, signIn, signUp};
}
