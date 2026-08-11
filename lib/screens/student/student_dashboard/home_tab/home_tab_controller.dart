part of 'home_tab_view.dart';

class HomeTabViewController extends GetxController {
  var userController = Get.find<UserController>();
  final AttendanceService attendanceService = AttendanceService();
  final ScheduleServices scheduleServices = ScheduleServices();

  final recentAttendance = <AttendanceModel>[].obs;
  final isLoadingAttendance = true.obs;

  final todaySchedules = <ScheduleModel>[].obs;
  final isLoadingSchedule = true.obs;
  final isExpandedSchedule = false.obs;

  void toggleScheduleExpand() {
    isExpandedSchedule.value = !isExpandedSchedule.value;
  }

  List<ScheduleModel> get visibleSchedules {
    if (isExpandedSchedule.value || todaySchedules.length <= 2) {
      return todaySchedules;
    }
    return todaySchedules.take(2).toList();
  }

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

  Worker? _profileWorker;

  @override
  void onInit() {
    super.onInit();
    if (userController.user == null && userController.profile == null) {
      userController.getProfile().then((_) {
        fetchTodaySchedules();
        fetchRecentAttendance();
      });
    }

    _profileWorker = ever(userController.isLoading, (bool loading) {
      if (!loading && (userController.user != null || userController.profile != null)) {
        fetchTodaySchedules();
        fetchRecentAttendance();
      }
    });

    notificationController.loadNotifications();
  }

  @override
  void onClose() {
    _profileWorker?.dispose();
    super.onClose();
  }

  @override
  void onReady() {
    super.onReady();
    fetchRecentAttendance();
    fetchTodaySchedules();
  }

  Future<void> fetchTodaySchedules() async {
    isLoadingSchedule.value = true;
    try {
      if (userController.profile == null && userController.user == null) {
        await userController.getProfile();
      }

      final classId = userController.profile?.classId;
      final schedules = await scheduleServices.fetchSchedules(
        classId: classId != null && classId > 0 ? classId : null,
      );
      final todayFull = _getTodayDayName();
      final todayShort = _getTodayShortDayName();

      var filtered = schedules.where((item) {
        final dayLower = item.day.toLowerCase();
        return dayLower == todayFull.toLowerCase() ||
            dayLower == todayShort.toLowerCase();
      }).toList();

      if (classId != null && classId > 0) {
        filtered = filtered.where((item) => item.classId == classId).toList();
      }

      filtered.sort((a, b) => a.startTime.compareTo(b.startTime));
      todaySchedules.assignAll(filtered);
    } catch (_) {
      todaySchedules.clear();
    } finally {
      isLoadingSchedule.value = false;
    }
  }

  String _getTodayDayName() {
    switch (DateTime.now().weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }

  String _getTodayShortDayName() {
    switch (DateTime.now().weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }

  Map<String, String> parseTimePill(String rawTime) {
    if (rawTime.isEmpty) return {'time': '--:--', 'period': ''};
    try {
      final parts = rawTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? parts[1] : '00';
      final period = hour >= 12 ? 'PM' : 'AM';
      final formattedHour = hour % 12 == 0 ? 12 : hour % 12;
      final timeStr = '${formattedHour.toString().padLeft(2, '0')}:$minute';
      return {'time': timeStr, 'period': period};
    } catch (_) {
      return {'time': rawTime, 'period': ''};
    }
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
      fetchTodaySchedules(),
    ]);
  }
}
