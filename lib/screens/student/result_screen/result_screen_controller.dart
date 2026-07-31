part of 'result_screen_view.dart';

class ResultScreenViewController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final ResultApi resultApi = ResultApi();

  late final TabController tabController;

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

    tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: 0,
    );

    tabController.addListener(_handleTabChange);

    getResult();
  }

  void _handleTabChange() {
    if (tabController.indexIsChanging) {
      return;
    }

    final int semester = tabController.index + 1;

    if (selectedSemester.value != semester) {
      changeSemester(semester);
    }
  }

  Future<void> getResult() async {
    try {
      isLoading.value = true;

      final List<ScoreModel> response =
          await resultApi.getResult();

      result.assignAll(response);

      debugPrint(
        'TOTAL SCORE RECORDS: ${result.length}',
      );

      _selectInitialSemesterAndMonth();

      _syncTabWithSemester();

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

  bool hasSemester(int semester) {
    return availableSemesters.contains(semester);
  }

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

  List<ScoreModel> get filterScores {
    final int? month =
        selectedMonth.value;

    if (month == null) {
      return [];
    }

    final List<ScoreModel> scores = result.where(
      (score) {
        final bool sameSemester =
            score.semester ==
            selectedSemester.value;

        final bool sameMonth =
            score.month == month;

        return sameSemester && sameMonth;
      },
    ).toList();

    scores.sort(
      (a, b) => a.subjectName.compareTo(
        b.subjectName,
      ),
    );

    return scores;
  }

  void _selectInitialSemesterAndMonth() {
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

    _selectLatestMonthForCurrentSemester();
  }

  void _selectLatestMonthForCurrentSemester() {
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

  void _syncTabWithSemester() {
    final int targetIndex =
        (selectedSemester.value - 1).clamp(0, 1);

    if (tabController.index != targetIndex) {
      tabController.animateTo(
        targetIndex,
      );
    }
  }

  Future<void> changeSemester(int semester) async {
  if (semester < 1 || semester > 2) {
    return;
  }

  if (selectedSemester.value == semester) {
    return;
  }

  selectedSemester.value = semester;
  selectedMonth.value = null;
  rank.value = null;

  // ជ្រើសខែចុងក្រោយតែម្តង នៅពេលប្ដូរ semester
  _selectLatestMonthForCurrentSemester();

  final int targetIndex = semester - 1;

  if (tabController.index != targetIndex) {
    tabController.animateTo(targetIndex);
  }

  await getRank();
}

  Future<void> changeMonth(int month) async {
  if (!semesterMonths.contains(month)) {
    debugPrint(
      'MONTH $month NOT FOUND IN '
      'SEMESTER ${selectedSemester.value}',
    );
    return;
  }

  // ប្ដូរ selected color ភ្លាមៗ
  selectedMonth.value = month;

  // លុប rank ចាស់
  rank.value = null;

  debugPrint(
    'SELECTED MONTH: ${selectedMonth.value}',
  );

  // បន្ទាប់មកទើប load rank
  await getRank();
}

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

  Future<void> refreshResult() async {
    final int oldSemester =
        selectedSemester.value;

    final int? oldMonth =
        selectedMonth.value;

    try {
      isLoading.value = true;

      final List<ScoreModel> response =
          await resultApi.getResult();

      result.assignAll(response);

      if (hasSemester(oldSemester)) {
        selectedSemester.value =
            oldSemester;

        if (oldMonth != null &&
            semesterMonths.contains(oldMonth)) {
          selectedMonth.value =
              oldMonth;
        } else {
          _selectLatestMonthForCurrentSemester();
        }
      } else {
        _selectInitialSemesterAndMonth();
      }

      _syncTabWithSemester();

      await getRank();
    } catch (e, stackTrace) {
      debugPrint(
        'REFRESH RESULT ERROR: $e',
      );

      debugPrint(
        'REFRESH RESULT STACK TRACE: $stackTrace',
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    tabController.removeListener(
      _handleTabChange,
    );

    tabController.dispose();

    super.onClose();
  }
}