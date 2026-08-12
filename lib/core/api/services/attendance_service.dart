import 'package:flutter/foundation.dart';

import 'package:tamdansers_lv2/core/api/services/base_api_service.dart';
import 'package:tamdansers_lv2/data/model/attendance_model.dart';


class AttendanceService {
  final baseApi =
      BaseApiService();


  // =========================================================
  // MY ATTENDANCE
  // =========================================================

  Future<List<AttendanceModel>>
      getMyAttendance() async {

    final response =
        await baseApi.get(
      endpoint:
          '/attendance/me',
    );

    final data =
        _extractList(
      response,
    );

    if (data is! List) {
      return [];
    }

    return List<
        AttendanceModel>.from(
      data.map(
        (item) =>
            AttendanceModel
                .fromJson(
          Map<String, dynamic>
              .from(
            item,
          ),
        ),
      ),
    );
  }


  // =========================================================
  // STUDENT SCAN
  // =========================================================

  Future<Map<String, dynamic>>
      scanAttendance({
    required String token,
    required double latitude,
    required double longitude,
    required double accuracy,
  }) async {

    try {
      debugPrint(
        'SCAN TOKEN: $token',
      );

      debugPrint(
        'STUDENT LAT: $latitude',
      );

      debugPrint(
        'STUDENT LNG: $longitude',
      );

      debugPrint(
        'STUDENT ACCURACY: $accuracy',
      );

      final response =
          await baseApi.post(
        endpoint:
            '/attendance/scan',

        data: {
          'token':
              token,

          'latitude':
              latitude,

          'longitude':
              longitude,

          'accuracy':
              accuracy,
        },
      );

      debugPrint(
        'SCAN RESPONSE: $response',
      );

      if (
          response
          is Map<String, dynamic>) {
        return response;
      }

      if (response is Map) {
        return Map<String, dynamic>
            .from(
          response,
        );
      }

      return {};

    } catch (error) {
      debugPrint(
        'SCAN SERVICE ERROR: $error',
      );

      rethrow;
    }
  }


  dynamic _extractList(
    dynamic response,
  ) {
    if (response is List) {
      return response;
    }

    if (response is Map) {
      for (final key in [
        'data',
        'attendance',
        'result',
        'items',
      ]) {
        final value =
            response[key];

        if (value is List) {
          return value;
        }

        if (value is Map) {
          final nested =
              _extractList(
            value,
          );

          if (nested is List) {
            return nested;
          }
        }
      }
    }

    return [];
  }
}