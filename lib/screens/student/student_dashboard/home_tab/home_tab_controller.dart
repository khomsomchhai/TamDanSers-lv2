part of 'home_tab_view.dart';

class HomeTabViewController extends GetxController {
  var userController = Get.find<UserController>();
  final AttendanceService attendanceService = AttendanceService();
  final recentAttendance = <AttendanceModel>[].obs;
  final isLoadingAttendance = true.obs;

  String getKhmerDate() {
    DateTime now = DateTime.now();
    List<String> khmerWeekDays = [
      "ថ្ងៃច័ន្ទ",
      "ថ្ងៃអង្គារ",
      "ថ្ងៃពុធ",
      "ថ្ងៃព្រហស្បតិ៍",
      "ថ្ងៃសុក្រ",
      "ថ្ងៃសៅរ៍",
      "ថ្ងៃអាទិត្យ",
    ];
    List<String> khmerMonths = [
      "មករា",
      "កុម្ភៈ",
      "មីនា",
      "មេសា",
      "ឧសភា",
      "មិថុនា",
      "កក្កដា",
      "សីហា",
      "កញ្ញា",
      "តុលា",
      "វិច្ឆិកា",
      "ធ្នូ",
    ];
    String weekDay = khmerWeekDays[now.weekday - 1];
    String month = khmerMonths[now.month - 1];
    return "$weekDay ទី${now.day} ខែ$month ឆ្នាំ${now.year}";
  }

  String getKhmerMonth() {
    DateTime now = DateTime.now();
    List<String> khmerMonths = [
      "មករា",
      "កុម្ភៈ",
      "មីនា",
      "មេសា",
      "ឧសភា",
      "មិថុនា",
      "កក្កដា",
      "សីហា",
      "កញ្ញា",
      "តុលា",
      "វិច្ឆិកា",
      "ធ្នូ",
    ];
    return khmerMonths[now.month - 1];
  }

  String getCurrentDate() {
    if (Get.locale?.languageCode == 'km') {
      return getKhmerDate();
    }

    return DateFormat(
      'EEEE, d MMMM yyyy',
      'en',
    ).format(DateTime.now());
  }

  final notificationController = Get.isRegistered<NotificationController>()
      ? Get.find<NotificationController>()
      : Get.put(NotificationController());

  @override
  void onInit() {
    super.onInit();
    if (userController.user == null && userController.profile == null) {
      userController.getProfile();
    }
    notificationController.loadNotifications();
  }

  @override
  void onReady() {
    super.onReady();
    fetchRecentAttendance();
  }

  Future<void> fetchRecentAttendance() async {
    isLoadingAttendance.value = true;
    try {
      final result = await attendanceService.getMyAttendance();
      final filtered =
          result.where((item) => !_isPendingApproval(item)).toList();
      recentAttendance.assignAll(filtered.take(3));
    } catch (e) {
      // Retry once on error
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        final result = await attendanceService.getMyAttendance();
        final filtered =
            result.where((item) => !_isPendingApproval(item)).toList();
        recentAttendance.assignAll(filtered.take(3));
      } catch (_) {
        recentAttendance.clear();
      }
    } finally {
      isLoadingAttendance.value = false;
    }
  }

  bool _isPendingApproval(AttendanceModel item) {
    final combined = '${item.status} ${item.remark}'.toLowerCase();
    return combined.contains('pending');
  }

  String mapStatus(String value) {
    switch (value.toUpperCase()) {
      case 'P':
        return 'attendance_status_present'.tr;
      case 'A':
        return 'attendance_status_absent'.tr;
      case 'E':
      case 'EXCUSED':
      case 'PERMISSION':
      case 'PM':
        return 'attendance_status_permission'.tr;
      default:
        return value;
    }
  }

  Color mapStatusColor(String value) {
    switch (value.toUpperCase()) {
      case 'P':
        return AppColors.success;
      case 'A':
        return AppColors.error;
      case 'E':
      case 'EXCUSED':
      case 'PERMISSION':
      case 'PM':
        return AppColors.info;
      default:
        return AppColors.grey;
    }
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

  Future<void> refreshHome() async {
    await Future.wait([
      userController.getProfile(),
      fetchRecentAttendance(),
    ]);
  }
}
