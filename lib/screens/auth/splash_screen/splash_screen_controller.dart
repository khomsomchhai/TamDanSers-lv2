part of 'splash_screen_view.dart';

class SplashScreenViewController extends GetxController {
  var box = GetStorage();

  @override
  void onReady() {
    super.onReady();
    startNavigation();
  }

  Future<void> startNavigation() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    await checkAuth();
  }

  Future<void> checkAuth() async {

    final token = box.read<String>("token");
    final role = box.read<String>("role");

    debugPrint("Token: $token");
    debugPrint("Role: $role");

    if (token == null || token.isEmpty) {
      Get.offAllNamed(AppRoutes.loginScreen);
      return;
    }

    try {
      // validate token
      await Get.find<UserController>().getProfile();

      if (role == "student") {
        Get.offAllNamed(AppRoutes.studentDashboard);
      } else if (role == "parent") {
        Get.offAllNamed(AppRoutes.parentDashboard);
      }else {
        await logout();
      }
    } catch(_) {
      await logout();
    }
  }

  Future<void> logout() async {
    await box.remove("token");
    await box.remove("role");

    Get.offAllNamed(AppRoutes.loginScreen);
  }

  
}