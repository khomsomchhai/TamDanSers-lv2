part of 'result_screen_view.dart';

class ResultScreenViewController extends GetxController {
  final ResultApi resultApi = ResultApi();

  final selectedSemester = 1.obs;
  final selectedMonth = RxnInt();

  final isLoading = false.obs;
  final isRankLoading = false.obs;

  final result = <ScoreModel>[].obs;
  final rank = Rxn<ScoreModel>();

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

    getResult();
  }

  // ============================================================
  // GET ALL SCORES
  // ============================================================

  Future<void> getResult() async {
    try {
      isLoading.value = true;

      final List<ScoreModel> response =
          await resultApi.getResult();

      result.assignAll(response);

      debugPrint(
        'TOTAL SCORE RECORDS: ${result.length}',
      );

      for (final score in result) {
        debugPrint(
          'SCORE: '
          'semester=${score.semester}, '
          'month=${score.month}, '
          'subject=${score.subjectName}, '
          'score=${score.score}, '
          'max=${score.maxScore}',
        );
      }

      selectLatestSemesterAndMonth();

      await getRank();
    } catch (e, stackTrace) {
      debugPrint(
        'GET RESULT ERROR: $e',
      );

      debugPrint(
        'GET RESULT STACK TRACE: $stackTrace',
      );

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

  // ============================================================
  // AVAILABLE SEMESTERS
  // ============================================================

  List<int> get availableSemesters {
    final List<int> semesters = result
        .map(
          (score) => score.semester,
        )
        .toSet()
        .toList();

    semesters.sort();

    return semesters;
  }

  // ============================================================
  // AVAILABLE MONTHS OF CURRENT SEMESTER
  // ============================================================

  List<int> get semesterMonths {
    final List<int> availableMonths = result
        .where(
          (score) =>
              score.semester ==
              selectedSemester.value,
        )
        .map(
          (score) => score.month,
        )
        .toSet()
        .toList();

    availableMonths.sort();

    return availableMonths;
  }

  // ============================================================
  // FILTER SCORES
  // ============================================================

  List<ScoreModel> get filterScores {
    final int? month =
        selectedMonth.value;

    return result.where((score) {
      final bool sameSemester =
          score.semester ==
          selectedSemester.value;

      final bool sameMonth =
          month == null ||
          score.month == month;

      return sameSemester && sameMonth;
    }).toList();
  }

  // ============================================================
  // SELECT INITIAL LATEST SEMESTER AND MONTH
  // ============================================================

  void selectLatestSemesterAndMonth() {
    final List<int> semesters =
        availableSemesters;

    if (semesters.isEmpty) {
      selectedSemester.value = 1;
      selectedMonth.value = null;
      rank.value = null;
      return;
    }

    selectedSemester.value =
        semesters.last;

    selectLatestMonthForCurrentSemester();
  }

  void selectLatestMonthForCurrentSemester() {
    final List<int> availableMonths =
        semesterMonths;

    if (availableMonths.isEmpty) {
      selectedMonth.value = null;
      rank.value = null;
      return;
    }

    selectedMonth.value =
        availableMonths.last;
  }

  // ============================================================
  // CHANGE SEMESTER
  // ============================================================

  Future<void> changeSemester(
    int semester,
  ) async {
    if (selectedSemester.value == semester) {
      return;
    }

    selectedSemester.value = semester;

    rank.value = null;

    selectLatestMonthForCurrentSemester();

    await getRank();
  }

  // ============================================================
  // CHANGE MONTH
  // ============================================================

 Future<void> changeMonth(int month) async {
  selectedMonth.value = month;
  rank.value = null;

  await getRank();
}

  // ============================================================
  // GET RANK
  // ============================================================

  Future<void> getRank() async {
    final int? month =
        selectedMonth.value;

    if (month == null) {
      rank.value = null;
      return;
    }

    try {
      isRankLoading.value = true;

      final ScoreModel response =
          await resultApi.getRankStudent(
        month: month,
        semester: selectedSemester.value,
      );

      rank.value = response;

      debugPrint(
        'RANK RESPONSE: '
        'semester=${selectedSemester.value}, '
        'month=$month, '
        'rank=${response.rank}, '
        'average=${response.average}, '
        'totalScore=${response.totalScore}',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'GET RANK ERROR: $e',
      );

      debugPrint(
        'GET RANK STACK TRACE: $stackTrace',
      );

      rank.value = null;
    } finally {
      isRankLoading.value = false;
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshResult() async {
    await getResult();
  }
}