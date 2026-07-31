part of 'parent_home_tab_view.dart';

class ParentHomeTabViewController
    extends GetxController {
  final UserController userController =
      Get.find<UserController>();

  final ParentAttendanceTabViewController
      attendanceController =
      Get.find<
          ParentAttendanceTabViewController>();

  final GetStorage box = GetStorage();

  final ResultApi resultApi =
      ResultApi();

  final isLoading = false.obs;

  final students =
      <Map<String, dynamic>>[].obs;

  final Rxn<Map<String, dynamic>>
      selectedChild =
      Rxn<Map<String, dynamic>>();

  final Rxn<ParentDashboardModel>
      dashboard =
      Rxn<ParentDashboardModel>();

  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();

    loadStudents();

    if (userController.user == null &&
        userController.profile == null) {
      userController.getProfile();
    }
  }

  void loadStudents() {
    final data =
        box.read('students');

    debugPrint(
      'STUDENTS FROM STORAGE: $data',
    );

    if (data is! List) {
      students.clear();
      return;
    }

    students.assignAll(
      data.map(
        (item) =>
            Map<String, dynamic>.from(
          item as Map,
        ),
      ),
    );

    debugPrint(
      'TOTAL STUDENTS: ${students.length}',
    );

    if (students.isEmpty) {
      selectedChild.value = null;
      return;
    }

    selectedChild.value =
        students.first;

    final studentId =
        _parseStudentId(
      students.first['id'],
    );

    if (studentId != null) {
      fetchDashboard(studentId);
    }
  }

  int? _parseStudentId(
    dynamic value,
  ) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
      value?.toString() ?? '',
    );
  }

  String get childName {
    return selectedChild
            .value?['student_name']
            ?.toString() ??
        'dont_have_child'.tr;
  }

  String get childCode {
    return selectedChild
            .value?['student_code']
            ?.toString() ??
        'dont_have_child'.tr;
  }

  void selectChild(
    Map<String, dynamic> child,
  ) {
    selectedChild.value = child;

    final studentId =
        _parseStudentId(
      child['id'],
    );

    if (studentId != null) {
      fetchDashboard(studentId);
    }
  }

  Future<void> fetchDashboard(
    int studentId,
  ) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final results =
          await Future.wait([
        resultApi.getParentDashboard(
          studentId: studentId,
        ),
        attendanceController
            .loadAttendanceByStudent(
          studentId,
        ),
      ]);

      dashboard.value =
          results.first
              as ParentDashboardModel;
    } catch (error, stackTrace) {
      errorMessage.value =
          'Failed to load dashboard';

      debugPrint(
        'PARENT DASHBOARD ERROR: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshHome() async {
    final studentId =
        _parseStudentId(
      selectedChild.value?['id'],
    );

    if (studentId == null) {
      return;
    }

    await fetchDashboard(
      studentId,
    );
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

    final weekDay =
        khmerWeekDays[
            now.weekday - 1];

    final month =
        khmerMonths[
            now.month - 1];

    return '$weekDay ទី${now.day} '
        'ខែ$month ឆ្នាំ${now.year}';
  }

  String formatNumber(
    dynamic value,
  ) {
    if (value == null) {
      return '0';
    }

    final number =
        double.tryParse(
      value.toString(),
    );

    if (number == null) {
      return value.toString();
    }

    if (number ==
        number.roundToDouble()) {
      return number
          .toInt()
          .toString();
    }

    return number
        .toStringAsFixed(1);
  }
}