part of 'create_password_parent_view.dart';

class CreatePasswordParentViewController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final newPasswordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final isHideNewPwd = true.obs;
  final isHideCfPwd = true.obs;
  final isLoading = false.obs;
  final authService = AuthServices();

  String? setupToken;

  @override
  void onInit() {
    super.onInit();
    _initializeArguments();
  }

  void _initializeArguments() {
    final args = Get.arguments as Map<String, dynamic>?;
    setupToken = args?['setup_token']?.toString();
  }

  void toggleNewPwd() {
    isHideNewPwd.toggle();
  }

  void toggleCfPwd() {
    isHideCfPwd.toggle();
  }

  Future<void> createPassword() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    final newPassword = newPasswordCtrl.text.trim();
    final confirmPassword = confirmPasswordCtrl.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      CustomSnackbar.error('please_fill_all_fields'.tr);
      return;
    }
    if (newPassword != confirmPassword) {
      CustomSnackbar.error('passwords_mismatch'.tr);
      return;
    }
    if (setupToken == null || setupToken!.isEmpty) {
      CustomSnackbar.error('request_failed'.tr);
      return;
    }

    try {
      isLoading.value = true;
      await authService.createParentPassword(
        setupToken: setupToken!,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      CustomSnackbar.success(
        'parent_password_created_successfully'.tr,
        title: 'success'.tr,
      );
      Get.offAllNamed(
        AppRoutes.loginScreen,
        arguments: {'defaultTab': 1},
      );
    } catch (error) {
      if (error is DioException) {
        CustomSnackbar.error(handleDioException(error));
      } else {
        CustomSnackbar.error('something_went_wrong_retry'.tr);
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    newPasswordCtrl.clear();
    confirmPasswordCtrl.clear();
    super.onClose();
  }
}
