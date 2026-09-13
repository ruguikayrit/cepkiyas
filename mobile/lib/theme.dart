import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Ck {
  static const bg = Color(0xFFFFFFFF);
  static const bg2 = Color(0xFFF5F7FB);
  static const panel = Color(0xFFFFFFFF);
  static const panel2 = Color(0xFFF3F5F8);
  static const line = Color(0xFFE4E8F0);
  static const ink = Color(0xFF0B1220);
  static const mute = Color(0xFF6B7280);
  static const mint = Color(0xFF1A5CFF);
  static const mintDim = Color(0xFFE8EFFF);
  static const gold = Color(0xFFD97706);
  static const danger = Color(0xFFDC4C54);

  static Color tone(double score) {
    if (score >= 88) return mint;
    if (score >= 76) return gold;
    return danger;
  }

  static ThemeData theme() {
    final text = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData(brightness: Brightness.light).textTheme.apply(
            bodyColor: ink,
            displayColor: ink,
          ),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      textTheme: text,
      primaryTextTheme: text,
      colorScheme: const ColorScheme.light(
        surface: panel,
        primary: mint,
        onPrimary: Colors.white,
        onSurface: ink,
        outline: line,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 12,
        toolbarHeight: 64,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
          color: mint,
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: panel2,
        selectedColor: mintDim,
        side: BorderSide(color: line),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: bg,
        indicatorColor: mintDim,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? mint : mute,
          );
        }),
      ),
      dividerColor: line,
      cardColor: panel,
      snackBarTheme: const SnackBarThemeData(backgroundColor: ink, contentTextStyle: TextStyle(color: Colors.white)),
    );
  }
}
