import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/core/api/services/parent_attendance_service.dart';
import 'package:tamdansers_lv2/data/model/attendance_model.dart';

class ParentAttendanceTabViewController extends GetxController {
  final ParentAttendanceService attendanceService =
      ParentAttendanceService();

  final attendanceList = <AttendanceModel>[].obs;
  final isLoading = false.obs;

  final selectedStudentId = RxnInt();
  final selectedMonth = DateTime.now().month.obs;
  final selectedYear = DateTime.now().year.obs;

  void changeMonth(int month, {int? year}) {
    selectedMonth.value = month;
    if (year != null) {
      selectedYear.value = year;
    }
    countAttendance();
  }

  // រាប់ចំនួនថ្ងៃមិនស្ទួន
  final presentDays = 0.obs;
  final absentDays = 0.obs;
  final permissionDays = 0.obs;

  // រាប់ចំនួន records / subjects
  final presentSubjects = 0.obs;
  final absentSubjects = 0.obs;
  final permissionSubjects = 0.obs;

  @override
  void onInit() {
    super.onInit();

    final arguments = Get.arguments;

    if (arguments is Map) {
      final studentId = int.tryParse(
        arguments['student_id']?.toString() ??
            arguments['studentId']?.toString() ??
            '',
      );

      if (studentId != null) {
        loadAttendanceByStudent(studentId);
      }
    }
  }

  Future<void> loadAttendanceByStudent(
    int studentId,
  ) async {
    selectedStudentId.value = studentId;
    selectedMonth.value = DateTime.now().month;
    selectedYear.value = DateTime.now().year;

    await getParentAttendance();
  }

