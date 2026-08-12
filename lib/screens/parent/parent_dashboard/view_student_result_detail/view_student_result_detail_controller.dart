import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:tamdansers_lv2/core/api/services/result_api.dart';
import 'package:tamdansers_lv2/data/model/SubjectResultDetailModel.dart';
import 'package:tamdansers_lv2/screens/parent/parent_dashboard/parent_home_tab/parent_home_tab_view.dart';

class ViewStudentResultDetailController extends GetxController {
  // ============================================================
  // DEPENDENCIES
  // ============================================================

  final ResultApi resultApi = ResultApi();
  final GetStorage _box = GetStorage();

  late final ParentHomeTabViewController homeTabController;

  // ============================================================
  // STATE
  // ============================================================

  final RxBool isLoading = false.obs;

  final RxString semesterTitle = 'លទ្ធផលសិក្សា'.obs;

  final RxList<SubjectResultDetailModel> subjectResults =
      <SubjectResultDetailModel>[].obs;

  // ============================================================
  // SUMMARY
  // ============================================================

  final RxDouble totalScore = 0.0.obs;

  final RxDouble totalMaxScore = 0.0.obs;

  final RxDouble average = 0.0.obs;

  final RxDouble percentage = 0.0.obs;

  final RxInt subjectCount = 0.obs;

  final RxInt rank = 0.obs;

  final RxInt totalStudents = 0.obs;

  final RxString monthName = ''.obs;

  final RxInt semester = 0.obs;

  final RxInt month = 0.obs;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    // ParentHomeTabController must already exist.
    homeTabController = Get.find<ParentHomeTabViewController>();

