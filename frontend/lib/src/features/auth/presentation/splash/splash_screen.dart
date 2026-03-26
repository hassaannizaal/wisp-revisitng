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

class _SplashScreenState extends ConsumerState<SplashScreen> with TickerProviderStateMixin {
  int _phase = 0;
  double _progress = 0;
  late Timer _timer;
  
  // Animation controllers for circles
  late AnimationController _circleController;

  @override
  void initState() {
    super.initState();
    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _startSplashing();
  }

  void _startSplashing() async {
    // Phase 0: Logo (2s)
    await Future.delayed(const Duration(seconds: 2));
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
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
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
      case 0: return AppColors.splashDark;
      case 1: return AppColors.splashMid;
      case 2: return AppColors.splashGreen;
      case 3: return AppColors.splashRed;
      default: return AppColors.splashDark;
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
        return Column(
          key: const ValueKey(0),
          mainAxisSize: MainAxisSize.min,
          children: [
            const WispLogo(size: 80),
            const SizedBox(height: 24),
            Text(
              'freud.ai',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
              ),
            ),
          ],
        );
      case 1:
        return Text(
          key: const ValueKey(1),
          '${(_progress * 100).toInt()}%',
          style: GoogleFonts.outfit(
            color: AppColors.splashAccent,
            fontSize: 48,
            fontWeight: FontWeight.w500,
          ),
        );
      case 2:
        return Column(
          key: const ValueKey(2),
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Fetching Data...',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Shake your screen to interact!',
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        );
      case 3:
        return Container(
          key: const ValueKey(3),
           padding: const EdgeInsets.symmetric(horizontal: 40),
           child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               const WispLogo(size: 40, color: AppColors.splashAccent),
               const SizedBox(height: 48),
               Text(
                '“In the midst of winter, I found there was within me an invincible summer.”',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '— ALBERT CAMUS',
                style: GoogleFonts.outfit(
                  color: Colors.white54,
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
    final logoColor = color ?? AppColors.splashAccent;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: _Dot(size: size * 0.4, color: logoColor),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _Dot(size: size * 0.4, color: logoColor),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: _Dot(size: size * 0.4, color: logoColor),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: _Dot(size: size * 0.4, color: logoColor),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final double size;
  final Color color;
  const _Dot({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
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
