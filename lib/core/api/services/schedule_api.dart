import 'package:tamdansers_lv2/core/api/services/base_api_service.dart';

class ScheduleApi {
  BaseApiService baseApiService =BaseApiService();

  Future<dynamic> getSchedule() async {
    var response = await baseApiService.get(
      endpoint: "/schedules",
    );
    return response;
  }
  Future<dynamic> getParentSchedule(int studentId)async{
    final response =await baseApiService.get(endpoint: '/parents/schedules/$studentId/today');
    return response;
  }
}