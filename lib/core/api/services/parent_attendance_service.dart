import 'package:flutter/foundation.dart';
import 'package:tamdansers_lv2/core/api/services/base_api_service.dart';
import 'package:tamdansers_lv2/data/model/attendance_model.dart';

class ParentAttendanceService {
  final BaseApiService baseApi = BaseApiService();

  Future<List<AttendanceModel>> getChildAttendance({
    required int studentId,
  }) async {
    final response = await baseApi.get(
      endpoint: '/parents/dashboard/$studentId',
    );

    debugPrint('PARENT DASHBOARD RESPONSE: $response');

    dynamic responseData = response;

    // ករណី BaseApiService return {data: {...}}
    if (response is Map && response['data'] is Map) {
      responseData = response['data'];
    }

    if (responseData is! Map) {
      debugPrint('Response is not Map');
      return [];
    }

    final attendanceData = responseData['attendance'];

    debugPrint('ATTENDANCE DATA: $attendanceData');

    if (attendanceData is! List) {
      debugPrint('Attendance is not List');
      return [];
    }

    return attendanceData.map((item) {
      return AttendanceModel.fromJson(
        Map<String, dynamic>.from(item as Map),
      );
    }).toList();
  }
}