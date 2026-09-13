import 'package:flutter/material.dart';

class Ck {
  static const bg = Color(0xFF08090B);
  static const bg2 = Color(0xFF0D0F13);
  static const panel = Color(0xFF11141A);
  static const panel2 = Color(0xFF171B22);
  static const line = Color(0xFF242A33);
  static const ink = Color(0xFFF4F6F8);
  static const mute = Color(0xFF8B939E);
  static const mint = Color(0xFF6EE7B7);
  static const mintDim = Color(0xFF163528);
  static const gold = Color(0xFFEFC15A);
  static const danger = Color(0xFFF07178);

  static Color tone(double score) {
    if (score >= 88) return mint;
    if (score >= 76) return gold;
    return danger;
  }

  static ThemeData theme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
    );
    return base.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        surface: panel,
        primary: mint,
        onPrimary: Color(0xFF08110C),
        onSurface: ink,
        outline: line,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          color: ink,
        ),
      ),
      dividerColor: line,
      cardColor: panel,
      snackBarTheme: const SnackBarThemeData(backgroundColor: panel2),
    );
  }
}
