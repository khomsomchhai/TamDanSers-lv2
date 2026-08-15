import 'package:dio/dio.dart';
import 'package:tamdansers_lv2/core/api/api_config.dart';
import 'package:tamdansers_lv2/core/services/auth_session_service.dart';

class BaseApiService {
  final ApiConfig apiConfig = ApiConfig();

  static const int _maxRetry = 3;

  bool _shouldRetry(DioException e) {
    final status = e.response?.statusCode;

    return status == 500 ||
        status == 502 ||
        status == 503 ||
        status == 504 ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError;
  }

  Future<T> _requestWithRetry<T>(
    Future<Response<T>> Function() request,
  ) async {
    for (int attempt = 0; attempt < _maxRetry; attempt++) {
      try {
        final response = await request();
        return response.data as T;
      } on DioException catch (e) {
        // Never retry unauthorized
        if (e.response?.statusCode == 401) {
          rethrow;
        }

        if (!_shouldRetry(e) || attempt == _maxRetry - 1) {
          rethrow;
        }

        // 1s -> 2s -> 3s
        await Future.delayed(Duration(seconds: attempt + 1));
      }
    }

    throw Exception("Request failed");
  }

  Future<dynamic> post({
    required String endpoint,
    required dynamic data,
    CancelToken? cancelToken,
  }) {
    return _requestWithRetry(
      () => apiConfig.dio.post(
        endpoint,
        data: data,
        cancelToken: cancelToken ?? AuthSessionService().activeRequestsToken,
      ),
    );
  }

  Future<dynamic> get({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) {
    return _requestWithRetry(
      () => apiConfig.dio.get(
        endpoint,
        queryParameters: queryParameters,
        cancelToken: cancelToken ?? AuthSessionService().activeRequestsToken,
      ),
    );
  }

  Future<dynamic> put({
    required String endpoint,
    dynamic data,
    CancelToken? cancelToken,
  }) {
    return _requestWithRetry(
      () => apiConfig.dio.put(
        endpoint,
        data: data,
        cancelToken: cancelToken ?? AuthSessionService().activeRequestsToken,
      ),
    );
  }

  Future<dynamic> delete({
    required String endpoint,
    CancelToken? cancelToken,
  }) {
    return _requestWithRetry(
      () => apiConfig.dio.delete(
        endpoint,
        cancelToken: cancelToken ?? AuthSessionService().activeRequestsToken,
      ),
    );
  }
}