import 'package:tamdansers_lv2/core/api/services/base_api_service.dart';
import 'package:tamdansers_lv2/data/model/permission_model.dart';

class PermissionServices {
  final baseApi = BaseApiService();

  Future<Map<String, dynamic>> createPermission({
    required String requestType,
    int? scheduleId,
    required String type,
    required String reason,
  }) async {
    final Map<String, dynamic> payload = {
      'request_type': requestType,
      'type': type,
      'reason': reason,
    };

    if (scheduleId != null) {
      payload['schedule_id'] = scheduleId;
    }

    final response = await baseApi.post(
      endpoint: '/permissions/',
      data: payload,
    );
    return Map<String, dynamic>.from(response);
  }

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
