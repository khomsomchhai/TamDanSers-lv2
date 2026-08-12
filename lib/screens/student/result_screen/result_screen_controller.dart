part of 'result_screen_view.dart';

enum ResultViewMode {
  monthly,
  semester,
  yearly,
}

class ResultScreenViewController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final ResultApi resultApi = ResultApi();
  final GetStorage _storage = GetStorage();
  static const String _cacheKeyResult = 'student_result_cache';

  late final TabController tabController;

  // =========================================================
  // VIEW STATE
  // =========================================================

  final selectedView = ResultViewMode.monthly.obs;

  final selectedSemester = 1.obs;
  final selectedMonth = RxnInt();

  final isLoading = true.obs;
  final isRankLoading = false.obs;
  final isYearRankLoading = false.obs;

  final result = <ScoreModel>[].obs;
  final rank = Rxn<ScoreModel>();
  final yearlyRank = Rxn<ScoreModel>();

  final Map<int, String> months = {
    1: 'month_1',
    2: 'month_2',
    3: 'month_3',
    4: 'month_4',
    5: 'month_5',
    6: 'month_6',
    7: 'month_7',
    8: 'month_8',
    9: 'month_9',
    10: 'month_10',
    11: 'month_11',
    12: 'month_12',
  };

  @override
  void onInit() {
    super.onInit();

    tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: 0,
    );

    tabController.addListener(_handleSemesterTabChange);

    _loadCachedResult();
    getResult();
  }

  // =========================================================
  // TAB / VIEW HANDLERS
  // =========================================================

  void _handleSemesterTabChange() {
    if (tabController.indexIsChanging) return;

    final int targetSemester = tabController.index + 1;

    if (selectedSemester.value != targetSemester) {
      changeSemester(targetSemester);
    }
  }

  void _loadCachedResult() {
    try {
      final dynamic cached = _storage.read(_cacheKeyResult);
      if (cached is List && cached.isNotEmpty) {
        final List<ScoreModel> cachedList = cached
            .whereType<Map>()
            .map((item) => ScoreModel.fromMap(Map<String, dynamic>.from(item)))
            .toList();
        if (cachedList.isNotEmpty) {
          result.assignAll(cachedList);
          _selectInitialSemesterAndMonth();
        }
      }
    } catch (_) {}
  }

  Future<void> changeView(ResultViewMode mode) async {
    selectedView.value = mode;

    if (mode == ResultViewMode.monthly) {
      await getRank();
      return;
    }

    if (mode == ResultViewMode.yearly) {
      await getYearRank();
    }
  }

  // =========================================================
  // YEARLY RANK
  // =========================================================

  Future<void> getYearRank() async {
    try {
      isYearRankLoading.value = true;

      final int currentYear = DateTime.now().year;

      final ScoreModel? response = await resultApi.getYearRank(
        year: currentYear,
      );

      yearlyRank.value = response;

      if (response != null) {
        debugPrint(
          'YEAR RANK RESPONSE: '
          'rank=${response.rank}, '
          'average=${response.average}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('GET YEAR RANK ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
      yearlyRank.value = null;
    } finally {
      isYearRankLoading.value = false;
    }
  }

  // =========================================================
  // LOAD RESULT
  // =========================================================

  Future<void> getResult() async {
    final bool hasCache = result.isNotEmpty;
    if (!hasCache) {
      isLoading.value = true;
    }

    try {
      final List<ScoreModel> response = await resultApi.getResult();

      result.assignAll(response);
      _storage.write(
        _cacheKeyResult,
        response.map((e) => e.toJson()).toList(),
      );

      debugPrint('TOTAL SCORE RECORDS: ${result.length}');

      _selectInitialSemesterAndMonth();

      await getRank();
    } catch (e, stackTrace) {
      debugPrint('GET RESULT ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      result.clear();
      rank.value = null;
      yearlyRank.value = null;
      selectedMonth.value = null;

      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =========================================================
  // SEMESTERS
  // =========================================================

  List<int> get availableSemesters {
    final List<int> semesters = result
        .map(
          (ScoreModel score) => score.semester,
        )
        .where(
          (int semester) => semester >= 1 && semester <= 2,
        )
        .toSet()
        .toList();

    semesters.sort();

    return semesters;
  }

  bool hasSemester(int semester) {
    return availableSemesters.contains(semester);
  }

  // =========================================================
  // MONTHS
  //
  // IMPORTANT:
  // month == 0 is treated as Semester Exam.
  // Normal monthly results are only month 1..12.
  // =========================================================

  List<int> monthsForSemester(int semester) {
    final List<int> availableMonths = result
        .where(
          (ScoreModel score) =>
              score.semester == semester &&
              score.month >= 1 &&
              score.month <= 12,
        )
        .map(
          (ScoreModel score) => score.month,
        )
        .toSet()
        .toList();

    availableMonths.sort();

    return availableMonths;
  }

  List<int> get semesterMonths {
    return monthsForSemester(
      selectedSemester.value,
    );
  }

  // =========================================================
  // FILTERED MONTHLY SCORES
  // =========================================================

  List<ScoreModel> get filterScores {
    final int? month = selectedMonth.value;

    if (month == null) {
      return [];
    }

    if (month < 1 || month > 12) {
      return [];
    }

    final List<ScoreModel> scores = result.where(
      (ScoreModel score) {
        return score.semester == selectedSemester.value && score.month == month;
      },
    ).toList();

    scores.sort(
      (ScoreModel a, ScoreModel b) => a.subjectName.compareTo(
        b.subjectName,
      ),
    );

    return scores;
  }

  // =========================================================
  // MONTHLY CALCULATIONS
  // =========================================================

  double get monthlyTotalScore {
    return filterScores.fold<double>(
      0,
      (double sum, ScoreModel score) => sum + score.score.toDouble(),
    );
  }

  int get monthlyTotalSubjects {
    return filterScores.length;
  }

  double get monthlyAverage {
    if (filterScores.isEmpty) {
      return 0;
    }

    return monthlyTotalScore / filterScores.length;
  }

  // =========================================================
  // MONTHLY RESULTS FOR A SEMESTER
  // =========================================================

  List<Map<String, dynamic>> monthlyResultsForSemester(
    int semester,
  ) {
    final List<Map<String, dynamic>> data = [];

    final List<int> semesterMonthList = monthsForSemester(semester);

    for (final int month in semesterMonthList) {
      final List<ScoreModel> scores = result.where(
        (ScoreModel score) {
          return score.semester == semester && score.month == month;
        },
      ).toList();

      if (scores.isEmpty) {
        continue;
      }

      final double total = scores.fold<double>(
        0,
        (double sum, ScoreModel item) => sum + item.score.toDouble(),
      );

      data.add({
        'month': month,
        'totalScore': total,
        'subjects': scores.length,
        'average': total / scores.length,
      });
    }

    return data;
  }

  List<Map<String, dynamic>> get semesterMonthlyResults {
    return monthlyResultsForSemester(
      selectedSemester.value,
    );
  }

  // =========================================================
  // MONTHLY AVERAGE FOR SEMESTER
  //
  // Same behavior as Web:
  // average of each month's average.
  //
  // Example:
  // Jan 10.75
  // Feb 69.00
  // Mar 43.00
  // Apr 34.00
  //
  // (10.75 + 69 + 43 + 34) / 4 = 39.19
  // =========================================================

  double semesterMonthlyAverageFor(
    int semester,
  ) {
    final List<Map<String, dynamic>> data = monthlyResultsForSemester(
      semester,
    );

    if (data.isEmpty) {
      return 0;
    }

    final double total = data.fold<double>(
      0,
      (
        double sum,
        Map<String, dynamic> item,
      ) =>
          sum + (item['average'] as double),
    );

    return total / data.length;
  }

  double get semesterMonthlyAverage {
    return semesterMonthlyAverageFor(
      selectedSemester.value,
    );
  }

  // =========================================================
  // SEMESTER EXAM
  //
  // This controller treats month == 0 as the semester exam.
  // It is excluded from the normal monthly list.
  // =========================================================

  List<ScoreModel> semesterExamScores(
    int semester,
  ) {
    return result.where(
      (ScoreModel score) {
        return score.semester == semester && score.month == 0;
      },
    ).toList();
  }

  bool hasSemesterExam(
    int semester,
  ) {
    return semesterExamScores(
      semester,
    ).isNotEmpty;
  }

  double semesterExamTotalFor(
    int semester,
  ) {
    final List<ScoreModel> scores = semesterExamScores(
      semester,
    );

    return scores.fold<double>(
      0,
      (double sum, ScoreModel item) => sum + item.score.toDouble(),
    );
  }

  int semesterExamSubjectCountFor(
    int semester,
  ) {
    return semesterExamScores(
      semester,
    ).length;
  }

  double semesterExamAverageFor(
    int semester,
  ) {
    final List<ScoreModel> scores = semesterExamScores(
      semester,
    );

    if (scores.isEmpty) {
      return 0;
    }

    final double total = scores.fold<double>(
      0,
      (double sum, ScoreModel item) => sum + item.score.toDouble(),
    );

    return total / scores.length;
  }

  double get semesterExamAverage {
    return semesterExamAverageFor(
      selectedSemester.value,
    );
  }

  // =========================================================
  // SEMESTER RESULT
  //
  // Web formula:
  //
  // Semester Result =
  // (Monthly Average + Semester Exam Average) / 2
  //
  // If no exam exists yet, use monthly average only.
  // =========================================================

  double semesterResultFor(
    int semester,
  ) {
    final double monthlyAverage = semesterMonthlyAverageFor(
      semester,
    );

    final double examAverage = semesterExamAverageFor(
      semester,
    );

    final bool hasMonthly = monthlyResultsForSemester(
      semester,
    ).isNotEmpty;

    final bool hasExam = hasSemesterExam(
      semester,
    );

    if (!hasMonthly && !hasExam) {
      return 0;
    }

    if (hasMonthly && !hasExam) {
      return monthlyAverage;
    }

    if (!hasMonthly && hasExam) {
      return examAverage;
    }

    return (monthlyAverage + examAverage) / 2;
  }

  double get semesterResult {
    return semesterResultFor(
      selectedSemester.value,
    );
  }

  // =========================================================
  // YEARLY CALCULATIONS
  // =========================================================

  double get semester1MonthlyAverage {
    return semesterMonthlyAverageFor(
      1,
    );
  }

  double get semester1ExamAverage {
    return semesterExamAverageFor(
      1,
    );
  }

  double get semester1Result {
    return semesterResultFor(
      1,
    );
  }

  double get semester2MonthlyAverage {
    return semesterMonthlyAverageFor(
      2,
    );
  }

  double get semester2ExamAverage {
    return semesterExamAverageFor(
      2,
    );
  }

  double get semester2Result {
    return semesterResultFor(
      2,
    );
  }

  double get yearlyAverage {
    final List<double> values = [];

    final bool semester1HasData =
        monthlyResultsForSemester(1).isNotEmpty || hasSemesterExam(1);

    final bool semester2HasData =
        monthlyResultsForSemester(2).isNotEmpty || hasSemesterExam(2);

    if (semester1HasData) {
      values.add(
        semester1Result,
      );
    }

    if (semester2HasData) {
      values.add(
        semester2Result,
      );
    }

    if (values.isEmpty) {
      return 0;
    }

    return values.fold<double>(
          0,
          (
            double sum,
            double value,
          ) =>
              sum + value,
        ) /
        values.length;
  }

  String get yearlyStatus {
    return yearlyAverage >= 50 ? 'PASS' : 'FAIL';
  }

  // =========================================================
  // INITIAL SELECTION
  // =========================================================

  void _selectInitialSemesterAndMonth() {
    final List<int> semesters = availableSemesters;

    if (semesters.isEmpty) {
      selectedSemester.value = 1;
      selectedMonth.value = null;
      rank.value = null;
      return;
    }

    selectedSemester.value = semesters.last;

    final int targetIndex = selectedSemester.value - 1;

    if (targetIndex >= 0 &&
        targetIndex < tabController.length &&
        tabController.index != targetIndex) {
      tabController.index = targetIndex;
    }

    _selectLatestMonthForCurrentSemester();
  }

  void _selectLatestMonthForCurrentSemester() {
    final List<int> availableMonths = semesterMonths;

    if (availableMonths.isEmpty) {
      selectedMonth.value = null;
      rank.value = null;
      return;
    }

    selectedMonth.value = availableMonths.last;
  }

  // =========================================================
  // CHANGE SEMESTER
  // =========================================================

  Future<void> changeSemester(
    int semester,
  ) async {
    if (semester < 1 || semester > 2) {
      return;
    }

    if (selectedSemester.value == semester) {
      return;
    }

    selectedSemester.value = semester;

    selectedMonth.value = null;
    rank.value = null;

    _selectLatestMonthForCurrentSemester();

    final int targetIndex = semester - 1;

    if (tabController.index != targetIndex) {
      tabController.animateTo(
        targetIndex,
      );
    }

    if (selectedView.value == ResultViewMode.monthly) {
      await getRank();
    }
  }

  // =========================================================
  // CHANGE MONTH
  // =========================================================

  Future<void> changeMonth(
    int month,
  ) async {
    if (month < 1 || month > 12) {
      return;
    }

    if (!semesterMonths.contains(
      month,
    )) {
      return;
    }

    selectedMonth.value = month;
    rank.value = null;

    await getRank();
  }

  // =========================================================
  // MONTHLY RANK
  // =========================================================

  Future<void> getRank() async {
    final int? month = selectedMonth.value;

    if (month == null) {
      rank.value = null;
      return;
    }

    try {
      isRankLoading.value = true;

      final ScoreModel? response = await resultApi.getRankStudent(
        month: month,
        semester: selectedSemester.value,
      );

      rank.value = response;
    } catch (e, stackTrace) {
      debugPrint(
        'GET RANK ERROR: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      rank.value = null;
    } finally {
      isRankLoading.value = false;
    }
  }

  // =========================================================
  // REFRESH
  // =========================================================

  Future<void> refreshResult() async {
    final int oldSemester = selectedSemester.value;

    final int? oldMonth = selectedMonth.value;

    try {
      isLoading.value = true;

      final List<ScoreModel> response = await resultApi.getResult();

      result.assignAll(
        response,
      );

      if (hasSemester(
        oldSemester,
      )) {
        selectedSemester.value = oldSemester;

        if (oldMonth != null &&
            semesterMonths.contains(
              oldMonth,
            )) {
          selectedMonth.value = oldMonth;
        } else {
          _selectLatestMonthForCurrentSemester();
        }
      } else {
        _selectInitialSemesterAndMonth();
      }

      if (selectedView.value == ResultViewMode.monthly) {
        await getRank();
      } else if (selectedView.value == ResultViewMode.yearly) {
        await getYearRank();
      }
    } catch (e, stackTrace) {
      debugPrint(
        'REFRESH RESULT ERROR: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =========================================================
  // CLOSE
  // =========================================================

  @override
  void onClose() {
    tabController.removeListener(
      _handleSemesterTabChange,
    );

    tabController.dispose();

    super.onClose();
  }
}
