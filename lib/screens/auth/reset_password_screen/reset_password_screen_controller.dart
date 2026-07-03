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
    timerText.value = 'Resend OTP in ${_secondsRemaining}s'.tr;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsRemaining--;
      if (_secondsRemaining <= 0) {
        canResend.value = true;
        timerText.value = 'Resend OTP'.tr;
        timer.cancel();
      } else {
        timerText.value = 'Resend OTP in ${_secondsRemaining}s'.tr;
      }
    });
  }

  void toggleNewPwd() {
    isHideNewPwd.value = !isHideNewPwd.value;
  }
  void toggleCfPwd() {
    isHideCfPwd.value = !isHideCfPwd.value;
  }

  Future<void> resendOtp() async {
    if (!canResend.value) return;
    if (phone.isEmpty) {
      CustomSnackbar.error('Phone number is missing.'.tr);
      return;
    }
    try {
      isLoading.value = true;
      final response = await authService.forgotPasswordService(phone: phone);
      final message = response['message']?.toString() ?? 'OTP resent successfully.'.tr;
      CustomSnackbar.success(message);
      _startResendTimer();
    } catch (error) {
      _handleError(error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword() async {
    final otp = otpCode.trim();
    final newPassword = newPasswordCtrl.text.trim();
    final confirmPassword = confirmPasswordCtrl.text.trim();

    if (otp.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      CustomSnackbar.error('Please fill in all fields.'.tr);
      return;
    }
    if (otp.length != 6) {
      CustomSnackbar.error('Please enter a 6-digit OTP.'.tr);
      return;
    }
    if (newPassword != confirmPassword) {
      CustomSnackbar.error('New password and confirm password do not match.'.tr);
      return;
    }

    try {
      isLoading.value = true;
      final response = await authService.resetPasswordService(
        phone: phone,
        otp: otp,
        newPassword: newPassword,
      );
      final message = response['message']?.toString() ?? 'Password changed successfully.'.tr;
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
      final resp = error.response;
      if (resp != null) {
        String message = 'Request failed'.tr;
        try {
          final data = resp.data;
          if (data is Map && data['message'] != null) {
            message = data['message'].toString();
          } else if (data is String && data.isNotEmpty) {
            message = data.toString();
          }
        } catch (_) {}

        if (message.isEmpty || message == 'Request failed'.tr) {
          if (resp.statusCode == 401) {
            message = 'Unauthorized. Please login again.'.tr;
          } else if (resp.statusCode == 404) {
            message = 'The request could not be completed.'.tr;
          } else if (resp.statusCode != null) {
            message = 'Something went wrong. Please try again.'.tr;
          }
        }

        CustomSnackbar.error(message);
        return;
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        CustomSnackbar.error('Connection timed out. Please check your internet connection.'.tr);
      } else if (error.type == DioExceptionType.unknown) {
        final errorText = error.error?.toString().toLowerCase() ?? '';
        if (errorText.contains('socketexception') || errorText.contains('connection') || errorText.contains('network')) {
          CustomSnackbar.error('Unable to connect. Please check your internet connection.'.tr);
        } else {
          CustomSnackbar.error('Something went wrong. Please try again.'.tr);
        }
      } else {
        CustomSnackbar.error('Something went wrong. Please try again.'.tr);
      }
    } else {
      final message = error.toString().replaceFirst('Exception: ', '');
      if (message.isEmpty || message == 'Failed') {
        CustomSnackbar.error('Something went wrong. Please try again.'.tr);
      } else {
        CustomSnackbar.error('Something went wrong. Please try again.'.tr);
      }
    }
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
