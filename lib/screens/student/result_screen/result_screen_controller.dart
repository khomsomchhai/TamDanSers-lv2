part of 'result_screen_view.dart';

class ResultScreenViewController extends GetxController {
  ResultApi resultApi = ResultApi();
  final selectedSemester = 1.obs;
  final selectedMonth = RxnInt();
  final isLoading = false.obs;
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

  var result = <ScoreModel>[].obs;

  Future<void> getResult() async {
    try {
      isLoading.value = true;
      var response = await resultApi.getResult();
      result.assignAll(response);
      selectFisrtMonth();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  final rank = Rxn<ScoreModel>();

  Future<void> getRank() async {
    rank.value = await resultApi.getRankStudent();
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

  double get monthTotalScore {
    return filterScores.fold(
      0.0,
      (sum, item) => sum + item.totalScore,
    );
  }

  void selectFisrtMonth() {
    if (semesterMonths.isNotEmpty) {
      selectedMonth.value = semesterMonths.first;
    } else {
      selectedMonth.value = null;
    }
  }

  final Map<int, String> subjects = {
    1: "khmer",
    2: "math",
    3: "english",
    4: "science",
    5: "social",
    6: "biology"
  };

  @override
  void onInit() {
    super.onInit();
    getResult();
    getRank();
  }
}
