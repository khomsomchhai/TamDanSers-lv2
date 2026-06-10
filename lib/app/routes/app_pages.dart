import 'package:get/route_manager.dart';
import 'package:tamdansers_lv2/app/routes/app_routes.dart';
import 'package:tamdansers_lv2/screens/auth/login_screen/login_screen_view.dart';
import 'package:tamdansers_lv2/screens/auth/splash_screen/splash_screen_view.dart';

class AppPages {
  static final List<GetPage> getPages = [
    GetPage(
      name: AppRoutes.splashScreen, 
      page: () => SplashScreenView(),
      binding: SplashScreenViewBinding(),
      transition: Transition.fadeIn
    ),
    GetPage(
      name: AppRoutes.loginScreen, 
      page: () => LoginScreenView(),
      binding: LoginScreenViewBinding(),
      transition: Transition.fadeIn
    )
  ];
}