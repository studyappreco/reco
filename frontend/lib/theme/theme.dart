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

  // https://api.flutter.dev/flutter/material/TextTheme-class.html
  static final TextTheme _baseTextTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
    displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),

    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w400),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),

    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),

    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),

    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightScheme,
      scaffoldBackgroundColor: AppColors.standardWhitebackground,

      // We will customize specific components here later
      // Examples: AppBarTheme, ButtonThemeData, etc.
      
      // and the font (FontFamily) and TextStyles

      textTheme: _baseTextTheme,

      // Global styling for all FilledButtons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: AppColors.background,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          textStyle: _baseTextTheme.labelLarge,
        ),
      ),

      // Global styling for all text input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFF9FAFB),
        hintStyle: TextStyle(color: AppColors.textSecondary),
        prefixIconColor: AppColors.textSecondary,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: AppColors.border, width: 1.0),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
      ),



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