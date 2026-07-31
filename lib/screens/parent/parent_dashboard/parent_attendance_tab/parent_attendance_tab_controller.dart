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

  void countAttendance() {
    /*
      API example:
      date: 2026-07-30, status: P, subject_id: 1
      date: 2026-07-30, status: P, subject_id: 2

      Result:
      presentSubjects = 2
      presentDays = 1
    */

    final presentRecords = attendanceList.where((item) {
      final status = normalizeStatus(item.status);

      return status == 'p' ||
          status == 'present';
    }).toList();

    final absentRecords = attendanceList.where((item) {
      final status = normalizeStatus(item.status);

      return status == 'a' ||
          status == 'absent';
    }).toList();

    final permissionRecords =
        attendanceList.where((item) {
      final status = normalizeStatus(item.status);

      return status == 'l' ||
          status == 'leave' ||
          status == 'permission' ||
          status == 'permitted';
    }).toList();

    // ចំនួន records / subjects
    presentSubjects.value =
        presentRecords.length;

    absentSubjects.value =
        absentRecords.length;

    permissionSubjects.value =
        permissionRecords.length;

    // ចំនួនថ្ងៃមិនស្ទួន
    presentDays.value =
        _countUniqueDates(presentRecords);

    absentDays.value =
        _countUniqueDates(absentRecords);

    permissionDays.value =
        _countUniqueDates(permissionRecords);
  }

  int _countUniqueDates(
    List<AttendanceModel> records,
  ) {
    final dates = <String>{};

    for (final attendance in records) {
      final dateKey = normalizeDate(
        attendance.date,
      );

      if (dateKey.isNotEmpty) {
        dates.add(dateKey);
      }
    }

    return dates.length;
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
    final now = DateTime.now();

    return attendanceList.where((attendance) {
      final date = DateTime.tryParse(
        attendance.date?.toString() ?? '',
      );

      if (date == null) {
        return false;
      }

      return date.year == now.year &&
          date.month == now.month;
    }).toList();
  }

  int get totalDays {
    final dates = <String>{};

    for (final attendance in attendanceList) {
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
  return 'month_${DateTime.now().month}';
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