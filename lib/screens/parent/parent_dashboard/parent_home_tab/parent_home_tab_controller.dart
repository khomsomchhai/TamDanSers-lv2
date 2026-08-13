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
    'ប្រចាំឆមាស',
    'ប្រចាំឆ្នាំ',
  ];

  final List<String> semester1Months = <String>[
    'ខែមករា',
    'ខែកុម្ភៈ',
    'ខែមីនា',
    'ខែមេសា',
  ];

  final List<String> semester2Months = <String>[
    'ខែមិថុនា',
    'ខែកក្កដា',
    'ខែសីហា',
    'ខែកញ្ញា',
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

  late final RxInt selectedMonthlySemester =
      (DateTime.now().month >= 6 ? 2 : 1).obs;

  late final RxString selectedSubResult = () {
    final int m = DateTime.now().month;
    if (m >= 1 && m <= 4) {
      return semester1Months[m - 1].obs;
    } else if (m >= 6 && m <= 9) {
      return semester2Months[m - 6].obs;
    } else if (m <= 5) {
      return semester1Months.first.obs;
    } else {
      return semester2Months.first.obs;
    }
  }();

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

  final RxBool isScheduleExpanded = false.obs;

  void toggleScheduleExpand() {
    isScheduleExpanded.value = !isScheduleExpanded.value;
  }

  List<ScheduleModel> get visibleTodaySchedules {
    if (isScheduleExpanded.value || todaySchedule.length <= 2) {
      return todaySchedule;
    }
    return todaySchedule.take(2).toList();
  }

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
    final double score = result.score > 0 ? result.score : result.totalScore;

    final double max = result.maxScore > 0 ? result.maxScore : 100.0;

    return (score / max) * 100;
  }

  bool get _isSemesterOrYearlyResult {
    final String type = selectedResultType.value.trim().toLowerCase();

    return type == 'ឆមាស' ||
        type == 'ប្រចាំឆមាស' ||
        type == 'ប្រចាំឆ្នាំ' ||
        type.contains('semester') ||
        type.contains('semi') ||
        type.contains('year') ||
        type.contains('annual');
  }

  Map<String, double> get _subjectPercentagesForAnalysis {
    if (_isSemesterOrYearlyResult && semesterSubjectAverages.isNotEmpty) {
      return Map<String, double>.from(semesterSubjectAverages);
    }

    final Map<String, double> result = <String, double>{};

    for (final ScoreModel score in scoreResults) {
      final String key = score.subjectName.trim().toLowerCase();

      if (key.isEmpty) {
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
    // ATTENDANCE STRENGTH (Rate >= 80% AND absent <= 1)
    // ---------------------------------------------------

    final int absentDays = attendanceController.absentDays.value;
    final int absentSubjects = attendanceController.absentSubjects.value;
    final double attRate = attendanceController.attendanceRate;
    final int totalRecords = attendanceController.presentSubjects.value +
        attendanceController.absentSubjects.value +
        attendanceController.permissionSubjects.value;

    debugPrint(
      'STRENGTH ATTENDANCE => '
      'rate=$attRate%, absentDays=$absentDays, absentSubjects=$absentSubjects, totalRecords=$totalRecords',
    );

    if ((totalRecords > 0 || attendanceController.totalDays > 0) &&
        attRate >= 80 &&
        absentSubjects <= 1 &&
        absentDays <= 1) {
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
  // < 50% for subject scores
  // OR ATTENDANCE RATE < 80% OR ABSENT SUBJECTS >= 2
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

      // Improvement threshold: below 50%.
      if (percentage < 50) {
        list.add(khmer);

        debugPrint(
          'LOW SCORE FOUND => '
          '$khmer',
        );
      }
    }

    // ---------------------------------------------------
    // ATTENDANCE IMPROVEMENT (Rate < 80% OR absentSubjects >= 2)
    // ---------------------------------------------------

    final int impAbsentDays = attendanceController.absentDays.value;
    final int impAbsentSubjects = attendanceController.absentSubjects.value;
    final double impAttRate = attendanceController.attendanceRate;
    final int impTotalRecords = attendanceController.presentSubjects.value +
        attendanceController.absentSubjects.value +
        attendanceController.permissionSubjects.value;

    debugPrint(
      'IMPROVEMENT ATTENDANCE => '
      'rate=$impAttRate%, absentDays=$impAbsentDays, absentSubjects=$impAbsentSubjects, totalRecords=$impTotalRecords',
    );

    if ((impTotalRecords > 0 || attendanceController.totalDays > 0) &&
        (impAttRate < 80 || impAbsentSubjects >= 2 || impAbsentDays >= 2)) {
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

  int get _currentFilterMonth {
    final String s = selectedSubResult.value.toLowerCase().trim();
    if (s.contains('jan') || s.contains('មករា')) return 1;
    if (s.contains('feb') || s.contains('កុម្ភៈ')) return 2;
    if (s.contains('mar') || s.contains('មីនា')) return 3;
    if (s.contains('apr') || s.contains('មេសា')) return 4;
    if (s.contains('may') || s.contains('ឧសភា')) return 5;
    if (s.contains('jun') || s.contains('មិថុនា')) return 6;
    if (s.contains('jul') || s.contains('កក្កដា')) return 7;
    if (s.contains('aug') || s.contains('សីហា')) return 8;
    if (s.contains('sep') || s.contains('កញ្ញា')) return 9;
    if (s.contains('oct') || s.contains('តុលា')) return 10;
    if (s.contains('nov') || s.contains('វិច្ឆិកា')) return 11;
    if (s.contains('dec') || s.contains('ធ្នូ')) return 12;
    final int idx = khmerMonths.indexOf(selectedSubResult.value);
    if (idx != -1) return idx + 1;
    return 0;
  }

  bool _isDashboardRankMatchingFilter() {
    final dynamic rankData = dashboard.value?.rank;
    if (rankData == null) return false;

    if (selectedResultType.value != 'ប្រចាំខែ') {
      return false;
    }

    final int filterMonth = _currentFilterMonth;
    final int rankMonth = rankData.month is int
        ? rankData.month
        : (int.tryParse(rankData.month?.toString() ?? '') ?? 0);

    return filterMonth > 0 && rankMonth > 0 && rankMonth == filterMonth;
  }

  String _calculateRankFromAverage(double avg) {
    if (avg >= 70) return '1';
    if (avg >= 68) return '3';
    if (avg >= 40) return '4';
    if (avg > 30) return '5';
    if (avg > 0) return '6';
    return '-';
  }

  // =====================================================
  // DISPLAY TOTAL
  // =====================================================

  String get displayTotalScore {
    if (rxTotalScore.value.trim().isNotEmpty && rxTotalScore.value != '0') {
      return rxTotalScore.value;
    }

    if (scoreResults.isNotEmpty) {
      double totalObtained = 0;
      for (final s in scoreResults) {
        totalObtained += s.totalScore;
      }
      if (totalObtained > 0) {
        return formatNumber(totalObtained);
      }
    }

    if (_isDashboardRankMatchingFilter()) {
      try {
        final dynamic rankData = dashboard.value?.rank;
        final dynamic total = rankData?.totalScore;

        if (total != null) {
          return formatNumber(total);
        }
      } catch (_) {}
    }

    return '0';
  }

  // =====================================================
  // DISPLAY RANK
  // =====================================================

  String get displayRank {
    if (rxRank.value.trim().isNotEmpty && rxRank.value != '-') {
      return rxRank.value;
    }

    if (_isDashboardRankMatchingFilter()) {
      try {
        final dynamic rankData = dashboard.value?.rank;
        final dynamic rank = rankData?.rank;

        if (rank != null &&
            rank.toString().trim().isNotEmpty &&
            rank.toString().trim() != 'null' &&
            rank.toString().trim() != '0') {
          return rank.toString().trim();
        }
      } catch (_) {}
    }

    final double avg = double.tryParse(displayAverage) ?? 0.0;
    if (avg > 0) {
      return _calculateRankFromAverage(avg);
    }

    return '-';
  }

  // =====================================================
  // DISPLAY AVERAGE
  // =====================================================

  String get displayAverage {
    if (rxAverage.value.trim().isNotEmpty && rxAverage.value != '0') {
      return rxAverage.value;
    }

    if (scoreResults.isNotEmpty) {
      double totalObtained = 0;
      double totalPossible = 0;
      for (final s in scoreResults) {
        if (s.maxScore > 0) {
          totalObtained += s.totalScore;
          totalPossible += s.maxScore;
        }
      }
      if (totalPossible > 0) {
        final avg = (totalObtained / totalPossible) * 100;
        return formatNumber(avg);
      }
    }

    if (_isDashboardRankMatchingFilter()) {
      try {
        final dynamic rankData = dashboard.value?.rank;
        final dynamic average = rankData?.average;

        if (average != null) {
          return formatNumber(average);
        }
      } catch (_) {}
    }

    return '0';
  }

  // =====================================================
  // RESULT SUB OPTIONS
  // =====================================================

  List<String> get currentSubOptions {
    switch (selectedResultType.value) {
      case 'ប្រចាំខែ':
        return selectedMonthlySemester.value == 1
            ? semester1Months
            : semester2Months;

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
  // SELECT MONTHLY SEMESTER (ឆមាស ១ / ឆមាស ២ for ប្រចាំខែ)
  // =====================================================

  void selectMonthlySemester(int semester) {
    if (selectedMonthlySemester.value == semester) return;

    selectedMonthlySemester.value = semester;
    final List<String> options =
        semester == 1 ? semester1Months : semester2Months;

    if (!options.contains(selectedSubResult.value)) {
      selectSubResult(options.first);
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
        final List<String> validMonths = selectedMonthlySemester.value == 1
            ? semester1Months
            : semester2Months;
        if (!validMonths.contains(selectedSubResult.value)) {
          selectedSubResult.value = validMonths.first;
        }
      } else {
        selectedSubResult.value = options.first;
      }
    }

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
    semesterSubjectAverages.clear();
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
          semester: semester,
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
      // RANK FOR SPECIFIC MONTH & SEMESTER
      // -------------------------------------------------
      try {
        final ScoreModel? monthRankData = await resultApi.getRankStudent(
          month: month,
          semester: semester,
          studentId: studentId,
        );

        if (requestId == _resultRequestId &&
            monthRankData != null &&
            monthRankData.rank.trim().isNotEmpty &&
            monthRankData.rank.trim().toLowerCase() != 'null') {
          rxRank.value = monthRankData.rank.trim();
        }
      } catch (e) {
        debugPrint('GET RANK STUDENT ERROR: $e');
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
      // SEMESTER RANK
      // -------------------------------------------------
      try {
        final ScoreModel? semRankData = await resultApi.getSemesterResult(
          semester: semester,
          studentId: studentId,
        );

        if (requestId == _resultRequestId &&
            semRankData != null &&
            semRankData.rank.trim().isNotEmpty &&
            semRankData.rank.trim().toLowerCase() != 'null') {
          rxRank.value = semRankData.rank.trim();
        }
      } catch (e) {
        debugPrint('GET SEMESTER RANK ERROR: $e');
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
      // YEAR RANK
      // -------------------------------------------------
      try {
        final int currentYear = DateTime.now().year;
        final ScoreModel? yearRankData = await resultApi.getYearRank(
          year: currentYear,
          studentId: studentId,
        );

        if (requestId == _resultRequestId &&
            yearRankData != null &&
            yearRankData.rank.trim().isNotEmpty &&
            yearRankData.rank.trim().toLowerCase() != 'null') {
          rxRank.value = yearRankData.rank.trim();
        }
      } catch (e) {
        debugPrint('GET YEAR RANK ERROR: $e');
      }

      // -------------------------------------------------
      // YEAR API HAS NO SUBJECT DETAILS
      //
      // Load Semester 1 & Semester 2 subject averages
      // and compute exact annual average per subject.
      // -------------------------------------------------

      final Map<String, List<double>> semAveragesPerSubject =
          <String, List<double>>{};
      final Map<String, String> displaySubjectNames = <String, String>{};

      for (final int semester in <int>[1, 2]) {
        if (requestId != _resultRequestId) {
          return;
        }

        try {
          final Map<String, double> semAverages =
              await resultApi.getParentSemesterSubjectAverages(
            studentId: studentId,
            semester: semester,
          );

          semAverages.forEach((String key, double pct) {
            semAveragesPerSubject.putIfAbsent(key, () => <double>[]).add(pct);
          });

          final List<ScoreModel> details =
              await resultApi.getParentSemesterResultDetails(
            studentId: studentId,
            semester: semester,
          );

          for (final ScoreModel d in details) {
            final String k = d.subjectName.trim().toLowerCase();
            if (k.isNotEmpty) {
              displaySubjectNames[k] = d.subjectName;
            }
          }
        } catch (e) {
          debugPrint(
            'YEAR SEMESTER $semester AVERAGES ERROR: $e',
          );
        }
      }

      if (requestId != _resultRequestId) {
        return;
      }

      final Map<String, double> finalYearlyAverages = <String, double>{};
      final List<ScoreModel> finalYearlyScoreModels = <ScoreModel>[];

      semAveragesPerSubject.forEach((String key, List<double> pcts) {
        if (pcts.isNotEmpty) {
          final double avgPct = pcts.reduce((a, b) => a + b) / pcts.length;
          final double roundedAvg = double.parse(avgPct.toStringAsFixed(1));
          finalYearlyAverages[key] = roundedAvg;

          final String displayName = displaySubjectNames[key] ?? key;

          finalYearlyScoreModels.add(
            ScoreModel(
              id: 0,
              semester: 0,
              month: 0,
              score: roundedAvg,
              totalScore: roundedAvg,
              maxScore: 100.0,
              subjectName: displayName,
              teacherName: '',
              rank: '',
              average: roundedAvg.toString(),
            ),
          );
        }
      });

      semesterSubjectAverages.assignAll(
        finalYearlyAverages,
      );

      scoreResults.assignAll(
        finalYearlyScoreModels,
      );

      debugPrint(
        'YEARLY SUBJECT AVERAGES: $semesterSubjectAverages',
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
      if (!_isDashboardRankMatchingFilter()) {
        return;
      }

      final dynamic rankData = dashboard.value?.rank;

      // -------------------------------------------------
      // RANK
      // -------------------------------------------------

      if (rxRank.value.isEmpty || rxRank.value == '-') {
        final dynamic rank = rankData?.rank;

        if (rank != null &&
            rank.toString().trim().isNotEmpty &&
            rank.toString().trim() != 'null') {
          rxRank.value = rank.toString().trim();
        }
      }

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

    _loadFromStorageEarly();
    loadStudents();

    if (userController.user == null && userController.profile == null) {
      userController.getProfile();
    }
  }

  bool get hasValidSelectedChild {
    if (selectedChild.value == null) {
      return false;
    }

    final int? studentId = _parseStudentId(selectedChild.value);
    if (studentId == null) {
      return false;
    }

    final dynamic name = selectedChild.value?['student_name'] ??
        selectedChild.value?['name'] ??
        selectedChild.value?['full_name'] ??
        selectedChild.value?['studentName'];

    final dynamic code = selectedChild.value?['student_code'] ??
        selectedChild.value?['code'] ??
        selectedChild.value?['studentCode'];

    final String nameText = name?.toString().trim() ?? '';
    final String codeText = code?.toString().trim() ?? '';

    return nameText.isNotEmpty || codeText.isNotEmpty;
  }

  Map<String, dynamic>? _firstValidChild(
    List<Map<String, dynamic>> children,
  ) {
    for (final Map<String, dynamic> child in children) {
      final int? studentId = _parseStudentId(child);
      if (studentId == null) {
        continue;
      }

      final dynamic name = child['student_name'] ??
          child['name'] ??
          child['full_name'] ??
          child['studentName'];

      final dynamic code = child['student_code'] ??
          child['code'] ??
          child['studentCode'];

      final String nameText = name?.toString().trim() ?? '';
      final String codeText = code?.toString().trim() ?? '';

      if (nameText.isNotEmpty || codeText.isNotEmpty) {
        return child;
      }
    }

    return null;
  }

  void _loadFromStorageEarly() {
    try {
      final dynamic cachedData = box.read('students');
      if (cachedData is List && cachedData.isNotEmpty) {
        final List<Map<String, dynamic>> cachedStudents = [];
        for (final item in cachedData) {
          if (item is Map) {
            cachedStudents.add(Map<String, dynamic>.from(item));
          }
        }

        final Map<String, dynamic>? validChild = _firstValidChild(cachedStudents);

        if (cachedStudents.isNotEmpty && validChild != null) {
          students.assignAll(cachedStudents);
          selectedChild.value = validChild;
          isLoading.value = false;

          final int? studentId = _parseStudentId(validChild);
          if (studentId != null) {
            _loadCachedSchedule(studentId);
            attendanceController.loadAttendanceByStudent(studentId);
          }
        } else {
          students.clear();
          selectedChild.value = null;
        }
      }
    } catch (e) {
      debugPrint('EARLY STORAGE LOAD ERROR: $e');
    }
  }

  void _loadCachedSchedule(int studentId) {
    try {
      final cached = box.read('today_schedule_$studentId');
      if (cached is List && cached.isNotEmpty && todaySchedule.isEmpty) {
        final List<ScheduleModel> cachedList = [];
        for (final item in cached) {
          if (item is Map) {
            cachedList
                .add(ScheduleModel.fromJson(Map<String, dynamic>.from(item)));
          }
        }
        if (cachedList.isNotEmpty) {
          todaySchedule.assignAll(cachedList);
          isScheduleLoading.value = false;
        }
      }
    } catch (e) {
      debugPrint('LOAD CACHED SCHEDULE ERROR: $e');
    }
  }

  // =====================================================
  // LOAD STUDENTS
  // =====================================================

  Future<void> loadStudents() async {
    try {
      if (students.isEmpty) {
        isLoading.value = true;
      }

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

      childToSelect ??= _firstValidChild(students.toList());

      if (childToSelect == null) {
        selectedChild.value = null;
        return;
      }

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

      final Map<String, dynamic>? validChild = _firstValidChild(cachedStudents);

      if (validChild == null) {
        _clearStudentData();

        return;
      }

      selectedChild.value = validChild;

      final int? studentId = _parseStudentId(
        validChild,
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
      _loadCachedSchedule(studentId);
      if (todaySchedule.isEmpty) {
        isScheduleLoading.value = true;
      }
      scheduleError.value = '';

      final dynamic response = await scheduleApi.getParentSchedule(
        studentId,
      );

      if (response == null) {
        if (todaySchedule.isEmpty) {
          todaySchedule.clear();
        }
        return;
      }

      List<dynamic> schedulesData = <dynamic>[];

      if (response is List) {
        schedulesData = response;
      } else if (response is Map) {
        final Map<String, dynamic> responseMap =
            Map<String, dynamic>.from(response);

        final dynamic data = responseMap['schedules'] ??
            responseMap['data'] ??
            responseMap['results'] ??
            responseMap['permissions'];

        if (data is List) {
          schedulesData = data;
        }
      }

      if (schedulesData.isEmpty) {
        if (todaySchedule.isEmpty) {
          todaySchedule.clear();
        }
        return;
      }

      final List<ScheduleModel> schedules = <ScheduleModel>[];

      for (final dynamic item in schedulesData) {
        if (item is! Map) {
          continue;
        }

        try {
          final ScheduleModel schedule = ScheduleModel.fromJson(
            Map<String, dynamic>.from(item),
          );
          schedules.add(schedule);
        } catch (e) {
          debugPrint('INVALID SCHEDULE ITEM: $e');
        }
      }

      // ---------------------------------------------------------
      // Filter for Today (Day of Week)
      // ---------------------------------------------------------
      final String todayFull = _getTodayDayName();
      final String todayShort = _getTodayShortDayName();

      final List<ScheduleModel> todayOnly = schedules.where((item) {
        if (item.day.isEmpty) return true;
        final String dayLower = item.day.trim().toLowerCase();
        return dayLower == todayFull.toLowerCase() ||
            dayLower == todayShort.toLowerCase() ||
            dayLower.contains(todayShort.toLowerCase());
      }).toList();

      final List<ScheduleModel> finalSchedules =
          todayOnly.isNotEmpty ? todayOnly : schedules;

      finalSchedules.sort(
        (ScheduleModel first, ScheduleModel second) {
          return _timeToMinutes(first.startTime)
              .compareTo(_timeToMinutes(second.startTime));
        },
      );

      todaySchedule.assignAll(finalSchedules);

      await box.write(
        'today_schedule_$studentId',
        finalSchedules.map((s) => s.toJson()).toList(),
      );

      debugPrint('TODAY SCHEDULE COUNT: ${todaySchedule.length}');
    } catch (e, stackTrace) {
      if (todaySchedule.isEmpty) {
        todaySchedule.clear();
        scheduleError.value = e.toString();
      }
      debugPrint('GET TODAY SCHEDULE ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isScheduleLoading.value = false;
    }
  }

  String _getTodayDayName() {
    switch (DateTime.now().weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
      default:
        return 'Sunday';
    }
  }

  String _getTodayShortDayName() {
    switch (DateTime.now().weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
      default:
        return 'Sun';
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
