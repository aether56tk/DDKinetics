import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Palette ─────────────────────────────────────────────────────────────────
  static const Color bg        = Color(0xFF0A0E17);
  static const Color surface   = Color(0xFF111827);
  static const Color card      = Color(0xFF1A2235);
  static const Color cardHover = Color(0xFF1F2A40);
  static const Color border    = Color(0xFF2D3A50);
  static const Color borderLight = Color(0xFF3D4E6A);

  static const Color accent    = Color(0xFF3B82F6);
  static const Color accentDim = Color(0xFF1D4ED8);
  static const Color accentGlow= Color(0xFF60A5FA);

  static const Color textPrimary   = Color(0xFFEEF2FF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted     = Color(0xFF475569);

  static const Color success  = Color(0xFF22C55E);
  static const Color warning  = Color(0xFFF59E0B);
  static const Color danger   = Color(0xFFEF4444);
  static const Color emergency= Color(0xFFFF4560);

  static const Color amr      = Color(0xFF3B82F6);
  static const Color smr      = Color(0xFFA855F7);

  // ── Result colors ────────────────────────────────────────────────────────────
  static Color resultColor(String label) {
    switch (label) {
      case 'Normal': return success;
      case 'Borderline': return warning;
      default: return danger;
    }
  }

  // ── Theme ────────────────────────────────────────────────────────────────────
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accentGlow,
        surface: surface,
        error: danger,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(
          color: textPrimary, fontSize: 34, fontWeight: FontWeight.w800,
          letterSpacing: -1.2, height: 1.1,
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          color: textPrimary, fontSize: 26, fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          color: textPrimary, fontSize: 20, fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.spaceGrotesk(
          color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.inter(color: textPrimary, fontSize: 15, height: 1.5),
        bodyMedium: GoogleFonts.inter(color: textSecondary, fontSize: 13, height: 1.5),
        bodySmall: GoogleFonts.inter(color: textMuted, fontSize: 11, letterSpacing: 0.3),
        labelLarge: GoogleFonts.spaceGrotesk(
          color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.3,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: textSecondary, size: 22),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: danger),
        ),
        labelStyle: GoogleFonts.inter(color: textSecondary, fontSize: 14),
        hintStyle: GoogleFonts.inter(color: textMuted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        inactiveTrackColor: border,
        thumbColor: accent,
        overlayColor: accent.withOpacity(0.15),
        valueIndicatorColor: accentDim,
        valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
        valueIndicatorTextStyle: GoogleFonts.spaceGrotesk(
          color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700,
        ),
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 1, space: 1),
    );
  }
}
