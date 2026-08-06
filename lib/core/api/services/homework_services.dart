import 'package:dio/dio.dart';
import 'package:tamdansers_lv2/core/api/services/base_api_service.dart';

class HomeworkServices {
  final BaseApiService baseApi =
      BaseApiService();

  Future<List<dynamic>>
      fetchHomeworkList() async {
    final response = await baseApi.get(
      endpoint: '/homework/',
    );

    if (response is List) {
      return response;
    }

    if (response is Map) {
      if (response['data'] is List) {
        return response['data'] as List;
      }

      if (response['homeworks'] is List) {
        return response['homeworks']
            as List;
      }
    }

    return [];
  }

  Future<List<dynamic>>
      fetchStudentHomeworkList(
    int studentId,
  ) async {
    final response = await baseApi.get(
      endpoint:
          '/homework/student/$studentId',
    );

    if (response is List) {
      return response;
    }

    if (response is Map) {
      if (response['data'] is List) {
        return response['data'] as List;
      }

      if (response['homeworks']
          is List) {
        return response['homeworks']
            as List;
      }
    }

    return [];
  }

  Future<List<dynamic>>
      fetchStudentSubmissions(
    int studentId,
  ) async {
    final response = await baseApi.get(
      endpoint:
          '/submissions/student/$studentId',
    );

    if (response is List) {
      return response;
    }

    if (response is Map) {
      if (response['data'] is List) {
        return response['data'] as List;
      }

      if (response['submissions']
          is List) {
        return response['submissions']
            as List;
      }
    }

    return [];
  }

  Future<dynamic> submitHomework({
    required int homeworkId,
    required int studentId,
    required String answerText,
    List<MultipartFile> files =
        const [],
  }) async {
    final Map<String, dynamic> data = {
      'homework_id': homeworkId,
      'student_id': studentId,
      'answer_text': answerText,
    };

    if (files.isNotEmpty) {
      data['files'] = files;
    }

    final formData =
        FormData.fromMap(data);

    return baseApi.post(
      endpoint: '/submissions/',
      data: formData,
    );
  }

  // =====================================================
  // Student edits submission
  // PUT /submissions/{submissionId}
  // =====================================================

  Future<dynamic> updateSubmission({
    required int submissionId,
    required int studentId,
    required String answerText,
    required bool keepOldFiles,
    List<MultipartFile> files =
        const [],
  }) async {
    final Map<String, dynamic> data = {
      'student_id': studentId,
      'answer_text': answerText,
      'keep_old_files': keepOldFiles,
    };

    if (files.isNotEmpty) {
      data['files'] = files;
    }

    final formData =
        FormData.fromMap(data);

    return baseApi.put(
      endpoint:
          '/submissions/$submissionId',
      data: formData,
    );
  }

  // =====================================================
  // Student deletes submission
  // DELETE /submissions/{submissionId}
  // =====================================================

  Future<dynamic> deleteSubmission({
    required int submissionId,
    required int studentId,
  }) async {
    return baseApi.delete(
      endpoint:
          '/submissions/$submissionId'
          '?student_id=$studentId',
    );
  }
}