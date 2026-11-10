import 'package:flutter/material.dart';

class AppColors {
  static const Color forestGreen = Color(0xFF319A4B);
  static const Color lightGreen = Color(0xFF87C757);
  static const Color darkBlack = Color(0xFF020202);
  static const Color offWhite = Color(0xFFF7F8F5);
  static const Color yellowAlert = Color(0xFFF0F66E);
  static const Color terracotta = Color(0xFFE4572E);
}

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return ColorScheme.fromSeed(
      seedColor: AppColors.forestGreen,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.forestGreen,
      onPrimary: Colors.white,
      secondary: AppColors.lightGreen,
      onSecondary: AppColors.darkBlack,
      tertiary: AppColors.yellowAlert,
      onTertiary: AppColors.darkBlack,
      error: AppColors.terracotta,
      onError: Colors.white,
      surface: AppColors.offWhite,
      onSurface: AppColors.darkBlack,
    );
  }

  static ColorScheme darkScheme() {
    return ColorScheme.fromSeed(
      seedColor: AppColors.forestGreen,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.lightGreen,
      onPrimary: AppColors.darkBlack,
      secondary: AppColors.forestGreen,
      onSecondary: Colors.white,
      tertiary: AppColors.yellowAlert,
      onTertiary: AppColors.darkBlack,
      error: AppColors.terracotta,
      onError: Colors.white,
    );
  }

  ThemeData light() => theme(lightScheme());

  ThemeData dark() => theme(darkScheme());

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
  );
}
