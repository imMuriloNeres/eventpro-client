import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    fontFamily: "Poppins",
    primaryColor: AppColors.bluePrimary,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.bluePrimary,
      primary: AppColors.bluePrimary,
      secondary: AppColors.blueSecondary,
      surface: AppColors.background,
      error: AppColors.redPrimary
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textSecondary)
    )
  );
}
