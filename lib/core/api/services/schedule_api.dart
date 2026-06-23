import 'package:tamdansers_lv2/core/api/services/base_api_service.dart';

class ScheduleApi {
  BaseApiService baseApi =BaseApiService();

  Future<dynamic> getSchedule() async {
    var response = await baseApi.get(
      endpoint: "/schedules",
    );
    return response;
  }
}