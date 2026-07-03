import 'package:tamdansers_lv2/core/api/services/base_api_service.dart';
import 'package:tamdansers_lv2/data/model/permission_model.dart';

class PermissionServices {
  final baseApi = BaseApiService();

  // Backend must provide POST /permissions/ endpoint.
  Future<Map<String, dynamic>> createPermission({
    required String type,
    required String fromDate,
    required String toDate,
    required String reason,
  }) async {
    final response = await baseApi.post(
      endpoint: '/permissions/',
      data: {
        'type': type,
        'start_date': fromDate,
        'end_date': toDate,
        'reason': reason,
      },
    );
    return Map<String, dynamic>.from(response);
  }

  // Backend must provide GET /permissions/student/me endpoint.
  Future<List<PermissionModel>> fetchMyPermissions() async {
    final response = await baseApi.get(
      endpoint: '/permissions/student/me',
    );

    final data = response is List
        ? response
        : (response['data'] ?? response['permissions'] ?? []);

    return List<PermissionModel>.from(
      data.map(
          (item) => PermissionModel.fromJson(Map<String, dynamic>.from(item))),
    );
  }
}
