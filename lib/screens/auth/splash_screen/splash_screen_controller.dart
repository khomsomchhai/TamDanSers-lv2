part of 'splash_screen_view.dart';

class SplashScreenViewController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final box = GetStorage();

  late final AnimationController animationController;
  late final Animation<double> logoFade;
  late final Animation<double> logoScale;

  @override
  void onInit() {
    super.onInit();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    logoFade = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOut,
    ).drive(
      Tween(begin: 0.0, end: 1.0),
    );

    logoScale = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutCubic,
    ).drive(
      Tween(begin: 0.85, end: 1.0),
    );

    animationController.forward();
  }

  @override
  void onReady() {
    super.onReady();
    startNavigation();
  }

  Future<void> startNavigation() async {
    final results = await Future.wait([
      Future.delayed(const Duration(milliseconds: 650)),
      _resolveDestination(),
    ]);

    final destination = results[1] as String;
    Get.offAllNamed(destination);
  }

  Future<String> _resolveDestination([int retryCount = 0]) async {
    final token = box.read<String>("token");
    final role = box.read<String>("role");

    if (token == null || token.isEmpty) {
      return AppRoutes.loginScreen;
    }

    if (!_isValidRole(role)) {
      await _clearSession();
      return AppRoutes.loginScreen;
    }

    try {
      await Get.find<UserController>().getProfile().timeout(
            const Duration(seconds: 8),
            onTimeout: () => throw DioException(
              requestOptions: RequestOptions(path: "/profile/me"),
              type: DioExceptionType.connectionTimeout,
            ),
          );

      return _destinationForRole(role!);
    } catch (error) {
      debugPrint("Splash Error: $error");

      // Token expired or invalid
      if (_isUnauthorizedError(error)) {
        await _clearSession();
        return AppRoutes.loginScreen;
      }

      // Retry every other error
      return await _handleNetworkRetry(role!, retryCount);
    }
  }

  Future<String> _handleNetworkRetry(
    String role,
    int retryCount,
  ) async {
    // Automatic retry 3 times
    if (retryCount < 3) {
      final delay = Duration(
        seconds: 1 << retryCount,
      ); // 1s -> 2s -> 4s

      debugPrint(
          "Retry ${retryCount + 1}/3 after ${delay.inSeconds}s...");

      await Future.delayed(delay);

      return _resolveDestination(retryCount + 1);
    }

    // Still failed
    final shouldRetry = await CustomDialog.showNetworkRetry(
      message: "unable_to_verify_account".tr,
      barrierDismissible: false,
    );

    if (shouldRetry) {
      return _resolveDestination(0);
    }

    return _destinationForRole(role);
  }

  Future<void> _clearSession() async {
    await box.remove("token");
    await box.remove("role");
  }

  bool _isValidRole(String? role) {
    return role == "student" || role == "parent";
  }

  String _destinationForRole(String role) {
    switch (role) {
      case "student":
        return AppRoutes.studentDashboard;
      case "parent":
        return AppRoutes.parentDashboard;
      default:
        return AppRoutes.loginScreen;
    }
  }

  bool _isUnauthorizedError(Object error) {
    if (error is DioException) {
      return error.response?.statusCode == 401;
    }

    return false;
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}