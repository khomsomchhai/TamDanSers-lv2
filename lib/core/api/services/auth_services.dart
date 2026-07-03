import 'package:dio/dio.dart';
import 'package:tamdansers_lv2/core/api/services/base_api_service.dart';

class AuthServices {
  final baseApi = BaseApiService();
  Future<Map<String, dynamic>> loginService({
    required String loginId,
    required String password
  }) async {
    var response = await baseApi.post(
      endpoint: "/auth/login", 
      data: {
        "login_id" : loginId,
        "password" : password
      }
    );
    return response;
  }

  Future<Map<String, dynamic>> fechProfile() async {
    var response = await baseApi.get(
      endpoint: "/profile/me",
    );
    return response;
  }

  Future<bool> checkTelegramService({
    required String phone,
  }) async {
    try {
      var response = await baseApi.post(
        endpoint: "/auth/check-telegram",
        data: {
          "phone": phone,
        },
      );
      return response['telegram_linked'] == true;
    } on DioException catch (e) {
      // If the endpoint doesn't exist on the server, skip the telegram check
      if (e.response?.statusCode == 404) {
        return true;
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> forgotPasswordService({
    required String phone,
  }) async {
    var response = await baseApi.post(
      endpoint: "/auth/forgot-password",
      data: {
        "phone": phone,
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> resetPasswordService({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    var response = await baseApi.post(
      endpoint: "/auth/reset-password",
      data: {
        "phone": phone,
        "otp": otp,
        "new_password": newPassword,
      },
    );
    return response;
  }
}