import 'package:flutter/material.dart';

abstract final class Palette {
  static const burntOrange = Color(0xFFBE5103);
  static const sun = Color(0xFFFFCE1B);
  static const teal = Color(0xFF069494);
  static const rust = Color(0xFFB7410E);
  static const cream = Color(0xFFFFF7E8);
  static const sand = Color(0xFFF7E6C4);
  static const paper = Color(0xFFFFFDF8);
  static const espresso = Color(0xFF3A2414);
}

abstract final class Spacing {
  static const s = 8.0;
  static const m = 16.0;
  static const l = 24.0;
  static const fabClearance = 96.0;
}

abstract final class Fonts {
  static const display = 'Arapey';
  static const body = 'Lato';
}

const _radius = 16.0;
const _appBarTitleSize = 32.0;
const _titleSize = 22.0;

ThemeData buildTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: Palette.burntOrange,
        brightness: Brightness.light,
      ).copyWith(
        primary: Palette.burntOrange,
        onPrimary: Colors.white,
        secondary: Palette.teal,
        onSecondary: Colors.white,
        tertiary: Palette.sun,
        onTertiary: Palette.espresso,
        error: Palette.rust,
        surface: Palette.cream,
        onSurface: Palette.espresso,
      );
  final base = ThemeData(
    colorScheme: scheme,
    fontFamily: Fonts.body,
    scaffoldBackgroundColor: Palette.cream,
  );
  final shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(_radius),
  );

  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      titleLarge: const TextStyle(
        fontFamily: Fonts.display,
        fontSize: _titleSize,
        color: Palette.espresso,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Palette.cream,
      foregroundColor: Palette.espresso,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: Fonts.display,
        fontSize: _appBarTitleSize,
        color: Palette.burntOrange,
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Palette.sand,
      indicatorColor: Palette.sun,
    ),
    cardTheme: CardThemeData(color: Palette.paper, elevation: 0, shape: shape),
    chipTheme: const ChipThemeData(
      backgroundColor: Palette.paper,
      side: BorderSide(color: Palette.sand),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Palette.paper,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius),
        borderSide: BorderSide.none,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Palette.teal,
      foregroundColor: Colors.white,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? Palette.teal : null,
      ),
    ),
  );
}
