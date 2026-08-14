import 'package:flutter/material.dart';
import 'package:tamdansers_lv2/core/api/services/base_api_service.dart';
import 'package:tamdansers_lv2/data/model/notification_model.dart';

class NotificationApi {
  final BaseApiService baseApiService =
      BaseApiService();

  // =========================================================
  // GET CURRENT USER NOTIFICATIONS
  // =========================================================

  Future<List<NotificationModel>>
    getNotifications() async {
  final dynamic response =
      await baseApiService.get(
    endpoint: '/notifications',
  );

  debugPrint(
    'NOTIFICATION RAW RESPONSE: $response',
  );

  debugPrint(
    'NOTIFICATION RAW TYPE: '
    '${response.runtimeType}',
  );

  if (response is! List) {
    debugPrint(
      'NOTIFICATION RESPONSE IS NOT A LIST',
    );

    return <NotificationModel>[];
  }

  final List<NotificationModel> result =
      <NotificationModel>[];

  for (final dynamic item in response) {
    try {
      if (item is Map) {
        final model =
            NotificationModel.fromJson(
          Map<String, dynamic>.from(
            item,
          ),
        );

        result.add(
          model,
        );
      }
    } catch (e, stackTrace) {
      debugPrint(
        'NOTIFICATION PARSE ERROR: $e',
      );

      debugPrint(
        'FAILED ITEM: $item',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }
  }

  debugPrint(
    'NOTIFICATION PARSED COUNT: '
    '${result.length}',
  );

  return result;
}

  // =========================================================
  // DELETE NOTIFICATION
  // =========================================================

  Future<void> deleteNotification(
    int notificationId,
  ) async {
    await baseApiService.delete(
      endpoint:
          '/notifications/$notificationId',
    );
  }

  // =========================================================
  // REMOVE FCM TOKEN ON LOGOUT
  // =========================================================

  Future<void> removeFcmToken() async {
    await baseApiService.delete(
      endpoint: '/notifications/fcm-token',
    );
  }
}