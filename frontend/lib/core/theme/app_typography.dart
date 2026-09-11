import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Three faces, three voices.
///
///   * [display] — Newsreader. The therapist speaking, and the user's own
///     reflections. Nothing else in the app uses it, so over time the typeface
///     itself becomes the signal that you are being spoken to, not instructed.
///   * [ui] — Manrope. The app talking: labels, lists, settings, buttons.
///   * [mono] — IBM Plex Mono. The system: timestamps, audit lines, admin and
///     governance surfaces (items 13, 15, 16).
class AppType {
  const AppType._();

  static TextStyle display([TextStyle? s]) => GoogleFonts.newsreader(textStyle: s);
  static TextStyle ui([TextStyle? s]) => GoogleFonts.manrope(textStyle: s);
  static TextStyle mono([TextStyle? s]) => GoogleFonts.ibmPlexMono(textStyle: s);

  // ---- Display / voice -------------------------------------------------
  static TextStyle get displayLarge =>
      GoogleFonts.newsreader(fontSize: 40, height: 1.10, fontWeight: FontWeight.w300, letterSpacing: -0.8);
  static TextStyle get displayMedium =>
      GoogleFonts.newsreader(fontSize: 30, height: 1.15, fontWeight: FontWeight.w400, letterSpacing: -0.45);

  /// Reserved for the therapist. Italic, ember-coloured at the call site.
  static TextStyle get voice =>
      GoogleFonts.newsreader(fontSize: 22, height: 1.45, fontWeight: FontWeight.w300, fontStyle: FontStyle.italic);

  /// Long-form therapist speech in chat bubbles.
  static TextStyle get voiceBody => GoogleFonts.newsreader(fontSize: 16.5, height: 1.50, fontWeight: FontWeight.w300);

  // ---- UI --------------------------------------------------------------
  static TextStyle get titleLarge =>
      GoogleFonts.manrope(fontSize: 23, height: 1.26, fontWeight: FontWeight.w600, letterSpacing: -0.23);
  static TextStyle get titleMedium => GoogleFonts.manrope(fontSize: 19, height: 1.32, fontWeight: FontWeight.w600);
  static TextStyle get bodyLarge => GoogleFonts.manrope(fontSize: 17, height: 1.53, fontWeight: FontWeight.w400);
  static TextStyle get bodyMedium => GoogleFonts.manrope(fontSize: 15, height: 1.55, fontWeight: FontWeight.w400);
  static TextStyle get label =>
      GoogleFonts.manrope(fontSize: 13, height: 1.38, fontWeight: FontWeight.w600, letterSpacing: 0.26);
  static TextStyle get caption => GoogleFonts.manrope(fontSize: 12, height: 1.42, fontWeight: FontWeight.w400);

  // ---- System ----------------------------------------------------------
  static TextStyle get monoBody =>
      GoogleFonts.ibmPlexMono(fontSize: 13, height: 1.40, fontWeight: FontWeight.w400, letterSpacing: 0.26);

  /// Eyebrows and section keys — uppercase, tracked out.
  static TextStyle get monoLabel =>
      GoogleFonts.ibmPlexMono(fontSize: 10.5, height: 1.40, fontWeight: FontWeight.w500, letterSpacing: 1.3);

  /// Any figure that sits in a column or updates in place.
  static TextStyle get numeric => GoogleFonts.ibmPlexMono(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextTheme textTheme(Color primary, Color secondary) => TextTheme(
    displayLarge: displayLarge.copyWith(color: primary),
    displayMedium: displayMedium.copyWith(color: primary),
    displaySmall: displayMedium.copyWith(fontSize: 25, color: primary),
    headlineMedium: titleLarge.copyWith(color: primary),
    titleLarge: titleLarge.copyWith(color: primary),
    titleMedium: titleMedium.copyWith(color: primary),
    bodyLarge: bodyLarge.copyWith(color: primary),
    bodyMedium: bodyMedium.copyWith(color: secondary),
    labelLarge: label.copyWith(color: primary),
    labelSmall: caption.copyWith(color: secondary),
  );
}
