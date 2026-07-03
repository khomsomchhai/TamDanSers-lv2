import 'dart:io';

import 'package:dio/dio.dart';
import 'package:tamdansers_lv2/core/api/services/base_api_service.dart';

class UserServices {
  final baseApi = BaseApiService();

  Future<Map<String, dynamic>> fechProfile() async {
    var response = await baseApi.get(
      endpoint: "/profile/me",
    );
    return response;
  }

  Future<Map<String, dynamic>> uploadAvatar(File file) async {
    final filename = file.path.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        file.path,
        filename: filename,
      ),
    });

    var response = await baseApi.post(
      endpoint: "/profile/avatar",
      data: formData,
    );
    return response;
  }
}