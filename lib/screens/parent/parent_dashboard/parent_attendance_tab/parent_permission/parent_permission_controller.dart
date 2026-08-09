part of 'parent_permission_view.dart';

class ParentPermissionController extends GetxController {
  // =====================================================
  // DEPENDENCIES
  // =====================================================

  final PermissionServices permissionServices = PermissionServices();

  final ParentHomeTabViewController parentHomeController =
      Get.find<ParentHomeTabViewController>();

  // =====================================================
  // FORM
  // =====================================================

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController reasonController = TextEditingController();

  // =====================================================
  // LOADING STATES
  // =====================================================

  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final isDeleting = false.obs;

  // =====================================================
  // DATA
  // =====================================================

  final permissionRequests = <PermissionModel>[].obs;

  final schedules = <Map<String, dynamic>>[].obs;

  final editingPermission = Rxn<PermissionModel>();

  // =====================================================
  // REQUEST OPTIONS
  // =====================================================

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

  // =====================================================
  // MON - SAT DAY FILTER
  // =====================================================

  final days = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  final selectedDay = 'Mon'.obs;

  // =====================================================
  // SELECTED VALUES
  // =====================================================

  final selectedRequestType = 'full_day'.obs;

  final selectedPermissionType = 'Sick'.obs;

  final selectedScheduleId = RxnInt();

  // =====================================================
  // GETTERS
  // =====================================================

  bool get isBySubject => selectedRequestType.value == 'subject';

  bool get isEditing => editingPermission.value != null;

  String get childName => parentHomeController.childName;

  String get childCode => parentHomeController.childCode;

  int? get selectedStudentId {
    final value = parentHomeController.selectedChild.value?['id'];

    return parseId(value);
  }

  // =====================================================
  // INIT
  // =====================================================

  @override
  void onInit() {
    super.onInit();

    // Default selected day = current day
    final now = DateTime.now();

    // Monday = 1
    // Tuesday = 2
    // ...
    // Saturday = 6
    if (now.weekday >= 1 && now.weekday <= 6) {
      selectedDay.value = days[now.weekday - 1];
    } else {
      // Sunday
      selectedDay.value = 'Mon';
    }

    loadData();
  }

  // =====================================================
  // PARSE ID
  // =====================================================

  int? parseId(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(
      value.toString().trim(),
    );
  }

  // =====================================================
  // FILTER SCHEDULES BY DAY
  // =====================================================

  List<Map<String, dynamic>> get filteredSchedules {
    final day = selectedDay.value.trim();

    if (day.isEmpty) {
      return schedules.toList();
    }

    return schedules
        .where(
          (item) => _matchesDay(item, day),
        )
        .toList();
  }

  // =====================================================
  // MATCH SCHEDULE DAY
  // =====================================================

  bool _matchesDay(
    Map<String, dynamic> item,
    String targetDay,
  ) {
    final rawValue = item['day'] ?? item['day_name'] ?? item['day_of_week'];

    final rawDay = rawValue?.toString().trim().toLowerCase() ?? '';

    if (rawDay.isEmpty) {
      return false;
    }

    final target = targetDay.trim().toLowerCase();

    switch (target) {
      // -------------------------------------------------
      // MONDAY
      // -------------------------------------------------
      case 'mon':
      case 'monday':
        return rawDay.contains('mon') ||
            rawDay.contains('ច័ន្ទ') ||
            rawDay.contains('ចន្ទ') ||
            rawDay == '1';

      // -------------------------------------------------
      // TUESDAY
      // -------------------------------------------------
      case 'tue':
      case 'tuesday':
        return rawDay.contains('tue') ||
            rawDay.contains('អង្គារ') ||
            rawDay == '2';

      // -------------------------------------------------
      // WEDNESDAY
      // -------------------------------------------------
      case 'wed':
      case 'wednesday':
        return rawDay.contains('wed') ||
            rawDay.contains('ពុធ') ||
            rawDay == '3';

      // -------------------------------------------------
      // THURSDAY
      // -------------------------------------------------
      case 'thu':
      case 'thursday':
        return rawDay.contains('thu') ||
            rawDay.contains('ព្រហស្បតិ៍') ||
            rawDay.contains('ព្រហស្បតិ៍') ||
            rawDay == '4';

      // -------------------------------------------------
      // FRIDAY
      // -------------------------------------------------
      case 'fri':
      case 'friday':
        return rawDay.contains('fri') ||
            rawDay.contains('សុក្រ') ||
            rawDay == '5';

      // -------------------------------------------------
      // SATURDAY
      // -------------------------------------------------
      case 'sat':
      case 'saturday':
        return rawDay.contains('sat') ||
            rawDay.contains('សៅរ៍') ||
            rawDay == '6';

      default:
        return false;
    }
  }

