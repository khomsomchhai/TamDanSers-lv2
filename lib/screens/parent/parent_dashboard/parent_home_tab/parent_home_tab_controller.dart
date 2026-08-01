part of 'parent_home_tab_view.dart';

class ParentHomeTabViewController
    extends GetxController {
  // =====================================================
  // Dependencies
  // =====================================================

  final UserController userController =
      Get.find<UserController>();

  final ParentAttendanceTabViewController
      attendanceController =
      Get.find<
          ParentAttendanceTabViewController>();

  final GetStorage box =
      GetStorage();

  final ResultApi resultApi =
      ResultApi();

  final AuthServices authServices =
      AuthServices();

  final ScheduleApi scheduleApi =
      ScheduleApi();

  // =====================================================
  // Loading and error states
  // =====================================================

  final isLoading = false.obs;

  final isScheduleLoading = false.obs;

  final errorMessage = ''.obs;

  final scheduleError = ''.obs;

  // =====================================================
  // Parent children
  // =====================================================

  final students =
      <Map<String, dynamic>>[].obs;

  final Rxn<Map<String, dynamic>>
      selectedChild =
      Rxn<Map<String, dynamic>>();

  // =====================================================
  // Dashboard
  // =====================================================

  final Rxn<ParentDashboardModel>
      dashboard =
      Rxn<ParentDashboardModel>();

  // =====================================================
  // Today's schedule
  // =====================================================

  final todaySchedule =
      <ScheduleModel>[].obs;

  // =====================================================
  // Attendance expand state
  // =====================================================

  final isAttendanceExpanded =
      false.obs;

  // =====================================================
  // Lifecycle
  // =====================================================

  @override
  void onInit() {
    super.onInit();

    loadStudents();

    if (userController.user == null &&
        userController.profile == null) {
      userController.getProfile();
    }
  }

  // =====================================================
  // Load parent children
  // =====================================================

  Future<void> loadStudents() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response =
          await authServices
              .getParentChildren();

      debugPrint(
        'PARENT CHILDREN RESPONSE: '
        '$response',
      );

      final dynamic data =
          response['students'];

      if (data is! List) {
        _clearStudentData();

        await box.remove(
          'students',
        );

        return;
      }

      final updatedStudents =
          data.map<Map<String, dynamic>>(
        (item) {
          return Map<String, dynamic>.from(
            item as Map,
          );
        },
      ).toList();

      students.assignAll(
        updatedStudents,
      );

      await box.write(
        'students',
        updatedStudents,
      );

      debugPrint(
        'TOTAL PARENT CHILDREN: '
        '${students.length}',
      );

      if (students.isEmpty) {
        _clearStudentData();
        return;
      }

      final oldSelectedId =
          _parseStudentId(
        selectedChild.value?['id'],
      );

      Map<String, dynamic>?
          childToSelect;

      if (oldSelectedId != null) {
        for (final child in students) {
          final childId =
              _parseStudentId(
            child['id'],
          );

          if (childId ==
              oldSelectedId) {
            childToSelect =
                child;

            break;
          }
        }
      }

      childToSelect ??=
          students.first;

      selectedChild.value =
          childToSelect;

      final studentId =
          _parseStudentId(
        childToSelect['id'],
      );

      if (studentId != null) {
        await _loadChildData(
          studentId,
        );
      }
    } catch (error, stackTrace) {
      errorMessage.value =
          'Failed to load children';

      debugPrint(
        'LOAD CHILDREN ERROR: '
        '$error',
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
  // Load children from local storage
  // =====================================================

  Future<void>
      loadStudentsFromStorage() async {
    final dynamic data =
        box.read('students');

    debugPrint(
      'STUDENTS FROM STORAGE: '
      '$data',
    );

    if (data is! List) {
      _clearStudentData();
      return;
    }

    final cachedStudents =
        data.map<Map<String, dynamic>>(
      (item) {
        return Map<String, dynamic>.from(
          item as Map,
        );
      },
    ).toList();

    students.assignAll(
      cachedStudents,
    );

    if (students.isEmpty) {
      _clearStudentData();
      return;
    }

    selectedChild.value =
        students.first;

    final studentId =
        _parseStudentId(
      students.first['id'],
    );

    if (studentId != null) {
      await _loadChildData(
        studentId,
      );
    }
  }

  // =====================================================
  // Select child
  // =====================================================

  Future<void> selectChild(
    Map<String, dynamic> child,
  ) async {
    selectedChild.value =
        child;

    final studentId =
        _parseStudentId(
      child['id'],
    );

    if (studentId == null) {
      dashboard.value = null;
      todaySchedule.clear();

      return;
    }

    await _loadChildData(
      studentId,
    );
  }

  // =====================================================
  // Load all selected child data
  // =====================================================

  Future<void> _loadChildData(
    int studentId,
  ) async {
    await Future.wait([
      fetchDashboard(
        studentId,
      ),
      getTodaySchedule(
        studentId,
      ),
    ]);
  }

  // =====================================================
  // Fetch parent dashboard
  // =====================================================

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
        'PARENT DASHBOARD ERROR: '
        '$error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =====================================================
  // Fetch today's schedule
  // =====================================================

  Future<void> getTodaySchedule(
    int studentId,
  ) async {
    try {
      isScheduleLoading.value =
          true;

      scheduleError.value = '';

      final response =
          await scheduleApi
              .getParentSchedule(
        studentId,
      );

      final dynamic responseData =
          response is Map<String, dynamic>
              ? response
              : response.data;

      if (responseData
          is! Map<String, dynamic>) {
        todaySchedule.clear();
        return;
      }

      final dynamic schedulesData =
          responseData['schedules'];

      if (schedulesData is! List) {
        todaySchedule.clear();
        return;
      }

      final schedules =
          schedulesData
              .map<ScheduleModel>(
        (item) {
          return ScheduleModel.fromJson(
            Map<String, dynamic>.from(
              item as Map,
            ),
          );
        },
      ).toList();

      schedules.sort(
        (first, second) {
          final firstTime =
              _timeToMinutes(
            first.startTime,
          );

          final secondTime =
              _timeToMinutes(
            second.startTime,
          );

          return firstTime.compareTo(
            secondTime,
          );
        },
      );

      todaySchedule.assignAll(
        schedules,
      );

      debugPrint(
        'TODAY SCHEDULE TOTAL: '
        '${todaySchedule.length}',
      );
    } catch (error, stackTrace) {
      todaySchedule.clear();

      scheduleError.value =
          error.toString();

      debugPrint(
        'GET TODAY SCHEDULE ERROR: '
        '$error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    } finally {
      isScheduleLoading.value =
          false;
    }
  }

  // =====================================================
  // Refresh homepage
  // =====================================================

  Future<void> refreshHome() async {
    await loadStudents();
  }

  // =====================================================
  // Attendance expand/collapse
  // =====================================================

  void toggleAttendanceExpanded() {
    isAttendanceExpanded.toggle();
  }

  // =====================================================
  // Clear student data
  // =====================================================

  void _clearStudentData() {
    students.clear();

    selectedChild.value =
        null;

    dashboard.value =
        null;

    todaySchedule.clear();
  }

  // =====================================================
  // Parse student ID
  // =====================================================

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

  // =====================================================
  // Selected child information
  // =====================================================

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

  // =====================================================
  // Current Khmer date
  // =====================================================

  String getCurrentDate() {
    final now =
        DateTime.now();

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

  // =====================================================
  // Number formatting
  // =====================================================

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

  // =====================================================
  // Schedule helpers
  // =====================================================

  bool isMorning(
    String startTime,
  ) {
    final text =
        startTime.trim();

    if (text.isEmpty) {
      return true;
    }

    final parts =
        text.split(':');

    if (parts.isEmpty) {
      return true;
    }

    final hour =
        int.tryParse(
          parts.first,
        ) ??
        0;

    return hour < 12;
  }

  String formatTime(
    String value,
  ) {
    final text =
        value.trim();

    if (text.isEmpty) {
      return '--:--';
    }

    final parts =
        text.split(':');

    if (parts.length < 2) {
      return text;
    }

    return '${parts[0]}:${parts[1]}';
  }

  int _timeToMinutes(
    String value,
  ) {
    final text =
        value.trim();

    if (text.isEmpty) {
      return 0;
    }

    final parts =
        text.split(':');

    if (parts.length < 2) {
      return 0;
    }

    final hour =
        int.tryParse(
          parts[0],
        ) ??
        0;

    final minute =
        int.tryParse(
          parts[1],
        ) ??
        0;

    return hour * 60 +
        minute;
  }
}