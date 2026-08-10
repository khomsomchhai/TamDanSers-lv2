part of 'parent_home_tab_view.dart';

class ParentHomeTabViewController extends GetxController {
  // =====================================================
  // DEPENDENCIES
  // =====================================================

  final UserController userController = Get.find<UserController>();

  final ParentAttendanceTabViewController attendanceController =
      Get.find<ParentAttendanceTabViewController>();

  final GetStorage box = GetStorage();

  final ResultApi resultApi = ResultApi();

  final AuthServices authServices = AuthServices();

  final ScheduleApi scheduleApi = ScheduleApi();

  // =====================================================
  // LOADING / ERROR
  // =====================================================

  final RxBool isLoading = false.obs;

  final RxBool isScheduleLoading = false.obs;

  final RxString errorMessage = ''.obs;

  final RxString scheduleError = ''.obs;

  // =====================================================
  // STUDENTS
  // =====================================================

  final RxList<Map<String, dynamic>> students = <Map<String, dynamic>>[].obs;

  final Rxn<Map<String, dynamic>> selectedChild = Rxn<Map<String, dynamic>>();

  // =====================================================
  // RESULT TYPE
  // =====================================================

  final List<String> resultTypes = <String>[
    'ប្រចាំខែ',
    'ឆមាស',
    'ប្រចាំឆមាស',
    'ប្រចាំឆ្នាំ',
  ];

  final List<String> khmerMonths = <String>[
    'ខែមករា',
    'ខែកុម្ភៈ',
    'ខែមីនា',
    'ខែមេសា',
    'ខែឧសភា',
    'ខែមិថុនា',
    'ខែកក្កដា',
    'ខែសីហា',
    'ខែកញ្ញា',
    'ខែតុលា',
    'ខែវិច្ឆិកា',
    'ខែធ្នូ',
  ];

  final RxString selectedResultType = 'ប្រចាំខែ'.obs;

  late final RxString selectedSubResult =
      khmerMonths[DateTime.now().month - 1].obs;

  final RxBool isResultExpanded = false.obs;

  // =====================================================
  // SCORE SUMMARY
  // =====================================================

  final RxString rxTotalScore = ''.obs;

  final RxString rxRank = ''.obs;

  final RxString rxAverage = ''.obs;

  // =====================================================
  // IMPORTANT
  //
  // ONLY REAL SUBJECT DETAIL RESULTS
  // ARE STORED HERE.
  //
  // Strength / Improvement MUST USE THIS LIST.
  // =====================================================

  final RxList<ScoreModel> scoreResults = <ScoreModel>[].obs;

  // Semester-only subject averages calculated from ALL monthly_results.
  // Key = normalized subject name, value = average percentage.
  final RxMap<String, double> semesterSubjectAverages = <String, double>{}.obs;

  int _resultRequestId = 0;

  // =====================================================
  // DASHBOARD
  // =====================================================

  final Rxn dashboard = Rxn();

  // =====================================================
  // STUDENT IMAGES
  // =====================================================

  final RxMap<int, String> studentImages = <int, String>{}.obs;

  // =====================================================
  // SCHEDULE
  // =====================================================

  final RxList<ScheduleModel> todaySchedule = <ScheduleModel>[].obs;

  // =====================================================
  // ATTENDANCE
  // =====================================================

  final RxBool isAttendanceExpanded = false.obs;

  // =====================================================
  // ACADEMIC PROGRESS
  // =====================================================

  final RxBool isAcademicProgressExpanded = true.obs;

  void toggleAcademicProgressExpanded() {
    isAcademicProgressExpanded.toggle();
  }

  // =====================================================
  // KHMER SUBJECT NAME
  // =====================================================

  String subjectNameKhmer(
    String subjectName,
  ) {
    final String name = subjectName.trim().toLowerCase();

    const Map<String, String> map = <String, String>{
      'khmer': 'ភាសាខ្មែរ',
      'math': 'គណិតវិទ្យា',
      'mathematics': 'គណិតវិទ្យា',
      'english': 'ភាសាអង់គ្លេស',
      'biology': 'ជីវវិទ្យា',
      'physics': 'រូបវិទ្យា',
      'chemistry': 'គីមីវិទ្យា',
      'history': 'ប្រវត្តិវិទ្យា',
      'geography': 'ភូមិវិទ្យា',
      'civics': 'សីលធម៌-ពលរដ្ឋវិជ្ជា',
      'computer': 'កុំព្យូទ័រ',
      'ict': 'បច្ចេកវិទ្យាព័ត៌មាន',
      'physical education': 'អប់រំកាយ',
      'pe': 'អប់រំកាយ',
      'art': 'សិល្បៈ',
      'music': 'តន្ត្រី',
    };

    return map[name] ?? subjectName.trim();
  }

  // =====================================================
  // SCORE PERCENTAGE
  //
  // IMPORTANT:
  //
  // 80/100 = 80%
  // 42/50  = 84%
  //
  // So we NEVER compare raw score directly.
  // =====================================================

  double _percentage(
    ScoreModel result,
  ) {
    final double score = result.totalScore;

    final double max = result.maxScore;

    if (max <= 0) {
      return 0;
    }

    return (score / max) * 100;
  }

