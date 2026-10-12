import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color seedColor = Color(0xFF6750A4);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      inputDecorationTheme: _inputDecorationTheme(colorScheme),
      filledButtonTheme: _filledButtonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(colorScheme),
      cardTheme: _cardTheme(colorScheme),
    );
  }

  static ThemeData dark() {
    final baseColorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );

    final colorScheme = baseColorScheme.copyWith(
      surface: Colors.black,
      surfaceDim: Colors.black,
      surfaceContainerLowest: Colors.black,
      surfaceContainerLow: const Color(0xFF121212),
      surfaceContainer: const Color(0xFF181818),
      surfaceContainerHigh: const Color(0xFF222222),
      surfaceContainerHighest: const Color(0xFF2C2C2C),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.black,
      canvasColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: _inputDecorationTheme(colorScheme),
      filledButtonTheme: _filledButtonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(colorScheme),
      cardTheme: _cardTheme(colorScheme),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(ColorScheme colors) {
    final borderRadius = BorderRadius.circular(12);
    final isDark = colors.brightness == Brightness.dark;

    return InputDecorationTheme(
      filled: true,
      fillColor: isDark
          ? const Color(0xFF161616)
          : colors.surfaceContainerHighest.withValues(alpha: 0.35),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF2A2A2A) : colors.outlineVariant,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: isDark
              ? const Color(0xFF2A2A2A)
              : colors.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: colors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: colors.error, width: 2),
      ),
      labelStyle: TextStyle(color: colors.onSurfaceVariant),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    );
  }

  static FilledButtonThemeData _filledButtonTheme() {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme colors) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(color: colors.outline),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  static CardThemeData _cardTheme(ColorScheme colors) {
    final isDark = colors.brightness == Brightness.dark;

    return CardThemeData(
      elevation: 0,
      color: isDark ? const Color(0xFF121212) : colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark
              ? const Color(0xFF222222)
              : colors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