  Future<void> getParentAttendance() async {
    final studentId = selectedStudentId.value;

    if (studentId == null) {
      attendanceList.clear();
      resetCount();

      debugPrint(
        'PARENT ATTENDANCE: studentId is null',
      );

      return;
    }

    try {
      isLoading.value = true;

      final result =
          await attendanceService.getChildAttendance(
        studentId: studentId,
      );

      attendanceList.assignAll(result);

      countAttendance();

      debugPrint(
        'ATTENDANCE STUDENT ID: $studentId',
      );
      debugPrint(
        'ATTENDANCE RECORDS: ${attendanceList.length}',
      );
      debugPrint(
        'PRESENT DAYS: ${presentDays.value}',
      );
      debugPrint(
        'PRESENT SUBJECTS: ${presentSubjects.value}',
      );
      debugPrint(
        'ABSENT DAYS: ${absentDays.value}',
      );
      debugPrint(
        'PERMISSION DAYS: ${permissionDays.value}',
      );
      debugPrint(
        'TOTAL UNIQUE DAYS: $totalDays',
      );
      debugPrint(
        'ATTENDANCE RATE: $attendanceRate',
      );
    } catch (error, stackTrace) {
      attendanceList.clear();
      resetCount();

      debugPrint(
        'GET PARENT ATTENDANCE ERROR: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    } finally {
      isLoading.value = false;
    }
  }
bool isPresentStatus(String status) {
  return status == 'p' ||
      status == 'present';
}

bool isAbsentStatus(String status) {
  return status == 'a' ||
      status == 'absent';
}

bool isPermissionStatus(String status) {
  return status == 'l' ||
      status == 'leave' ||
      status == 'permission' ||
      status == 'permitted';
}
void countAttendance() {
  final Map<String, List<AttendanceModel>> attendanceByDate = {};
  final recordsToCount = filteredAttendance;

  for (final item in recordsToCount) {
    final dateKey = normalizeDate(item.date);

    if (dateKey.isEmpty) {
      continue;
    }

    attendanceByDate.putIfAbsent(
      dateKey,
      () => <AttendanceModel>[],
    );

    attendanceByDate[dateKey]!.add(item);
  }

  int calculatedPresentDays = 0;
  int calculatedAbsentDays = 0;
  int calculatedPermissionDays = 0;

  for (final dailyAttendance in attendanceByDate.values) {
    final statuses = dailyAttendance
        .map(
          (item) => normalizeStatus(item.status),
        )
        .toList();

    final hasPresent = statuses.any(
      isPresentStatus,
    );

    final allAbsent = statuses.isNotEmpty &&
        statuses.every(
          isAbsentStatus,
        );

    final allPermission = statuses.isNotEmpty &&
        statuses.every(
          isPermissionStatus,
        );

    if (hasPresent) {
      calculatedPresentDays += 1;
    } else if (allAbsent) {
      calculatedAbsentDays += 1;
    } else if (allPermission) {
      calculatedPermissionDays += 1;
    } else {
      final hasPermission = statuses.any(
        isPermissionStatus,
      );

      final hasAbsent = statuses.any(
        isAbsentStatus,
      );

      if (hasPermission && !hasAbsent) {
        calculatedPermissionDays += 1;
      } else if (hasAbsent) {
        calculatedAbsentDays += 1;
      }
    }
  }

  presentDays.value = calculatedPresentDays;
  absentDays.value = calculatedAbsentDays;
  permissionDays.value = calculatedPermissionDays;

  presentSubjects.value = recordsToCount.where((item) {
    return isPresentStatus(
      normalizeStatus(item.status),
    );
  }).length;

  absentSubjects.value = recordsToCount.where((item) {
    return isAbsentStatus(
      normalizeStatus(item.status),
    );
  }).length;

  permissionSubjects.value = recordsToCount.where((item) {
    return isPermissionStatus(
      normalizeStatus(item.status),
    );
  }).length;

  debugPrint(
    'PRESENT DAYS: ${presentDays.value}',
  );

  debugPrint(
    'ABSENT DAYS: ${absentDays.value}',
  );

  debugPrint(
    'PERMISSION DAYS: ${permissionDays.value}',
  );

  debugPrint(
    'PRESENT SUBJECTS: ${presentSubjects.value}',
  );

  debugPrint(
    'ABSENT SUBJECTS: ${absentSubjects.value}',
  );

  debugPrint(
    'PERMISSION SUBJECTS: ${permissionSubjects.value}',
  );
}
  String normalizeDate(dynamic value) {
    if (value == null) {
      return '';
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return '';
    }

    final date = DateTime.tryParse(text);

    if (date == null) {
      return text;
    }

    final month = date.month
        .toString()
        .padLeft(2, '0');

    final day = date.day
        .toString()
        .padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  String normalizeStatus(dynamic status) {
    return status
            ?.toString()
            .trim()
            .toLowerCase() ??
        '';
  }

  List<AttendanceModel> get filteredAttendance {
    return attendanceList.where((attendance) {
      final date = DateTime.tryParse(
        attendance.date.toString(),
      );

      if (date == null) {
        return false;
      }

      return date.year == selectedYear.value &&
          date.month == selectedMonth.value;
    }).toList();
  }

  int get totalDays {
    final dates = <String>{};

    for (final attendance in filteredAttendance) {
      final dateKey = normalizeDate(
        attendance.date,
      );

      if (dateKey.isNotEmpty) {
        dates.add(dateKey);
      }
    }

    return dates.length;
  }

  int get totalSubjects {
    return attendanceList.length;
  }

  double get attendanceRate {
    if (totalDays == 0) {
      return 0;
    }

    return presentDays.value /
        totalDays *
        100;
  }

  String get currentMonthName {
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
    final monthIndex = (selectedMonth.value - 1).clamp(0, 11);
    if (Get.locale?.languageCode == 'km') {
      return khmerMonths[monthIndex];
    }
    const englishMonths = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return englishMonths[monthIndex];
  }

  String getStatusText(dynamic status) {
    switch (normalizeStatus(status)) {
      case 'p':
      case 'present':
        return 'attendance_status_present'.tr;

      case 'a':
      case 'absent':
        return 'attendance_status_absent'.tr;

      case 'l':
      case 'leave':
      case 'permission':
      case 'permitted':
        return 'attendance_status_permission'.tr;

      default:
        return 'មិនស្គាល់';
    }
  }

  IconData getStatusIcon(dynamic status) {
    switch (normalizeStatus(status)) {
      case 'p':
      case 'present':
        return Icons.check_circle_outline;

      case 'a':
      case 'absent':
        return Icons.cancel_outlined;

      case 'l':
      case 'leave':
      case 'permission':
      case 'permitted':
        return Icons.event_available_outlined;

      default:
        return Icons.help_outline;
    }
  }

  Color getStatusColor(dynamic status) {
    switch (normalizeStatus(status)) {
      case 'p':
      case 'present':
        return AppColors.success;

      case 'a':
      case 'absent':
        return AppColors.error;

      case 'l':
      case 'leave':
      case 'permission':
      case 'permitted':
        return AppColors.warning;

      default:
        return AppColors.grey;
    }
  }

  String formatDate(dynamic value) {
    if (value == null) {
      return '-';
    }

    final date = DateTime.tryParse(
      value.toString(),
    );

    if (date == null) {
      return value.toString();
    }

    final day = date.day
        .toString()
        .padLeft(2, '0');

    final month = date.month
        .toString()
        .padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  void resetCount() {
    presentDays.value = 0;
    absentDays.value = 0;
    permissionDays.value = 0;

    presentSubjects.value = 0;
    absentSubjects.value = 0;
    permissionSubjects.value = 0;
  }

  Future<void> refreshAttendance() async {
    await getParentAttendance();
  }
}