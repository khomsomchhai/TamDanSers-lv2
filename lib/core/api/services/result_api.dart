import 'package:tamdansers_lv2/core/api/services/base_api_service.dart';
import 'package:tamdansers_lv2/data/model/parent_model.dart';
import 'package:tamdansers_lv2/data/model/score_model.dart';

class ResultApi {
  final BaseApiService baseApiService =
      BaseApiService();

  // =========================================================
  // STUDENT RESULT
  // =========================================================

  Future<List<ScoreModel>> getResult() async {
    final dynamic response =
        await baseApiService.get(
      endpoint: '/scores/student/me',
    );

    if (response is! List) {
      return [];
    }

    return response
        .map(
          (dynamic item) =>
              ScoreModel.fromMap(
            Map<String, dynamic>.from(
              item,
            ),
          ),
        )
        .toList();
  }

  // =========================================================
  // MONTHLY RANK
  // =========================================================

  Future<ScoreModel> getRankStudent({
    required int month,
    required int semester,
  }) async {
    final dynamic response =
        await baseApiService.get(
      endpoint:
          '/scores/student/rank'
          '?month=$month'
          '&semester=$semester',
    );

    return ScoreModel.fromMap(
      Map<String, dynamic>.from(
        response,
      ),
    );
  }

  // =========================================================
  // YEARLY RANK
  // =========================================================

  Future<ScoreModel> getYearRank() async {
    final dynamic response =
        await baseApiService.get(
      endpoint:
          '/scores/student/year-rank',
    );

    return ScoreModel.fromMap(
      Map<String, dynamic>.from(
        response,
      ),
    );
  }

  // =========================================================
  // PARENT DASHBOARD
  // =========================================================

  Future<ParentDashboardModel>
      getParentDashboard({
    required int studentId,
  }) async {
    final dynamic response =
        await baseApiService.get(
      endpoint:
          '/parents/dashboard/$studentId',
    );

    return ParentDashboardModel.fromMap(
      Map<String, dynamic>.from(
        response,
      ),
    );
  }
}