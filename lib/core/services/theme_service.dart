import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService {

  final box = GetStorage();
  final key = "isDarkMode";

  ThemeMode get themeMode {
    bool isDark = box.read(key) ?? false;

    return isDark
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  void switchTheme() {

    bool isDark = Get.isDarkMode;
    Get.changeThemeMode(
      isDark
          ? ThemeMode.light
          : ThemeMode.dark,
    );
    box.write(key, !isDark);
  }
}