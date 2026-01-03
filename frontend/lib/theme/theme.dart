import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {

  // Light Mode (our base colors)
  static final ColorScheme _lightScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primaryBlue,
    brightness: Brightness.light,
    primary: AppColors.primaryBlue,
    surface: AppColors.surface,
    onSurface: AppColors.textMain,
  );

  // Dark Mode (Placeholder if we want that)
  static final ColorScheme _darkScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primaryBlue,
    brightness: Brightness.dark,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightScheme,
      scaffoldBackgroundColor: AppColors.background,

      // We will customize specific components here later
      // Examples: AppBarTheme, ButtonThemeData, etc.
      
      // and the font (FontFamily) and TextStyles

    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _darkScheme,

      // exactly the same as in light mode but customized for dark mode
    );
  }
}