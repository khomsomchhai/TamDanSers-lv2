import 'package:dio/dio.dart';
import 'package:tamdansers_lv2/core/api/services/base_api_service.dart';

class HomeworkServices {
  final baseApi = BaseApiService();

  Future<List<dynamic>> fetchHomeworkList() async {
    var response = await baseApi.get(
      endpoint: "/homework/",
    );
    if (response is List) {
      return response;
    } else if (response is Map && response.containsKey('data')) {
      return response['data'] as List;
    } else if (response is Map && response.containsKey('homeworks')) {
      return response['homeworks'] as List;
    }
    return [];
  }

  Future<List<dynamic>> fetchStudentHomeworkList(int studentId) async {
    var response = await baseApi.get(
      endpoint: "/homework/student/$studentId",
    );
    if (response is List) {
      return response;
    } else if (response is Map) {
      if (response.containsKey('data') && response['data'] is List) {
        return response['data'] as List;
      } else if (response.containsKey('homeworks') &&
          response['homeworks'] is List) {
        return response['homeworks'] as List;
      }
    }
    return [];
  }

  Future<List<dynamic>> fetchStudentSubmissions(int studentId) async {
    var response = await baseApi.get(
      endpoint: "/submissions/student/$studentId",
    );
    if (response is List) {
      return response;
    } else if (response is Map) {
      if (response.containsKey('data') && response['data'] is List) {
        return response['data'] as List;
      } else if (response.containsKey('submissions') &&
          response['submissions'] is List) {
        return response['submissions'] as List;
      }
    }
    return [];
  }

  Future<dynamic> submitHomework({
    required int homeworkId,
    required int studentId,
    required String answerText,
    MultipartFile? file,
  }) async {
    final Map<String, dynamic> data = {
      "homework_id": homeworkId,
      "student_id": studentId,
      "answer_text": answerText,
    };
    if (file != null) {
      data["file"] = file;
    }
    final formData = FormData.fromMap(data);
    final response = await baseApi.post(
      endpoint: "/submissions/",
      data: formData,
    );
    return response;
  }
}
