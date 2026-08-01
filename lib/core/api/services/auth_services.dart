import 'package:dio/dio.dart';
import 'package:tamdansers_lv2/core/api/services/base_api_service.dart';

class AuthServices {
  final baseApi = BaseApiService();

  Future<Map<String, dynamic>> loginService(
      {required String loginId, required String password}) async {
    var response = await baseApi.post(
      endpoint: "/auth/login",
      data: {"login_id": loginId, "password": password},
    );
    return response;
  }

  Future<Map<String, dynamic>> loginParentService(
      {required String studentCode, required String password}) async {
    var response = await baseApi.post(
      endpoint: "/auth/parent/login",
      data: {"student_code": studentCode, "password": password},
    );
    return response;
  }

  Future<Map<String, dynamic>> requestParentOtp({
    required String studentCode,
    required String parentPhone,
  }) async {
    var response = await baseApi.post(
      endpoint: "/auth/parent/request-otp",
      data: {
        "student_code": studentCode,
        "parent_phone": parentPhone,
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> verifyParentOtp({
    required String studentCode,
    required String parentPhone,
    required String otp,
  }) async {
    var response = await baseApi.post(
      endpoint: "/auth/parent/verify-otp",
      data: {
        "student_code": studentCode,
        "parent_phone": parentPhone,
        "otp": otp,
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> createParentPassword({
    required String setupToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    var response = await baseApi.post(
      endpoint: "/auth/parent/create-password",
      data: {
        "setup_token": setupToken,
        "new_password": newPassword,
        "confirm_password": confirmPassword,
      },
    );
    return response;
  }
  Future<Map<String, dynamic>> fechProfile() async {
  var response = await baseApi.get(
    endpoint: "/profile/me",
  );

  return response;
}

Future<Map<String, dynamic>> getParentChildren() async {
  final response = await baseApi.get(
    endpoint: "/parents/children",
  );

  return response;
}



  Future<bool> checkSmsService({
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

  Future<Map<String, dynamic>> saveFcmToken({
    required String fcmToken,
  }) async {
    var response = await baseApi.post(
      endpoint: "/notifications/fcm-token",
      data: {
        "token": fcmToken,
      },
    );
    return response;
  }
}
