import 'package:flutter/material.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_text_styles.dart';

ThemeData get lightTheme => ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.lightBackground,
  cardColor: AppColors.white,
  dividerColor: AppColors.grey,
  hintColor: AppColors.hintColor,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    surface: AppColors.white,
    onPrimary: AppColors.white,
    onSurface: AppColors.dark,
    error: AppColors.error,
    onError: AppColors.white
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.lightBackground,
    foregroundColor: AppColors.dark,
    elevation: 0,
    centerTitle: true,
  ),
  textTheme: TextTheme(

    headlineLarge: AppTextStyles.headlineLarge.copyWith(
      color: AppColors.dark,
    ),

    headlineMedium: AppTextStyles.headlineMedium.copyWith(
      color: AppColors.dark,
    ),

    headlineSmall: AppTextStyles.headlineSmall.copyWith(
      color: AppColors.dark,
    ),

    titleLarge: AppTextStyles.titleLarge.copyWith(
      color: AppColors.dark,
    ),

    titleMedium: AppTextStyles.titleMedium.copyWith(
      color: AppColors.dark,
    ),

    titleSmall: AppTextStyles.titleSmall.copyWith(
      color: AppColors.dark
    ),

    bodyLarge: AppTextStyles.bodyLarge.copyWith(
      color: AppColors.dark,
    ),

    bodyMedium: AppTextStyles.bodyMedium.copyWith(
      color: AppColors.dark,
    ),

    bodySmall: AppTextStyles.bodySmall.copyWith(
      color: AppColors.dark,
    ),
  ),
);

