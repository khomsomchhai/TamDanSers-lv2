part of 'login_screen_view.dart';

class LoginScreenViewController extends GetxController {
  final idCtrl = TextEditingController();
  final pwdCtrl = TextEditingController();

  final formKey = GlobalKey<FormState>();

  final isRemember = false.obs;
  final isHidePwd = true.obs;
  final isLoading = false.obs;

  final authService = AuthServices();
  final box = GetStorage();

  void togglePwd() {
    isHidePwd.value = !isHidePwd.value;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      CustomSnackbar.error("Please fill in all required fields.");
      return;
    }

    try {
      isLoading.value = true;

      final response = await authService.loginService(
        loginId: idCtrl.text.trim(),
        password: pwdCtrl.text,
      );

      final token = response["access_token"]?.toString().trim();

      if (token == null || token.isEmpty) {
        CustomSnackbar.error("Login failed.");
        return;
      }

      await box.write("token", token);
      await box.write("role", response["role"]);

      // Save FCM Token (don't block login if it fails)
      try {
        await FirebaseMessaging.instance.requestPermission();

        final fcmToken = await FirebaseMessaging.instance.getToken();

        debugPrint("FCM Token: $fcmToken");

        if (fcmToken != null) {
          await authService.saveFcmToken(fcmToken: fcmToken);
          debugPrint("FCM token saved successfully");
        }
      } catch (e) {
        debugPrint("Save FCM Token Error: $e");
      }

      switch (response["role"]) {
        case "student":
          Get.offAllNamed(AppRoutes.studentDashboard);
          break;

        case "parent":
          Get.offAllNamed(AppRoutes.parentDashboard);
          break;

        default:
          CustomSnackbar.error("Unknown user role.");
      }
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          CustomSnackbar.error(
            "Connection timed out. Please try again.",
          );
          break;

        case DioExceptionType.connectionError:
          CustomSnackbar.error(
            "Unable to connect. Please check your internet connection.",
          );
          break;

        case DioExceptionType.badResponse:
          switch (e.response?.statusCode) {
            case 400:
              CustomSnackbar.error("Invalid request.");
              break;

            case 401:
              CustomSnackbar.error("Login credentials are incorrect.");
              break;

            case 403:
              CustomSnackbar.error("Access denied.");
              break;

            case 404:
              CustomSnackbar.error("Service not found.");
              break;

            case 500:
              CustomSnackbar.error(
                "Server error. Please try again later.",
              );
              break;

            default:
              CustomSnackbar.error(
                "Something went wrong. Please try again.",
              );
          }
          break;

        case DioExceptionType.cancel:
          CustomSnackbar.error("Request cancelled.");
          break;

        case DioExceptionType.badCertificate:
          CustomSnackbar.error("Security certificate error.");
          break;

        case DioExceptionType.unknown:
        default:
          final error = e.error?.toString().toLowerCase() ?? "";

          if (error.contains("socketexception") ||
              error.contains("connection") ||
              error.contains("network")) {
            CustomSnackbar.error(
              "Unable to connect. Please check your internet connection.",
            );
          } else {
            CustomSnackbar.error(
              "Something went wrong. Please try again.",
            );
          }
      }
    } catch (e) {
      debugPrint("Login Error: $e");
      CustomSnackbar.error(
        "Something went wrong. Please try again.",
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    idCtrl.dispose();
    pwdCtrl.dispose();
    super.onClose();
  }
}