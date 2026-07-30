part of 'parent_home_tab_view.dart';
class ParentHomeTabViewController extends GetxController {
  final userController = Get.find<UserController>();
  final box = GetStorage();
  final ResultApi resultApi = ResultApi(); // instance ថ្មី

  final isLoading = false.obs; // តែមួយប៉ុណ្ណោះ
  final students = <Map<String, dynamic>>[].obs;
  final Rxn<Map<String, dynamic>> selectedChild = Rxn<Map<String, dynamic>>(); // ថ្មី
  final Rxn<ParentDashboardModel> dashboard = Rxn<ParentDashboardModel>();
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();

    loadStudents();

    if (userController.user == null && userController.profile == null) {
      userController.getProfile();
    }
  }
  void loadStudents() {
  final data = box.read("students");

  debugPrint("STUDENTS FROM STORAGE: $data");

  if (data is List) {
    students.assignAll(
      data.map(
        (item) => Map<String, dynamic>.from(item),
      ),
    );

    debugPrint("TOTAL STUDENTS: ${students.length}");

    for (final student in students) {
      debugPrint(
        "STUDENT: ${student["student_name"]} - ${student["student_code"]}",
      );
    }

    if (students.isNotEmpty) {
      selectedChild.value = students.first;

      final studentId = students.first["id"];

      if (studentId != null) {
        fetchDashboard(
          studentId is int
              ? studentId
              : int.parse(studentId.toString()),
        );
      }
    }
  }
}
  String get childName {
    if (selectedChild.value == null) return "dont_have_child";
    return selectedChild.value?["student_name"]?.toString() ?? "dont_have_child";
  }

  String get childCode {
    if (selectedChild.value == null) return "dont_have_child";
    return selectedChild.value?["student_code"]?.toString() ?? "dont_have_child";
  }
 void selectChild(Map<String, dynamic> child) {
  selectedChild.value = child;

  final studentId = child["id"];

  if (studentId != null) {
    fetchDashboard(
      studentId is int
          ? studentId
          : int.parse(studentId.toString()),
    );
  }

  update();
}
  Future<void> fetchDashboard(int studentId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await resultApi.getParentDashboard(studentId: studentId);
      dashboard.value = result;
    } catch (e) {
      errorMessage.value = 'Failed to load dashboard';
    } finally {
      isLoading.value = false;
    }
  }
  String getCurrentDate() {
  final now = DateTime.now();

  const khmerWeekDays = [
    'ថ្ងៃច័ន្ទ',
    'ថ្ងៃអង្គារ',
    'ថ្ងៃពុធ',
    'ថ្ងៃព្រហស្បតិ៍',
    'ថ្ងៃសុក្រ',
    'ថ្ងៃសៅរ៍',
    'ថ្ងៃអាទិត្យ',
  ];

  const khmerMonths = [
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

  final weekDay = khmerWeekDays[now.weekday - 1];
  final month = khmerMonths[now.month - 1];

  return '$weekDay ទី${now.day} ខែ$month ឆ្នាំ${now.year}';
}
String formatNumber(dynamic value) {
  if (value == null) return '0';

  final number = double.tryParse(value.toString());

  if (number == null) {
    return value.toString();
  }

  if (number == number.roundToDouble()) {
    return number.toInt().toString();
  }

  return number.toStringAsFixed(1);
}
  
}
