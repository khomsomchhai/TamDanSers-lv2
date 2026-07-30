
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/core/api/services/parent_attendance_service.dart';
import 'package:tamdansers_lv2/data/model/attendance_model.dart';


class ParentAttendanceTabViewController extends GetxController {
  final ParentAttendanceService attendanceService =
      ParentAttendanceService();

  final attendanceList = <AttendanceModel>[].obs;

  final isLoading = false.obs;

  final presentCount = 0.obs;
  final absentCount = 0.obs;
  final permissionCount = 0.obs;

  final selectedMonth = DateTime.now().month.obs;
  final selectedYear = DateTime.now().year.obs;

  int? studentId;

  final Map<int, String> khmerMonths = {
    1: 'មករា',
    2: 'កុម្ភៈ',
    3: 'មីនា',
    4: 'មេសា',
    5: 'ឧសភា',
    6: 'មិថុនា',
    7: 'កក្កដា',
    8: 'សីហា',
    9: 'កញ្ញា',
    10: 'តុលា',
    11: 'វិច្ឆិកា',
    12: 'ធ្នូ',
  };

  @override
  void onInit() {
    super.onInit();

    _getStudentId();

    if (studentId != null) {
      getParentAttendance();
    } else {
      debugPrint('PARENT ATTENDANCE: Student ID is null');
    }
  }

  void _getStudentId() {
    final arguments = Get.arguments;

    if (arguments is Map) {
      studentId = int.tryParse(
        arguments['student_id']?.toString() ??
            arguments['studentId']?.toString() ??
            '',
      );
    } else if (arguments is int) {
      studentId = arguments;
    } else if (arguments is String) {
      studentId = int.tryParse(arguments);
    }

    // សម្រាប់សាកល្បងបណ្ដោះអាសន្ន
    studentId ??= 6;
  }

  Future<void> getParentAttendance() async {
    if (studentId == null) {
      return;
    }

    try {
      isLoading.value = true;

      final result = await attendanceService.getChildAttendance(
        studentId: studentId!,
      );

      attendanceList.assignAll(result);

      countAttendance();
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

  List<AttendanceModel> get filteredAttendance {
    return attendanceList.where((attendance) {
      final parsedDate = DateTime.tryParse(
        attendance.date?.toString() ?? '',
      );

      if (parsedDate == null) {
        return false;
      }

      return parsedDate.month == selectedMonth.value &&
          parsedDate.year == selectedYear.value;
    }).toList();
  }

  void countAttendance() {
    final monthlyList = filteredAttendance;

    presentCount.value = monthlyList.where((attendance) {
      final status = normalizeStatus(attendance.status);

      return status == 'p' || status == 'present';
    }).length;

    absentCount.value = monthlyList.where((attendance) {
      final status = normalizeStatus(attendance.status);

      return status == 'a' || status == 'absent';
    }).length;

    permissionCount.value = monthlyList.where((attendance) {
      final status = normalizeStatus(attendance.status);

      return status == 'l' ||
          status == 'leave' ||
          status == 'permission' ||
          status == 'permitted';
    }).length;
  }

  int get totalDays {
    return presentCount.value +
        absentCount.value +
        permissionCount.value;
  }

  double get attendanceRate {
    final total = totalDays;

    if (total == 0) {
      return 0;
    }

    return presentCount.value / total * 100;
  }

  String get currentMonthName {
    return khmerMonths[selectedMonth.value] ?? '';
  }

  String normalizeStatus(dynamic status) {
    return status?.toString().trim().toLowerCase() ?? '';
  }

  String getStatusText(dynamic status) {
    switch (normalizeStatus(status)) {
      case 'p':
      case 'present':
        return 'វត្តមាន';

      case 'a':
      case 'absent':
        return 'អវត្តមាន';

      case 'l':
      case 'leave':
      case 'permission':
      case 'permitted':
        return 'សុំច្បាប់';

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
        return Colors.orange;

      default:
        return Colors.grey;
    }
  }

  String formatDate(dynamic value) {
    if (value == null) {
      return '-';
    }

    final date = DateTime.tryParse(value.toString());

    if (date == null) {
      return value.toString();
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  void resetCount() {
    presentCount.value = 0;
    absentCount.value = 0;
    permissionCount.value = 0;
  }

  Future<void> refreshAttendance() async {
    await getParentAttendance();
  }
}