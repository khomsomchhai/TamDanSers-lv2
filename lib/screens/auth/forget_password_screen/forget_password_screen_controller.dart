part of 'forget_password_screen_view.dart';

class ForgetPasswordScreenViewController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final phoneCtrl = TextEditingController();
  final isLoading = false.obs;
  final isTelegramLoading = false.obs;
  final authService = AuthServices();
  final telegramService = TelegramService();

  Future<void> submitPhone() async {
    if (!formKey.currentState!.validate()) {
      CustomSnackbar.error('Please enter your phone number.'.tr);
      return;
    }

    var phone = phoneCtrl.text.trim();
    if (!phone.startsWith("0")) {
      phone = "0$phone";
    }

    try {
      isLoading.value = true;
      var response = await authService.forgotPasswordService(phone: phone);
      var message = response['message']?.toString() ?? 'An OTP has been sent to your phone number.'.tr;
      CustomSnackbar.success(message);
      Get.toNamed(AppRoutes.resetPasswordScreen, arguments: {'phone': phone});
    } catch (error) {
      _handleError(error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> connectTelegram() async {
    var phone = phoneCtrl.text.trim();
    if (!phone.startsWith("0")) {
      phone = "0$phone";
    }
    try {
      isTelegramLoading.value = true;
      await telegramService.connectTelegram(phone);
    } finally {
      isTelegramLoading.value = false;
    }
  }
  
  void _handleError(dynamic error) {
    if (error is DioException) {
      final resp = error.response;
      if (resp != null) {
        String msg = 'Request failed'.tr;
        try {
          final data = resp.data;
          if (data != null) {
            if (data is Map && data['message'] != null) {
              msg = data['message'].toString();
            } else if (data is String && data.isNotEmpty) {
              msg = data.toString();
            }
          }
        } catch (_) {}

        if ((msg.isEmpty) || (msg == 'Request failed'.tr)) {
          if (resp.statusCode == 401) {
            msg = 'Unauthorized. Please login again.'.tr;
          } else if (resp.statusCode == 404) {
            msg = 'Not found. Please check the phone number.'.tr;
          } else if (resp.statusCode != null) {
            msg = 'Request failed (code: ${resp.statusCode})'.tr;
          }
        }

        CustomSnackbar.error(msg);
        return;
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        CustomSnackbar.error('Connection timed out. Please check your internet connection.'.tr);
      } else if (error.type == DioExceptionType.unknown) {
        var errorText = error.error?.toString().toLowerCase() ?? "";
        if (errorText.contains("socketexception") || errorText.contains("connection") || errorText.contains("network")) {
          CustomSnackbar.error('Unable to connect. Please check your internet connection.'.tr);
        } else {
          CustomSnackbar.error('Request failed'.tr);
        }
      } else {
        CustomSnackbar.error('Request failed'.tr);
      }
    } else {
      var message = error.toString().replaceFirst('Exception: ', '');
      if (message.isEmpty || message == 'Failed') {
        message = 'Request failed'.tr;
      }
      CustomSnackbar.error("Something went wrong");
    }
  }

  @override
  void onClose() {
    phoneCtrl.dispose();
    super.onClose();
  }
}