import 'package:flutter/material.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_text_styles.dart';

ThemeData get darkTheme => ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.darkBackground,
  cardColor: AppColors.grey,
  dividerColor: Colors.white12,
  hintColor: AppColors.hintColor,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    surface: AppColors.white,
    onPrimary: AppColors.white,
    onSurface: AppColors.dark,
    error: AppColors.error,
    onError: AppColors.white

  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkBackground,
    foregroundColor: AppColors.white,
    elevation: 0,
    centerTitle: true,
  ),
  textTheme: TextTheme(
    headlineLarge: AppTextStyles.headlineLarge.copyWith(
      color: AppColors.white,
    ),

    headlineMedium: AppTextStyles.headlineMedium.copyWith(
      color: AppColors.white,
    ),

    headlineSmall: AppTextStyles.headlineSmall.copyWith(
      color: AppColors.white,
    ),

    titleLarge: AppTextStyles.titleLarge.copyWith(
      color: AppColors.white,
    ),

    titleMedium: AppTextStyles.titleMedium.copyWith(
      color: AppColors.white,
    ),

    titleSmall: AppTextStyles.titleSmall.copyWith(
      color: AppColors.white
    ),

    bodyLarge: AppTextStyles.bodyLarge.copyWith(
      color: AppColors.white,
    ),

    bodyMedium: AppTextStyles.bodyMedium.copyWith(
      color: AppColors.white,
    ),

    bodySmall: AppTextStyles.bodySmall.copyWith(
      color: AppColors.white,
    ),
  ),
);

