import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildAppTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final baseScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF7A5CFF),
    brightness: brightness,
  );

  final colorScheme = baseScheme.copyWith(
    surface: isDark ? const Color(0xFF0F1116) : const Color(0xFFF6F2EC),
    onSurface: isDark ? const Color(0xFFF6F2EC) : const Color(0xFF13151A),
    primary: const Color(0xFF7A5CFF),
    secondary: const Color(0xFF56B8D6),
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
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: isDark ? const Color(0xFF181C25) : const Color(0xFFFFFFFF),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF181C25) : const Color(0xFFFFFFFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: isDark ? const Color(0xFF181C25) : const Color(0xFFFFFFFF),
      selectedColor: const Color(0xFF7A5CFF).withValues(alpha: 0.16),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      labelStyle: TextStyle(color: colorScheme.onSurface),
      secondaryLabelStyle: TextStyle(color: colorScheme.onSurface),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    ),
  );
}
