import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../login/login_screen.dart';

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
    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _logoFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _textFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.4, 0.9, curve: Curves.easeIn),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutQuint),
      ),
    );

    _startSplashing();
  }

  void _startSplashing() async {
    // Start intro animation
    _introController.forward();
    
    // Phase 0: Logo (2s)
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

  void _nextPhase() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _phase = 2); // Fetching Data

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _phase = 3); // Quote

    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // Check auth state and navigate (can be used for conditional logic)
    // final authState = ref.read(authStateChangesProvider);
    if (!mounted) return;

    // ignore: unawaited_futures
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        color: _getBackgroundColor(),
        child: Stack(
          children: [
            // Background Circles
            if (_phase > 0) ..._buildAnimatedCircles(),

            // Content
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _buildPhaseContent(),
              ),
            ),
          ],
        ),
      ),
    );
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
    // Phases 0 & 1 are dark; Phases 2 & 3 are light.
    if (_phase <= 1) {
      return Colors.white;
    } else {
      return AppColors.splashTextDark;
    }
  }

  List<Widget> _buildAnimatedCircles() {
    return [
      _PositionedCircle(
        top: -100,
        left: -100,
        size: 300,
        color: const Color.fromRGBO(255, 255, 255, 0.05),
        animation: _circleController,
      ),
      _PositionedCircle(
        bottom: -50,
        right: -50,
        size: 250,
        color: const Color.fromRGBO(255, 255, 255, 0.03),
        animation: _circleController,
        reverse: true,
      ),
      if (_phase == 1)
        Center(
          child: Container(
            width: 400,
            height: 400,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromRGBO(0, 0, 0, 0.1),
            ),
          ),
        ),
    ];
  }

  Widget _buildPhaseContent() {
    switch (_phase) {
      case 0:
        final color = _getContentColor();
        return AnimatedBuilder(
          animation: _introController,
          builder: (context, child) {
            return Column(
              key: const ValueKey(0),
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: const WispLogo(size: 120),
                  ),
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: Text(
                      'WISP.ai',
                      style: GoogleFonts.outfit(
                        color: color,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      case 1:
        return Text(
          key: const ValueKey(1),
          '${(_progress * 100).toInt()}%',
          style: GoogleFonts.outfit(
            color: _getContentColor(),
            fontSize: 48,
            fontWeight: FontWeight.w500,
          ),
        );
      case 2:
        final color = _getContentColor();
        return Column(
          key: const ValueKey(2),
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Fetching Data...',
              style: GoogleFonts.outfit(
                color: color,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Loading your personalized mental wellness journey...',
              style: GoogleFonts.outfit(
                color: color.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        );
      case 3:
        final color = _getContentColor();
        return Container(
          key: const ValueKey(3),
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              WispLogo(size: 80, color: color),
              const SizedBox(height: 48),
              Text(
                '“In the midst of winter, I found there was within me an invincible summer.”',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '— ALBERT CAMUS',
                style: GoogleFonts.outfit(
                  color: color.withOpacity(0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class WispLogo extends StatelessWidget {
  final double size;
  final Color? color;
  const WispLogo({super.key, required this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/wisp_logo.png',
        fit: BoxFit.contain,
        // If color is provided, we can use it to tint the logo if needed
        // but for now let's use the original logo colors.
        color: color,
      ),
    );
  }
}

class _PositionedCircle extends StatelessWidget {
  final double? top, bottom, left, right;
  final double size;
  final Color color;
  final Animation<double> animation;
  final bool reverse;

  const _PositionedCircle({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.color,
    required this.animation,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final val = reverse ? 1.0 - animation.value : animation.value;
        return Positioned(
          top: top != null ? top! + (val * 20) : null,
          bottom: bottom != null ? bottom! - (val * 20) : null,
          left: left != null ? left! + (val * 20) : null,
          right: right != null ? right! - (val * 20) : null,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
