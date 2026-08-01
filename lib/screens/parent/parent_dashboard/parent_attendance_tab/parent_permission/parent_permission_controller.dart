part of 'parent_permission_view.dart';

class ParentPermissionController
    extends GetxController {
  final PermissionServices
      permissionServices =
      PermissionServices();

  final ParentHomeTabViewController
      parentHomeController =
      Get.find<
          ParentHomeTabViewController>();

  final GlobalKey<FormState>
      formKey =
      GlobalKey<FormState>();

  final TextEditingController
      reasonController =
      TextEditingController();

  final isLoading = false.obs;
  final isSubmitting = false.obs;

  final permissionRequests =
      <PermissionModel>[].obs;

  final schedules =
      <Map<String, dynamic>>[].obs;

  final requestTypes = [
    'full_day',
    'subject',
  ];

  final permissionTypes = [
    'Sick',
    'Personal',
    'Family',
    'Other',
  ];

  final selectedRequestType =
      'full_day'.obs;

  final selectedPermissionType =
      'Sick'.obs;

  final selectedScheduleId =
      RxnInt();

  bool get isBySubject =>
      selectedRequestType.value ==
      'subject';

  String get childName =>
      parentHomeController.childName;

  String get childCode =>
      parentHomeController.childCode;

  int? get selectedStudentId {
    final value =
        parentHomeController
            .selectedChild
            .value?['id'];

    return parseId(value);
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  int? parseId(
    dynamic value,
  ) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
      value?.toString() ?? '',
    );
  }

  Future<void> loadData() async {
    final studentId =
        selectedStudentId;

    if (studentId == null) {
      permissionRequests.clear();
      schedules.clear();

      Get.snackbar(
        'error'.tr,
        'ask_permission_student_not_found'
            .tr,
        snackPosition:
            SnackPosition.BOTTOM,
      );

      return;
    }

    try {
      isLoading.value = true;

      final results =
          await Future.wait([
        permissionServices
            .fetchParentPermissions(
          studentId: studentId,
        ),
        permissionServices
            .fetchParentSchedules(
          studentId: studentId,
        ),
      ]);

      final permissions =
          results[0]
              as List<PermissionModel>;

      final scheduleData =
          results[1]
              as List<
                  Map<String, dynamic>>;

      permissionRequests.assignAll(
        permissions,
      );

      schedules.assignAll(
        scheduleData,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'LOAD PARENT PERMISSION ERROR: '
        '$error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      Get.snackbar(
        'error'.tr,
        'ask_permission_failed_load'.tr,
        snackPosition:
            SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void changeRequestType(
    String value,
  ) {
    selectedRequestType.value =
        value;

    if (value == 'full_day') {
      selectedScheduleId.value =
          null;
    }
  }

  Future<void>
      submitPermission() async {
    final studentId =
        selectedStudentId;

    if (studentId == null) {
      Get.snackbar(
        'error'.tr,
        'ask_permission_student_not_found'
            .tr,
        snackPosition:
            SnackPosition.BOTTOM,
      );

      return;
    }

    final reason =
        reasonController.text
            .trim();

    if (selectedRequestType
        .value.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'ask_permission_please_select_request_type'
            .tr,
        snackPosition:
            SnackPosition.BOTTOM,
      );

      return;
    }

    if (isBySubject &&
        selectedScheduleId.value ==
            null) {
      Get.snackbar(
        'error'.tr,
        'ask_permission_please_select_subject'
            .tr,
        snackPosition:
            SnackPosition.BOTTOM,
      );

      return;
    }

    if (selectedPermissionType
        .value.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'ask_permission_please_select_permission_type'
            .tr,
        snackPosition:
            SnackPosition.BOTTOM,
      );

      return;
    }

    if (reason.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'ask_permission_please_enter_reason'
            .tr,
        snackPosition:
            SnackPosition.BOTTOM,
      );

      return;
    }

    try {
      isSubmitting.value = true;

      await permissionServices
          .createParentPermission(
        studentId: studentId,
        requestType:
            selectedRequestType
                .value,
        scheduleId:
            selectedRequestType
                        .value ==
                    'subject'
                ? selectedScheduleId
                    .value
                : null,
        type:
            selectedPermissionType
                .value,
        reason: reason,
      );

      reasonController.clear();

      selectedRequestType.value =
          'full_day';

      selectedPermissionType.value =
          'Sick';

      selectedScheduleId.value =
          null;

      await loadData();

      Get.snackbar(
        'success'.tr,
        'ask_permission_submitted'.tr,
        snackPosition:
            SnackPosition.BOTTOM,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'CREATE PARENT PERMISSION ERROR: '
        '$error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      final errorText =
          error.toString().toLowerCase();

      String message =
          'ask_permission_failed_submit'
              .tr;

      if (errorText.contains(
        'already requested',
      )) {
        message =
            'ask_permission_already_requested_today'
                .tr;
      } else if (errorText.contains(
            'no schedule',
          ) ||
          errorText.contains(
            'schedule not found',
          )) {
        message =
            'ask_permission_no_schedule_today'
                .tr;
      }

      Get.snackbar(
        'error'.tr,
        message,
        snackPosition:
            SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  String requestTypeLabel(
    String type,
  ) {
    switch (type.toLowerCase()) {
      case 'full_day':
        return 'ask_permission_request_type_full_day'
            .tr;

      case 'subject':
        return 'ask_permission_request_type_by_subject'
            .tr;

      default:
        return type;
    }
  }

  String formatRequestType(
    String type,
  ) {
    return requestTypeLabel(
      type,
    );
  }

  String permissionTypeLabel(
    String type,
  ) {
    switch (type.toLowerCase()) {
      case 'sick':
        return 'ask_permission_type_sick'
            .tr;

      case 'personal':
        return 'ask_permission_type_personal'
            .tr;

      case 'family':
        return 'ask_permission_type_family'
            .tr;

      case 'other':
        return 'ask_permission_type_other'
            .tr;

      default:
        return type;
    }
  }

  String scheduleLabel(
    Map<String, dynamic> item,
  ) {
    final subject =
        item['subject_name']
                ?.toString() ??
            '-';

    final start =
        _formatTime(
      item['start_time']
              ?.toString() ??
          '',
    );

    final end =
        _formatTime(
      item['end_time']
              ?.toString() ??
          '',
    );

    if (start.isEmpty &&
        end.isEmpty) {
      return subject;
    }

    if (start.isEmpty) {
      return '$subject ($end)';
    }

    if (end.isEmpty) {
      return '$subject ($start)';
    }

    return '$subject ($start - $end)';
  }

  String _formatTime(
    String value,
  ) {
    final text =
        value.trim();

    if (text.isEmpty) {
      return '';
    }

    final parts =
        text.split(':');

    if (parts.length < 2) {
      return text;
    }

    return '${parts[0]}:${parts[1]}';
  }

  String formatCreatedDate(
    dynamic value,
  ) {
    if (value == null) {
      return '-';
    }

    final date =
        DateTime.tryParse(
      value.toString(),
    );

    if (date == null) {
      return value.toString();
    }

    final day =
        date.day
            .toString()
            .padLeft(
              2,
              '0',
            );

    final month =
        date.month
            .toString()
            .padLeft(
              2,
              '0',
            );

    return '$day/$month/${date.year}';
  }

  Color statusColor(
    String status,
  ) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(
          0xFFF59E0B,
        );

      case 'approved':
        return const Color(
          0xFF22C55E,
        );

      case 'rejected':
        return const Color(
          0xFFEF4444,
        );

      default:
        return const Color(
          0xFF6B7280,
        );
    }
  }

  String statusLabel(
    String status,
  ) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'ask_permission_status_pending'
            .tr;

      case 'approved':
        return 'ask_permission_status_approved'
            .tr;

      case 'rejected':
        return 'ask_permission_status_rejected'
            .tr;

      default:
        return status;
    }
  }

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }
}