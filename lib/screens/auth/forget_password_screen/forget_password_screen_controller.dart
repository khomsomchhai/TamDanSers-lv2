part of 'forget_password_screen_view.dart';

class ForgetPasswordScreenViewController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final phoneCtrl = TextEditingController();
  final isLoading = false.obs;
  final authService = AuthServices();

  Future<void> submitPhone() async {
    if (!formKey.currentState!.validate()) {
      CustomSnackbar.error('please_enter_phone_number'.tr);
      return;
    }

    var phone = phoneCtrl.text.trim();
    if (!phone.startsWith("0")) {
      phone = "0$phone";
    }

    try {
      isLoading.value = true;
      var response = await authService.forgotPasswordService(phone: phone);
      var message = response['message']?.toString() ?? 'otp_sent'.tr;
      CustomSnackbar.success(message);
      Get.toNamed(AppRoutes.resetPasswordScreen, arguments: {'phone': phone});
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
        String msg = 'request_failed'.tr;
        try {
          final data = resp.data;
          if (data != null) {
            msg = _extractErrorMessage(data);
          }
        } catch (_) {}

        if ((msg.isEmpty) || (msg == 'request_failed'.tr)) {
          if (resp.statusCode == 401) {
            msg = 'unauthorized_login_again'.tr;
          } else if (resp.statusCode == 404) {
            msg = 'not_found_phone'.tr;
          } else if (resp.statusCode == 500) {
            msg = 'sms_send_failed'.tr;
          } else if (resp.statusCode != null) {
            msg = 'request_failed'.tr;
          }
        }

        CustomSnackbar.error(msg);
        return;
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        CustomSnackbar.error('unable_to_connect'.tr);
      } else if (error.type == DioExceptionType.unknown) {
        var errorText = error.error?.toString().toLowerCase() ?? "";
        if (errorText.contains("socketexception") || errorText.contains("connection") || errorText.contains("network")) {
          CustomSnackbar.error('unable_to_connect'.tr);
        } else {
          CustomSnackbar.error('request_failed'.tr);
        }
      } else {
        CustomSnackbar.error('request_failed'.tr);
      }
    } else {
      var message = error.toString().replaceFirst('Exception: ', '');
      if (message.isEmpty || message == 'Failed') {
        message = 'request_failed'.tr;
      }
      CustomSnackbar.error('something_went_wrong'.tr);
    }
  }

  String _extractErrorMessage(dynamic data) {
    if (data is Map) {
      for (final key in ['message', 'detail', 'error', 'title']) {
        final value = data[key];
        if (value is String && value.trim().isNotEmpty) {
          final normalized = value.trim().toLowerCase();
          if (normalized.contains('not linked') || normalized.contains('telegram') || normalized.contains('sms')) {
            return 'We could not send the SMS. Please check your phone number and try again.'.tr;
          }
          return value.trim();
        }
      }

      if (data['errors'] is Map) {
        final errors = data['errors'] as Map;
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            final firstValue = value.first;
            if (firstValue is String && firstValue.trim().isNotEmpty) {
              final normalized = firstValue.trim().toLowerCase();
              if (normalized.contains('not linked') || normalized.contains('telegram') || normalized.contains('sms')) {
                return 'sms_send_failed'.tr;
              }
              return firstValue.trim();
            }
          } else if (value is String && value.trim().isNotEmpty) {
            final normalized = value.trim().toLowerCase();
            if (normalized.contains('not linked') || normalized.contains('telegram') || normalized.contains('sms')) {
              return 'We could not send the SMS. Please check your phone number and try again.'.tr;
            }
            return value.trim();
          }
        }
      }
    } else if (data is String && data.trim().isNotEmpty) {
      final normalized = data.trim().toLowerCase();
      if (normalized.contains('not linked') || normalized.contains('telegram')) {
        return 'phone_not_linked_telegram'.tr;
      }
      return data.trim();
    }

    return '';
  }

  @override
  void onClose() {
    phoneCtrl.dispose();
    super.onClose();
  }
}