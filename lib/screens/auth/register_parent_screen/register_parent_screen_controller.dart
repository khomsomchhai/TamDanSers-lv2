part of 'register_parent_screen_view.dart';

class RegisterParentScreenViewController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final studentIdCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final isLoading = false.obs;

  void continueRegistration() {
    Get.focusScope?.unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;

    // The registration API is not available in AuthServices yet. Validation is
    // kept here so the submission call can be added without changing the UI.
  }

  @override
  void onClose() {
    studentIdCtrl.dispose();
    phoneCtrl.dispose();
    super.onClose();
  }
}
