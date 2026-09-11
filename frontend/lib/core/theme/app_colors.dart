import 'package:flutter/material.dart';

/// WISP LIFE semantic colour roles.
///
/// Dark-first: [dark] is the product's default theme, [light] is the variant.
///
/// Every colour here has exactly one job. The discipline is what keeps a
/// 17-module product legible:
///   * [accent]   the app's own voice, primary actions — and "private"
///   * [ember]    a voice is speaking to you (AI therapist, human therapist)
///   * [caution]  someone other than you can see this
///   * [alert]    crisis only. Never form validation.
///   * [positive] streaks, completion, improvement
///
/// Access from a widget:
///   `final c = Theme.of(context).extension<WispColors>()!;`
@immutable
class WispColors extends ThemeExtension<WispColors> {
  const WispColors({
    required this.ground,
    required this.surface,
    required this.raised,
    required this.line,
    required this.lineSoft,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.accentInk,
    required this.accentDim,
    required this.ember,
    required this.emberDim,
    required this.alert,
    required this.alertDim,
    required this.caution,
    required this.cautionDim,
    required this.positive,
    required this.positiveDim,
  });

  // Grounds
  final Color ground;
  final Color surface;
  final Color raised;
  final Color line;
  final Color lineSoft;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  // Semantic roles
  final Color accent;
  final Color accentInk;
  final Color accentDim;
  final Color ember;
  final Color emberDim;
  final Color alert;
  final Color alertDim;
  final Color caution;
  final Color cautionDim;
  final Color positive;
  final Color positiveDim;

  /// Night — the default theme. The hour this product matters most is 2am.
  static const WispColors dark = WispColors(
    ground: Color(0xFF090E1A),
    surface: Color(0xFF111A2C),
    raised: Color(0xFF1B2740),
    line: Color(0xFF2A3956),
    lineSoft: Color(0xFF1E2B42),
    textPrimary: Color(0xFFE8EDF5),
    textSecondary: Color(0xFFA3B1C6),
    textTertiary: Color(0xFF6E7F99),
    accent: Color(0xFF5FCBB9),
    accentInk: Color(0xFF8FE0D1),
    accentDim: Color(0xFF12312D),
    ember: Color(0xFFF0A97F),
    emberDim: Color(0xFF3A2418),
    alert: Color(0xFFFF7365),
    alertDim: Color(0xFF3D1A18),
    caution: Color(0xFFEDC66A),
    cautionDim: Color(0xFF332812),
    positive: Color(0xFF7FD48F),
    positiveDim: Color(0xFF143224),
  );

  /// Day — the variant.
  static const WispColors light = WispColors(
    ground: Color(0xFFEFF2F6),
    surface: Color(0xFFFFFFFF),
    raised: Color(0xFFE4EAF2),
    line: Color(0xFFD3DBE6),
    lineSoft: Color(0xFFE3E9F0),
    textPrimary: Color(0xFF0E1524),
    textSecondary: Color(0xFF46556C),
    textTertiary: Color(0xFF71809A),
    accent: Color(0xFF17897A),
    accentInk: Color(0xFF106255),
    accentDim: Color(0xFFD9EFEA),
    ember: Color(0xFFC26A38),
    emberDim: Color(0xFFF7E6DA),
    alert: Color(0xFFC8452F),
    alertDim: Color(0xFFF8DFDA),
    caution: Color(0xFF8F6D15),
    cautionDim: Color(0xFFF5EBD2),
    positive: Color(0xFF2E7D45),
    positiveDim: Color(0xFFDCEFE1),
  );

  @override
  WispColors copyWith({
    Color? ground,
    Color? surface,
    Color? raised,
    Color? line,
    Color? lineSoft,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? accent,
    Color? accentInk,
    Color? accentDim,
    Color? ember,
    Color? emberDim,
    Color? alert,
    Color? alertDim,
    Color? caution,
    Color? cautionDim,
    Color? positive,
    Color? positiveDim,
  }) {
    return WispColors(
      ground: ground ?? this.ground,
      surface: surface ?? this.surface,
      raised: raised ?? this.raised,
      line: line ?? this.line,
      lineSoft: lineSoft ?? this.lineSoft,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      accent: accent ?? this.accent,
      accentInk: accentInk ?? this.accentInk,
      accentDim: accentDim ?? this.accentDim,
      ember: ember ?? this.ember,
      emberDim: emberDim ?? this.emberDim,
      alert: alert ?? this.alert,
      alertDim: alertDim ?? this.alertDim,
      caution: caution ?? this.caution,
      cautionDim: cautionDim ?? this.cautionDim,
      positive: positive ?? this.positive,
      positiveDim: positiveDim ?? this.positiveDim,
    );
  }

  @override
  WispColors lerp(ThemeExtension<WispColors>? other, double t) {
    if (other is! WispColors) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return WispColors(
      ground: c(ground, other.ground),
      surface: c(surface, other.surface),
      raised: c(raised, other.raised),
      line: c(line, other.line),
      lineSoft: c(lineSoft, other.lineSoft),
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      textTertiary: c(textTertiary, other.textTertiary),
      accent: c(accent, other.accent),
      accentInk: c(accentInk, other.accentInk),
      accentDim: c(accentDim, other.accentDim),
      ember: c(ember, other.ember),
      emberDim: c(emberDim, other.emberDim),
      alert: c(alert, other.alert),
      alertDim: c(alertDim, other.alertDim),
      caution: c(caution, other.caution),
      cautionDim: c(cautionDim, other.cautionDim),
      positive: c(positive, other.positive),
      positiveDim: c(positiveDim, other.positiveDim),
    );
  }
}

/// Convenience accessor: `context.wisp.accent`
extension WispColorsX on BuildContext {
  WispColors get wisp => Theme.of(this).extension<WispColors>() ?? WispColors.dark;
}
