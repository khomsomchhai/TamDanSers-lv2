import 'package:tamdansers_lv2/core/api/services/base_api_service.dart';
import 'package:tamdansers_lv2/data/model/permission_model.dart';

class PermissionServices {
  final BaseApiService baseApi =
      BaseApiService();

  // =====================================================
  // Student create permission
  // POST /permissions/
  // =====================================================
  Future<Map<String, dynamic>>
      createPermission({
    required String requestType,
    int? scheduleId,
    required String type,
    required String reason,
  }) async {
    final Map<String, dynamic> payload = {
      'request_type': requestType,
      'type': type,
      'reason': reason.trim(),
    };

    if (requestType == 'subject' &&
        scheduleId != null) {
      payload['schedule_id'] =
          scheduleId;
    }

    final response =
        await baseApi.post(
      endpoint: '/permissions/',
      data: payload,
    );

    return Map<String, dynamic>.from(
      response,
    );
  }

  // =====================================================
  // Student history
  // GET /permissions/student/me
  // =====================================================
  Future<List<PermissionModel>>
      fetchMyPermissions() async {
    final response =
        await baseApi.get(
      endpoint:
          '/permissions/student/me',
    );

    final dynamic data =
        response is List
            ? response
            : response['data'] ??
                response['permissions'] ??
                [];

    return List<PermissionModel>.from(
      data.map(
        (item) =>
            PermissionModel.fromJson(
          Map<String, dynamic>.from(
            item,
          ),
        ),
      ),
    );
  }

  // =====================================================
  // Parent create permission
  // POST /permissions/parent
  // =====================================================
  Future<Map<String, dynamic>>
      createParentPermission({
    required int studentId,
    required String requestType,
    int? scheduleId,
    required String type,
    required String reason,
  }) async {
    final Map<String, dynamic> payload = {
      'student_id': studentId,
      'request_type': requestType,
      'type': type,
      'reason': reason.trim(),
    };

    if (requestType == 'subject' &&
        scheduleId != null) {
      payload['schedule_id'] =
          scheduleId;
    }

    final response =
        await baseApi.post(
      endpoint:
          '/permissions/parent',
      data: payload,
    );

    return Map<String, dynamic>.from(
      response,
    );
  }

  // =====================================================
  // Parent history
  // GET /permissions/parent/{student_id}
  // =====================================================
  Future<List<PermissionModel>>
      fetchParentPermissions({
    required int studentId,
  }) async {
    final response =
        await baseApi.get(
      endpoint:
          '/permissions/parent/$studentId',
    );

    final dynamic data =
        response is List
            ? response
            : response['data'] ??
                response['permissions'] ??
                [];

    return List<PermissionModel>.from(
      data.map(
        (item) =>
            PermissionModel.fromJson(
          Map<String, dynamic>.from(
            item,
          ),
        ),
      ),
    );
  }

  // =====================================================
  // Parent child schedules
  // GET /permissions/parent/{student_id}/schedules
  // =====================================================
  Future<List<Map<String, dynamic>>>
      fetchParentSchedules({
    required int studentId,
  }) async {
    final response =
        await baseApi.get(
      endpoint:
          '/permissions/parent/'
          '$studentId/schedules',
    );

    final dynamic data =
        response is List
            ? response
            : response['data'] ??
                response['schedules'] ??
                [];

    return List<Map<String, dynamic>>.from(
      data.map(
        (item) =>
            Map<String, dynamic>.from(
          item,
        ),
      ),
    );
  }
}