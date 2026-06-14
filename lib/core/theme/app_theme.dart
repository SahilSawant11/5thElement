import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildAppTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final baseScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF6D6AFB),
    brightness: brightness,
  );

  final colorScheme = baseScheme.copyWith(
    surface: isDark ? const Color(0xFF0C0F14) : const Color(0xFFF7F2EA),
    onSurface: isDark ? const Color(0xFFF4EFE7) : const Color(0xFF12151D),
    primary: const Color(0xFF6D6AFB),
    secondary: const Color(0xFF3CC5B8),
    tertiary: const Color(0xFFF2A65A),
    outline: isDark ? const Color(0xFF313645) : const Color(0xFFE3DDD2),
    surfaceTint: const Color(0xFF6D6AFB),
  );

  final baseTextTheme = ThemeData(brightness: brightness).textTheme;

  return ThemeData(
    brightness: brightness,
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    textTheme: GoogleFonts.manropeTextTheme(baseTextTheme).copyWith(
      displaySmall: GoogleFonts.cormorantGaramond(
        textStyle: baseTextTheme.displaySmall,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: GoogleFonts.cormorantGaramond(
        textStyle: baseTextTheme.headlineMedium,
        fontWeight: FontWeight.w600,
      ),
    ),
    splashFactory: InkSparkle.splashFactory,
    visualDensity: VisualDensity.standard,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: isDark ? const Color(0xFF161A22) : const Color(0xFFFFFFFF),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF161A22) : const Color(0xFFFFFFFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: isDark ? const Color(0xFF161A22) : const Color(0xFFFFFFFF),
      selectedColor: const Color(0xFF6D6AFB).withValues(alpha: 0.16),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      labelStyle: TextStyle(color: colorScheme.onSurface),
      secondaryLabelStyle: TextStyle(color: colorScheme.onSurface),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colorScheme.primary,
      circularTrackColor: colorScheme.primary.withValues(alpha: 0.16),
    ),
  );
}
