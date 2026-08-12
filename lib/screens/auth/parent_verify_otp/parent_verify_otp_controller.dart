part of 'parent_verify_otp_view.dart';

class ParentVerifyOtpViewController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final otpControllers = List.generate(6, (_) => TextEditingController());
  final otpFocusNodes = List.generate(6, (_) => FocusNode());
  final isLoading = false.obs;

  final authService = AuthServices();
  String studentCode = '';
  String parentPhone = '';

  String get otpCode => otpControllers.map((c) => c.text).join();

  @override
  void onInit() {
    super.onInit();
    _initializeArgs();
  }

  void _initializeArgs() {
    final args = Get.arguments as Map<String, dynamic>?;
    studentCode = args?['student_code']?.toString() ?? '';
    parentPhone = args?['parent_phone']?.toString() ?? '';
  }

  void handleOtpChanged(BuildContext context, int index, String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length > 1) {
      for (var offset = 0; offset < digits.length && index + offset < 6; offset++) {
        otpControllers[index + offset].text = digits[offset];
      }
      final nextIndex = (index + digits.length).clamp(0, 5);
      if (index + digits.length >= 6) {
        FocusScope.of(context).unfocus();
      } else {
        otpFocusNodes[nextIndex].requestFocus();
      }
      return;
    }

    if (digits.isNotEmpty && index < 5) {
      otpFocusNodes[index + 1].requestFocus();
    } else if (digits.isEmpty && index > 0) {
      otpFocusNodes[index - 1].requestFocus();
    }
  }

  Future<void> resendOtp() async {
    if (studentCode.isEmpty || parentPhone.isEmpty) {
      CustomSnackbar.error('please_fill_all_fields'.tr);
      return;
    }
    try {
      isLoading.value = true;
      final response = await authService.requestParentOtp(
        studentCode: studentCode,
        parentPhone: parentPhone,
      );
      final message = response['message']?.toString() ?? 'otp_resent_successfully'.tr;
      CustomSnackbar.success(message);
    } catch (e) {
      if (e is DioException) CustomSnackbar.error(handleDioException(e));
      else CustomSnackbar.error('something_went_wrong_retry'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    final otp = otpCode.trim();
    if (otp.isEmpty || otp.length != 6) {
      CustomSnackbar.error('please_enter_otp'.tr);
      return;
    }
    try {
      isLoading.value = true;
      final response = await authService.verifyParentOtp(
        studentCode: studentCode,
        parentPhone: parentPhone,
        otp: otp,
      );
      final setupToken = response['setup_token']?.toString();
      if (setupToken == null || setupToken.isEmpty) {
        CustomSnackbar.success(response['message']?.toString() ?? 'otp_sent'.tr);
        Get.offAllNamed(AppRoutes.loginScreen);
      } else {
        CustomSnackbar.success(response['message']?.toString() ?? 'otp_sent'.tr);
        Get.toNamed(
          AppRoutes.parentCreatePassword,
          arguments: {
            'setup_token': setupToken,
          },
        );
      }
    } catch (e) {
      if (e is DioException) {
        CustomSnackbar.error(handleDioException(e));
      } else {
        CustomSnackbar.error('something_went_wrong_retry'.tr);
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    for (final c in otpControllers) {
      c.dispose();
    }
    for (final n in otpFocusNodes) {
      n.dispose();
    }
    super.onClose();
  }
}