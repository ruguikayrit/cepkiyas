import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

/// Tek tipografi sistemi — ekranlarda mümkün olduğunca bunu kullanın.
abstract final class CkType {
  static TextStyle _base({
    required double size,
    FontWeight weight = FontWeight.w500,
    Color color = Ck.ink,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.manrope(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextTheme textTheme() {
    return TextTheme(
      displayLarge: _base(size: 34, weight: FontWeight.w800, letterSpacing: -1.0, height: 1.08),
      displayMedium: _base(size: 28, weight: FontWeight.w800, letterSpacing: -0.8, height: 1.1),
      displaySmall: _base(size: 24, weight: FontWeight.w700, letterSpacing: -0.6, height: 1.12),
      headlineLarge: _base(size: 22, weight: FontWeight.w700, letterSpacing: -0.5, height: 1.15),
      headlineMedium: _base(size: 20, weight: FontWeight.w700, letterSpacing: -0.45, height: 1.18),
      headlineSmall: _base(size: 18, weight: FontWeight.w700, letterSpacing: -0.35, height: 1.2),
      titleLarge: _base(size: 17, weight: FontWeight.w700, letterSpacing: -0.25, height: 1.25),
      titleMedium: _base(size: 15, weight: FontWeight.w600, letterSpacing: -0.15, height: 1.3),
      titleSmall: _base(size: 13, weight: FontWeight.w600, letterSpacing: 0, height: 1.32),
      bodyLarge: _base(size: 15, weight: FontWeight.w500, height: 1.45),
      bodyMedium: _base(size: 14, weight: FontWeight.w500, height: 1.42),
      bodySmall: _base(size: 12, weight: FontWeight.w500, color: Ck.mute, height: 1.38),
      labelLarge: _base(size: 14, weight: FontWeight.w600, letterSpacing: 0.1, height: 1.2),
      labelMedium: _base(size: 12, weight: FontWeight.w600, letterSpacing: 0.15, height: 1.25),
      labelSmall: _base(size: 11, weight: FontWeight.w600, letterSpacing: 0.35, height: 1.2),
    );
  }

  /// Üst bar ve auth ekranları — vektör metin, PNG yok.
  static TextStyle brandWordmark(double height) {
    final size = (height * 0.78).clamp(18.0, 40.0);
    return GoogleFonts.manrope(
      fontSize: size,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.04 * size,
      height: 1.0,
    );
  }

  static TextStyle brandTekno(double height) => brandWordmark(height).copyWith(color: Ck.ink);

  static TextStyle brandKiyas(double height) => brandWordmark(height).copyWith(color: Ck.mint);

  static TextStyle sectionLabel() => _base(
        size: 12,
        weight: FontWeight.w700,
        color: Ck.mute,
        letterSpacing: 0.6,
        height: 1.2,
      );

  static TextStyle overline() => _base(
        size: 11,
        weight: FontWeight.w700,
        color: Ck.mute,
        letterSpacing: 0.8,
        height: 1.2,
      );

  static TextStyle navLabel({required bool selected}) => _base(
        size: 11,
        weight: selected ? FontWeight.w700 : FontWeight.w500,
        color: selected ? Ck.navActive : Ck.navMute,
        letterSpacing: 0.1,
        height: 1.1,
      );
}
