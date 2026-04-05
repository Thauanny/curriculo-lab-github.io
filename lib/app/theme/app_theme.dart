import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Modern indigo-violet palette
  static const Color _seed = Color(0xFF6366F1); // Indigo-500
  static const Color _surface = Color(0xFFFAFAFC);
  static const Color _canvas = Color(0xFFF4F4F8);
  static const Color _ink = Color(0xFF0F172A); // Slate-900

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
      primary: _seed,
      surface: _surface,
    );

    final bodyTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _canvas,
      textTheme: bodyTextTheme.copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 52,
          height: 1.02,
          fontWeight: FontWeight.w800,
          color: _ink,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 36,
          height: 1.08,
          fontWeight: FontWeight.w800,
          color: _ink,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 30,
          height: 1.1,
          fontWeight: FontWeight.w700,
          color: _ink,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 28,
          height: 1.1,
          fontWeight: FontWeight.w700,
          color: _ink,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _ink,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _ink,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _ink.withValues(alpha: 0.7),
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          height: 1.55,
          fontWeight: FontWeight.w400,
          color: _ink.withValues(alpha: 0.85),
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          height: 1.5,
          fontWeight: FontWeight.w400,
          color: _ink.withValues(alpha: 0.7),
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          height: 1.5,
          fontWeight: FontWeight.w400,
          color: _ink.withValues(alpha: 0.55),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: const Color(0xFFE2E8F0)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _seed, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: _ink.withValues(alpha: 0.35),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _seed,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _seed,
          side: const BorderSide(color: _seed),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _seed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF1F5F9),
        side: BorderSide.none,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: _ink.withValues(alpha: 0.8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}