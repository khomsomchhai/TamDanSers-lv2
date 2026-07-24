import 'package:tamdansers_lv2/core/api/services/base_api_service.dart';
import 'package:tamdansers_lv2/data/model/notification_model.dart';

class NotificationApi {
  final BaseApiService baseApiService = BaseApiService();
  
  Future<List<NotificationModel>> getNotifications() async {
    var response = await baseApiService.get(endpoint: "/notifications");
    return (response as List)
        .map((e) => NotificationModel.fromJson(e))
        .toList();
  }
}