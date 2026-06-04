import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central design tokens for Listeo.
///
/// These mirror the CSS custom properties from the original prototype.
/// The values are the "default look": menthe background, leaf-green + bloc-yellow
/// palette, Quicksand type, 10px radius. Change them here to retheme the app.
class LoTheme {
  // ── palette ────────────────────────────────────────────────
  static const Color primary = Color(0xFF388C5A); // premium sage/forest green
  static const Color accent = Color(0xFFF5D90A); // bloc yellow

  // derived from primary (precomputed color-mix from the prototype)
  static const Color primarySoft = Color(0xFFE9F4EE); // primary 13% on white
  static const Color primaryPress = Color(0xFF2B6B44); // primary 72% on black
  static Color get primaryShadow => primary.withValues(alpha: 0.35);

  static const Color accentInk = Color(0xFFB49E06); // accent 62% on #4a3d00

  // ── menthe background tint ─────────────────────────────────
  static const Color bg = Color(0xFFF5F9F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFE9F2ED);
  static const Color line = Color(0xFFDEEAE3);
  static const Color lineStrong = Color(0xFFC9DBD0);

  // ── ink (text) ─────────────────────────────────────────────
  static const Color ink = Color(0xFF1E3A27); // primary 38% on #1b2417
  static const Color ink2 = Color(0xFF526659);
  static const Color ink3 = Color(0xFF8BA093);

  // ── danger ─────────────────────────────────────────────────
  static const Color danger = Color(0xFFD7584F);
  static const Color dangerSoft = Color(0xFFFBE7E4);

  // ── geometry ───────────────────────────────────────────────
  static const double radius = 10;
  static double r(double mult) => radius * mult;

  // ── motion ─────────────────────────────────────────────────
  /// cubic-bezier(0.16, 1, 0.3, 1) — the prototype's signature ease-out-expo-ish curve.
  static const Curve ease = Cubic(0.16, 1, 0.3, 1);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration med = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 360);

  // ── elevation ──────────────────────────────────────────────
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x0D282E20), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0D282E20), blurRadius: 18, offset: Offset(0, 6)),
  ];

  // ── type ───────────────────────────────────────────────────
  static TextStyle font({
    double size = 16,
    FontWeight weight = FontWeight.w600,
    Color color = ink,
    double? height,
    double letterSpacing = 0,
    TextDecoration? decoration,
    Color? decorationColor,
  }) {
    return GoogleFonts.quicksand(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationThickness: decoration == null ? null : 2.5,
    );
  }

  static ThemeData themeData() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        surface: surface,
      ),
      textTheme: GoogleFonts.quicksandTextTheme(),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}

/// Tone accents for recipe folders / list cards (small color markers).
class Tone {
  final Color dot;
  final Color soft;
  const Tone(this.dot, this.soft);

  static const Map<String, Tone> _tones = {
    'green': Tone(Color(0xFF4C9F6F), Color(0xFFECF6F1)),
    'yellow': Tone(Color(0xFFCCA73C), Color(0xFFFAF6E6)),
    'tomate': Tone(Color(0xFFCD5D55), Color(0xFFFAF0EE)),
    'salade': Tone(Color(0xFF7A9C52), Color(0xFFF3F7EE)),
    'sucre': Tone(Color(0xFFC37895), Color(0xFFF8EFF2)),
    'curry': Tone(Color(0xFFCC7F3B), Color(0xFFFAF1EA)),
  };

  static Tone of(String? key) => _tones[key] ?? _tones['green']!;

  static List<String> get allTones => ['green', 'yellow', 'curry', 'tomate', 'salade', 'sucre'];

  /// tones assigned to freshly created lists / dishes, cycled in order.
  static const List<String> newTones = ['green', 'yellow', 'curry', 'tomate', 'salade'];
}
