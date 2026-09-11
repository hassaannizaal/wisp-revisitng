import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_metrics.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../auth/data/firebase_auth_repository.dart';
import '../../moods/presentation/mood_check_in_controller.dart';
import '../../wisps/domain/wisp.dart';
import 'home_controller.dart';

/// Interim hub on the new tokens. Replaced by docs/screens/04-home.md once
/// mood, water and the mode badge exist to fill it.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _saveWisp(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(recentWispsProvider.notifier)
          .save(mood: 'Zen', reflection: 'The architecture is pure and the connection is secure. Handshake complete.');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save that. $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.wisp;
    final user = ref.watch(authRepositoryProvider).currentUser;
    final firstName = (user?.displayName ?? '').trim().split(' ').first;
    final wisps = ref.watch(recentWispsProvider);
    final today = ref.watch(todayMoodProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(firstName.isEmpty ? 'Home' : 'Hello, $firstName'),
        actions: [
          TapTargetIconButton(
            icon: Icons.logout,
            tooltip: 'Sign out',
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
          const SizedBox(width: Space.sm),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: Space.screen.copyWith(top: Space.base, bottom: Space.xl),
            children: [
              Text('A quiet place to put things down', style: AppType.displayMedium.copyWith(color: c.textPrimary)),
              const SizedBox(height: Space.sm),
              Text(
                'Your session is active and the backend is listening.',
                style: AppType.bodyMedium.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: Space.lg),
              Text('TODAY', style: AppType.monoLabel.copyWith(color: c.textTertiary)),
              const SizedBox(height: Space.sm),
              _TodayCard(
                prompt: today == null
                    ? 'How are you arriving today?'
                    : 'Logged as ${today.mood.label}. Want to write about it?',
                action: today == null ? 'Check in' : 'Check in again',
                onTap: () async {
                  await context.push(AppRoutes.moodNew);
                  ref.invalidate(todayMoodProvider);
                },
              ),
              const SizedBox(height: Space.lg),
              PrimaryButton(label: 'Save a wisp', icon: Icons.add, onPressed: () => _saveWisp(context, ref)),
              const SizedBox(height: Space.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('RECENT', style: AppType.monoLabel.copyWith(color: c.textTertiary)),
                  TapTargetIconButton(
                    icon: Icons.refresh,
                    size: 20,
                    tooltip: 'Refresh',
                    onPressed: () => ref.invalidate(recentWispsProvider),
                  ),
                ],
              ),
              const SizedBox(height: Space.sm),
              _RecentWisps(wisps: wisps),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.prompt, required this.action, required this.onTap});

  final String prompt;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.wisp;
    return Container(
      padding: const EdgeInsets.all(Space.base),
      decoration: BoxDecoration(color: c.raised, borderRadius: Radii.cardR),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(prompt, style: AppType.voice.copyWith(color: c.textPrimary)),
          const SizedBox(height: Space.md),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(onPressed: onTap, child: Text(action)),
          ),
        ],
      ),
    );
  }
}

class _RecentWisps extends StatelessWidget {
  const _RecentWisps({required this.wisps});

  final AsyncValue<List<Wisp>> wisps;

  @override
  Widget build(BuildContext context) {
    final c = context.wisp;
    return wisps.when(
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.xl),
        child: Center(child: CircularProgressIndicator(color: c.textTertiary, strokeWidth: 2)),
      ),
      error: (error, _) => _Message(text: 'Could not load your wisps.\n$error'),
      data: (items) => items.isEmpty
          ? const _Message(text: 'Nothing here yet. Save your first one above.')
          : Column(children: [for (final wisp in items) _WispTile(wisp: wisp)]),
    );
  }
}

class _WispTile extends StatelessWidget {
  const _WispTile({required this.wisp});

  final Wisp wisp;

  @override
  Widget build(BuildContext context) {
    final c = context.wisp;
    return Container(
      margin: const EdgeInsets.only(bottom: Space.md),
      padding: const EdgeInsets.all(Space.base),
      decoration: BoxDecoration(
        color: c.raised,
        borderRadius: Radii.cardR,
        border: Border.all(color: c.lineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(wisp.mood.toUpperCase(), style: AppType.monoLabel.copyWith(color: c.accentInk)),
              const Spacer(),
              Text(_relative(wisp.createdAt), style: AppType.monoLabel.copyWith(color: c.textTertiary)),
            ],
          ),
          const SizedBox(height: Space.sm),
          Text(wisp.reflection, style: AppType.voiceBody.copyWith(color: c.textPrimary)),
        ],
      ),
    );
  }

  static String _relative(DateTime? date) {
    if (date == null) return 'JUST NOW';
    final d = DateTime.now().difference(date);
    if (d.inMinutes < 1) return 'JUST NOW';
    if (d.inHours < 1) return '${d.inMinutes} MIN AGO';
    if (d.inDays < 1) return '${d.inHours} H AGO';
    if (d.inDays < 7) return '${d.inDays} D AGO';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.lg),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppType.bodyMedium.copyWith(color: context.wisp.textTertiary),
      ),
    );
  }
}
