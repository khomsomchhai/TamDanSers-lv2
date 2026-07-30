part of 'result_screen_view.dart';

class ResultScreenViewController extends GetxController {
  ResultApi resultApi = ResultApi();

  final selectedSemester = 1.obs;
  final selectedMonth = RxnInt();
  final isLoading = false.obs;

  final result = <ScoreModel>[].obs;
  final rank = Rxn<ScoreModel>();

  final Map<int, String> months = {
    1: "month_1",
    2: "month_2",
    3: "month_3",
    4: "month_4",
    5: "month_5",
    6: "month_6",
    7: "month_7",
    8: "month_8",
    9: "month_9",
    10: "month_10",
    11: "month_11",
    12: "month_12",
  };

  Future<void> getResult() async {
    try {
      isLoading.value = true;

      final response = await resultApi.getResult();
      result.assignAll(response);

      selectLatestSemesterAndMonth();
      await getRank();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getRank() async {
    if (selectedMonth.value == null) return;

    rank.value = await resultApi.getRankStudent(
      month: selectedMonth.value!,
      semester: selectedSemester.value,
    );
  }

  List<int> get semesterMonths {
    return result
        .where((e) => e.semester == selectedSemester.value)
        .map((e) => e.month)
        .toSet()
        .toList()
      ..sort();
  }

  List<ScoreModel> get filterScores {
    return result.where((e) {
      final sameSemester = e.semester == selectedSemester.value;
      final sameMonth =
          selectedMonth.value == null || e.month == selectedMonth.value;

      return sameSemester && sameMonth;
    }).toList();
  }

void selectLatestSemesterAndMonth() {
  final semesters = result
      .map((e) => e.semester)
      .toSet()
      .toList()
    ..sort();

  if (semesters.isEmpty) {
    selectedMonth.value = null;
    rank.value = null;
    return;
  }

  selectedSemester.value = semesters.last;

  if (semesterMonths.isNotEmpty) {
    selectedMonth.value = semesterMonths.last;
  } else {
    selectedMonth.value = null;
    rank.value = null;
  }
}

  @override
  void onInit() {
    super.onInit();
    getResult();
  }
}