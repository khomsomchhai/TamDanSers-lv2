import 'package:dio/dio.dart';
import 'package:tamdansers_lv2/core/api/api_config.dart';

class BaseApiService {
  final ApiConfig apiConfig = ApiConfig();
  Future <dynamic> post({
    required String endpoint,
    required dynamic data,
  })async {
    try {
      var response = await apiConfig.dio.post(endpoint, data: data);
      return response.data;
    } catch (e) {
      throw Exception("Failed");
    }
  }

  Future <dynamic> get({
    required String endpoint,
    Map<String, dynamic>? queryParameters
  }) async {
    try{
      var response = await apiConfig.dio.get(
        endpoint,
        queryParameters: queryParameters
      );
      return response.data;
    }on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception("Unauthorized");
      }
      throw Exception(e.message);
    }
  }

  Future<dynamic> delete({required String endpoint}) async {
    try{
      var response = await apiConfig.dio.delete(endpoint);
      return response.data;
    }catch (e) {
      throw Exception("Failed");
    }
  }

  Future <dynamic> put({
    required String endpoint,
    dynamic data,
  })async {
    try {
      var response = await apiConfig.dio.put(endpoint, data: data);
      return response.data;
    }catch (e) {
      throw Exception("Failed");
    }
  }



}
