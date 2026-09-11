import 'package:flutter/material.dart';

/// Spacing on a 4pt base.
class Space {
  const Space._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 72;

  /// Standard screen side gutter.
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: 20);
}

/// Radius is assigned by role, not stamped uniformly.
///
/// [live] is reserved: fully round means *alive or urgent* — the character
/// orb, the panic button, the mode badge. Nothing static gets it.
class Radii {
  const Radii._();
  static const double chip = 6;
  static const double data = 10;
  static const double card = 12;
  static const double sheet = 20;
  static const double live = 999;

  static BorderRadius get chipR => BorderRadius.circular(chip);
  static BorderRadius get dataR => BorderRadius.circular(data);
  static BorderRadius get cardR => BorderRadius.circular(card);
  static BorderRadius get sheetR => const BorderRadius.vertical(top: Radius.circular(sheet));
  static BorderRadius get liveR => BorderRadius.circular(live);
}

/// Everything breathes except safety.
///
/// Durations run slower than Flutter's defaults on purpose — urgency is the
/// wrong feeling in almost every screen here. [none] is the exception and it
/// is absolute: anything on the crisis path renders on the same frame as the
/// tap that asked for it.
class Motion {
  const Motion._();

  static const Duration breath = Duration(milliseconds: 620);
  static const Duration settle = Duration(milliseconds: 320);
  static const Duration touch = Duration(milliseconds: 140);
  static const Duration none = Duration.zero;

  /// The character's idle breath, tuned to a resting exhale.
  static const Duration cycle = Duration(milliseconds: 5200);

  static const Curve breathCurve = Cubic(0.37, 0, 0.24, 1);
  static const Curve settleCurve = Cubic(0.32, 0.72, 0, 1);
  static const Curve touchCurve = Curves.easeOut;

  /// Use on every crisis surface. Honours the platform's reduce-motion
  /// setting everywhere else via [respecting].
  static Duration respecting(BuildContext context, Duration d) =>
      MediaQuery.maybeDisableAnimationsOf(context) == true ? Duration.zero : d;
}
