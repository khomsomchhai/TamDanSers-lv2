import 'package:dio/dio.dart';
import 'package:get/get.dart';

String handleDioException(DioException e) {
  final error = e.error?.toString().toLowerCase() ?? '';

  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'connection_timeout_retry'.tr;

    case DioExceptionType.connectionError:
      return 'unable_to_connect'.tr;

    case DioExceptionType.badResponse:
      switch (e.response?.statusCode) {
        case 400:
          return 'invalid_request'.tr;

        case 401:
          return 'invalid_login_credentials'.tr;

        case 403:
          return 'access_denied'.tr;

        case 404:
          try {
            final data = e.response?.data;
            if (data is Map) {
              final detail = data['detail']?.toString();
              final message = data['message']?.toString();

              if (detail != null && detail.isNotEmpty) {
                return detail;
              }

              if (message != null && message.isNotEmpty) {
                return message;
              }
            }
          } catch (_) {}

          return 'service_not_found'.tr;

        case 429:
          return 'too_many_requests'.tr;

        case 500:
        case 502:
        case 503:
        case 504:
          return 'server_error_retry'.tr;

        default:
          try {
            final data = e.response?.data;

            if (data is Map) {
              final message = data['message']?.toString();

              if (message != null && message.isNotEmpty) {
                return message;
              }
            }
          } catch (_) {}

          return 'something_went_wrong_retry'.tr;
      }

    case DioExceptionType.cancel:
      return 'request_cancelled'.tr;

    case DioExceptionType.badCertificate:
      return 'security_certificate_error'.tr;

    case DioExceptionType.unknown:
    default:
      if (error.contains('socketexception') ||
          error.contains('failed host lookup') ||
          error.contains('network') ||
          error.contains('connection')) {
        return 'unable_to_connect'.tr;
      }

      return 'something_went_wrong_retry'.tr;
  }
}