  bool get _isSemesterResult {
    final String type = selectedResultType.value.trim().toLowerCase();

    return type == 'ឆមាស' ||
        type == 'ប្រចាំឆមាស' ||
        type.contains('semester') ||
        type.contains('semi');
  }

  Map<String, double> get _subjectPercentagesForAnalysis {
    if (_isSemesterResult && semesterSubjectAverages.isNotEmpty) {
      return Map<String, double>.from(semesterSubjectAverages);
    }

    final Map<String, double> result = <String, double>{};

    for (final ScoreModel score in scoreResults) {
      final String key = score.subjectName.trim().toLowerCase();

      if (key.isEmpty || score.maxScore <= 0) {
        continue;
      }

      result[key] = _percentage(score);
    }

    return result;
  }

  // =====================================================
  // STRENGTHS
  //
  // >= 80%
  // OR ABSENCE 1-2
  // =====================================================

  List<String> get strengthsList {
    final List<String> list = <String>[];

    debugPrint(
      '==============================================',
    );

    debugPrint(
      '--- DEBUG STRENGTH RESULTS ---',
    );

    debugPrint(
      'Score Results Type: '
      '${scoreResults.runtimeType}',
    );

    debugPrint(
      'Score Results Count: '
      '${scoreResults.length}',
    );

    // ---------------------------------------------------
    // SUBJECTS
    // ---------------------------------------------------

    final Map<String, double> subjectPercentages =
        _subjectPercentagesForAnalysis;

    for (final MapEntry<String, double> entry in subjectPercentages.entries) {
      final String subject = entry.key.trim();

      if (subject.isEmpty) {
        continue;
      }

      final double percentage = entry.value;
      final String khmer = subjectNameKhmer(subject);

      debugPrint(
        'STRENGTH CHECK => '
        'subject="$subject", '
        'KH="$khmer", '
        'percentage=$percentage',
      );

      if (percentage >= 80) {
        list.add(khmer);
      }
    }

    // ---------------------------------------------------
    // ATTENDANCE
    // ---------------------------------------------------

    final int absentDays = attendanceController.absentDays.value;

    debugPrint(
      'STRENGTH ATTENDANCE => '
      'absent=$absentDays',
    );

    if (absentDays >= 1 && absentDays <= 2) {
      list.add('វត្តមានល្អ');
    }

    // ---------------------------------------------------
    // UNIQUE
    // ---------------------------------------------------

    final List<String> finalList = list.toSet().toList();

    if (finalList.isEmpty) {
      finalList.add('ខិតខំបន្ថែម');
    }

    debugPrint(
      'FINAL STRENGTHS LIST: '
      '$finalList',
    );

    debugPrint(
      '==============================================',
    );

    return finalList;
  }

  // =====================================================
  // IMPROVEMENTS
  //
  // < 50%
  // OR ABSENCE >= 8
  // =====================================================

  List<String> get improvementsList {
    final List<String> list = <String>[];

    debugPrint(
      '==============================================',
    );

    debugPrint(
      '--- DEBUG IMPROVEMENT RESULTS ---',
    );

    debugPrint(
      'Score Results Type: '
      '${scoreResults.runtimeType}',
    );

    debugPrint(
      'Score Results Count: '
      '${scoreResults.length}',
    );

    // ---------------------------------------------------
    // SUBJECTS
    // ---------------------------------------------------

    final Map<String, double> subjectPercentages =
        _subjectPercentagesForAnalysis;

    for (final MapEntry<String, double> entry in subjectPercentages.entries) {
      final String subject = entry.key.trim();

      if (subject.isEmpty) {
        continue;
      }

      final double percentage = entry.value;
      final String khmer = subjectNameKhmer(subject);

      debugPrint(
        'IMPROVEMENT CHECK => '
        'subject="$subject", '
        'KH="$khmer", '
        'percentage=$percentage',
      );

      // Improvement threshold: below 60%.
      if (percentage < 60) {
        list.add(khmer);

        debugPrint(
          'LOW SCORE FOUND => '
          '$khmer',
        );
      }
    }

    // ---------------------------------------------------
    // ATTENDANCE
    // ---------------------------------------------------

    final int absentDays = attendanceController.absentDays.value;

    debugPrint(
      'IMPROVEMENT ATTENDANCE => '
      'absent=$absentDays',
    );

    if (absentDays >= 8) {
      list.add('វត្តមាន');
    }

    // ---------------------------------------------------
    // UNIQUE
    // ---------------------------------------------------

    final List<String> finalList = list.toSet().toList();

    if (finalList.isEmpty) {
      finalList.add('គ្មាន');
    }

    debugPrint(
      'FINAL IMPROVEMENTS LIST: '
      '$finalList',
    );

    debugPrint(
      '==============================================',
    );

    return finalList;
  }

  // =====================================================
  // DISPLAY TOTAL
  // =====================================================

