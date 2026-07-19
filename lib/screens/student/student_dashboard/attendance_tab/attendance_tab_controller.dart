part of 'attendance_tab_view.dart';

class AttendanceTabViewController extends GetxController {
  final AttendanceService attendanceService = AttendanceService();

  final isLoading = false.obs;
  final attendanceList = <AttendanceModel>[].obs;
  final selectedDate = Rxn<DateTime>();

  List<AttendanceModel> get displayedAttendance {
    if (selectedDate.value == null) {
      return attendanceList;
    }

    return attendanceList.where((item) {
      final parsed = DateTime.tryParse(item.date);
      if (parsed == null) {
        return false;
      }

      return parsed.year == selectedDate.value!.year &&
          parsed.month == selectedDate.value!.month &&
          parsed.day == selectedDate.value!.day;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchAttendance();
  }

  Future<void> fetchAttendance() async {
    isLoading.value = true;
    try {
      final result = await attendanceService.getMyAttendance();
      attendanceList.assignAll(result);
    } catch (_) {
      CustomSnackbar.error('attendance_failed_load'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
    );

    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  void clearDateFilter() {
    selectedDate.value = null;
  }

  String formatDate(String rawDate) {
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) {
      return rawDate;
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${parsed.day.toString().padLeft(2, '0')} ${months[parsed.month - 1]} ${parsed.year}';
  }

  String formatTimeRange(String start, String end) {
    return '${_timeOnly(start)} - ${_timeOnly(end)}';
  }

  String mapStatus(String value) {
    switch (value.toUpperCase()) {
      case 'P':
        return 'attendance_status_present'.tr;
      case 'A':
        return 'attendance_status_absent'.tr;
      case 'L':
        return 'attendance_status_late'.tr;
      default:
        return value;
    }
  }

  Color statusColor(String value) {
    switch (value.toUpperCase()) {
      case 'P':
        return AppColors.success;
      case 'A':
        return AppColors.error;
      case 'L':
        return AppColors.warning;
      default:
        return AppColors.grey;
    }
  }

  String _timeOnly(String raw) {
    if (raw.isEmpty) {
      return raw;
    }

    final chunks = raw.split(':');
    if (chunks.length < 2) {
      return raw;
    }

    return '${chunks[0].padLeft(2, '0')}:${chunks[1].padLeft(2, '0')}';
  }
}
