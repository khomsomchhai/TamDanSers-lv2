part of 'result_screen_view.dart';

enum ResultViewMode {
  monthly,
  semester,
  yearly,
}

class ResultScreenViewController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final ResultApi resultApi = ResultApi();

  late final TabController tabController;

  // View Mode: Monthly / Semester / Yearly
  final selectedView = ResultViewMode.monthly.obs;

  final selectedSemester = 1.obs;
  final selectedMonth = RxnInt();

  final isLoading = false.obs;
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

    // Set length to 2 to match Semester 1 and Semester 2 tabs
    tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: 0,
    );

    tabController.addListener(_handleSemesterTabChange);

    getResult();
  }

  void _handleSemesterTabChange() {
    if (tabController.indexIsChanging) return;

    final int targetSemester = tabController.index + 1;
    if (selectedSemester.value != targetSemester) {
      changeSemester(targetSemester);
    }
  }

  Future<void> changeView(ResultViewMode mode) async {
    selectedView.value = mode;

    if (mode == ResultViewMode.monthly) {
      await getRank();
    } else if (mode == ResultViewMode.yearly) {
      await getYearRank();
    }
  }

  Future<void> getYearRank() async {
    try {
      isYearRankLoading.value = true;

      // 1. Get the current year
      final int currentYear = DateTime.now().year;

      // 2. Call getYearRank with required 'year' parameter
      final ScoreModel? response = await resultApi.getYearRank(
        year: currentYear,
        // studentId: studentId, // Pass studentId here if needed
      );

      // 3. Update reactive state
      yearlyRank.value = response;

      if (response != null) {
        debugPrint(
          'YEAR RANK RESPONSE: rank=${response.rank}, average=${response.average}',
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
    try {
      isLoading.value = true;

      final List<ScoreModel> response = await resultApi.getResult();
      result.assignAll(response);

      debugPrint('TOTAL SCORE RECORDS: ${result.length}');

      _selectInitialSemesterAndMonth();
      await getRank();
    } catch (e, stackTrace) {
      debugPrint('GET RESULT ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      result.clear();
      rank.value = null;
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
  // SEMESTERS & MONTHS
  // =========================================================

  List<int> get availableSemesters {
    final List<int> semesters =
        result.map((score) => score.semester).toSet().toList();
    semesters.sort();
    return semesters;
  }

  bool hasSemester(int semester) {
    return availableSemesters.contains(semester);
  }

  List<int> get semesterMonths {
    final List<int> availableMonths = result
        .where((score) => score.semester == selectedSemester.value)
        .map((score) => score.month)
        .toSet()
        .toList();

    availableMonths.sort();
    return availableMonths;
  }

  List<ScoreModel> get filterScores {
    final int? month = selectedMonth.value;
    if (month == null) return [];

    final List<ScoreModel> scores = result.where((score) {
      return score.semester == selectedSemester.value && score.month == month;
    }).toList();

    scores.sort((a, b) => a.subjectName.compareTo(b.subjectName));
    return scores;
  }

  // =========================================================
  // MONTHLY & SEMESTER CALCULATIONS
  // =========================================================

  double get monthlyTotalScore {
    return filterScores.fold<double>(
      0,
      (sum, score) => sum + score.score.toDouble(),
    );
  }

  int get monthlyTotalSubjects => filterScores.length;

  double get monthlyAverage {
    if (filterScores.isEmpty) return 0;
    return monthlyTotalScore / filterScores.length;
  }

  List<Map<String, dynamic>> get semesterMonthlyResults {
    final List<Map<String, dynamic>> data = [];

    for (final int month in semesterMonths) {
      final List<ScoreModel> scores = result.where((score) {
        return score.semester == selectedSemester.value && score.month == month;
      }).toList();

      if (scores.isEmpty) continue;

      final double total = scores.fold<double>(
        0,
        (sum, item) => sum + item.score.toDouble(),
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

  double get semesterMonthlyAverage {
    final data = semesterMonthlyResults;
    if (data.isEmpty) return 0;

    final double total = data.fold<double>(
      0,
      (sum, item) => sum + (item['average'] as double),
    );

    return total / data.length;
  }

  double get semesterResult => semesterMonthlyAverage;

  // =========================================================
  // YEARLY CALCULATIONS
  // =========================================================

  double semesterAverage(int semester) {
    final List<int> monthsInSemester = result
        .where((score) => score.semester == semester)
        .map((score) => score.month)
        .toSet()
        .toList();

    if (monthsInSemester.isEmpty) return 0;

    final List<double> averages = [];

    for (final int month in monthsInSemester) {
      final List<ScoreModel> scores = result.where((score) {
        return score.semester == semester && score.month == month;
      }).toList();

      if (scores.isEmpty) continue;

      final double total = scores.fold<double>(
        0,
        (sum, item) => sum + item.score.toDouble(),
      );

      averages.add(total / scores.length);
    }

    if (averages.isEmpty) return 0;

    return averages.fold<double>(0, (sum, value) => sum + value) /
        averages.length;
  }

  double get semester1Result => semesterAverage(1);

  double get semester2Result => semesterAverage(2);

  double get yearlyAverage {
    final List<double> values = [];

    if (hasSemester(1)) values.add(semester1Result);
    if (hasSemester(2)) values.add(semester2Result);

    if (values.isEmpty) return 0;

    return values.fold<double>(0, (sum, value) => sum + value) / values.length;
  }

  String get yearlyStatus => yearlyAverage >= 50 ? 'PASS' : 'FAIL';

  // =========================================================
  // SELECTION HANDLERS
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

  Future<void> changeSemester(int semester) async {
    if (semester < 1 || semester > 2) return;
    if (selectedSemester.value == semester) return;

    selectedSemester.value = semester;
    selectedMonth.value = null;
    rank.value = null;

    _selectLatestMonthForCurrentSemester();

    final int targetIndex = semester - 1;
    if (tabController.index != targetIndex) {
      tabController.animateTo(targetIndex);
    }

    await getRank();
  }

  Future<void> changeMonth(int month) async {
    if (!semesterMonths.contains(month)) return;

    selectedMonth.value = month;
    rank.value = null;

    await getRank();
  }

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
      debugPrint('GET RANK ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
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
      result.assignAll(response);

      if (hasSemester(oldSemester)) {
        selectedSemester.value = oldSemester;

        if (oldMonth != null && semesterMonths.contains(oldMonth)) {
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
      debugPrint('REFRESH RESULT ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    tabController.removeListener(_handleSemesterTabChange);
    tabController.dispose();
    super.onClose();
  }
}