  String get displayTotalScore {
    if (rxTotalScore.value.trim().isNotEmpty) {
      return rxTotalScore.value;
    }

    try {
      final dynamic rankData = dashboard.value?.rank;

      final dynamic total = rankData?.totalScore;

      if (total != null) {
        return formatNumber(total);
      }
    } catch (_) {}

    return '0';
  }

  // =====================================================
  // DISPLAY RANK
  // =====================================================

  String get displayRank {
    if (rxRank.value.trim().isNotEmpty) {
      return rxRank.value;
    }

    try {
      final dynamic rankData = dashboard.value?.rank;

      final dynamic rank = rankData?.rank;

      if (rank != null) {
        return rank.toString();
      }
    } catch (_) {}

    return '-';
  }

  // =====================================================
  // DISPLAY AVERAGE
  // =====================================================

  String get displayAverage {
    if (rxAverage.value.trim().isNotEmpty) {
      return rxAverage.value;
    }

    try {
      final dynamic rankData = dashboard.value?.rank;

      final dynamic average = rankData?.average;

      if (average != null) {
        return formatNumber(average);
      }
    } catch (_) {}

    return '0';
  }

  // =====================================================
  // RESULT SUB OPTIONS
  // =====================================================

  List<String> get currentSubOptions {
    switch (selectedResultType.value) {
      case 'ប្រចាំខែ':
        return khmerMonths;

      case 'ឆមាស':
        return <String>[
          'ឆមាស ១',
          'ឆមាស ២',
        ];

      case 'ប្រចាំឆមាស':
        return <String>[
          'ប្រចាំឆមាស ១',
          'ប្រចាំឆមាស ២',
        ];

      case 'ប្រចាំឆ្នាំ':
      default:
        return <String>[
          'ប្រចាំឆ្នាំ',
        ];
    }
  }

  // =====================================================
  // SELECT RESULT TYPE
  // =====================================================

  void selectResultType(
    String type,
  ) {
    selectedResultType.value = type;

    final List<String> options = currentSubOptions;

    if (options.isNotEmpty) {
      if (type == 'ប្រចាំខែ') {
        selectedSubResult.value = khmerMonths[DateTime.now().month - 1];
      } else {
        selectedSubResult.value = options.first;
      }
    }

    isResultExpanded.value = false;

    _resultRequestId++;

    dashboard.value = null;

    _resetScores();

    _triggerResultApi();
  }

  // =====================================================
  // SELECT SUB RESULT
  // =====================================================

  void selectSubResult(
    String subOption,
  ) {
    selectedSubResult.value = subOption;

    isResultExpanded.value = false;

    _resultRequestId++;

    dashboard.value = null;

    _resetScores();

    _triggerResultApi();
  }

  // =====================================================
  // RESET SCORES
  // =====================================================

  void _resetScores() {
    rxTotalScore.value = '';

    rxRank.value = '';

    rxAverage.value = '';

    // VERY IMPORTANT
    scoreResults.clear();
  }

  // =====================================================
  // TRIGGER RESULT API
  // =====================================================

  void _triggerResultApi() {
    final Map<String, dynamic>? child = selectedChild.value;

    if (child == null) {
      _resetScores();

      dashboard.value = null;

      return;
    }

    final int? studentId = _parseStudentId(child);

    if (studentId == null) {
      _resetScores();

      dashboard.value = null;

      return;
    }

    fetchResultByType(
      studentId,
      selectedResultType.value,
      selectedSubResult.value,
    );
  }

  // =====================================================
  // BUILD API PARAMS
  // =====================================================

  Map<String, dynamic> _buildApiParams(
    String type,
    String subFilter,
  ) {
    String apiType = 'monthly';

    dynamic apiValue;

    int month = DateTime.now().month;

    int semester = month <= 6 ? 1 : 2;

    final int year = DateTime.now().year;

    switch (type) {
      case 'ប្រចាំខែ':
        apiType = 'monthly';

        final int monthIndex = khmerMonths.indexOf(
          subFilter,
        );

        if (monthIndex >= 0) {
          month = monthIndex + 1;
        }

        semester = month <= 6 ? 1 : 2;

        apiValue = month;

        break;

      case 'ឆមាស':
      case 'ប្រចាំឆមាស':
        apiType = type == 'ឆមាស' ? 'semester' : 'semi_annual';

        semester = subFilter.contains('២') ? 2 : 1;

        apiValue = semester;

        break;

      case 'ប្រចាំឆ្នាំ':
      default:
        apiType = 'yearly';

        apiValue = year;

        break;
    }

    return <String, dynamic>{
      'type': apiType,
      'filter': apiValue,
      'month': month,
      'semester': semester,
      'year': year,
    };
  }

  // =====================================================
  // FETCH RESULT
  // =====================================================

