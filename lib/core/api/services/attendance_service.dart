import 'package:tamdansers_lv2/core/api/services/base_api_service.dart';
import 'package:tamdansers_lv2/data/model/attendance_model.dart';

class AttendanceService {
  final BaseApiService baseApi = BaseApiService();

  Future<List<AttendanceModel>> getMyAttendance() async {
    final response = await baseApi.get(endpoint: '/attendance/me');
    final data = response is List
        ? response
        : (response['data'] ?? response['attendance'] ?? []);

    return List<AttendanceModel>.from(
      data.map(
          (item) => AttendanceModel.fromJson(Map<String, dynamic>.from(item))),
    );
  }
}
