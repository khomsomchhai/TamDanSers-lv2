import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';

enum SnackPositionType { top, bottom }

class CustomSnackbar {
  static void success(
    String message, {
    String title = "Success",
    SnackPositionType position = SnackPositionType.bottom,
  }) {
    _show(
      message: message,
      title: title,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle,
      position: position,
    );
  }

  static void error(
    String message, {
    String title = "Error",
    SnackPositionType position = SnackPositionType.bottom,
  }) {
    _show(
      message: message,
      title: title,
      backgroundColor: AppColors.error,
      icon: Icons.error,
      position: position,
    );
  }

  static void warning(
    String message, {
    String title = "Warning",
    SnackPositionType position = SnackPositionType.bottom,
  }) {
    _show(
      message: message,
      title: title,
      backgroundColor: AppColors.warning,
      icon: Icons.warning_amber_rounded,
      position: position,
    );
  }

  static void info(
    String message, {
    String title = "Info",
    SnackPositionType position = SnackPositionType.bottom,
  }) {
    _show(
      message: message,
      title: title,
      backgroundColor: AppColors.primary,
      icon: Icons.info,
      position: position,
    );
  }

  static void _show({
    required String message,
    required String title,
    required Color backgroundColor,
    required IconData icon,
    required SnackPositionType position,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition:
          position == SnackPositionType.bottom ? SnackPosition.BOTTOM : SnackPosition.TOP,
      backgroundColor: backgroundColor,
      colorText: AppColors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      icon: Icon(icon, color: AppColors.white),
      duration: const Duration(seconds: 3),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
      animationDuration: const Duration(milliseconds: 500),
    );
  }
}