  // =====================================================
  // FETCH DATA
  // =====================================================

  Future<void> loadData() async {
    final studentId = selectedStudentId;

    if (studentId == null) {
      permissionRequests.clear();
      schedules.clear();

      _showError(
        'ask_permission_student_not_found'.tr,
      );

      return;
    }

    try {
      isLoading.value = true;

      // -------------------------------------------------
      // FETCH PERMISSION REQUESTS
      // -------------------------------------------------

      final fetchedPermissions =
          await permissionServices.fetchParentPermissions(
        studentId: studentId,
      );

      // -------------------------------------------------
      // FETCH SCHEDULES
      // -------------------------------------------------

      final fetchedSchedules = await permissionServices.fetchParentSchedules(
        studentId: studentId,
      );

      // -------------------------------------------------
      // UPDATE OBSERVABLES
      // -------------------------------------------------

      permissionRequests.assignAll(
        fetchedPermissions,
      );

      schedules.assignAll(
        fetchedSchedules,
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

  // =====================================================
  // CHANGE REQUEST TYPE
  // =====================================================

  void changeRequestType(String value) {
    selectedRequestType.value = value;

    if (value == 'full_day') {
      selectedScheduleId.value = null;
    }
  }

  // =====================================================
  // SUBMIT CREATE / UPDATE REQUEST
  // =====================================================

  Future<void> submitPermission() async {
    if (isSubmitting.value) {
      return;
    }

    final studentId = selectedStudentId;

    // -------------------------------------------------
    // STUDENT CHECK
    // -------------------------------------------------

    if (studentId == null) {
      _showError(
        'ask_permission_student_not_found'.tr,
      );

      return;
    }

    // -------------------------------------------------
    // REQUEST TYPE CHECK
    // -------------------------------------------------

    if (selectedRequestType.value.trim().isEmpty) {
      _showError(
        'ask_permission_please_select_request_type'.tr,
      );

      return;
    }

    // -------------------------------------------------
    // SUBJECT CHECK
    // -------------------------------------------------

    if (isBySubject && selectedScheduleId.value == null) {
      _showError(
        'ask_permission_please_select_subject'.tr,
      );

      return;
    }

    // -------------------------------------------------
    // PERMISSION TYPE CHECK
    // -------------------------------------------------

    if (selectedPermissionType.value.trim().isEmpty) {
      _showError(
        'ask_permission_please_select_permission_type'.tr,
      );

      return;
    }

    // -------------------------------------------------
    // REASON CHECK
    // -------------------------------------------------

    final reason = reasonController.text.trim();

    if (reason.isEmpty) {
      _showError(
        'ask_permission_please_enter_reason'.tr,
      );

      return;
    }

    try {
      isSubmitting.value = true;

      final editing = editingPermission.value;

      // =================================================
      // CREATE
      // =================================================

      if (editing == null) {
        // -----------------------------------------------
        // DUPLICATE CHECK
        // -----------------------------------------------

        if (_hasDuplicateRequestToday()) {
          _showError(
            'ask_permission_already_requested_today'.tr,
          );

          return;
        }

        // -----------------------------------------------
        // CREATE API
        // -----------------------------------------------

        await permissionServices.createParentPermission(
          studentId: studentId,
          requestType: selectedRequestType.value,
          scheduleId: isBySubject ? selectedScheduleId.value : null,
          type: selectedPermissionType.value,
          reason: reason,
        );

        _showSuccess(
          'ask_permission_submitted'.tr,
        );
      }

      // =================================================
      // UPDATE
      // =================================================

      else {
        // -----------------------------------------------
        // ATTENDANCE LOCK CHECK
        // -----------------------------------------------

        if (!editing.canEdit || editing.attendanceSaved) {
          _showError(
            'permission_attendance_locked'.tr,
          );

          return;
        }

        // -----------------------------------------------
        // UPDATE API
        // -----------------------------------------------

        await permissionServices.updatePermission(
          permissionId: editing.id,
          requestType: selectedRequestType.value,
          scheduleId: isBySubject ? selectedScheduleId.value : null,
          type: selectedPermissionType.value,
          reason: reason,
        );

        _showSuccess(
          'permission_updated'.tr,
        );
      }

      // -------------------------------------------------
      // RESET FORM
      // -------------------------------------------------

      clearForm();

      // -------------------------------------------------
      // REFRESH DATA
      // -------------------------------------------------

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
          fallbackKey: 'ask_permission_failed_submit',
        ),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  // =====================================================
  // START EDIT
  // =====================================================

  void startEditPermission(
    PermissionModel permission,
  ) {
    if (!permission.canEdit || permission.attendanceSaved) {
      _showError(
        'permission_attendance_locked'.tr,
      );

      return;
    }

    editingPermission.value = permission;

    // -------------------------------------------------
    // REQUEST TYPE
    // -------------------------------------------------

    selectedRequestType.value =
        permission.requestType == 'subject' ? 'subject' : 'full_day';

    // -------------------------------------------------
    // PERMISSION TYPE
    // -------------------------------------------------

    final matchedType = permissionTypes.firstWhere(
      (type) => type.toLowerCase() == permission.type.trim().toLowerCase(),
      orElse: () => 'Sick',
    );

    selectedPermissionType.value = matchedType;

    // -------------------------------------------------
    // SCHEDULE
    // -------------------------------------------------

    selectedScheduleId.value = permission.scheduleId;

    // -------------------------------------------------
    // REASON
    // -------------------------------------------------

    reasonController.text = permission.reason;

    // -------------------------------------------------
    // SELECT DAY FROM PERMISSION SCHEDULE
    // -------------------------------------------------

    if (permission.scheduleId != null) {
      final matchedSchedule = schedules.firstWhereOrNull(
        (item) => parseId(item['id']) == permission.scheduleId,
      );

      if (matchedSchedule != null) {
        final scheduleDay = matchedSchedule['day'] ??
            matchedSchedule['day_name'] ??
            matchedSchedule['day_of_week'];

        final normalizedDay = _normalizeDay(scheduleDay);

        if (normalizedDay != null) {
          selectedDay.value = normalizedDay;
        }
      }
    }
  }

  // =====================================================
  // NORMALIZE DAY
  // =====================================================

  String? _normalizeDay(dynamic value) {
    if (value == null) {
      return null;
    }

    final day = value.toString().trim().toLowerCase();

    if (day.isEmpty) {
      return null;
    }

    if (day == '1' ||
        day.contains('mon') ||
        day.contains('ច័ន្ទ') ||
        day.contains('ចន្ទ')) {
      return 'Mon';
    }

    if (day == '2' || day.contains('tue') || day.contains('អង្គារ')) {
      return 'Tue';
    }

    if (day == '3' || day.contains('wed') || day.contains('ពុធ')) {
      return 'Wed';
    }

    if (day == '4' || day.contains('thu') || day.contains('ព្រហស្បតិ៍')) {
      return 'Thu';
    }

    if (day == '5' || day.contains('fri') || day.contains('សុក្រ')) {
      return 'Fri';
    }

    if (day == '6' || day.contains('sat') || day.contains('សៅរ៍')) {
      return 'Sat';
    }

    return null;
  }

  // =====================================================
  // CANCEL EDIT
  // =====================================================

  void cancelEditPermission() {
    clearForm();
  }

  // =====================================================
  // CLEAR FORM
  // =====================================================

  void clearForm() {
    editingPermission.value = null;

    selectedRequestType.value = 'full_day';

    selectedPermissionType.value = 'Sick';

    selectedScheduleId.value = null;

    reasonController.clear();

    formKey.currentState?.reset();
  }

  // =====================================================
  // DELETE CONFIRMATION
  // =====================================================

  Future<void> confirmDeletePermission(
    PermissionModel permission,
  ) async {
    if (!permission.canDelete || permission.attendanceSaved) {
      _showError(
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
                color: AppColors.dark.withValues(alpha: 0.12),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // -----------------------------------------
              // DELETE ICON
              // -----------------------------------------

              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 30,
                ),
              ),

              const SizedBox(height: 16),

              // -----------------------------------------
              // TITLE
              // -----------------------------------------

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

              // -----------------------------------------
              // MESSAGE
              // -----------------------------------------

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

              // -----------------------------------------
              // BUTTONS
              // -----------------------------------------

              Row(
                children: [
                  // CANCEL
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(
                        result: false,
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(
                          double.infinity,
                          46,
                        ),
                        foregroundColor: AppColors.hintColor,
                        side: const BorderSide(
                          color: AppColors.border,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            13,
                          ),
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

                  // DELETE
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(
                        result: true,
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(
                          double.infinity,
                          46,
                        ),
                        elevation: 0,
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            13,
                          ),
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

  // =====================================================
  // DELETE REQUEST
  // =====================================================

  Future<void> deletePermission(
    PermissionModel permission,
  ) async {
    if (isDeleting.value) {
      return;
    }

    try {
      isDeleting.value = true;

      await permissionServices.deletePermission(
        permissionId: permission.id,
      );

      permissionRequests.removeWhere(
        (item) => item.id == permission.id,
      );

      if (editingPermission.value?.id == permission.id) {
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
          fallbackKey: 'permission_delete_failed',
        ),
      );
    } finally {
      isDeleting.value = false;
    }
  }

  // =====================================================
  // DUPLICATE REQUEST CHECK
  // =====================================================

  bool _hasDuplicateRequestToday() {
    return permissionRequests.any(
      (request) {
        if (!_isToday(
          request.createdAt,
        )) {
          return false;
        }

        // -----------------------------------------------
        // FULL DAY
        // -----------------------------------------------

        if (selectedRequestType.value == 'full_day') {
          return request.requestType == 'full_day';
        }

        // -----------------------------------------------
        // SUBJECT
        // -----------------------------------------------

        return request.requestType == 'subject' &&
            request.scheduleId == selectedScheduleId.value;
      },
    );
  }

  // =====================================================
  // CHECK TODAY
  // =====================================================

  bool _isToday(String? value) {
    if (value == null || value.trim().isEmpty) {
      return false;
    }

    final parsed = DateTime.tryParse(value);

    if (parsed == null) {
      return false;
    }

    final now = DateTime.now();

    final local = parsed.toLocal();

    return local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
  }

  // =====================================================
  // EXTRACT API ERROR
  // =====================================================

  String _extractErrorMessage(
    dynamic error, {
    required String fallbackKey,
  }) {
    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map) {
        final message = data['detail'] ?? data['message'];

        if (message != null && message.toString().trim().isNotEmpty) {
          return message.toString();
        }
      }
    }

    final text = error.toString();

    if (text.toLowerCase().contains(
          'already requested',
        )) {
      return 'ask_permission_already_requested_today'.tr;
    }

    return fallbackKey.tr;
  }

  // =====================================================
  // ERROR SNACKBAR
  // =====================================================

  void _showError(
    String message,
  ) {
    CustomSnackbar.error(
      message,
      title: 'error'.tr,
    );
  }

  // =====================================================
  // SUCCESS SNACKBAR
  // =====================================================

  void _showSuccess(
    String message,
  ) {
    CustomSnackbar.success(
      message,
      title: 'success'.tr,
    );
  }

  // =====================================================
  // REQUEST TYPE LABEL
  // =====================================================

  String requestTypeLabel(
    String type,
  ) {
    switch (type.toLowerCase()) {
      case 'full_day':
        return 'ask_permission_request_type_full_day'.tr;

      case 'subject':
        return 'ask_permission_request_type_by_subject'.tr;

      default:
        return type;
    }
  }

  String formatRequestType(
    String type,
  ) {
    return requestTypeLabel(type);
  }

  // =====================================================
  // PERMISSION TYPE LABEL
  // =====================================================

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

  // =====================================================
  // SCHEDULE LABEL
  // =====================================================

  String scheduleLabel(
    Map<String, dynamic> item,
  ) {
    final subject = item['subject_name']?.toString().trim().isNotEmpty == true
        ? item['subject_name'].toString().trim()
        : '-';

    final start = _formatTime(
      item['start_time'],
    );

    final end = _formatTime(
      item['end_time'],
    );

    // -----------------------------------------------
    // SUBJECT ONLY
    // -----------------------------------------------

    if (start.isEmpty && end.isEmpty) {
      return subject;
    }

    // -----------------------------------------------
    // START + END
    // -----------------------------------------------

    if (start.isNotEmpty && end.isNotEmpty) {
      return '$subject ($start - $end)';
    }

    // -----------------------------------------------
    // START ONLY
    // -----------------------------------------------

    if (start.isNotEmpty) {
      return '$subject ($start)';
    }

    // -----------------------------------------------
    // END ONLY
    // -----------------------------------------------

    return '$subject ($end)';
  }

  // =====================================================
  // TIME FORMATTER
  //
  // Supports:
  //
  // 07:30
  // 7:30
  // 07:30:00
  // [07, 30, 00]
  // [7, 30]
  // =====================================================

  String _formatTime(
    dynamic value,
  ) {
    if (value == null) {
      return '';
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return '';
    }

    // -----------------------------------------------
    // REMOVE BRACKETS
    // -----------------------------------------------

    final clean = text.replaceAll('[', '').replaceAll(']', '').trim();

    // -----------------------------------------------
    // HANDLE COLON FORMAT
    //
    // 07:30
    // 07:30:00
    // -----------------------------------------------

    final colonParts = clean.split(':');

    if (colonParts.length >= 2) {
      final hour = colonParts[0].trim().padLeft(2, '0');

      final minute = colonParts[1].trim().padLeft(2, '0');

      return '$hour:$minute';
    }

    // -----------------------------------------------
    // HANDLE COMMA FORMAT
    //
    // 07, 30, 00
    // -----------------------------------------------

    final commaParts = clean.split(',');

    if (commaParts.length >= 2) {
      final hour = commaParts[0].trim().padLeft(2, '0');

      final minute = commaParts[1].trim().padLeft(2, '0');

      return '$hour:$minute';
    }

    return text;
  }

  // =====================================================
  // CREATED DATE FORMAT
  // =====================================================

  String formatCreatedDate(
    dynamic value,
  ) {
    if (value == null) {
      return '-';
    }

    final date = DateTime.tryParse(
      value.toString(),
    );

    if (date == null) {
      return value.toString();
    }

    final local = date.toLocal();

    final day = local.day.toString().padLeft(2, '0');

    final month = local.month.toString().padLeft(2, '0');

    return '$day/$month/${local.year}';
  }

  // =====================================================
  // STATUS COLOR
  // =====================================================

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

  // =====================================================
  // STATUS LABEL
  // =====================================================

  String statusLabel(
    String status,
  ) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'ask_permission_status_pending'.tr;

      case 'approved':
        return 'ask_permission_status_approved'.tr;

      case 'rejected':
        return 'ask_permission_status_rejected'.tr;

      default:
        return status;
    }
  }

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void onClose() {
    reasonController.dispose();

    super.onClose();
  }
}
