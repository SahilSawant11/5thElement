import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildAppTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final baseScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF6A5EF5),
    brightness: brightness,
  );

  final colorScheme = baseScheme.copyWith(
    surface: isDark ? const Color(0xFF0B0E13) : const Color(0xFFF6F0E7),
    onSurface: isDark ? const Color(0xFFF5F0E8) : const Color(0xFF11151D),
    primary: const Color(0xFF6A5EF5),
    secondary: const Color(0xFF2EB6A8),
    tertiary: const Color(0xFFF19A5A),
    outline: isDark ? const Color(0xFF303544) : const Color(0xFFE5DDD1),
    surfaceTint: const Color(0xFF6A5EF5),
  );

  final baseTextTheme = ThemeData(brightness: brightness).textTheme;

  return ThemeData(
    brightness: brightness,
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    textTheme: GoogleFonts.manropeTextTheme(baseTextTheme).copyWith(
      displayLarge: GoogleFonts.cormorantGaramond(
        textStyle: baseTextTheme.displayLarge,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      displaySmall: GoogleFonts.cormorantGaramond(
        textStyle: baseTextTheme.displaySmall,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      headlineSmall: GoogleFonts.cormorantGaramond(
        textStyle: baseTextTheme.headlineSmall,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: GoogleFonts.cormorantGaramond(
        textStyle: baseTextTheme.headlineMedium,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.manrope(
        textStyle: baseTextTheme.titleLarge,
        fontWeight: FontWeight.w700,
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
      color: isDark ? const Color(0xFF151A23) : const Color(0xFFFFFFFF),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF151A23) : const Color(0xFFFFFFFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide.none,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: isDark ? const Color(0xFF151A23) : const Color(0xFFFFFFFF),
      selectedColor: const Color(0xFF6A5EF5).withValues(alpha: 0.16),
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
    dividerTheme: DividerThemeData(
      color: colorScheme.outline.withValues(alpha: 0.5),
      thickness: 1,
      space: 1,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700),
      ),
    ),
  );
}
