import 'package:tamdansers_lv2/core/api/services/base_api_service.dart';

class UserServices {
  final baseApi = BaseApiService();

  Future<Map<String, dynamic>> fechProfile() async {
    var response = await baseApi.get(
      endpoint: "/profile/me",
    );
    return response;
  }
}