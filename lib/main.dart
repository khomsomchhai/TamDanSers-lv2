import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tamdansers_lv2/app/localization/app_translation.dart';
import 'package:tamdansers_lv2/app/localization/localization_service.dart';
import 'package:tamdansers_lv2/app/routes/app_pages.dart';
import 'package:tamdansers_lv2/app/routes/app_routes.dart';
import 'package:tamdansers_lv2/app/themes/dark_theme.dart';
import 'package:tamdansers_lv2/app/themes/light_theme.dart';
import 'package:tamdansers_lv2/core/api/controllers/initial_binding.dart';
import 'package:tamdansers_lv2/core/services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  await initializeDateFormatting();

  final themeService = ThemeService();

  runApp(MainApp(themeService: themeService,));
}

class MainApp extends StatelessWidget {
  final ThemeService themeService;
  const MainApp({super.key, required this.themeService});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splashScreen,
      initialBinding: InitialBinding(),
      translations: AppTranslation(),
      locale: LocalizationService().getLocale(),

      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeService.themeMode,
      getPages: AppPages.getPages,
    );
  }
}
