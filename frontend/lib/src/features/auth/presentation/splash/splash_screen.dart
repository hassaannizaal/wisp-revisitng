import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/wisp_logo.dart';
import '../../../../../core/services/audio_service.dart';
import '../welcome/welcome_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  int _phase = 0;
  double _progress = 0;
  late Timer _timer;
  late String _selectedQuote;
  bool _hasInteracted = false;
  final Completer<void> _interactionCompleter = Completer<void>();

  static const List<String> _wellnessQuotes = [
    "You don't have to be okay all the time",
    "Healing is not linear",
    "Still here. Still trying. That counts",
    "Surviving is enough",
    "Small steps are still movement",
    "This moment will pass",
    "You've survived every hard day so far",
    "Right now is enough",
    "Be gentle with yourself",
    "You deserve your own kindness",
    "Progress, not perfection",
    "Breathe. You are still here",
    "Pause. You are allowed to pause",
    "One breath at a time",
    "The night always ends",
    "Low days are not lost days",
    "Darkness is not the destination",
    "You are not your worst thought",
    "You are not your diagnosis",
    "You are more than this moment",
  ];

  // Animation controllers for circles and intro
  late AnimationController _circleController;
  late AnimationController _introController;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    // Select a random wellness quote
    _selectedQuote = _wellnessQuotes[Random().nextInt(_wellnessQuotes.length)];

    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _logoFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _textFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.4, 0.9, curve: Curves.easeIn),
    );

    _textSlide =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutQuart),
      ),
    );

    unawaited(_startSplashing());
  }

  Future<void> _startSplashing() async {
    unawaited(_introController.forward());

    // Web Autoplay Compliance: Wait for first gesture before sound & phase 1
    if (kIsWeb && !_hasInteracted) {
      await _interactionCompleter.future;
    }

    unawaited(AudioService().playLogoSound());

    // Phase 0: Logo (3s)
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() => _phase = 1);

    // Phase 1: Progress (simulate 0 to 99%)
    _timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (_progress < 0.99) {
        setState(() {
          _progress += 0.01;
        });
      } else {
        timer.cancel();
        _nextPhase();
      }
    });
  }

  Future<void> _nextPhase() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _phase = 2);

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _phase = 3);

    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;

    // ignore: unawaited_futures
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const WelcomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 1000),
      ),
    );
  }

  @override
  void dispose() {
    _circleController.dispose();
    _introController.dispose();
    if (mounted && _timer.isActive) _timer.cancel();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (_phase) {
      case 0:
        return AppColors.splashPhase0;
      case 1:
        return AppColors.splashPhase1;
      case 2:
        return AppColors.splashPhase2;
      case 3:
        return AppColors.splashPhase3;
      default:
        return AppColors.splashPhase0;
    }
  }

  Color _getContentColor() {
    // Phase 0, 1, and 2 are now dark based. Phase 3 is light.
    return _phase <= 2 ? Colors.white : AppColors.splashTextDark;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!_hasInteracted) {
            setState(() => _hasInteracted = true);
            if (!_interactionCompleter.isCompleted) {
              _interactionCompleter.complete();
            }
          }
        },
        child: Stack(
          children: [
            // Background Gradient and Bokeh
            _BokehBackground(
              phase: _phase,
              animation: _circleController,
              backgroundColor: _getBackgroundColor(),
            ),

            // Content
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 1000),
                switchInCurve: Curves.easeInOutCubic,
                switchOutCurve: Curves.easeInOutCubic,
                child: _buildPhaseContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseContent() {
    final contentColor = _getContentColor();

    switch (_phase) {
      case 0:
        return AnimatedBuilder(
          key: const ValueKey(0),
          animation: _introController,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: const WispLogo(fontSize: 64, showText: false),
                  ),
                ),
                const SizedBox(height: 32),
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: Text(
                      'WISP.ai',
                      style: GoogleFonts.outfit(
                        color: contentColor,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ),
                if (kIsWeb && !_hasInteracted)
                  Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: _InteractionPrompt(animation: _introController),
                  ),
              ],
            );
          },
        );
      case 1:
        return _PhaseTransition(
          key: const ValueKey(1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(_progress * 100).toInt()}%',
                style: GoogleFonts.outfit(
                  color: contentColor,
                  fontSize: 64,
                  fontWeight: FontWeight.w200,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 40),
              _PremiumProgress(progress: _progress, color: contentColor),
            ],
          ),
        );
      case 2:
        return _PhaseTransition(
          key: const ValueKey(2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Fetching Data...',
                style: GoogleFonts.outfit(
                  color: contentColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Aligning your mindful journey...',
                style: GoogleFonts.outfit(
                  color: contentColor.withValues(alpha: 0.6),
                  fontSize: 16,
                  height: 1.5,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      case 3:
        return _PhaseTransition(
          key: const ValueKey(3),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                WispLogo(
                    fontSize: 32,
                    color: contentColor.withValues(alpha: 0.8),
                    showText: false),
                const SizedBox(height: 56),
                Text(
                  _selectedQuote,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: contentColor,
                    fontSize: 26,
                    fontWeight: FontWeight.w300, // Thinner for a more airy feel
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 48), // Bottom padding
              ],
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _BokehBackground extends StatelessWidget {
  final int phase;
  final Animation<double> animation;
  final Color backgroundColor;

  const _BokehBackground({
    required this.phase,
    required this.animation,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOutCubic,
      color: backgroundColor,
      child: Stack(
        children: [
          // Slow drifting orbs
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Stack(
                children: [
                  _PositionedOrb(
                    top: -50 + (animation.value * 30),
                    left: -50 + (animation.value * 20),
                    size: 400,
                    // Pulse with Login screen lavender
                    color: const Color(0xFF6B5B95).withValues(alpha: 0.12),
                  ),
                  _PositionedOrb(
                    bottom: 100 - (animation.value * 40),
                    right: -100 + (animation.value * 30),
                    size: 500,
                    // Pulse with Login screen peach
                    color: const Color(0xFFE9B384).withValues(alpha: 0.08),
                  ),
                  _PositionedOrb(
                    top: 200 + (animation.value * 50),
                    right: 50,
                    size: 300,
                    color: Colors.white.withValues(alpha: 0.03),
                  ),
                ],
              );
            },
          ),

          // Blur Layer for Bokeh effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }
}

class _PositionedOrb extends StatelessWidget {
  final double? top, bottom, left, right;
  final double size;
  final Color color;

  const _PositionedOrb({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _PhaseTransition extends StatefulWidget {
  final Widget child;
  const _PhaseTransition({super.key, required this.child});

  @override
  State<_PhaseTransition> createState() => _PhaseTransitionState();
}

class _PhaseTransitionState extends State<_PhaseTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slide =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutQuart,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

class _PremiumProgress extends StatelessWidget {
  final double progress;
  final Color color;
  const _PremiumProgress({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 3,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 240 * progress,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InteractionPrompt extends StatelessWidget {
  final Animation<double> animation;
  const _InteractionPrompt({required this.animation});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.touch_app_outlined, color: Colors.white54, size: 24),
          const SizedBox(height: 12),
          Text(
            'TAP TO BEGIN YOUR JOURNEY',
            style: GoogleFonts.outfit(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
