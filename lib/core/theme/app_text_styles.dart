import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle h1 = TextStyle(fontSize: 32, fontWeight: FontWeight.w700);
  static const TextStyle h2 = TextStyle(fontSize: 24, fontWeight: FontWeight.w600);
  static const TextStyle h3 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
  static const TextStyle h4 = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  static const TextStyle h5 = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  static const TextStyle bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
  static const TextStyle bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
  static const TextStyle bodySmall = TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
  static const TextStyle labelLarge = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
  static const TextStyle labelSmall = TextStyle(fontSize: 11, fontWeight: FontWeight.w500);
  static const TextStyle priceLarge = TextStyle(fontSize: 22, fontWeight: FontWeight.w700);
  static const TextStyle priceMedium = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    colorScheme: const ColorScheme.light(primary: AppColors.primary, secondary: AppColors.secondary),
  );
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    colorScheme: const ColorScheme.dark(primary: AppColors.primary, secondary: AppColors.secondary),
  );
}
