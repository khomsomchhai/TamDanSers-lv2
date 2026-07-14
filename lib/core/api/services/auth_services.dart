import 'package:tamdansers_lv2/core/api/services/base_api_service.dart';

class AuthServices {
  final baseApi = BaseApiService();
  Future<Map<String, dynamic>> loginService(
      {required String loginId, required String password}) async {
    var response = await baseApi.post(
        endpoint: "/auth/login",
        data: {"login_id": loginId, "password": password});
    return response;
  }

  Future<Map<String, dynamic>> fechProfile() async {
    var response = await baseApi.get(
      endpoint: "/profile/me",
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
