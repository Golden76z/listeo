import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central design tokens for Listeo.
///
/// These mirror the CSS custom properties from the original prototype.
/// The values are the "default look": menthe background, leaf-green + bloc-yellow
/// palette, Quicksand type, 10px radius. Change them here to retheme the app.
class LoTheme {
  // ── palette ────────────────────────────────────────────────
  static const Color primary = Color(0xFF2F9E54); // leaf green
  static const Color accent = Color(0xFFF5D90A); // bloc yellow

  // derived from primary (precomputed color-mix from the prototype)
  static const Color primarySoft = Color(0xFFE4F2E9); // primary 13% on white
  static const Color primaryPress = Color(0xFF22713C); // primary 72% on black
  static Color get primaryShadow => primary.withOpacity(0.42);

  static const Color accentInk = Color(0xFFB49E06); // accent 62% on #4a3d00

  // ── menthe background tint ─────────────────────────────────
  static const Color bg = Color(0xFFF3FAF4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFE8F3EA);
  static const Color line = Color(0xFFE0EEE2);
  static const Color lineStrong = Color(0xFFCADDCD);

  // ── ink (text) ─────────────────────────────────────────────
  static const Color ink = Color(0xFF23522E); // primary 38% on #1b2417
  static const Color ink2 = Color(0xFF5A6253);
  static const Color ink3 = Color(0xFF9AA08C);

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
        background: bg,
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
    'green': Tone(Color(0xFF3DA35D), Color(0xFFE7F3E9)),
    'yellow': Tone(Color(0xFFE0B400), Color(0xFFFBF1CC)),
    'tomate': Tone(Color(0xFFE0584F), Color(0xFFFBE6E4)),
    'salade': Tone(Color(0xFF6DA833), Color(0xFFEBF3DE)),
    'sucre': Tone(Color(0xFFE08AB0), Color(0xFFFAE8F0)),
    'curry': Tone(Color(0xFFE08A2B), Color(0xFFFBEDDC)),
  };

  static Tone of(String? key) => _tones[key] ?? _tones['green']!;

  /// tones assigned to freshly created lists / dishes, cycled in order.
  static const List<String> newTones = ['green', 'yellow', 'curry', 'tomate', 'salade'];
}
