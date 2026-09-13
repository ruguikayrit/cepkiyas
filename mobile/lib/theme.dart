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
  static const navBg = Color(0xFF0B1220);
  static const navInk = Color(0xFFE8EDF5);
  static const navMute = Color(0xFF8B939E);
  static const navActive = Color(0xFF6EA8FF);
  static const navIndicator = Color(0xFF1A2740);

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
        centerTitle: true,
        titleSpacing: 0,
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
        backgroundColor: navBg,
        indicatorColor: navIndicator,
        elevation: 0,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected) ? navActive : navMute,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? navActive : navMute,
          );
        }),
      ),
      dividerColor: line,
      cardColor: panel,
      snackBarTheme: const SnackBarThemeData(backgroundColor: ink, contentTextStyle: TextStyle(color: Colors.white)),
    );
  }
}
