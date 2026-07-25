part of 'parent_verify_otp_view.dart';

class ParentVerifyOtpViewController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final otpControllers = List.generate(6, (_) => TextEditingController());
  final otpFocusNodes = List.generate(6, (_) => FocusNode());
  final timerText = ''.obs;
  final canResend = false.obs;
  final isLoading = false.obs;
  Timer? _timer;
  int _secondsRemaining = 120;

  final authService = AuthServices();
  String studentCode = '';
  String parentPhone = '';

  String get otpCode => otpControllers.map((c) => c.text).join();

  @override
  void onInit() {
    super.onInit();
    _initializeArgs();
    _startResendTimer();
  }

  void _initializeArgs() {
    final args = Get.arguments as Map<String, dynamic>?;
    studentCode = args?['student_code']?.toString() ?? '';
    parentPhone = args?['parent_phone']?.toString() ?? '';
  }

  void _startResendTimer() {
    _secondsRemaining = 120;
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
    if (!canResend.value) return;
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
      _startResendTimer();
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
    _timer?.cancel();
    for (final c in otpControllers) {
      c.dispose();
    }
    for (final n in otpFocusNodes) {
      n.dispose();
    }
    super.onClose();
  }
}