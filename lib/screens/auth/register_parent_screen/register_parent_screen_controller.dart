part of 'register_parent_screen_view.dart';

class RegisterParentScreenViewController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final studentIdCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final isLoading = false.obs;

  Future<void> continueRegistration() async {
    Get.focusScope?.unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;

    final normalizedPhone = _normalizePhone(phoneCtrl.text.trim());

    isLoading.value = true;
    try {
      final response = await AuthServices().requestParentOtp(
        studentCode: studentIdCtrl.text.trim(),
        parentPhone: normalizedPhone,
      );

      final rawMessage = response['message']?.toString();
      final message = rawMessage == null ||
              rawMessage.toLowerCase() == 'otp sent successfully' ||
              rawMessage.toLowerCase() == 'an otp has been sent to your phone number.'
          ? 'otp_sent'.tr
          : rawMessage;
      CustomSnackbar.success(message, title: 'success'.tr);
      // Navigate to OTP verification screen
      Get.toNamed(
        AppRoutes.parentVerifyOtp,
        arguments: {
          'student_code': studentIdCtrl.text.trim(),
          'parent_phone': normalizedPhone,
        },
      );
    } on DioException catch (e) {
      CustomSnackbar.error(handleDioException(e));
    } catch (_) {
      CustomSnackbar.error('something_went_wrong_retry'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  String _normalizePhone(String phone) {
    if (phone.isEmpty || phone.startsWith('0')) return phone;
    return '0$phone';
  }

  @override
  void onClose() {
    studentIdCtrl.clear();
    phoneCtrl.clear();
    super.onClose();
  }
}
