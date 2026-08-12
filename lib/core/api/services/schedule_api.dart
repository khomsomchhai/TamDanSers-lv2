import 'package:tamdansers_lv2/core/api/services/base_api_service.dart';

class ScheduleApi {
  final BaseApiService baseApiService = BaseApiService();

  // ==========================================
  // STUDENT SCHEDULE
  // Get schedules with fallback endpoints
  // ==========================================
  Future<dynamic> getSchedule() async {
    final List<String> endpoints = [
      "/schedules/student/me",
      "/schedules",
    ];

    for (final String endpoint in endpoints) {
      try {
        final response = await baseApiService.get(endpoint: endpoint);
        if (response != null) {
          return response;
        }
      } catch (_) {}
    }

    return null;
  }

  // ==========================================
  // PARENT - STUDENT TODAY SCHEDULE
  // Fallback through all parent/student schedule routes
  // ==========================================
  Future<dynamic> getParentSchedule(
    int studentId,
  ) async {
    final List<String> endpoints = [
      "/parents/schedules/$studentId/today",
      "/permissions/parent/$studentId/schedules",
      "/schedules/student/$studentId",
      "/parents/schedules/$studentId",
      "/schedules?student_id=$studentId",
      "/schedules",
    ];

    for (final String endpoint in endpoints) {
      try {
        final response = await baseApiService.get(endpoint: endpoint);
        if (response != null) {
          if (response is List && response.isNotEmpty) {
            return response;
          }
          if (response is Map) {
            final dynamic listData = response['schedules'] ??
                response['data'] ??
                response['results'] ??
                response['permissions'];
            if (listData is List && listData.isNotEmpty) {
              return response;
            }
          }
        }
      } catch (_) {}
    }

    return null;
  }
}