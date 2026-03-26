import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';
import '../../domain/app_user.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to auth state and navigate accordingly
    ref.listen<AsyncValue<AppUser?>>(authStateChangesProvider, (previous, next) {
      if (next.hasValue) {
        if (next.value == null) {
          // Navigator.of(context).pushReplacement(...)
        } else {
          // Navigator.of(context).pushReplacement(...)
        }
      }
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
