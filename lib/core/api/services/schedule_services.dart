import 'package:tamdansers_lv2/core/api/services/base_api_service.dart';
import 'package:tamdansers_lv2/data/model/schedule_model.dart';

class ScheduleServices {
  final baseApi = BaseApiService();

  Future<List<ScheduleModel>> fetchSchedules() async {
    final response = await baseApi.get(endpoint: '/schedules');
    final data = response is List
        ? response
        : (response['data'] ?? response['schedules'] ?? []);

    return List<ScheduleModel>.from(
      data.map(
          (item) => ScheduleModel.fromJson(Map<String, dynamic>.from(item))),
    );
  }
}
