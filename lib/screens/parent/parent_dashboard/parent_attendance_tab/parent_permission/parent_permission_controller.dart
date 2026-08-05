part of 'parent_permission_view.dart';

class ParentPermissionController
    extends GetxController {
  final PermissionServices permissionServices =
      PermissionServices();

  final ParentHomeTabViewController
      parentHomeController =
      Get.find<
          ParentHomeTabViewController>();

  final GlobalKey<FormState> formKey =
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

  final editingPermission =
      Rxn<PermissionModel>();

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

  bool get isEditing =>
      editingPermission.value != null;

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

      _showError(
        'ask_permission_student_not_found'
            .tr,
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

      permissionRequests.assignAll(
        results[0]
            as List<PermissionModel>,
      );

      schedules.assignAll(
        results[1]
            as List<Map<String, dynamic>>,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'LOAD PARENT PERMISSION ERROR: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      _showError(
        'ask_permission_failed_load'.tr,
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
      selectedScheduleId.value = null;
    }
  }

  Future<void> submitPermission() async {
    if (isSubmitting.value) {
      return;
    }

    final studentId =
        selectedStudentId;

    if (studentId == null) {
      _showError(
        'ask_permission_student_not_found'
            .tr,
      );
      return;
    }

    if (selectedRequestType.value
        .trim()
        .isEmpty) {
      _showError(
        'ask_permission_please_select_request_type'
            .tr,
      );
      return;
    }

    if (isBySubject &&
        selectedScheduleId.value == null) {
      _showError(
        'ask_permission_please_select_subject'
            .tr,
      );
      return;
    }

    if (selectedPermissionType.value
        .trim()
        .isEmpty) {
      _showError(
        'ask_permission_please_select_permission_type'
            .tr,
      );
      return;
    }

    final reason =
        reasonController.text.trim();

    if (reason.isEmpty) {
      _showError(
        'ask_permission_please_enter_reason'
            .tr,
      );
      return;
    }

    try {
      isSubmitting.value = true;

      final editing =
          editingPermission.value;

      if (editing == null) {
        if (_hasDuplicateRequestToday()) {
          _showError(
            'ask_permission_already_requested_today'
                .tr,
          );
          return;
        }

        await permissionServices
            .createParentPermission(
          studentId: studentId,
          requestType:
              selectedRequestType.value,
          scheduleId:
              isBySubject
                  ? selectedScheduleId.value
                  : null,
          type:
              selectedPermissionType.value,
          reason: reason,
        );

        _showSuccess(
          'ask_permission_submitted'.tr,
        );
      } else {
        if (!editing.canEdit ||
            editing.attendanceSaved) {
          _showError(
            'permission_attendance_locked'.tr,
          );
          return;
        }

        await permissionServices
            .updatePermission(
          permissionId: editing.id,
          requestType:
              selectedRequestType.value,
          scheduleId:
              isBySubject
                  ? selectedScheduleId.value
                  : null,
          type:
              selectedPermissionType.value,
          reason: reason,
        );

        _showSuccess(
          'permission_updated'.tr,
        );
      }

      clearForm();

      await loadData();
    } catch (error, stackTrace) {
      debugPrint(
        'SUBMIT PARENT PERMISSION ERROR: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      _showError(
        _extractErrorMessage(
          error,
          fallbackKey:
              'ask_permission_failed_submit',
        ),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void startEditPermission(
    PermissionModel permission,
  ) {
    if (!permission.canEdit ||
        permission.attendanceSaved) {
      _showError(
        'permission_attendance_locked'.tr,
      );
      return;
    }

    editingPermission.value =
        permission;

    selectedRequestType.value =
        permission.requestType ==
                'subject'
            ? 'subject'
            : 'full_day';

    selectedPermissionType.value =
        permission.type;

    reasonController.text =
        permission.reason;

    Future.microtask(() {
      selectedScheduleId.value =
          permission.scheduleId;
    });
  }

  void cancelEditPermission() {
    clearForm();
  }

  void clearForm() {
    editingPermission.value = null;

    selectedRequestType.value =
        'full_day';

    selectedPermissionType.value =
        'Sick';

    selectedScheduleId.value = null;

    reasonController.clear();

    formKey.currentState?.reset();
  }

Future<void> confirmDeletePermission(
  PermissionModel permission,
) async {
  if (!permission.canDelete ||
      permission.attendanceSaved) {
    CustomSnackbar.error(
      'permission_attendance_locked'.tr,
    );
    return;
  }

  final confirmed = await Get.dialog<bool>(
    Dialog(
      backgroundColor: AppColors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 28,
      ),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          maxWidth: 380,
        ),
        padding: const EdgeInsets.fromLTRB(
          20,
          22,
          20,
          18,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.dark.withValues(
                alpha: 0.12,
              ),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'permission_delete_title'.tr,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.dark,
                fontSize: 18,
                height: 1.35,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'permission_delete_message'.tr,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.hintColor,
                fontSize: 13,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.back(result: false);
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(
                        double.infinity,
                        46,
                      ),
                      foregroundColor:
                          AppColors.hintColor,
                      side: const BorderSide(
                        color: AppColors.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(13),
                      ),
                    ),
                    child: Text(
                      'cancel'.tr,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back(result: true);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(
                        double.infinity,
                        46,
                      ),
                      elevation: 0,
                      backgroundColor:
                          AppColors.error,
                      foregroundColor:
                          AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(13),
                      ),
                    ),
                    child: Text(
                      'delete'.tr,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: false,
  );

  if (confirmed != true) {
    return;
  }

  await deletePermission(
    permission,
  );
}
  Future<void> deletePermission(
    PermissionModel permission,
  ) async {
    try {
      isLoading.value = true;

      await permissionServices
          .deletePermission(
        permissionId:
            permission.id,
      );

      permissionRequests.removeWhere(
        (item) =>
            item.id == permission.id,
      );

      if (editingPermission.value?.id ==
          permission.id) {
        clearForm();
      }

      _showSuccess(
        'permission_deleted'.tr,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'DELETE PARENT PERMISSION ERROR: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      _showError(
        _extractErrorMessage(
          error,
          fallbackKey:
              'permission_delete_failed',
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _hasDuplicateRequestToday() {
    return permissionRequests.any(
      (request) {
        if (!_isToday(
          request.createdAt,
        )) {
          return false;
        }

        if (selectedRequestType.value ==
            'full_day') {
          return request.requestType ==
              'full_day';
        }

        return request.requestType ==
                'subject' &&
            request.scheduleId ==
                selectedScheduleId.value;
      },
    );
  }

  bool _isToday(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return false;
    }

    final parsed =
        DateTime.tryParse(value);

    if (parsed == null) {
      return false;
    }

    final now = DateTime.now();
    final local = parsed.toLocal();

    return local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
  }

  String _extractErrorMessage(
    dynamic error, {
    required String fallbackKey,
  }) {
    if (error is DioException) {
      final data =
          error.response?.data;

      if (data is Map) {
        final message =
            data['detail'] ??
                data['message'];

        if (message != null &&
            message
                .toString()
                .trim()
                .isNotEmpty) {
          return message.toString();
        }
      }
    }

    final text =
        error.toString();

    if (text
        .toLowerCase()
        .contains('already requested')) {
      return 'ask_permission_already_requested_today'
          .tr;
    }

    return fallbackKey.tr;
  }

  void _showError(
    String message,
  ) {
    Get.snackbar(
      'error'.tr,
      message,
      snackPosition:
          SnackPosition.BOTTOM,
    );
  }

  void _showSuccess(
    String message,
  ) {
    Get.snackbar(
      'success'.tr,
      message,
      snackPosition:
          SnackPosition.BOTTOM,
    );
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
    return requestTypeLabel(type);
  }

  String permissionTypeLabel(
    String type,
  ) {
    switch (type.toLowerCase()) {
      case 'sick':
        return 'ask_permission_type_sick'.tr;

      case 'personal':
        return 'ask_permission_type_personal'.tr;

      case 'family':
        return 'ask_permission_type_family'.tr;

      case 'other':
        return 'ask_permission_type_other'.tr;

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

    final start = _formatTime(
      item['start_time']
              ?.toString() ??
          '',
    );

    final end = _formatTime(
      item['end_time']
              ?.toString() ??
          '',
    );

    if (start.isEmpty &&
        end.isEmpty) {
      return subject;
    }

    return '$subject ($start - $end)';
  }

  String _formatTime(
    String value,
  ) {
    final text = value.trim();

    if (text.isEmpty) {
      return '';
    }

    final parts = text.split(':');

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

    final local = date.toLocal();

    final day = local.day
        .toString()
        .padLeft(2, '0');

    final month = local.month
        .toString()
        .padLeft(2, '0');

    return '$day/$month/${local.year}';
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