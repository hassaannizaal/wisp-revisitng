import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_metrics.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../domain/mood.dart';
import 'mood_check_in_controller.dart';

/// Spec: docs/screens/05-mood-check-in.md
class MoodCheckInScreen extends ConsumerWidget {
  const MoodCheckInScreen({super.key});

  void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.wisp;
    final state = ref.watch(moodCheckInControllerProvider);
    final selected = state.selected;

    ref.listen(moodCheckInControllerProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(Space.md, Space.sm, Space.md, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    // A dismissible task, not a destination — × rather than a chevron.
                    child: TapTargetIconButton(icon: Icons.close, tooltip: 'Close', onPressed: () => _close(context)),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: Space.screen.copyWith(top: Space.base, bottom: Space.lg),
                    children: [
                      AnimatedSwitcher(
                        duration: Motion.respecting(context, Motion.settle),
                        switchInCurve: Motion.settleCurve,
                        child: Text(
                          selected == null ? 'How are you arriving today?' : 'Noted. Anything behind it?',
                          key: ValueKey(selected == null),
                          style: AppType.displayLarge.copyWith(color: c.textPrimary),
                        ),
                      ),
                      const SizedBox(height: Space.xl),
                      for (final mood in Mood.values) ...[
                        _MoodOption(
                          mood: mood,
                          selected: mood == selected,
                          onTap: () => ref.read(moodCheckInControllerProvider.notifier).select(mood),
                        ),
                        if (mood != Mood.values.last) const SizedBox(height: Space.md),
                      ],
                      const SizedBox(height: Space.lg),
                      Text(
                        'Five states, not a score out of ten. Nothing here is being graded or ranked.',
                        textAlign: TextAlign.center,
                        style: AppType.caption.copyWith(color: c.textTertiary),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: Space.screen.copyWith(top: Space.sm, bottom: Space.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PrimaryButton(
                        label: selected == null ? 'Continue' : 'Write about it',
                        onPressed: state.log == null
                            ? null
                            : () => context.go(
                                Uri(
                                  path: AppRoutes.journalNew,
                                  queryParameters: {'moodLogId': state.log!.id},
                                ).toString(),
                              ),
                      ),
                      const SizedBox(height: Space.sm),
                      // Skipping is a legitimate answer and is never nagged.
                      Center(
                        child: QuietButton(label: 'Skip today', onPressed: () => _close(context)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MoodOption extends StatelessWidget {
  const _MoodOption({required this.mood, required this.selected, required this.onTap});

  final Mood mood;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.wisp;
    return Semantics(
      button: true,
      selected: selected,
      label: '${mood.label}. ${mood.hint}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: Radii.cardR,
          child: AnimatedContainer(
            duration: Motion.respecting(context, Motion.touch),
            curve: Motion.touchCurve,
            height: 66,
            padding: const EdgeInsets.symmetric(horizontal: Space.base),
            decoration: BoxDecoration(
              color: selected ? c.accentDim : Colors.transparent,
              borderRadius: Radii.cardR,
              border: Border.all(color: selected ? c.accent : c.line, width: selected ? 1.5 : 1),
            ),
            child: Row(
              children: [
                Icon(mood.icon, size: 28, color: selected ? c.accent : c.textTertiary),
                const SizedBox(width: Space.base),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mood.label,
                        style: AppType.titleMedium.copyWith(color: selected ? c.accentInk : c.textPrimary),
                      ),
                      Text(mood.hint, style: AppType.caption.copyWith(color: c.textTertiary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