  Future<void> fetchResultByType(
    int studentId,
    String type,
    String subFilter,
  ) async {
    final int requestId = ++_resultRequestId;

    try {
      isLoading.value = true;

      errorMessage.value = '';

      _resetScores();

      dashboard.value = null;

      final Map<String, dynamic> params = _buildApiParams(
        type,
        subFilter,
      );

      final String apiType = params['type'] as String;

      final dynamic apiFilter = params['filter'];

      final int month = params['month'] as int;

      final int semester = params['semester'] as int;

      debugPrint(
        '==============================================',
      );

      debugPrint(
        'FETCH RESULT',
      );

      debugPrint(
        'student=$studentId',
      );

      debugPrint(
        'type=$apiType',
      );

      debugPrint(
        'filter=$apiFilter',
      );

      debugPrint(
        'month=$month',
      );

      debugPrint(
        'semester=$semester',
      );

      debugPrint(
        '==============================================',
      );

      // =================================================
      // 1. DASHBOARD SUMMARY
      // =================================================

      try {
        final dynamic db = await resultApi.getParentDashboard(
          studentId: studentId,
          type: apiType,
          filter: apiFilter,
        );

        if (requestId != _resultRequestId) {
          return;
        }

        dashboard.value = db;

        debugPrint(
          'PARENT DASHBOARD LOADED: '
          '$db',
        );
      } catch (e, stackTrace) {
        debugPrint(
          'PARENT DASHBOARD ERROR: '
          '$e',
        );

        debugPrintStack(
          stackTrace: stackTrace,
        );
      }

      // =================================================
      // 2. LOAD REAL SUBJECT DETAILS
      // =================================================

      if (apiType == 'monthly') {
        await _loadMonthlyResults(
          studentId: studentId,
          semester: semester,
          month: month,
          requestId: requestId,
        );
      } else if (apiType == 'semester' || apiType == 'semi_annual') {
        await _loadSemesterResults(
          studentId: studentId,
          semester: semester,
          requestId: requestId,
        );
      } else if (apiType == 'yearly') {
        await _loadYearlyResults(
          studentId: studentId,
          requestId: requestId,
        );
      }

      if (requestId != _resultRequestId) {
        return;
      }

      // =================================================
      // 3. DASHBOARD SUMMARY FALLBACK
      // =================================================

      _applyDashboardFallback();

      // =================================================
      // 4. DEFAULT VALUES
      // =================================================

      if (rxTotalScore.value.isEmpty) {
        rxTotalScore.value = '0';
      }

      if (rxRank.value.isEmpty) {
        rxRank.value = '-';
      }

      if (rxAverage.value.isEmpty) {
        rxAverage.value = '0';
      }

      debugPrint(
        '==============================================',
      );

      debugPrint(
        'FINAL SCORE => '
        'total=${rxTotalScore.value}, '
        'rank=${rxRank.value}, '
        'average=${rxAverage.value}',
      );

      debugPrint(
        'FINAL SUBJECT COUNT: '
        '${scoreResults.length}',
      );

      for (final ScoreModel result in scoreResults) {
        debugPrint(
          'FINAL SUBJECT => '
          '${result.subjectName} '
          '${result.totalScore}/${result.maxScore} '
          'percentage=${_percentage(result)}%',
        );
      }

      debugPrint(
        'STRENGTHS => '
        '$strengthsList',
      );

      debugPrint(
        'IMPROVEMENTS => '
        '$improvementsList',
      );

      debugPrint(
        '==============================================',
      );
    } catch (e, stackTrace) {
      if (requestId == _resultRequestId) {
        errorMessage.value = 'មិនអាចទាញយកលទ្ធផលសិស្សបានទេ';
      }

      debugPrint(
        'FETCH RESULT ERROR: '
        '$e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    } finally {
      if (requestId == _resultRequestId) {
        isLoading.value = false;
      }
    }
  }

  // =====================================================
  // LOAD MONTHLY RESULTS
  // =====================================================

  Future<void> _loadMonthlyResults({
    required int studentId,
    required int semester,
    required int month,
    required int requestId,
  }) async {
    try {
      debugPrint(
        'LOAD MONTH DETAIL RESULT '
        'student=$studentId '
        'semester=$semester '
        'month=$month',
      );

      // -------------------------------------------------
      // SUMMARY
      // -------------------------------------------------

      final ScoreModel? summary = await resultApi.getParentMonthResult(
        studentId: studentId,
        semester: semester,
        month: month,
      );

      if (requestId != _resultRequestId) {
        return;
      }

      if (summary != null) {
        _applyScoreSummary(
          summary,
        );
      }

      // -------------------------------------------------
      // REAL SUBJECT DETAILS
      // -------------------------------------------------

      final List<ScoreModel> details = await resultApi.getParentResultDetails(
        studentId: studentId,
        semester: semester,
        month: month,
      );

      if (requestId != _resultRequestId) {
        return;
      }

      semesterSubjectAverages.clear();

      scoreResults.assignAll(
        _uniqueSubjects(details),
      );

      debugPrint(
        'MONTH DETAIL SUBJECT COUNT: '
        '${scoreResults.length}',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'MONTH RESULT ERROR: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }
  }

  // =====================================================
  // LOAD SEMESTER RESULTS
  // =====================================================

  Future<void> _loadSemesterResults({
    required int studentId,
    required int semester,
    required int requestId,
  }) async {
    try {
      debugPrint(
        'LOAD SEMESTER RESULT '
        'student=$studentId '
        'semester=$semester',
      );

      // -------------------------------------------------
      // SUMMARY
      // -------------------------------------------------

      final ScoreModel? summary = await resultApi.getParentSemesterResult(
        studentId: studentId,
        semester: semester,
      );

      if (requestId != _resultRequestId) {
        return;
      }

      if (summary != null) {
        _applyScoreSummary(
          summary,
        );
      }

      // -------------------------------------------------
      // SUBJECT DETAILS
      // -------------------------------------------------

      // IMPORTANT:
      // The semester endpoint can contain multiple monthly_results.
      // Calculate each subject's semester average from ALL months.
      final Map<String, double> subjectAverages =
          await resultApi.getParentSemesterSubjectAverages(
        studentId: studentId,
        semester: semester,
      );

      if (requestId != _resultRequestId) {
        return;
      }

      semesterSubjectAverages.assignAll(
        subjectAverages,
      );

      // Keep the detail list for the semester detail UI.
      final List<ScoreModel> details =
          await resultApi.getParentSemesterResultDetails(
        studentId: studentId,
        semester: semester,
      );

      if (requestId != _resultRequestId) {
        return;
      }

      scoreResults.assignAll(
        _uniqueSubjects(details),
      );

      debugPrint(
        'SEMESTER SUBJECT COUNT: '
        '${scoreResults.length}',
      );

      debugPrint(
        'SEMESTER SUBJECT AVERAGES: '
        '$semesterSubjectAverages',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'SEMESTER RESULT ERROR: '
        '$e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }
  }

  // =====================================================
  // LOAD YEARLY RESULTS
  // =====================================================

  Future<void> _loadYearlyResults({
    required int studentId,
    required int requestId,
  }) async {
    try {
      debugPrint(
        'LOAD YEARLY RESULT '
        'student=$studentId',
      );

      // -------------------------------------------------
      // YEAR SUMMARY
      // -------------------------------------------------

      final ScoreModel? summary = await resultApi.getParentYearlyResult(
        studentId: studentId,
      );

      if (requestId != _resultRequestId) {
        return;
      }

      if (summary != null) {
        _applyScoreSummary(
          summary,
        );
      }

      // -------------------------------------------------
      // YEAR API CURRENTLY HAS NO SUBJECT DETAILS
      //
      // Therefore load semester 1 and semester 2
      // details and merge them.
      // -------------------------------------------------

      final List<ScoreModel> allResults = <ScoreModel>[];

      for (final int semester in <int>[1, 2]) {
        if (requestId != _resultRequestId) {
          return;
        }

        try {
          final List<ScoreModel> semesterResults =
              await resultApi.getParentSemesterResultDetails(
            studentId: studentId,
            semester: semester,
          );

          allResults.addAll(
            semesterResults,
          );
        } catch (e) {
          debugPrint(
            'YEAR SEMESTER $semester '
            'DETAIL ERROR: $e',
          );
        }
      }

      if (requestId != _resultRequestId) {
        return;
      }

      // -------------------------------------------------
      // For yearly view:
      // Keep the BEST percentage per subject.
      //
      // This prevents:
      // Math 5
      // Math 99
      //
      // from creating duplicate UI items.
      // -------------------------------------------------

      final Map<String, ScoreModel> bestBySubject = <String, ScoreModel>{};

      for (final ScoreModel result in allResults) {
        final String key = result.subjectName.trim().toLowerCase();

        if (key.isEmpty) {
          continue;
        }

        final ScoreModel? old = bestBySubject[key];

        if (old == null || _percentage(result) > _percentage(old)) {
          bestBySubject[key] = result;
        }
      }

      scoreResults.assignAll(
        bestBySubject.values.toList(),
      );

      debugPrint(
        'YEAR SUBJECT COUNT: '
        '${scoreResults.length}',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'YEARLY RESULT ERROR: '
        '$e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }
  }

  // =====================================================
  // REMOVE DUPLICATE SUBJECTS
  // =====================================================

  List<ScoreModel> _uniqueSubjects(
    List<ScoreModel> input,
  ) {
    final Map<String, ScoreModel> unique = <String, ScoreModel>{};

    for (final ScoreModel result in input) {
      final String key = result.subjectName.trim().toLowerCase();

      if (key.isEmpty) {
        continue;
      }

      // -------------------------------------------------
      // If same subject appears multiple times,
      // keep the latest/highest percentage.
      // -------------------------------------------------

      final ScoreModel? old = unique[key];

      if (old == null || _percentage(result) > _percentage(old)) {
        unique[key] = result;
      }
    }

    return unique.values.toList();
  }

  // =====================================================
  // APPLY SCORE SUMMARY
  // =====================================================

  void _applyScoreSummary(
    ScoreModel scoreData,
  ) {
    // ---------------------------------------------------
    // TOTAL
    // ---------------------------------------------------

    if (scoreData.totalScore > 0) {
      rxTotalScore.value = formatNumber(
        scoreData.totalScore,
      );
    }

    // ---------------------------------------------------
    // RANK
    // ---------------------------------------------------

    final String rank = scoreData.rank.trim();

    if (rank.isNotEmpty && rank != '0' && rank.toLowerCase() != 'null') {
      rxRank.value = rank;
    }

    // ---------------------------------------------------
    // AVERAGE
    // ---------------------------------------------------

    final double? average = double.tryParse(
      scoreData.average,
    );

    if (average != null && average > 0) {
      rxAverage.value = formatNumber(average);
    }
  }

  // =====================================================
  // DASHBOARD FALLBACK
  // =====================================================

  void _applyDashboardFallback() {
    try {
      final dynamic rankData = dashboard.value?.rank;

      // -------------------------------------------------
      // TOTAL
      // -------------------------------------------------

      if (rxTotalScore.value.isEmpty) {
        final dynamic total = rankData?.totalScore;

        if (total != null) {
          final double parsed = double.tryParse(
                total.toString(),
              ) ??
              0;

          if (parsed > 0) {
            rxTotalScore.value = formatNumber(parsed);
          }
        }
      }

      // -------------------------------------------------
      // RANK
      // -------------------------------------------------

      if (rxRank.value.isEmpty) {
        final dynamic rank = rankData?.rank;

        if (rank != null && rank.toString().trim().isNotEmpty) {
          rxRank.value = rank.toString();
        }
      }

      // -------------------------------------------------
      // AVERAGE
      // -------------------------------------------------

      if (rxAverage.value.isEmpty) {
        final dynamic average = rankData?.average;

        if (average != null) {
          final double parsed = double.tryParse(
                average.toString(),
              ) ??
              0;

          if (parsed > 0) {
            rxAverage.value = formatNumber(parsed);
          }
        }
      }
    } catch (e) {
      debugPrint(
        'DASHBOARD FALLBACK ERROR: '
        '$e',
      );
    }
  }

  // =====================================================
  // INIT
  // =====================================================

  @override
  void onInit() {
    super.onInit();

    loadStudents();

    if (userController.user == null && userController.profile == null) {
      userController.getProfile();
    }
  }

  // =====================================================
  // LOAD STUDENTS
  // =====================================================

  Future<void> loadStudents() async {
    try {
      isLoading.value = true;

      errorMessage.value = '';

      final dynamic response = await authServices.getParentChildren();

      dynamic data;

      if (response is Map) {
        data = response['students'] ?? response['children'] ?? response['data'];
      } else if (response is List) {
        data = response;
      }

      if (data is! List) {
        _clearStudentData();

        await box.remove(
          'students',
        );

        return;
      }

      final List<Map<String, dynamic>> updatedStudents =
          <Map<String, dynamic>>[];

      for (final dynamic item in data) {
        if (item is Map) {
          updatedStudents.add(
            Map<String, dynamic>.from(
              item,
            ),
          );
        }
      }

      students.assignAll(
        updatedStudents,
      );

      await box.write(
        'students',
        updatedStudents,
      );

      // -------------------------------------------------
      // LOAD IMAGES
      // -------------------------------------------------

      for (final Map<String, dynamic> child in updatedStudents) {
        final int? childId = _parseStudentId(child);

        if (childId == null) {
          continue;
        }

        _loadStudentImage(
          childId,
        );
      }

      if (students.isEmpty) {
        _clearStudentData();

        return;
      }

      // -------------------------------------------------
      // KEEP SELECTED CHILD
      // -------------------------------------------------

      final int? oldSelectedId = _parseStudentId(
        selectedChild.value,
      );

      Map<String, dynamic>? childToSelect;

      if (oldSelectedId != null) {
        for (final Map<String, dynamic> child in students) {
          final int? childId = _parseStudentId(child);

          if (childId == oldSelectedId) {
            childToSelect = child;

            break;
          }
        }
      }

      childToSelect ??= students.first;

      selectedChild.value = childToSelect;

      final int? studentId = _parseStudentId(
        childToSelect,
      );

      if (studentId != null) {
        await _loadChildData(
          studentId,
        );
      }
    } catch (e, stackTrace) {
      errorMessage.value = 'មិនអាចទាញយកព័ត៌មានកូនបានទេ';

      debugPrint(
        'LOAD CHILDREN ERROR: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      await loadStudentsFromStorage();
    } finally {
      isLoading.value = false;
    }
  }

  // =====================================================
  // LOAD IMAGE
  // =====================================================

  Future<void> _loadStudentImage(
    int studentId,
  ) async {
    try {
      final dynamic db = await resultApi.getParentDashboard(
        studentId: studentId,
      );

      final dynamic image = db.student?.profileImage;

      if (image != null && image.toString().trim().isNotEmpty) {
        studentImages[studentId] = image.toString();
      }
    } catch (e) {
      debugPrint(
        'LOAD STUDENT IMAGE ERROR '
        '$studentId: $e',
      );
    }
  }

  // =====================================================
  // LOAD STUDENTS STORAGE
  // =====================================================

  Future<void> loadStudentsFromStorage() async {
    try {
      final dynamic data = box.read('students');

      if (data is! List) {
        _clearStudentData();

        return;
      }

      final List<Map<String, dynamic>> cachedStudents =
          <Map<String, dynamic>>[];

      for (final dynamic item in data) {
        if (item is Map) {
          cachedStudents.add(
            Map<String, dynamic>.from(
              item,
            ),
          );
        }
      }

      students.assignAll(
        cachedStudents,
      );

      if (students.isEmpty) {
        _clearStudentData();

        return;
      }

      selectedChild.value = students.first;

      final int? studentId = _parseStudentId(
        students.first,
      );

      if (studentId != null) {
        await _loadChildData(
          studentId,
        );
      }
    } catch (e, stackTrace) {
      debugPrint(
        'LOAD STUDENTS STORAGE ERROR: '
        '$e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      _clearStudentData();
    }
  }

  // =====================================================
  // SELECT CHILD
  // =====================================================

  Future<void> selectChild(
    Map<String, dynamic> child,
  ) async {
    _resultRequestId++;

    selectedChild.value = child;

    dashboard.value = null;

    _resetScores();

    todaySchedule.clear();

    final int? studentId = _parseStudentId(child);

    if (studentId == null) {
      errorMessage.value = 'លេខសម្គាល់សិស្សមិនត្រឹមត្រូវ';

      return;
    }

    await _loadChildData(
      studentId,
    );
  }

  // =====================================================
  // LOAD CHILD DATA
  // =====================================================

  Future<void> _loadChildData(
    int studentId,
  ) async {
    await Future.wait(
      <Future<void>>[
        fetchDashboard(
          studentId,
        ),
        getTodaySchedule(
          studentId,
        ),
      ],
    );
  }

  // =====================================================
  // FETCH DASHBOARD
  // =====================================================

  Future<void> fetchDashboard(
    int studentId,
  ) async {
    try {
      errorMessage.value = '';

      _resetScores();

      // -------------------------------------------------
      // ATTENDANCE
      // -------------------------------------------------

      try {
        await attendanceController.loadAttendanceByStudent(
          studentId,
        );
      } catch (e, stackTrace) {
        debugPrint(
          'ATTENDANCE LOAD ERROR: '
          '$e',
        );

        debugPrintStack(
          stackTrace: stackTrace,
        );
      }

      // -------------------------------------------------
      // RESULTS
      // -------------------------------------------------

      await fetchResultByType(
        studentId,
        selectedResultType.value,
        selectedSubResult.value,
      );
    } catch (e, stackTrace) {
      errorMessage.value = 'មិនអាចទាញយកផ្ទាំងព័ត៌មានបានទេ';

      debugPrint(
        'PARENT DASHBOARD ERROR: '
        '$e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }
  }

  // =====================================================
  // REFRESH HOME
  // =====================================================

  Future<void> refreshHome() async {
    final DateTime now = DateTime.now();

    selectedResultType.value = 'ប្រចាំខែ';

    selectedSubResult.value = khmerMonths[now.month - 1];

    attendanceController.selectedMonth.value = now.month;

    attendanceController.selectedYear.value = now.year;

    await loadStudents();
  }

  // =====================================================
  // TODAY SCHEDULE
  // =====================================================

  Future<void> getTodaySchedule(
    int studentId,
  ) async {
    try {
      isScheduleLoading.value = true;

      scheduleError.value = '';

      final dynamic response = await scheduleApi.getParentSchedule(
        studentId,
      );

      dynamic responseData;

      if (response is Map) {
        responseData = Map<String, dynamic>.from(
          response,
        );
      } else {
        try {
          responseData = response.data;
        } catch (_) {
          responseData = null;
        }
      }

      if (responseData is! Map) {
        todaySchedule.clear();

        return;
      }

      final Map<String, dynamic> responseMap = Map<String, dynamic>.from(
        responseData,
      );

      final dynamic schedulesData =
          responseMap['schedules'] ?? responseMap['data'];

      if (schedulesData is! List) {
        todaySchedule.clear();

        return;
      }

      final List<ScheduleModel> schedules = <ScheduleModel>[];

      for (final dynamic item in schedulesData) {
        if (item is! Map) {
          continue;
        }

        try {
          final ScheduleModel schedule = ScheduleModel.fromJson(
            Map<String, dynamic>.from(
              item,
            ),
          );

          schedules.add(
            schedule,
          );
        } catch (e) {
          debugPrint(
            'INVALID SCHEDULE ITEM: '
            '$e',
          );
        }
      }

      schedules.sort(
        (
          ScheduleModel first,
          ScheduleModel second,
        ) {
          return _timeToMinutes(
            first.startTime,
          ).compareTo(
            _timeToMinutes(
              second.startTime,
            ),
          );
        },
      );

      todaySchedule.assignAll(
        schedules,
      );

      debugPrint(
        'TODAY SCHEDULE COUNT: '
        '${todaySchedule.length}',
      );
    } catch (e, stackTrace) {
      todaySchedule.clear();

      scheduleError.value = e.toString();

      debugPrint(
        'GET TODAY SCHEDULE ERROR: '
        '$e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    } finally {
      isScheduleLoading.value = false;
    }
  }

  // =====================================================
  // ATTENDANCE EXPAND
  // =====================================================

  void toggleAttendanceExpanded() {
    isAttendanceExpanded.toggle();
  }

  // =====================================================
  // CLEAR STUDENT DATA
  // =====================================================

  void _clearStudentData() {
    students.clear();

    selectedChild.value = null;

    dashboard.value = null;

    todaySchedule.clear();

    studentImages.clear();

    _resetScores();

    _resultRequestId++;
  }

  // =====================================================
  // PARSE STUDENT ID
  // =====================================================

  int? _parseStudentId(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      final String text = value.trim();

      if (text.isEmpty) {
        return null;
      }

      return int.tryParse(text);
    }

    if (value is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(
        value,
      );

      const List<String> directKeys = <String>[
        'id',
        'student_id',
        'studentId',
        'child_id',
        'childId',
        'user_id',
        'userId',
      ];

      for (final String key in directKeys) {
        if (!map.containsKey(key)) {
          continue;
        }

        final int? id = _parseStudentId(
          map[key],
        );

        if (id != null) {
          return id;
        }
      }

      const List<String> nestedKeys = <String>[
        'student',
        'child',
        'user',
        'data',
        'result',
      ];

      for (final String key in nestedKeys) {
        final dynamic nested = map[key];

        if (nested == null) {
          continue;
        }

        final int? id = _parseStudentId(
          nested,
        );

        if (id != null) {
          return id;
        }
      }
    }

    return null;
  }

  // =====================================================
  // CHILD NAME
  // =====================================================

  String get childName {
    final Map<String, dynamic>? child = selectedChild.value;

    if (child == null) {
      return 'dont_have_child'.tr;
    }

    final dynamic name = child['student_name'] ??
        child['name'] ??
        child['full_name'] ??
        child['studentName'];

    if (name != null && name.toString().trim().isNotEmpty) {
      return name.toString();
    }

    return 'dont_have_child'.tr;
  }

  String get childProfileImage {
    return selectedChild.value?['profile_image']?.toString() ?? '';
  }

  // =====================================================
  // CHILD CODE
  // =====================================================

  String get childCode {
    final Map<String, dynamic>? child = selectedChild.value;

    if (child == null) {
      return 'dont_have_child'.tr;
    }

    final dynamic code =
        child['student_code'] ?? child['code'] ?? child['studentCode'];

    if (code != null && code.toString().trim().isNotEmpty) {
      return code.toString();
    }

    return 'dont_have_child'.tr;
  }

  // =====================================================
  // CURRENT DATE
  // =====================================================

  String getCurrentDate() {
    final DateTime now = DateTime.now();

    const List<String> khmerWeekDays = <String>[
      'ថ្ងៃច័ន្ទ',
      'ថ្ងៃអង្គារ',
      'ថ្ងៃពុធ',
      'ថ្ងៃព្រហស្បតិ៍',
      'ថ្ងៃសុក្រ',
      'ថ្ងៃសៅរ៍',
      'ថ្ងៃអាទិត្យ',
    ];

    const List<String> khmerMonthNames = <String>[
      'មករា',
      'កុម្ភៈ',
      'មីនា',
      'មេសា',
      'ឧសភា',
      'មិថុនា',
      'កក្កដា',
      'សីហា',
      'កញ្ញា',
      'តុលា',
      'វិច្ឆិកា',
      'ធ្នូ',
    ];

    final String weekDay = khmerWeekDays[now.weekday - 1];

    final String month = khmerMonthNames[now.month - 1];

    return '$weekDay '
        'ទី${now.day} '
        'ខែ$month '
        'ឆ្នាំ${now.year}';
  }

  // =====================================================
  // FORMAT NUMBER
  // =====================================================

  String formatNumber(
    dynamic value,
  ) {
    if (value == null) {
      return '0';
    }

    final double? number = double.tryParse(
      value.toString(),
    );

    if (number == null) {
      return value.toString();
    }

    if (number == number.roundToDouble()) {
      return number.toInt().toString();
    }

    return number.toStringAsFixed(1);
  }

  // =====================================================
  // MORNING / AFTERNOON
  // =====================================================

  bool isMorning(
    String startTime,
  ) {
    final String text = startTime.trim();

    if (text.isEmpty) {
      return true;
    }

    final List<String> parts = text.split(':');

    if (parts.isEmpty) {
      return true;
    }

    final int hour = int.tryParse(
          parts.first,
        ) ??
        0;

    return hour < 12;
  }

  // =====================================================
  // FORMAT TIME
  // =====================================================

  String formatTime(
    String value,
  ) {
    final String text = value.trim();

    if (text.isEmpty) {
      return '--:--';
    }

    final List<String> parts = text.split(':');

    if (parts.length < 2) {
      return text;
    }

    final String hour = parts[0].padLeft(2, '0');

    final String minute = parts[1].padLeft(2, '0');

    return '$hour:$minute';
  }

  // =====================================================
  // TIME TO MINUTES
  // =====================================================

  int _timeToMinutes(
    String value,
  ) {
    final String text = value.trim();

    if (text.isEmpty) {
      return 0;
    }

    final List<String> parts = text.split(':');

    if (parts.length < 2) {
      return 0;
    }

    final int hour = int.tryParse(parts[0]) ?? 0;

    final int minute = int.tryParse(parts[1]) ?? 0;

    return hour * 60 + minute;
  }
}
