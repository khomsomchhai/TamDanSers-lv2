import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService {

  final box = GetStorage();
  final key = "isDarkMode";

  ThemeMode get themeMode {
    final isDark = box.read(key) ?? false;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  bool get isDarkMode => Get.isDarkMode;

  void switchTheme() {
    final isDark = Get.isDarkMode;
    setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  void setThemeMode(ThemeMode mode) {
    final isDark = mode == ThemeMode.dark;
    box.write(key, isDark);
    Get.changeThemeMode(mode);
  }
}