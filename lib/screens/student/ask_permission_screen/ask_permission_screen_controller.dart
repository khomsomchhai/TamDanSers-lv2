part of 'ask_permission_screen_view.dart';

class AskPermissionScreenViewController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final reasonController = TextEditingController();
  final PermissionServices permissionServices = PermissionServices();
  final ScheduleServices scheduleServices = ScheduleServices();
  final userController = Get.find<UserController>();

  final selectedRequestType = 'By Subject'.obs;
  final selectedScheduleId = RxnInt();
  final selectedPermissionType = ''.obs;
  final isLoading = false.obs;
  final isScheduleLoading = false.obs;

  final permissionRequests = <PermissionModel>[].obs;
  final schedules = <ScheduleModel>[].obs;

  final requestTypes = const ['By Subject', 'Full Day'];

  final List<String> permissionTypes = const [
    'Sick',
    'Family',
    'Personal',
    'Other',
  ];

  Worker? _requestTypeWorker;

  bool get isBySubject => selectedRequestType.value == 'By Subject';

  String get requestTypeApiValue => isBySubject ? 'subject' : 'full_day';

  @override
  void onInit() {
    super.onInit();
    fetchTodaySchedules();
    _requestTypeWorker =
        ever<String>(selectedRequestType, _onRequestTypeChanged);
    fetchMyPermissions();
  }

  void _onRequestTypeChanged(String value) {
    if (value == 'By Subject' && schedules.isEmpty) {
      fetchTodaySchedules();
    }

    selectedScheduleId.value = null;
  }

  Future<void> fetchTodaySchedules() async {
    isScheduleLoading.value = true;
    try {
      await _ensureProfileLoaded();
      final classId = userController.profile?.classId;
      final result = await scheduleServices.fetchSchedules(
        classId: classId != null && classId > 0 ? classId : null,
      );
      final today = _todayDayName().toLowerCase();
      var todaySchedules = result
          .where((item) => item.day.trim().toLowerCase() == today)
          .toList();

      if (classId != null && classId > 0) {
        todaySchedules =
            todaySchedules.where((item) => item.classId == classId).toList();
      }

      schedules.assignAll(todaySchedules);
    } catch (_) {
      schedules.clear();
    } finally {
      isScheduleLoading.value = false;
    }
  }

  Future<void> _ensureProfileLoaded() async {
    if (userController.profile == null) {
      await userController.getProfile();
    }
  }

  Future<void> fetchMyPermissions() async {
    try {
      final result = await permissionServices.fetchMyPermissions();
      permissionRequests.assignAll(result);
    } catch (_) {
      permissionRequests.clear();
    }
  }

  Future<void> submitPermission() async {
    if (selectedRequestType.value.trim().isEmpty) {
      CustomSnackbar.error('ask_permission_please_select_request_type'.tr);
      return;
    }

    await Future.wait([
      fetchTodaySchedules(),
      fetchMyPermissions(),
    ]);

    if (!isBySubject && schedules.isEmpty) {
      CustomSnackbar.error('ask_permission_no_schedule_today'.tr);
      return;
    }

    if (_hasRequestedToday()) {
      CustomSnackbar.error('ask_permission_already_requested_today'.tr);
      return;
    }

    if (isBySubject && selectedScheduleId.value == null) {
      CustomSnackbar.error('ask_permission_please_select_subject'.tr);
      return;
    }

    if (selectedPermissionType.value.trim().isEmpty) {
      CustomSnackbar.error('ask_permission_please_select_permission_type'.tr);
      return;
    }

    final reason = reasonController.text.trim();
    if (reason.isEmpty) {
      CustomSnackbar.error('ask_permission_please_enter_reason'.tr);
      return;
    }

    isLoading.value = true;
    try {
      await permissionServices.createPermission(
        requestType: requestTypeApiValue,
        scheduleId: isBySubject ? selectedScheduleId.value : null,
        type: selectedPermissionType.value,
        reason: reason,
      );

      CustomSnackbar.success('ask_permission_submitted'.tr);

      selectedScheduleId.value = null;
      selectedPermissionType.value = '';
      reasonController.clear();

      await fetchMyPermissions();
    } catch (e) {
      String message = 'ask_permission_failed_submit'.tr;
      if (e is DioException) {
        final serverMsg = e.response?.data?['message'] ??
            e.response?.data?['detail'] ??
            e.response?.data?.toString();
        if (serverMsg != null && serverMsg.toString().isNotEmpty) {
          message = serverMsg.toString();
        }
      }
      debugPrint('[submitPermission] error: $e');
      CustomSnackbar.error(message);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _requestTypeWorker?.dispose();
    reasonController.dispose();
    super.onClose();
  }

  String formatCreatedDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) {
      return '-';
    }

    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) {
      return rawDate;
    }

    final year = parsed.year.toString().padLeft(4, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    final day = parsed.day.toString().padLeft(2, '0');
    final hour = parsed.hour.toString().padLeft(2, '0');
    final minute = parsed.minute.toString().padLeft(2, '0');

    return '$year-$month-$day $hour:$minute';
  }

  String scheduleLabel(ScheduleModel item) {
    return '${item.subjectName} - ${item.day} (${item.startTime} - ${item.endTime})';
  }

  String _todayDayName() {
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

  String formatRequestType(String value) {
    switch (value.toLowerCase()) {
      case 'subject':
      case 'by_subject':
        return 'ask_permission_request_type_by_subject'.tr;
      case 'full_day':
        return 'ask_permission_request_type_full_day'.tr;
      default:
        return value;
    }
  }

  String requestTypeLabel(String value) {
    switch (value) {
      case 'By Subject':
        return 'ask_permission_request_type_by_subject'.tr;
      case 'Full Day':
        return 'ask_permission_request_type_full_day'.tr;
      default:
        return value;
    }
  }

  bool _hasRequestedToday() {
    return permissionRequests.any(
      (request) => _isToday(request.createdAt),
    );
  }

  bool _isToday(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) {
      return false;
    }

    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) {
      return false;
    }

    final now = DateTime.now();
    final local = parsed.toLocal();
    return local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
  }
}
