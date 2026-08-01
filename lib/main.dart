import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'package:tamdansers_lv2/core/services/notification_service.dart';
import 'package:tamdansers_lv2/core/services/theme_service.dart';
import 'package:tamdansers_lv2/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fast initialization only
  await GetStorage.init();
  final themeService = ThemeService();

  // Initialize Firebase (required first)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Setup local notifications (quick)
  await setupLocalNotifications();

  // Defer heavy operations: date formatting and FCM setup
  // These will run in background after app loads
  Future.microtask(() async {
    await initializeDateFormatting();
    await setupFCM();
  });

  runApp(MainApp(
    themeService: themeService,
  ));
}

class MainApp extends StatefulWidget {
  final ThemeService themeService;
  const MainApp({super.key, required this.themeService});

  @override 
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {


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

      themeMode: widget.themeService.themeMode,
      getPages: AppPages.getPages,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        overscroll: false,
      ),
    );
  }
}
