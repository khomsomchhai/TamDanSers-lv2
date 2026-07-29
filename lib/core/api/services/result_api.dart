import 'package:tamdansers_lv2/core/api/services/base_api_service.dart';
import 'package:tamdansers_lv2/data/model/parent_model.dart';
import 'package:tamdansers_lv2/data/model/score_model.dart';

class ResultApi {
  BaseApiService baseApiService = BaseApiService();

  Future<List<ScoreModel>> getResult() async {
    final response = await baseApiService.get(
      endpoint: '/scores/student/me',
    );

    return (response as List).map((e) => ScoreModel.fromMap(e)).toList();
  }

  Future<ScoreModel> getRankStudent({
    required int month,
    required int semester,
  }) async {
    final response = await baseApiService.get(
      endpoint: '/scores/student/rank?month=$month&semester=$semester',
    );

    return ScoreModel.fromMap(response);
  }

  Future<ParentDashboardModel> getParentDashboard({
  required int studentId,
}) async {
  final response = await baseApiService.get(
    endpoint: '/parents/dashboard/$studentId',
  );

  return ParentDashboardModel.fromMap(response);
}
}