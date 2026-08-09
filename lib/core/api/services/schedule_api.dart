import 'package:tamdansers_lv2/core/api/services/base_api_service.dart';

class ScheduleApi {
  final BaseApiService baseApiService =
      BaseApiService();

  // ==========================================
  // STUDENT SCHEDULE
  // Get only schedules for logged-in student's class
  // ==========================================
  Future<dynamic> getSchedule() async {
    try {
      final response =
          await baseApiService.get(
        endpoint: "/schedules/student/me",
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // ==========================================
  // PARENT - STUDENT TODAY SCHEDULE
  // ==========================================
  Future<dynamic> getParentSchedule(
    int studentId,
  ) async {
    try {
      final response =
          await baseApiService.get(
        endpoint:
            "/parents/schedules/$studentId/today",
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}