part of 'reset_password_screen_view.dart';

class ResetPasswordScreenViewController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final newPasswordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final isLoading = false.obs;
  final isHideNewPwd = true.obs;
  final isHideCfPwd = true.obs;
  final timerText = ''.obs;
  final canResend = false.obs;
  final authService = AuthServices();
  final otpControllers = List.generate(6, (_) => TextEditingController());
  final otpFocusNodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _secondsRemaining = 300;
  String phone = '';

  String get otpCode => otpControllers.map((controller) => controller.text).join();

  @override
  void onInit() {
    super.onInit();
    _initializePhone();
    _startResendTimer();
  }

  void _initializePhone() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    phone = arguments?['phone']?.toString() ?? '';
  }

  void _startResendTimer() {
    _secondsRemaining = 300;
    canResend.value = false;
    timerText.value = '${'resend_otp_in'.tr} ${_secondsRemaining}s';
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsRemaining--;
      if (_secondsRemaining <= 0) {
        canResend.value = true;
        timerText.value = 'resend_otp'.tr;
        timer.cancel();
      } else {
        timerText.value = '${'resend_otp_in'.tr} ${_secondsRemaining}s';
      }
    });
  }

  void toggleNewPwd() {
    isHideNewPwd.value = !isHideNewPwd.value;
  }
  void toggleCfPwd() {
    isHideCfPwd.value = !isHideCfPwd.value;
  }

  void handleOtpChanged(BuildContext context, int index, String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    // Support pasting the complete code into any OTP field.
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
    if (!canResend.value) return;
    if (phone.isEmpty) {
      CustomSnackbar.error('phone_number_missing'.tr);
      return;
    }
    try {
      isLoading.value = true;
      final response = await authService.forgotPasswordService(phone: phone);
      final message = response['message']?.toString() ?? 'otp_resent_successfully'.tr;
      CustomSnackbar.success(message);
      _startResendTimer();
    } catch (error) {
      _handleError(error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword() async {
    if (phone.isEmpty) {
      CustomSnackbar.error('phone_number_missing'.tr);
      return;
    }
    if (!(formKey.currentState?.validate() ?? false)) {
      CustomSnackbar.error('please_correct_fields'.tr);
      return;
    }

    final otp = otpCode.trim();
    final newPassword = newPasswordCtrl.text.trim();
    final confirmPassword = confirmPasswordCtrl.text.trim();

    if (otp.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      CustomSnackbar.error('please_fill_all_fields'.tr);
      return;
    }
    if (otp.length != 6) {
      CustomSnackbar.error('please_enter_otp'.tr);
      return;
    }
    if (newPassword != confirmPassword) {
      CustomSnackbar.error('passwords_mismatch'.tr);
      return;
    }

    try {
      isLoading.value = true;
      final response = await authService.resetPasswordService(
        phone: phone,
        otp: otp,
        newPassword: newPassword,
      );
      final message = response['message']?.toString() ?? 'password_changed_successfully'.tr;
      CustomSnackbar.success(message);
      Get.offAllNamed(AppRoutes.loginScreen);
    } catch (error) {
      _handleError(error);
    } finally {
      isLoading.value = false;
    }
  }

  void _handleError(dynamic error) {
    if (error is DioException) {
      // Timeout
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        CustomSnackbar.error(
          'unable_to_connect'.tr,
        );
        return;
      }

      // No internet
      if (error.type == DioExceptionType.unknown) {
        final text = error.error.toString().toLowerCase();

        if (text.contains('socketexception') ||
            text.contains('connection') ||
            text.contains('network')) {
          CustomSnackbar.error(
            'unable_to_connect'.tr,
          );
        } else {
          CustomSnackbar.error(
            'something_went_wrong_retry'.tr,
          );
        }
        return;
      }

      switch (error.response?.statusCode) {
        case 400:
          CustomSnackbar.error('invalid_request'.tr);
          break;

        case 401:
          CustomSnackbar.error('invalid_otp_password'.tr);
          break;

        case 403:
          CustomSnackbar.error('access_denied'.tr);
          break;

        case 404:
          CustomSnackbar.error('requested_information_not_found'.tr);
          break;

        case 409:
          CustomSnackbar.error('request_already_exists'.tr);
          break;

        case 422:
          CustomSnackbar.error('please_check_input'.tr);
          break;

        case 500:
          CustomSnackbar.error(
            'server_error_retry'.tr,
          );
          break;

        default:
          CustomSnackbar.error(
            'something_went_wrong_retry'.tr,
          );
      }

      return;
    }

    CustomSnackbar.error(
      'something_went_wrong_retry'.tr,
    );
  }

  @override
  void onClose() {
    _timer?.cancel();
    for (final controller in otpControllers) {
      controller.dispose();
    }
    for (final node in otpFocusNodes) {
      node.dispose();
    }
    newPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.onClose();
  }
}
