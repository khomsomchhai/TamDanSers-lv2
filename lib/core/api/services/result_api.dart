import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:tamdansers_lv2/core/api/services/base_api_service.dart';
import 'package:tamdansers_lv2/core/api/controllers/user_controller.dart';
import 'package:tamdansers_lv2/data/model/parent_model.dart';
import 'package:tamdansers_lv2/data/model/score_model.dart';

class ResultApi {
  final BaseApiService baseApiService = BaseApiService();

  // =====================================================
  // UNWRAP API RESPONSE
  // =====================================================

  dynamic _unwrapResponse(dynamic response) {
    debugPrint('RAW API RESPONSE: $response');

    dynamic data = response;

    // Dio Response
    try {
      if (data != null && data.runtimeType.toString() == 'Response') {
        data = data.data;
      }
    } catch (_) {}

    // Unwrap data/result/response
    for (int i = 0; i < 5; i++) {
      if (data is Map) {
        if (data.containsKey('rank') ||
            data.containsKey('summary') ||
            data.containsKey('yearly_summary') ||
            data.containsKey('monthly_results') ||
            data.containsKey('student') ||
            data.containsKey('semester_rank') ||
            data.containsKey('yearly_rank') ||
            data.containsKey('semester_exam')) {
          break;
        }

        if (data['data'] != null) {
          data = data['data'];
          continue;
        }

        if (data['result'] != null) {
          data = data['result'];
          continue;
        }

        if (data['response'] != null) {
          data = data['response'];
          continue;
        }
      }

      break;
    }

    debugPrint('UNWRAPPED RESPONSE: $data');

    return data;
  }

  Map<String, dynamic> _unwrapMap(dynamic response, {int? studentId}) {
    dynamic data = _unwrapResponse(response);

    int? activeStudentId = studentId;
    if (activeStudentId == null || activeStudentId == 0) {
      try {
        final dynamic storedId = GetStorage().read('student_id');
        if (storedId != null) {
          activeStudentId = int.tryParse(storedId.toString()) ?? (storedId as int?);
        }
      } catch (_) {}
      if (activeStudentId == null || activeStudentId == 0) {
        try {
          if (Get.isRegistered<UserController>()) {
            activeStudentId = Get.find<UserController>().profile?.id;
          }
        } catch (_) {}
      }
    }

    if (data is num || data is String) {
      return <String, dynamic>{'rank': data.toString()};
    }

    if (data is Map) {
      final Map<String, dynamic> result = Map<String, dynamic>.from(data);
      if (response is Map &&
          response['rank'] != null &&
          !result.containsKey('rank')) {
        result['rank'] = response['rank'];
      }
      return result;
    }

    if (data is List && data.isNotEmpty) {
      if (activeStudentId != null && activeStudentId > 0) {
        for (final dynamic item in data) {
          if (item is Map) {
            final dynamic sId = item['student_id'] ??
                item['studentId'] ??
                item['id'] ??
                item['user_id'] ??
                item['userId'];

            if (sId != null &&
                (sId == activeStudentId ||
                    sId.toString().trim() == activeStudentId.toString().trim())) {
              return Map<String, dynamic>.from(item);
            }
          }
        }
      }

      final dynamic first = data.first;
      if (first is Map) {
        return Map<String, dynamic>.from(first);
      }
      if (first is num || first is String) {
        return <String, dynamic>{'rank': first.toString()};
      }
    }

    if (response is Map<String, dynamic> && response['rank'] != null) {
      return <String, dynamic>{'rank': response['rank'].toString()};
    }

    return <String, dynamic>{};
  }

  // =====================================================
  // SAFE DOUBLE
  // =====================================================

