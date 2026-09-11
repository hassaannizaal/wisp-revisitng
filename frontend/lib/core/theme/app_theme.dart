import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_metrics.dart';
import 'app_typography.dart';

/// WISP LIFE theme.
///
/// Dark-first: [dark] is the product default. Set
/// `themeMode: ThemeMode.dark` in MaterialApp until the user picks otherwise.
class AppTheme {
  const AppTheme._();

  static ThemeData get dark => _build(WispColors.dark, Brightness.dark);
  static ThemeData get light => _build(WispColors.light, Brightness.light);

  static ThemeData _build(WispColors c, Brightness b) {
    final onAccent = b == Brightness.dark ? c.ground : Colors.white;

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      scaffoldBackgroundColor: c.ground,
      canvasColor: c.ground,
      extensions: <ThemeExtension<dynamic>>[c],

      colorScheme: ColorScheme(
        brightness: b,
        primary: c.accent,
        onPrimary: onAccent,
        secondary: c.ember,
        onSecondary: b == Brightness.dark ? c.ground : Colors.white,
        error: c.alert,
        onError: Colors.white,
        surface: c.surface,
        onSurface: c.textPrimary,
        surfaceContainerHighest: c.raised,
        outline: c.line,
        outlineVariant: c.lineSoft,
      ),

      textTheme: AppType.textTheme(c.textPrimary, c.textSecondary),
      dividerTheme: DividerThemeData(color: c.lineSoft, thickness: 1, space: 1),
      splashFactory: InkSparkle.splashFactory,

      appBarTheme: AppBarTheme(
        backgroundColor: c.ground,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppType.titleMedium.copyWith(color: c.textPrimary),
      ),

      cardTheme: CardThemeData(
        color: c.raised,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: Radii.cardR),
      ),

      // Primary action. Full-width is a screen-level decision, not a
      // button-level one — set minimumSize at the call site where it applies.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.accent,
          foregroundColor: onAccent,
          disabledBackgroundColor: c.raised,
          disabledForegroundColor: c.textTertiary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: Radii.cardR),
          textStyle: AppType.ui(const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          animationDuration: Motion.touch,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.textPrimary,
          side: BorderSide(color: c.line),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: Radii.cardR),
          textStyle: AppType.ui(const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accentInk,
          textStyle: AppType.ui(const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.raised,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle: AppType.bodyMedium.copyWith(color: c.textTertiary),
        labelStyle: AppType.label.copyWith(color: c.textSecondary),
        border: OutlineInputBorder(
          borderRadius: Radii.cardR,
          borderSide: BorderSide(color: c.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: Radii.cardR,
          borderSide: BorderSide(color: c.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: Radii.cardR,
          borderSide: BorderSide(color: c.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: Radii.cardR,
          // Form errors use the outline, not the crisis colour. See the
          // hard rule in the design system: coral means crisis only.
          borderSide: BorderSide(color: c.caution),
        ),
        errorStyle: AppType.caption.copyWith(color: c.caution),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: Radii.sheetR),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.raised,
        contentTextStyle: AppType.bodyMedium.copyWith(color: c.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: Radii.cardR),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: c.raised,
        side: BorderSide(color: c.line),
        labelStyle: AppType.label.copyWith(color: c.textSecondary),
        shape: RoundedRectangleBorder(borderRadius: Radii.chipR),
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
