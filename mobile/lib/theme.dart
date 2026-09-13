import 'package:flutter/material.dart';
import 'typography.dart';

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
    final text = CkType.textTheme();
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
        titleTextStyle: CkType.brandWordmark(26).copyWith(color: mint),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: panel2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: CkType.textTheme().bodyMedium?.copyWith(color: mute),
        hintStyle: CkType.textTheme().bodyMedium?.copyWith(color: mute),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: line)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: line)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: mint, width: 1.5)),
        errorStyle: CkType.textTheme().bodySmall?.copyWith(color: danger, fontSize: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: CkType.textTheme().labelLarge,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: CkType.textTheme().labelLarge,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: CkType.textTheme().labelLarge?.copyWith(color: mint)),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: CkType.textTheme().titleMedium,
        subtitleTextStyle: CkType.textTheme().bodySmall,
        contentPadding: EdgeInsets.zero,
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
          return CkType.navLabel(selected: states.contains(WidgetState.selected));
        }),
      ),
      dividerColor: line,
      cardColor: panel,
      snackBarTheme: const SnackBarThemeData(backgroundColor: ink, contentTextStyle: TextStyle(color: Colors.white)),
    );
  }
}
