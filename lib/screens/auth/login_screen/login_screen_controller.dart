part of 'login_screen_view.dart';

class LoginScreenViewController extends GetxController {
  final studentIdCtrl = TextEditingController();
  final parentIdCtrl = TextEditingController();
  final studentPwdCtrl = TextEditingController();
  final parentPwdCtrl = TextEditingController();

  TextEditingController get currentIdCtrl =>
      selectedTab.value == 1 ? parentIdCtrl : studentIdCtrl;

  TextEditingController get currentPwdCtrl =>
      selectedTab.value == 1 ? parentPwdCtrl : studentPwdCtrl;

  final formKey = GlobalKey<FormState>();

  final selectedTab = 0.obs;
  final previousTab = 0.obs;
  final isRemember = false.obs;
  final isHidePwd = true.obs;
  final isLoading = false.obs;

  var isKeyboardOpen = false.obs;
  final authService = AuthServices();
  final box = GetStorage();

  void changeTab(int index) {
    if (selectedTab.value == index) return;
    previousTab.value = selectedTab.value;
    selectedTab.value = index;
  }

  void updateKeyboard(BuildContext context) {
    isKeyboardOpen.value = MediaQuery.of(context).viewInsets.bottom > 0;
  }

  void togglePwd() {
    isHidePwd.value = !isHidePwd.value;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      CustomSnackbar.error('please_fill_required'.tr);
      return;
    }

    try {
      isLoading.value = true;

      final response = selectedTab.value == 1
          ? await authService.loginParentService(
              studentCode: currentIdCtrl.text.trim(),
              password: currentPwdCtrl.text,
            )
          : await authService.loginService(
              loginId: currentIdCtrl.text.trim(),
              password: currentPwdCtrl.text,
            );

      final token = response["access_token"]?.toString().trim();

      if (token == null || token.isEmpty) {
        CustomSnackbar.error('login_failed'.tr);
        return;
      }

      await box.write("token", token);
await box.write("role", response["role"]);

if (response["role"] == "parent") {
  await box.write("parent", response["parent"]);
  await box.write("students", response["students"]);
}

      // Fetch profile immediately after login success
      try {
        await Get.find<UserController>().getProfile();
      } catch (e) {
        debugPrint("GetProfile Error: $e");
      }

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
          CustomSnackbar.error('unknown_user_role'.tr);
      }
    } on DioException catch (e) {
      CustomSnackbar.error(handleDioException(e));
    } catch (e) {
      debugPrint("Login Error: $e");
      CustomSnackbar.error(
        'something_went_wrong_retry'.tr,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    studentIdCtrl.dispose();
    parentIdCtrl.dispose();
    studentPwdCtrl.dispose();
    parentPwdCtrl.dispose();
    super.onClose();
  }
}