  double _double(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  // =====================================================
  // STUDENT SCORES
  // =====================================================

  Future<List<ScoreModel>> getResult() async {
    final dynamic response = await baseApiService.get(
      endpoint: '/scores/student/me',
    );

    final dynamic data = _unwrapResponse(response);

    if (data is List) {
      return data
          .whereType<Map>()
          .map(
            (item) => ScoreModel.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    return <ScoreModel>[];
  }

  // =====================================================
  // RANK
  // =====================================================

  Future<ScoreModel?> getRankStudent({
    required int month,
    required int semester,
    int? studentId,
  }) async {
    final List<String> queryParams = <String>[
      'month=$month',
      'semester=$semester',
    ];

    if (studentId != null) {
      queryParams.add(
        'student_id=$studentId',
      );
    }

    final String endpoint = '/scores/student/rank?${queryParams.join('&')}';

    final response = await baseApiService.get(
      endpoint: endpoint,
    );

    final Map<String, dynamic> data = _unwrapMap(response, studentId: studentId);

    if (data.isEmpty) {
      return null;
    }

    return ScoreModel.fromMap(data);
  }

  // =====================================================
  // SEMESTER SUMMARY
  // =====================================================

  Future<ScoreModel?> getSemesterResult({
    required int semester,
    int? studentId,
  }) async {
    final List<String> queryParams = <String>[
      'semester=$semester',
    ];

    if (studentId != null) {
      queryParams.add(
        'student_id=$studentId',
      );
    }

    final String endpoint =
        '/scores/student/semester-result?${queryParams.join('&')}';

    final response = await baseApiService.get(
      endpoint: endpoint,
    );

    final Map<String, dynamic> data = _unwrapMap(response, studentId: studentId);

    if (data.isEmpty) {
      return null;
    }

    return ScoreModel.fromMap(data);
  }
Future<ScoreModel?> getSemesterRank({
  required int semester,
}) async {
  try {
    final dynamic response =
        await baseApiService.get(
      endpoint:
          '/scores/student/semester-rank?semester=$semester',
    );

    debugPrint(
      'SEMESTER RANK RESPONSE: $response',
    );

    if (response == null) {
      return null;
    }

    Map<String, dynamic> data;

    if (response is Map<String, dynamic>) {
      data = response;
    } else if (response is Map) {
      data = Map<String, dynamic>.from(
        response,
      );
    } else {
      debugPrint(
        'SEMESTER RANK INVALID RESPONSE TYPE: '
        '${response.runtimeType}',
      );

      return null;
    }

    if (data.isEmpty) {
      return null;
    }

    final ScoreModel model =
        ScoreModel.fromMap(data);

    debugPrint(
      'SEMESTER RANK PARSED => '
      'rank=${model.rank}, '
      'semester=${model.semester}, '
      'totalScore=${model.totalScore}, '
      'average=${model.average}',
    );

    return model;
  } catch (e, stackTrace) {
    debugPrint(
      'GET SEMESTER RANK API ERROR: $e',
    );

    debugPrintStack(
      stackTrace: stackTrace,
    );

    rethrow;
  }
}
  // =====================================================
  // YEAR RANK
  // =====================================================

  Future<ScoreModel?> getYearRank({
    required int year,
    int? studentId,
  }) async {
    final List<String> queryParams = <String>[
      'year=$year',
    ];

    if (studentId != null) {
      queryParams.add(
        'student_id=$studentId',
      );
    }

    final String endpoint =
        '/scores/student/year-rank?${queryParams.join('&')}';

    final response = await baseApiService.get(
      endpoint: endpoint,
    );

    final Map<String, dynamic> data = _unwrapMap(response, studentId: studentId);

    if (data.isEmpty) {
      return null;
    }

    return ScoreModel.fromMap(data);
  }

  // =====================================================
  // PARENT MONTH SUMMARY
  // =====================================================

  Future<ScoreModel?> getParentMonthResult({
    required int studentId,
    required int semester,
    required int month,
  }) async {
    final String endpoint =
        '/parents/results/$studentId/semester/$semester/month/$month';

    debugPrint(
      'PARENT MONTH RESULT ENDPOINT: $endpoint',
    );

    final response = await baseApiService.get(
      endpoint: endpoint,
    );

    final Map<String, dynamic> data = _unwrapMap(response, studentId: studentId);

    if (data.isEmpty) {
      return null;
    }

    // -------------------------------------------------
    // NEW API: Extract rank from monthly_results[].rank
    // for the specific requested month.
    // -------------------------------------------------

    if (data['rank'] == null || (data['rank'] is! Map && data['rank'] is! int)) {
      final dynamic monthlyResults = data['monthly_results'];
      if (monthlyResults is List) {
        for (final dynamic monthItem in monthlyResults) {
          if (monthItem is Map) {
            final dynamic mMonth = monthItem['month'];
            if (mMonth != null && mMonth.toString() == month.toString()) {
              final dynamic monthRank = monthItem['rank'];
              if (monthRank is Map) {
                data['rank'] = Map<String, dynamic>.from(monthRank);
              }
              break;
            }
          }
        }
      }
    }

    return ScoreModel.fromMap(data);
  }

  // =====================================================
  // PARENT MONTH SUBJECT DETAILS
  //
  // IMPORTANT:
  //
  // We ONLY read the selected month.
  //
  // No merging with other months.
  // No highest-score logic.
  // =====================================================

  Future<List<ScoreModel>> getParentResultDetails({
    required int studentId,
    required int semester,
    required int month,
  }) async {
    final String endpoint =
        '/parents/results/$studentId/semester/$semester/month/$month';

    debugPrint(
      'PARENT MONTH DETAIL ENDPOINT: $endpoint',
    );

    final response = await baseApiService.get(
      endpoint: endpoint,
    );

    final Map<String, dynamic> data = _unwrapMap(response);

    return _extractMonthSubjectResults(
      data,
      month,
    );
  }

  // =====================================================
  // PARENT SEMESTER SUMMARY
  // =====================================================

  Future<ScoreModel?> getParentSemesterResult({
    required int studentId,
    required int semester,
  }) async {
    final String endpoint = '/parents/results/$studentId/semester/$semester';

    debugPrint(
      'PARENT SEMESTER RESULT ENDPOINT: $endpoint',
    );

    final response = await baseApiService.get(
      endpoint: endpoint,
    );

    final Map<String, dynamic> data = _unwrapMap(response, studentId: studentId);

    if (data.isEmpty) {
      return null;
    }

    // -------------------------------------------------
    // NEW API: Extract rank from semester_rank
    // -------------------------------------------------

    if (data['rank'] == null || (data['rank'] is! Map && data['rank'] is! int)) {
      final dynamic semesterRank = data['semester_rank'];
      if (semesterRank is Map) {
        data['rank'] = Map<String, dynamic>.from(semesterRank);
      }
    }

    return ScoreModel.fromMap(data);
  }

  // =====================================================
  // PARENT SEMESTER SUBJECT DETAILS
  // =====================================================

  Future<List<ScoreModel>> getParentSemesterResultDetails({
    required int studentId,
    required int semester,
  }) async {
    final String endpoint = '/parents/results/$studentId/semester/$semester';

    debugPrint(
      'PARENT SEMESTER DETAIL ENDPOINT: $endpoint',
    );

    final response = await baseApiService.get(
      endpoint: endpoint,
    );

    final Map<String, dynamic> data = _unwrapMap(response);

    return _extractSemesterSubjectResults(
      data,
      semester,
    );
  }
  // =====================================================
  // PARENT SEMESTER SUBJECT AVERAGES
  //
  // A semester response can contain multiple monthly_results.
  // Collect ALL subject_results from ALL months, group by
  // subject, and calculate the average percentage.
  //
  // We NEVER keep only the last month or highest score.
  // =====================================================

  Future<Map<String, double>> getParentSemesterSubjectAverages({
    required int studentId,
    required int semester,
  }) async {
    final String endpoint = '/parents/results/$studentId/semester/$semester';

    debugPrint(
      'PARENT SEMESTER AVERAGES ENDPOINT: $endpoint',
    );

    final response = await baseApiService.get(
      endpoint: endpoint,
    );

    final Map<String, dynamic> data = _unwrapMap(response);

    return _extractSemesterSubjectAverages(data);
  }

  // =====================================================
  // PARENT YEARLY SUMMARY
  // =====================================================

  Future<ScoreModel?> getParentYearlyResult({
    required int studentId,
  }) async {
    final String endpoint = '/parents/results/$studentId/yearly';

    debugPrint(
      'PARENT YEARLY RESULT ENDPOINT: $endpoint',
    );

    final response = await baseApiService.get(
      endpoint: endpoint,
    );

    final Map<String, dynamic> data = _unwrapMap(response, studentId: studentId);

    if (data.isEmpty) {
      return null;
    }

    // -------------------------------------------------
    // NEW API: Extract rank from yearly_rank
    // -------------------------------------------------

    if (data['rank'] == null || (data['rank'] is! Map && data['rank'] is! int)) {
      final dynamic yearlyRank = data['yearly_rank'];
      if (yearlyRank is Map) {
        data['rank'] = Map<String, dynamic>.from(yearlyRank);
      }
    }

    return ScoreModel.fromMap(data);
  }

  // =====================================================
  // PARENT DASHBOARD
  // =====================================================

  Future<ParentDashboardModel?> getParentDashboard({
    required int studentId,
    String? type,
    dynamic filter,
    int? semester,
  }) async {
    final List<String> queryParams = <String>[];

    if (type != null && type.trim().isNotEmpty) {
      queryParams.add(
        'type=$type',
      );
    }

    if (filter != null) {
      if (type == 'monthly' || type == 'month') {
        queryParams.add(
          'month=$filter',
        );
      } else if (type == 'semester' || type == 'semi_annual') {
        queryParams.add(
          'semester=$filter',
        );
      } else if (type == 'yearly' || type == 'annual') {
        queryParams.add(
          'year=$filter',
        );
      }
    }

    if (semester != null && semester > 0) {
      queryParams.add(
        'semester=$semester',
      );
    }

    String endpoint = '/parents/dashboard/$studentId';

    if (queryParams.isNotEmpty) {
      endpoint += '?${queryParams.join('&')}';
    }

    debugPrint(
      'PARENT DASHBOARD ENDPOINT: $endpoint',
    );

    final response = await baseApiService.get(
      endpoint: endpoint,
    );

    final Map<String, dynamic> data = _unwrapMap(response);

    if (data.isEmpty) {
      return null;
    }

    return ParentDashboardModel.fromMap(
      data,
    );
  }

  // =====================================================
  // EXTRACT MONTH SUBJECT RESULTS
  // =====================================================

  List<ScoreModel> _extractMonthSubjectResults(
    Map<String, dynamic> data,
    int selectedMonth,
  ) {
    final List<ScoreModel> results = <ScoreModel>[];

    debugPrint(
      '========================================',
    );

    debugPrint(
      'RESULT DETAIL RAW MONTH=$selectedMonth',
    );

    // ---------------------------------------------------
    // CASE 1
    //
    // Direct:
    //
    // {
    //   subject_results: [...]
    // }
    // ---------------------------------------------------

    final dynamic direct = data['subject_results'];

    if (direct is List) {
      for (final dynamic item in direct) {
        if (item is! Map) {
          continue;
        }

        final Map<String, dynamic> map = Map<String, dynamic>.from(item);

        final int itemMonth = _parseInt(
          map['month'],
        );

        if (itemMonth != 0 && itemMonth != selectedMonth) {
          continue;
        }

        try {
          results.add(
            ScoreModel.fromMap(map),
          );
        } catch (e) {
          debugPrint(
            'MONTH SUBJECT PARSE ERROR: $e',
          );
        }
      }
    }

    // ---------------------------------------------------
    // CASE 2
    //
    // ACTUAL PARENT MONTH RESPONSE:
    //
    // {
    //   "semester": 1,
    //   "month": 4,
    //   "results": [...]
    // }
    //
    // IMPORTANT: the API uses `results` for the selected month.
    // Read it directly and filter by the requested month.
    // ---------------------------------------------------
    final dynamic actualResults = data['results'];

    if (actualResults is List) {
      for (final dynamic item in actualResults) {
        if (item is! Map) {
          continue;
        }

        final Map<String, dynamic> map = Map<String, dynamic>.from(item);
        final int itemMonth = _parseInt(map['month']);

        if (itemMonth != 0 && itemMonth != selectedMonth) {
          continue;
        }

        try {
          final ScoreModel model = ScoreModel.fromMap(map);
          results.add(model);

          debugPrint(
            'RESULT DETAIL PARSED FROM results => '
            '${model.subjectName} | '
            '${model.totalScore}/${model.maxScore} | '
            'month=${itemMonth == 0 ? selectedMonth : itemMonth}',
          );
        } catch (e) {
          debugPrint('MONTH results PARSE ERROR: $e');
        }
      }
    }

    // ---------------------------------------------------
    // CASE 3
    //
    // monthly_results:
    //
    // [
    //   {
    //      month: 1,
    //      subject_results: [...]
    //   }
    // ]
    // ---------------------------------------------------

    final dynamic monthlyResults = data['monthly_results'];

    if (monthlyResults is List) {
      for (final dynamic monthItem in monthlyResults) {
        if (monthItem is! Map) {
          continue;
        }

        final Map<String, dynamic> monthMap = Map<String, dynamic>.from(
          monthItem,
        );

        final int itemMonth = _parseInt(
          monthMap['month'],
        );

        if (itemMonth != selectedMonth) {
          continue;
        }

        final dynamic subjectResults = monthMap['subject_results'];

        if (subjectResults is! List) {
          continue;
        }

        for (final dynamic subjectItem in subjectResults) {
          if (subjectItem is! Map) {
            continue;
          }

          try {
            final ScoreModel model = ScoreModel.fromMap(
              Map<String, dynamic>.from(
                subjectItem,
              ),
            );

            results.add(model);

            debugPrint(
              'RESULT DETAIL PARSED => '
              '${model.subjectName} | '
              '${model.totalScore}/${model.maxScore}',
            );
          } catch (e) {
            debugPrint(
              'MONTH SUBJECT PARSE ERROR: $e',
            );
          }
        }
      }
    }

    final List<ScoreModel> unique = _uniqueBySubjectKeepingLast(
      results,
    );

    debugPrint(
      'RESULT DETAIL SUBJECT COUNT: '
      '${unique.length}',
    );

    debugPrint(
      '========================================',
    );

    return unique;
  }

  // =====================================================
  // EXTRACT SEMESTER SUBJECT AVERAGES
  // =====================================================

  Map<String, double> _extractSemesterSubjectAverages(
    Map<String, dynamic> data,
  ) {
    final Map<String, List<double>> percentagesBySubject =
        <String, List<double>>{};

    final dynamic monthlyResults = data['monthly_results'];

    if (monthlyResults is List) {
      for (final dynamic monthItem in monthlyResults) {
        if (monthItem is! Map) {
          continue;
        }

        final Map<String, dynamic> monthMap =
            Map<String, dynamic>.from(monthItem);

        final dynamic subjectResults = monthMap['subject_results'];

        if (subjectResults is! List) {
          continue;
        }

        for (final dynamic subjectItem in subjectResults) {
          if (subjectItem is! Map) {
            continue;
          }

          try {
            final ScoreModel result = ScoreModel.fromMap(
              Map<String, dynamic>.from(subjectItem),
            );

            final String key = result.subjectName.trim().toLowerCase();
            final double maxScore =
                result.maxScore > 0 ? result.maxScore : 100.0;

            if (key.isEmpty) {
              continue;
            }

            final double scoreValue =
                result.score > 0 ? result.score : result.totalScore;

            final double percentage = (scoreValue / maxScore) * 100;

            percentagesBySubject
                .putIfAbsent(key, () => <double>[])
                .add(percentage);
          } catch (e) {
            debugPrint(
              'SEMESTER AVERAGE SUBJECT PARSE ERROR: $e',
            );
          }
        }
      }
    }

    // Fallback for APIs that return semester `results` directly.
    if (percentagesBySubject.isEmpty) {
      final dynamic flatResults = data['results'];

      if (flatResults is List) {
        for (final dynamic item in flatResults) {
          if (item is! Map) {
            continue;
          }

          try {
            final ScoreModel result = ScoreModel.fromMap(
              Map<String, dynamic>.from(item),
            );

            final String key = result.subjectName.trim().toLowerCase();
            if (key.isEmpty || result.maxScore <= 0) {
              continue;
            }

            percentagesBySubject
                .putIfAbsent(key, () => <double>[])
                .add((result.totalScore / result.maxScore) * 100);
          } catch (e) {
            debugPrint('SEMESTER flat results PARSE ERROR: $e');
          }
        }
      }
    }

    // Fallback when monthly_results is unavailable.
    if (percentagesBySubject.isEmpty) {
      final List<String> directKeys = <String>[
        'subject_results',
        'semester_subject_results',
        'semester_results',
      ];

      for (final String keyName in directKeys) {
        final dynamic value = data[keyName];

        if (value is! List) {
          continue;
        }

        for (final dynamic item in value) {
          if (item is! Map) {
            continue;
          }

          try {
            final ScoreModel result = ScoreModel.fromMap(
              Map<String, dynamic>.from(item),
            );

            final String key = result.subjectName.trim().toLowerCase();
            final double maxScore = result.maxScore;

            if (key.isEmpty || maxScore <= 0) {
              continue;
            }

            final double percentage = (result.totalScore / maxScore) * 100;

            percentagesBySubject
                .putIfAbsent(key, () => <double>[])
                .add(percentage);
          } catch (e) {
            debugPrint(
              'SEMESTER DIRECT AVERAGE PARSE ERROR: $e',
            );
          }
        }

        if (percentagesBySubject.isNotEmpty) {
          break;
        }
      }
    }

    final Map<String, double> averages = <String, double>{};

    percentagesBySubject.forEach(
      (String subject, List<double> values) {
        if (values.isEmpty) {
          return;
        }

        final double average =
            values.reduce((double a, double b) => a + b) / values.length;

        averages[subject] = average;

        debugPrint(
          'SEMESTER SUBJECT AVERAGE => '
          '$subject = ${average.toStringAsFixed(2)}% '
          'from ${values.length} month(s)',
        );
      },
    );

    return averages;
  }

  // =====================================================
  // EXTRACT SEMESTER SUBJECT RESULTS
  //
  // IMPORTANT:
  //
  // We do NOT use "highest score".
  //
  // We first look for semester-level data.
  // If the API only exposes monthly_results,
  // we keep the LAST result for each subject,
  // because it represents the most recent semester
  // result available in that response.
  // =====================================================

  List<ScoreModel> _extractSemesterSubjectResults(
    Map<String, dynamic> data,
    int semester,
  ) {
    final List<ScoreModel> directResults = <ScoreModel>[];

    debugPrint(
      '==============================================',
    );

    debugPrint(
      'SEMESTER DETAIL EXTRACT '
      'semester=$semester',
    );

    // ---------------------------------------------------
    // 1. Direct semester subject_results
    // ---------------------------------------------------

    final List<String> directKeys = <String>[
      'subject_results',
      'semester_subject_results',
      'semester_results',
    ];

    for (final String key in directKeys) {
      final dynamic value = data[key];

      if (value is! List) {
        continue;
      }

      for (final dynamic item in value) {
        if (item is! Map) {
          continue;
        }

        try {
          final ScoreModel model = ScoreModel.fromMap(
            Map<String, dynamic>.from(item),
          );

          directResults.add(model);
        } catch (e) {
          debugPrint(
            'SEMESTER DIRECT PARSE ERROR: $e',
          );
        }
      }

      if (directResults.isNotEmpty) {
        break;
      }
    }

    if (directResults.isNotEmpty) {
      final List<ScoreModel> unique = _uniqueBySubjectKeepingLast(
        directResults,
      );

      _debugSemesterResults(
        unique,
      );

      return unique;
    }

    // ---------------------------------------------------
    // 2. Look inside monthly_results
    // ---------------------------------------------------

    final dynamic monthlyResults = data['monthly_results'];

    final List<ScoreModel> monthlySubjects = <ScoreModel>[];

    if (monthlyResults is List) {
      for (final dynamic monthItem in monthlyResults) {
        if (monthItem is! Map) {
          continue;
        }

        final Map<String, dynamic> monthMap = Map<String, dynamic>.from(
          monthItem,
        );

        final dynamic subjectResults = monthMap['subject_results'];

        if (subjectResults is! List) {
          continue;
        }

        for (final dynamic subjectItem in subjectResults) {
          if (subjectItem is! Map) {
            continue;
          }

          try {
            final ScoreModel model = ScoreModel.fromMap(
              Map<String, dynamic>.from(
                subjectItem,
              ),
            );

            monthlySubjects.add(model);
          } catch (e) {
            debugPrint(
              'SEMESTER MONTH SUBJECT PARSE ERROR: '
              '$e',
            );
          }
        }
      }
    }

    // ---------------------------------------------------
    // 3. Semester exam results
    // ---------------------------------------------------

    final List<ScoreModel> examSubjects = <ScoreModel>[];

    final List<String> examKeys = <String>[
      'semester_exam_results',
      'exam_results',
      'semester_exam_subjects',
    ];

    for (final String key in examKeys) {
      final dynamic value = data[key];

      if (value is! List) {
        continue;
      }

      for (final dynamic item in value) {
        if (item is! Map) {
          continue;
        }

        try {
          examSubjects.add(
            ScoreModel.fromMap(
              Map<String, dynamic>.from(item),
            ),
          );
        } catch (e) {
          debugPrint(
            'SEMESTER EXAM PARSE ERROR: $e',
          );
        }
      }

      if (examSubjects.isNotEmpty) {
        break;
      }
    }

    // ---------------------------------------------------
    // 4. Merge monthly + exam
    // ---------------------------------------------------
    //
    // If exam data exists, it should be preferred.
    // Otherwise use the latest monthly record.
    //
    // DO NOT use highest score.
    // ---------------------------------------------------

    final Map<String, ScoreModel> bySubject = <String, ScoreModel>{};

    for (final ScoreModel result in monthlySubjects) {
      final String key = result.subjectName.trim().toLowerCase();

      if (key.isEmpty) {
        continue;
      }

      bySubject[key] = result;
    }

    for (final ScoreModel result in examSubjects) {
      final String key = result.subjectName.trim().toLowerCase();

      if (key.isEmpty) {
        continue;
      }

      bySubject[key] = result;
    }

    final List<ScoreModel> finalResults = bySubject.values.toList();

    _debugSemesterResults(
      finalResults,
    );

    return finalResults;
  }

  // =====================================================
  // UNIQUE KEEP LAST
  // =====================================================

  List<ScoreModel> _uniqueBySubjectKeepingLast(
    List<ScoreModel> input,
  ) {
    final Map<String, ScoreModel> map = <String, ScoreModel>{};

    for (final ScoreModel result in input) {
      final String key = result.subjectName.trim().toLowerCase();

      if (key.isEmpty) {
        continue;
      }

      // IMPORTANT:
      // Keep LAST, NOT highest.
      map[key] = result;
    }

    return map.values.toList();
  }

  // =====================================================
  // DEBUG SEMESTER
  // =====================================================

  void _debugSemesterResults(
    List<ScoreModel> results,
  ) {
    debugPrint(
      'SEMESTER DETAIL SUBJECT COUNT: '
      '${results.length}',
    );

    for (final ScoreModel result in results) {
      debugPrint(
        'SEMESTER DETAIL => '
        '${result.subjectName} | '
        '${result.totalScore}/${result.maxScore}',
      );
    }

    debugPrint(
      'SEMESTER SUBJECT COUNT: '
      '${results.length}',
    );

    debugPrint(
      '==============================================',
    );
  }

  // =====================================================
  // PARSE INT
  // =====================================================

  int _parseInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value.toString(),
        ) ??
        0;
  }
}