    fetchDetailedResultsFromApi();
  }

  void _loadFromCache(String cacheKey) {
    try {
      final dynamic cached = _box.read(cacheKey);
      if (cached != null) {
        final dynamic data = _unwrapResponse(cached);
        if (data != null) {
          final List<SubjectResultDetailModel> parsedResults =
              _parseSubjectResults(data);
          if (parsedResults.isNotEmpty) {
            subjectResults.assignAll(parsedResults);
            _parseSummary(data);

            final double sumScore =
                parsedResults.fold(0.0, (double sum, item) => sum + item.score);
            final double sumMax = parsedResults.fold(
                0.0,
                (double sum, item) =>
                    sum + (item.maxScore > 0 ? item.maxScore : 100.0));

            if (totalScore.value == 0) totalScore.value = sumScore;
            if (totalMaxScore.value == 0) totalMaxScore.value = sumMax;
            if (average.value == 0) {
              if (sumMax > 0) {
                average.value = (sumScore / sumMax) * 100;
              } else {
                final double sumPct = parsedResults.fold(
                    0.0, (double sum, item) => sum + item.percentageValue);
                average.value = sumPct / parsedResults.length;
              }
            }
            if (percentage.value == 0) {
              percentage.value = totalMaxScore.value > 0
                  ? (totalScore.value / totalMaxScore.value * 100)
                  : average.value;
            }
            if (subjectCount.value == 0) {
              subjectCount.value = parsedResults.length;
            }

            isLoading.value = false;
          }
        }
      }
    } catch (e) {
      debugPrint('LOAD RESULT DETAIL CACHE ERROR: $e');
    }
  }

  // ============================================================
  // FETCH DETAIL RESULTS
  // ============================================================

  Future<void> fetchDetailedResultsFromApi() async {
    try {
      // ========================================================
      // SELECTED CHILD
      // ========================================================

      final dynamic child = homeTabController.selectedChild.value;

      final int? studentId = _parseStudentId(child);

      // ========================================================
      // FILTER
      // ========================================================

      final String selectedType = homeTabController.selectedResultType.value;

      final String selectedSub = homeTabController.selectedSubResult.value;

      // ========================================================
      // TITLE
      // ========================================================

      if (selectedType.trim().isNotEmpty && selectedSub.trim().isNotEmpty) {
        semesterTitle.value = '$selectedType • $selectedSub';
      } else if (selectedType.trim().isNotEmpty) {
        semesterTitle.value = selectedType;
      } else if (selectedSub.trim().isNotEmpty) {
        semesterTitle.value = selectedSub;
      } else {
        semesterTitle.value = 'លទ្ធផលសិក្សា';
      }

      if (studentId == null) {
        debugPrint(
          'RESULT DETAIL ERROR: studentId is null',
        );

        return;
      }

      final _ResultApiFilter filter = _buildApiFilter(
        selectedType,
        selectedSub,
      );

      final String cacheKey =
          'result_detail_${studentId}_${filter.type}_${filter.semester}_${filter.month}';

      _loadFromCache(cacheKey);

      if (subjectResults.isEmpty) {
        isLoading.value = true;
      }

      // ========================================================
      // BUILD ENDPOINT
      // ========================================================

      late final String endpoint;

      if (filter.type == 'monthly') {
        endpoint = '/parents/results/'
            '$studentId'
            '/semester/'
            '${filter.semester}'
            '/month/'
            '${filter.month}';
      } else if (filter.type == 'semester' || filter.type == 'semi_annual') {
        endpoint = '/parents/results/'
            '$studentId'
            '/semester/'
            '${filter.semester}';
      } else {
        endpoint = '/parents/results/'
            '$studentId'
            '/yearly';
      }

      final dynamic response = await resultApi.baseApiService.get(
        endpoint: endpoint,
      );

      final dynamic data = _unwrapResponse(response);

      if (data == null) {
        debugPrint(
          'RESULT DETAIL ERROR: response is null',
        );

        return;
      }

      await _box.write(cacheKey, response);

      // ========================================================
      // PARSE SUBJECT RESULTS
      // ========================================================

      List<SubjectResultDetailModel> parsedResults = _parseSubjectResults(data);

      if (parsedResults.isEmpty && filter.type == 'yearly') {
        debugPrint(
          'RESULT DETAIL: Yearly API returned no subjects, fetching semester details fallback...',
        );

        parsedResults = await _fetchYearlySubjectFallback(studentId);
      }

      subjectResults.assignAll(
        parsedResults,
      );

      // ========================================================
      // PARSE SUMMARY (With Fallback Calculation)
      // ========================================================

      _parseSummary(data);

      if (parsedResults.isNotEmpty) {
        final double sumScore =
            parsedResults.fold(0.0, (double sum, item) => sum + item.score);
        final double sumMax = parsedResults.fold(
            0.0,
            (double sum, item) =>
                sum + (item.maxScore > 0 ? item.maxScore : 100.0));

        if (totalScore.value == 0) {
          totalScore.value = sumScore;
        }
        if (totalMaxScore.value == 0) {
          totalMaxScore.value = sumMax;
        }
        if (average.value == 0) {
          if (sumMax > 0) {
            average.value = (sumScore / sumMax) * 100;
          } else {
            final double sumPct = parsedResults.fold(
                0.0, (double sum, item) => sum + item.percentageValue);
            average.value = sumPct / parsedResults.length;
          }
        }
        if (percentage.value == 0) {
          percentage.value = totalMaxScore.value > 0
              ? (totalScore.value / totalMaxScore.value * 100)
              : average.value;
        }
        if (subjectCount.value == 0) {
          subjectCount.value = parsedResults.length;
        }
      }

      // ========================================================
      // FINAL LOG
      // ========================================================

      debugPrint(
        '========================================',
      );

      debugPrint(
        'RESULT DETAIL SUBJECT COUNT: '
        '${subjectResults.length}',
      );

      for (final SubjectResultDetailModel result in subjectResults) {
        debugPrint(
          'SUBJECT => '
          'id=${result.subjectId}, '
          'name=${result.subjectName}, '
          'score=${result.score}, '
          'max=${result.maxScore}, '
          'percentage=${result.percentageValue}',
        );
      }

      debugPrint(
        '========================================',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'RESULT DETAIL ERROR: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      subjectResults.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // BUILD API FILTER
  // ============================================================

  _ResultApiFilter _buildApiFilter(
    String type,
    String sub,
  ) {
    final String normalizedType = type.trim().toLowerCase();
    final String normalizedSub = sub.trim().toLowerCase();

    int semesterValue = 1;
    int monthValue = 1;
    bool hasMonthMatch = false;

    // ----------------------------------------------------------
    // SEMESTER
    // ----------------------------------------------------------

    if (normalizedSub.contains('semester 2') ||
        normalizedSub.contains('semester2') ||
        normalizedSub.contains('ឆមាស 2') ||
        normalizedSub.contains('ឆមាស២') ||
        normalizedSub.contains('ឆមាស ២') ||
        normalizedSub.contains('ឆមាសទី ២') ||
        normalizedSub.contains('ឆមាសទី២') ||
        normalizedSub.contains('ប្រចាំឆមាស 2') ||
        normalizedSub.contains('ប្រចាំឆមាស ២') ||
        normalizedSub.contains('ប្រចាំឆមាស២')) {
      semesterValue = 2;
    } else if (normalizedSub.contains('semester 1') ||
        normalizedSub.contains('semester1') ||
        normalizedSub.contains('ឆមាស 1') ||
        normalizedSub.contains('ឆមាស១') ||
        normalizedSub.contains('ឆមាស ១') ||
        normalizedSub.contains('ឆមាសទី ១') ||
        normalizedSub.contains('ឆមាសទី១') ||
        normalizedSub.contains('ប្រចាំឆមាស 1') ||
        normalizedSub.contains('ប្រចាំឆមាស ១') ||
        normalizedSub.contains('ប្រចាំឆមាស១')) {
      semesterValue = 1;
    }

    // ----------------------------------------------------------
    // MONTH
    // ----------------------------------------------------------

    final Map<String, int> months = {
      'january': 1,
      'jan': 1,
      'មករា': 1,
      'february': 2,
      'feb': 2,
      'កុម្ភៈ': 2,
      'march': 3,
      'mar': 3,
      'មីនា': 3,
      'april': 4,
      'apr': 4,
      'មេសា': 4,
      'may': 5,
      'ឧសភា': 5,
      'june': 6,
      'jun': 6,
      'មិថុនា': 6,
      'july': 7,
      'jul': 7,
      'កក្កដា': 7,
      'august': 8,
      'aug': 8,
      'សីហា': 8,
      'september': 9,
      'sep': 9,
      'sept': 9,
      'កញ្ញា': 9,
      'october': 10,
      'oct': 10,
      'តុលា': 10,
      'november': 11,
      'nov': 11,
      'វិច្ឆិកា': 11,
      'december': 12,
      'dec': 12,
      'ធ្នូ': 12,
    };

    for (final entry in months.entries) {
      if (normalizedSub.contains(entry.key)) {
        monthValue = entry.value;
        hasMonthMatch = true;
        break;
      }
    }

    // ----------------------------------------------------------
    // DIRECT MONTH NUMBER
    // ----------------------------------------------------------

    final RegExp monthRegex = RegExp(r'(?:month|ខែ)\s*(\d{1,2})');

    final Match? monthMatch = monthRegex.firstMatch(
      normalizedSub,
    );

    if (monthMatch != null) {
      final int? parsedMonth = int.tryParse(
        monthMatch.group(1) ?? '',
      );

      if (parsedMonth != null && parsedMonth >= 1 && parsedMonth <= 12) {
        monthValue = parsedMonth;
        hasMonthMatch = true;
      }
    }

    // ----------------------------------------------------------
    // MONTH -> SEMESTER (Only if a specific month was matched)
    // ----------------------------------------------------------
    if (hasMonthMatch) {
      if (monthValue >= 1 && monthValue <= 6) {
        semesterValue = 1;
      } else if (monthValue >= 7 && monthValue <= 12) {
        semesterValue = 2;
      }
    }

    // ----------------------------------------------------------
    // TYPE
    // ----------------------------------------------------------

    String apiType;

    if (normalizedType.contains('month') ||
        normalizedType.contains('monthly') ||
        normalizedType.contains('ប្រចាំខែ')) {
      apiType = 'monthly';
    } else if (normalizedType.contains('semester') ||
        normalizedType.contains('semi') ||
        normalizedType.contains('ឆមាស')) {
      apiType = 'semester';
    } else if (normalizedType.contains('year') ||
        normalizedType.contains('annual') ||
        normalizedType.contains('ប្រចាំឆ្នាំ')) {
      apiType = 'yearly';
    } else {
      apiType = 'monthly';
    }

    return _ResultApiFilter(
      type: apiType,
      month: monthValue,
      semester: semesterValue,
    );
  }

  // ============================================================
  // PARSE SUMMARY
  // ============================================================

  void _parseSummary(
    dynamic data,
  ) {
    if (data is! Map) {
      return;
    }

    // ----------------------------------------------------------
    // SEMESTER
    // ----------------------------------------------------------

    semester.value = _parseInt(
      data['semester'],
    );

    // ----------------------------------------------------------
    // MONTH
    // ----------------------------------------------------------

    month.value = _parseInt(
      data['month'],
    );

    // ----------------------------------------------------------
    // MONTH NAME
    // ----------------------------------------------------------

    monthName.value = data['month_name']?.toString() ?? '';

    // ----------------------------------------------------------
    // SUMMARY
    // ----------------------------------------------------------

    final dynamic summary = data['summary'];

    if (summary is Map) {
      totalScore.value = _parseDouble(
        summary['total_score'] ?? summary['total'] ?? data['total_score'],
      );

      totalMaxScore.value = _parseDouble(
        summary['total_max'] ?? summary['total_max_score'] ?? data['total_max'],
      );

      average.value = _parseDouble(
        summary['average'] ??
            summary['semester_result'] ??
            summary['monthly_average'] ??
            summary['yearly_average'] ??
            summary['yearly_result'] ??
            summary['overall_average'] ??
            summary['semester_exam_average'] ??
            data['average'] ??
            data['semester_result'] ??
            data['yearly_result'] ??
            data['yearly_average'],
      );

      percentage.value = _parseDouble(
        summary['percentage'] ??
            summary['percent'] ??
            (average.value > 0 ? average.value : null),
      );

      subjectCount.value = _parseInt(
        summary['subjects'] ?? summary['total_subjects'] ?? data['subjects'],
      );
    } else {
      average.value = _parseDouble(
        data['average'] ??
            data['semester_result'] ??
            data['yearly_result'] ??
            data['yearly_average'],
      );
      totalScore.value = _parseDouble(data['total_score']);
      totalMaxScore.value = _parseDouble(data['total_max']);
      percentage.value = _parseDouble(data['percentage'] ?? average.value);
    }

    // ----------------------------------------------------------
    // RANK
    // ----------------------------------------------------------

    final dynamic rankData = data['rank'];

    if (rankData is Map) {
      rank.value = _parseInt(
        rankData['rank'],
      );

      totalStudents.value = _parseInt(
        rankData['total_students'],
      );

      if (average.value == 0) {
        average.value = _parseDouble(
          rankData['average'],
        );
      }

      if (totalScore.value == 0) {
        totalScore.value = _parseDouble(
          rankData['total_score'],
        );
      }

      if (totalMaxScore.value == 0) {
        totalMaxScore.value = _parseDouble(
          rankData['total_max'],
        );
      }
    } else if (data['rank'] != null) {
      rank.value = _parseInt(data['rank']);
    }

    // ----------------------------------------------------------
    // SEMESTER RANK (new API structure)
    // ----------------------------------------------------------

    if (rank.value == 0) {
      final dynamic semesterRankData = data['semester_rank'];

      if (semesterRankData is Map) {
        rank.value = _parseInt(
          semesterRankData['rank'],
        );

        if (totalStudents.value == 0) {
          totalStudents.value = _parseInt(
            semesterRankData['total_students'],
          );
        }
      } else if (semesterRankData != null) {
        rank.value = _parseInt(semesterRankData);
      }
    }

    // ----------------------------------------------------------
    // YEARLY RANK (new API structure)
    // ----------------------------------------------------------

    if (rank.value == 0) {
      final dynamic yearlyRankData = data['yearly_rank'];

      if (yearlyRankData is Map) {
        rank.value = _parseInt(
          yearlyRankData['rank'],
        );

        if (totalStudents.value == 0) {
          totalStudents.value = _parseInt(
            yearlyRankData['total_students'],
          );
        }
      } else if (yearlyRankData != null) {
        rank.value = _parseInt(yearlyRankData);
      }
    }

    // ----------------------------------------------------------
    // MONTHLY RANK (new API: monthly_results[].rank)
    // ----------------------------------------------------------

    if (rank.value == 0 && month.value > 0) {
      final dynamic monthlyResults = data['monthly_results'];

      if (monthlyResults is List) {
        for (final dynamic monthItem in monthlyResults) {
          if (monthItem is! Map) {
            continue;
          }

          final int mMonth = _parseInt(monthItem['month']);

          if (mMonth == month.value && monthItem['rank'] is Map) {
            rank.value = _parseInt(
              monthItem['rank']['rank'],
            );

            if (totalStudents.value == 0) {
              totalStudents.value = _parseInt(
                monthItem['rank']['total_students'],
              );
            }

            break;
          }
        }
      }
    }

    // ----------------------------------------------------------
    // FALLBACK: Home tab rank
    // ----------------------------------------------------------

    if (rank.value == 0) {
      final String homeRank = homeTabController.displayRank;
      if (homeRank.isNotEmpty && homeRank != '-') {
        rank.value = int.tryParse(homeRank) ?? 0;
      }
    }
  }

  // ============================================================
  // PARSE SUBJECT RESULTS
  // ============================================================

  List<SubjectResultDetailModel> _parseSubjectResults(
    dynamic data,
  ) {
    final List<SubjectResultDetailModel> list = [];

    dynamic resultsList;

    // ==========================================================
    // MAP RESPONSE
    // ==========================================================

    if (data is Map) {
      final dynamic monthlyResults = data['monthly_results'];

      if (monthlyResults is List && monthlyResults.isNotEmpty) {
        // IMPORTANT:
        // Semester detail must aggregate ALL monthly subject_results.
        // Calculate the average percentage per subject across all months in the semester.
        final Map<String, List<Map<String, dynamic>>> groupedSubjects =
            <String, List<Map<String, dynamic>>>{};

        for (final dynamic monthItem in monthlyResults) {
          if (monthItem is! Map) {
            continue;
          }

          dynamic monthSubjects =
              monthItem['results'] ?? monthItem['subject_results'];

          if (monthSubjects is! List) {
            continue;
          }

          for (final dynamic item in monthSubjects) {
            if (item is! Map) {
              continue;
            }

            final Map<String, dynamic> map = Map<String, dynamic>.from(
              item,
            );

            final String subjectName = map['subject_name']?.toString().trim() ??
                map['subject']?.toString().trim() ??
                map['name']?.toString().trim() ??
                '';

            final String subjectId =
                (map['subject_id'] ?? map['subjectId'] ?? map['id']).toString();

            final String key =
                subjectName.isNotEmpty ? subjectName.toLowerCase() : subjectId;

            if (key.isEmpty) {
              continue;
            }

            groupedSubjects
                .putIfAbsent(key, () => <Map<String, dynamic>>[])
                .add(map);
          }
        }

        // Also check direct subject_results / semester_exam_subjects / results if present
        final dynamic extraSubjects = data['subject_results'] ??
            data['semester_exam_subjects'] ??
            data['results'];

        if (extraSubjects is List) {
          for (final dynamic item in extraSubjects) {
            if (item is! Map) {
              continue;
            }

            final Map<String, dynamic> map = Map<String, dynamic>.from(
              item,
            );

            final String subjectName = map['subject_name']?.toString().trim() ??
                map['subject']?.toString().trim() ??
                map['name']?.toString().trim() ??
                '';

            final String subjectId =
                (map['subject_id'] ?? map['subjectId'] ?? map['id']).toString();

            final String key =
                subjectName.isNotEmpty ? subjectName.toLowerCase() : subjectId;

            if (key.isEmpty) {
              continue;
            }

            groupedSubjects
                .putIfAbsent(key, () => <Map<String, dynamic>>[])
                .add(map);
          }
        }

        final List<Map<String, dynamic>> averagedSubjects =
            <Map<String, dynamic>>[];

        groupedSubjects.forEach(
          (String key, List<Map<String, dynamic>> items) {
            double percentageTotal = 0;
            int validCount = 0;
            Map<String, dynamic>? firstValid;

            for (final Map<String, dynamic> item in items) {
              final double score = _parseDouble(
                item['total_score'] ??
                    item['score'] ??
                    item['semester_result'] ??
                    item['monthly_average'] ??
                    item['average'] ??
                    item['result'] ??
                    0,
              );

              final double maxScore = _parseDouble(
                item['max_score'] ?? item['total_max'] ?? item['max'] ?? 100,
              );

              if (maxScore <= 0) {
                continue;
              }

              firstValid ??= item;
              percentageTotal += (score / maxScore) * 100;
              validCount++;
            }

            if (firstValid == null || validCount == 0) {
              return;
            }

            final Map<String, dynamic> averaged =
                Map<String, dynamic>.from(firstValid);

            // Store the semester average as a percentage out of 100.
            averaged['total_score'] = percentageTotal / validCount;
            averaged['score'] = percentageTotal / validCount;
            averaged['max_score'] = 100;

            averagedSubjects.add(averaged);
          },
        );

        if (averagedSubjects.isNotEmpty) {
          resultsList = averagedSubjects;
        }
      }

      if (resultsList is! List) {
        resultsList = data['results'];
      }

      if (resultsList is! List) {
        resultsList = data['subject_results'];
      }

      if (resultsList is! List) {
        resultsList = data['semester_exam_subjects'];
      }

      if (resultsList is! List) {
        resultsList = data['subjects'];
      }

      if (resultsList is! List) {
        resultsList = data['data'];
      }

      if (resultsList is! List) {
        resultsList = data['semester_results'];
      }
    }

    // ==========================================================
    // DIRECT LIST
    // ==========================================================

    if (data is List) {
      resultsList = data;
    }

    // ==========================================================
    // NO RESULTS
    // ==========================================================

    if (resultsList is! List) {
      debugPrint(
        'RESULT DETAIL: results list NOT FOUND',
      );

      debugPrint(
        'RESULT DETAIL DATA TYPE: '
        '${data.runtimeType}',
      );

      return list;
    }

    debugPrint(
      'RESULT DETAIL RAW RESULTS COUNT: '
      '${resultsList.length}',
    );

    // ==========================================================
    // EACH RESULT
    // ==========================================================

    for (final dynamic item in resultsList) {
      if (item is! Map) {
        continue;
      }

      final Map<String, dynamic> map = Map<String, dynamic>.from(item);

      // --------------------------------------------------------
      // SUBJECT ID
      // --------------------------------------------------------

      final int subjectId = _parseInt(
        map['subject_id'] ?? map['subjectId'] ?? map['id'],
      );

      // --------------------------------------------------------
      // SUBJECT NAME
      // --------------------------------------------------------

      final String subjectName = map['subject_name']?.toString().trim() ??
          map['subject']?.toString().trim() ??
          map['name']?.toString().trim() ??
          '';

      if (subjectName.isEmpty) {
        debugPrint(
          'RESULT DETAIL: subject name empty',
        );

        continue;
      }

      // --------------------------------------------------------
      // SCORE
      // --------------------------------------------------------
      //
      // Your actual API:
      //
      // score: 39.0
      // total_score: 39.0
      //
      // Prefer total_score because it includes bonus.
      //
      // --------------------------------------------------------

      final double score = _parseDouble(
        map['total_score'] ??
            map['score'] ??
            map['semester_result'] ??
            map['monthly_average'] ??
            map['average'] ??
            map['result'] ??
            0,
      );

      // --------------------------------------------------------
      // MAX SCORE
      // --------------------------------------------------------

      final double maxScore = _parseDouble(
        map['max_score'] ?? map['total_max'] ?? map['max'] ?? 100,
      );

      // --------------------------------------------------------
      // CREATE MODEL
      // --------------------------------------------------------

      final SubjectResultDetailModel result = SubjectResultDetailModel(
        subjectId: subjectId,
        subjectName: subjectName,
        score: score,
        maxScore: maxScore > 0 ? maxScore : 100,
      );

      list.add(result);

      debugPrint(
        'RESULT DETAIL PARSED => '
        '${result.subjectName} | '
        '${result.score}/${result.maxScore}',
      );
    }

    return list;
  }

  // ============================================================
  // UNWRAP RESPONSE
  // ============================================================

  dynamic _unwrapResponse(
    dynamic response,
  ) {
    if (response == null) {
      return null;
    }

    // Dio Response
    try {
      final dynamic data = response.data;

      if (data != null) {
        return data;
      }
    } catch (_) {}

    // Some APIs return {data: {...}}
    if (response is Map) {
      final dynamic nested = response['data'];

      if (nested is Map || nested is List) {
        return nested;
      }
    }

    return response;
  }

  // ============================================================
  // PARSE INT
  // ============================================================

  int _parseInt(
    dynamic value,
  ) {
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
          value.toString().trim(),
        ) ??
        0;
  }

  // ============================================================
  // PARSE DOUBLE
  // ============================================================

  double _parseDouble(
    dynamic value,
  ) {
    if (value == null) {
      return 0.0;
    }

    if (value is num) {
      return value.toDouble();
    }

    final String text = value.toString().trim();

    if (text.isEmpty) {
      return 0.0;
    }

    return double.tryParse(
          text,
        ) ??
        0.0;
  }

  // ============================================================
  // PARSE STUDENT ID
  // ============================================================

  int? _parseStudentId(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(
        value.trim(),
      );
    }

    if (value is Map) {
      final List<String> keys = [
        'id',
        'student_id',
        'studentId',
        'child_id',
        'childId',
      ];

      for (final String key in keys) {
        final int? id = _parseStudentId(
          value[key],
        );

        if (id != null) {
          return id;
        }
      }

      final int? studentId = _parseStudentId(
        value['student'],
      );

      if (studentId != null) {
        return studentId;
      }

      final int? childId = _parseStudentId(
        value['child'],
      );

      if (childId != null) {
        return childId;
      }
    }

    return null;
  }

  // ============================================================
  // FORMAT NUMBER
  // ============================================================

  String formatNumber(
    double value,
  ) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  // ============================================================
  // YEARLY SUBJECT FALLBACK
  // ============================================================
  //
  // The backend API for /parents/results/$studentId/yearly
  // returns overall summary data but no subject list array.
  // We fetch semester 1 and 2 subject details and calculate
  // the annual subject percentage average.
  //
  // ============================================================

  Future<List<SubjectResultDetailModel>> _fetchYearlySubjectFallback(
    int studentId,
  ) async {
    final List<Map<String, dynamic>> allMonthSubjects =
        <Map<String, dynamic>>[];

    for (final int sem in <int>[1, 2]) {
      try {
        final dynamic semResp = await resultApi.baseApiService.get(
          endpoint: '/parents/results/$studentId/semester/$sem',
        );

        final dynamic semData = _unwrapResponse(semResp);

        if (semData is Map) {
          final dynamic monthlyResults = semData['monthly_results'];

          if (monthlyResults is List) {
            for (final dynamic mItem in monthlyResults) {
              if (mItem is Map) {
                final dynamic mSubjects =
                    mItem['results'] ?? mItem['subject_results'];

                if (mSubjects is List) {
                  for (final dynamic s in mSubjects) {
                    if (s is Map) {
                      allMonthSubjects.add(
                        Map<String, dynamic>.from(s),
                      );
                    }
                  }
                }
              }
            }
          } else {
            final dynamic semResults =
                semData['results'] ?? semData['subject_results'];

            if (semResults is List) {
              for (final dynamic s in semResults) {
                if (s is Map) {
                  allMonthSubjects.add(
                    Map<String, dynamic>.from(s),
                  );
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint(
          'YEARLY FALLBACK SEMESTER $sem ERROR: $e',
        );
      }
    }

    if (allMonthSubjects.isEmpty) {
      return <SubjectResultDetailModel>[];
    }

    final Map<String, List<Map<String, dynamic>>> grouped =
        <String, List<Map<String, dynamic>>>{};

    for (final Map<String, dynamic> item in allMonthSubjects) {
      final String name = item['subject_name']?.toString().trim() ??
          item['subject']?.toString().trim() ??
          item['name']?.toString().trim() ??
          '';

      final String id =
          (item['subject_id'] ?? item['subjectId'] ?? item['id'] ?? '')
              .toString();

      final String key = name.isNotEmpty ? name.toLowerCase() : id;

      if (key.isEmpty) {
        continue;
      }

      grouped.putIfAbsent(key, () => <Map<String, dynamic>>[]).add(item);
    }

    final List<SubjectResultDetailModel> list = <SubjectResultDetailModel>[];

    grouped.forEach((String key, List<Map<String, dynamic>> items) {
      double totalPercentage = 0;
      int count = 0;
      String subjectName = '';
      int subjectId = 0;

      for (final Map<String, dynamic> item in items) {
        if (subjectName.isEmpty) {
          subjectName = item['subject_name']?.toString().trim() ??
              item['subject']?.toString().trim() ??
              item['name']?.toString().trim() ??
              '';
        }

        if (subjectId == 0) {
          subjectId = _parseInt(
            item['subject_id'] ?? item['subjectId'] ?? item['id'],
          );
        }

        final double sc = _parseDouble(
          item['total_score'] ??
              item['score'] ??
              item['monthly_average'] ??
              item['average'] ??
              0,
        );

        final double mx = _parseDouble(
          item['max_score'] ?? item['total_max'] ?? item['max'] ?? 100,
        );

        final double effectiveMax = mx > 0 ? mx : 100.0;

        totalPercentage += (sc / effectiveMax) * 100;
        count++;
      }

      if (count > 0 && subjectName.isNotEmpty) {
        final double avgPercent = totalPercentage / count;

        list.add(
          SubjectResultDetailModel(
            subjectId: subjectId,
            subjectName: subjectName,
            score: double.parse(avgPercent.toStringAsFixed(1)),
            maxScore: 100.0,
          ),
        );
      }
    });

    return list;
  }
}

// ================================================================
// API FILTER MODEL
// ================================================================

class _ResultApiFilter {
  final String type;
  final int month;
  final int semester;

  const _ResultApiFilter({
    required this.type,
    required this.month,
    required this.semester,
  });
}
