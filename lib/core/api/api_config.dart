import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:tamdansers_lv2/core/services/auth_session_service.dart';

class ApiConfig {
  late Dio dio;
  ApiConfig() {
    dio = Dio(
      BaseOptions(
        baseUrl: "https://tamdansers-1fvbe1msgz9hki.sabay.com",
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          "Content-Type": "application/json",
        },
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          var token = GetStorage().read("token");
          if (token is String) {
            token = token.trim();
          }
          if (token != null && token is String && token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          }
          handler.next(options);
        },
        onError: (DioException e, handler) async {
          final bool isUnauthorized = e.response?.statusCode == 401;
          final bool hasToken = (GetStorage().read<String>('token') ?? '')
              .toString()
              .trim()
              .isNotEmpty;

          if (isUnauthorized && hasToken) {
            await AuthSessionService().handleUnauthorized();
          }

          handler.next(e);
        },
      ),
    );
    dio.interceptors.add(
      PrettyDioLogger(
        requestBody: true,
        requestHeader: true,
        responseBody: true,
      ),
    );
  }
}
