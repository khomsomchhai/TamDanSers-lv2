part of 'ask_permission_screen_view.dart';

class AskPermissionScreenViewController
    extends GetxController {
  final formKey = GlobalKey<FormState>();

  final reasonController =
      TextEditingController();

  final PermissionServices permissionServices =
      PermissionServices();

  final ScheduleServices scheduleServices =
      ScheduleServices();

  final UserController userController =
      Get.find<UserController>();

  final selectedRequestType =
      'subject'.obs;

  final selectedScheduleId =
      RxnInt();

  final selectedPermissionType =
      ''.obs;

  final isLoading = false.obs;
  final isScheduleLoading = false.obs;

  final permissionRequests =
      <PermissionModel>[].obs;

  final schedules =
      <ScheduleModel>[].obs;

  final editingPermission =
      Rxn<PermissionModel>();

  final requestTypes = const [
    'subject',
    'full_day',
  ];

  final List<String> permissionTypes = const [
    'Sick',
    'Family',
    'Personal',
    'Other',
  ];

  Worker? _requestTypeWorker;

  bool get isBySubject =>
      selectedRequestType.value ==
      'subject';

  bool get isEditing =>
      editingPermission.value != null;

  String get requestTypeApiValue =>
      isBySubject
          ? 'subject'
          : 'full_day';

  @override
  void onInit() {
    super.onInit();

    _requestTypeWorker =
        ever<String>(
      selectedRequestType,
      _onRequestTypeChanged,
    );

    loadData();
  }

  Future<void> loadData() async {
    await Future.wait([
      fetchTodaySchedules(),
      fetchMyPermissions(),
    ]);
  }

  void _onRequestTypeChanged(
    String value,
  ) {
    if (value == 'subject' &&
        schedules.isEmpty) {
      fetchTodaySchedules();
    }

    /*
      ពេលកំពុង Edit កុំ reset schedule
      ព្រោះ startEditPermission បានដាក់ schedule រួច។
    */
    if (!isEditing) {
      selectedScheduleId.value = null;
    }

    if (value == 'Full Day') {
      selectedScheduleId.value = null;
    }
  }

  Future<void> fetchTodaySchedules() async {
    try {
      isScheduleLoading.value = true;

      await _ensureProfileLoaded();

      final classId =
          userController.profile?.classId;

      final result =
          await scheduleServices.fetchSchedules(
        classId:
            classId != null && classId > 0
                ? classId
                : null,
      );

      final today =
          _todayDayName().toLowerCase();

      var todaySchedules = result.where(
        (item) {
          return item.day
                  .trim()
                  .toLowerCase() ==
              today;
        },
      ).toList();

      if (classId != null &&
          classId > 0) {
        todaySchedules =
            todaySchedules.where(
          (item) {
            return item.classId ==
                classId;
          },
        ).toList();
      }

      schedules.assignAll(
        todaySchedules,
      );
    } catch (error, stackTrace) {
      schedules.clear();

      debugPrint(
        'FETCH TODAY SCHEDULE ERROR: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
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
      final result =
          await permissionServices
              .fetchMyPermissions();

      permissionRequests.assignAll(
        result,
      );
    } catch (error, stackTrace) {
      permissionRequests.clear();

      debugPrint(
        'FETCH MY PERMISSIONS ERROR: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> submitPermission() async {
    if (isLoading.value) {
      return;
    }

    if (selectedRequestType.value
        .trim()
        .isEmpty) {
      CustomSnackbar.error(
        'ask_permission_please_select_request_type'
            .tr,
      );
      return;
    }

    /*
      កែពី logic ចាស់:
      មុននេះអ្នកប្រើ !isBySubject ដែលខុស។
    */
    if (isBySubject &&
        schedules.isEmpty) {
      CustomSnackbar.error(
        'ask_permission_no_schedule_today'.tr,
      );
      return;
    }

    if (isBySubject &&
        selectedScheduleId.value == null) {
      CustomSnackbar.error(
        'ask_permission_please_select_subject'
            .tr,
      );
      return;
    }

    if (selectedPermissionType.value
        .trim()
        .isEmpty) {
      CustomSnackbar.error(
        'ask_permission_please_select_permission_type'
            .tr,
      );
      return;
    }

    final reason =
        reasonController.text.trim();

    if (reason.isEmpty) {
      CustomSnackbar.error(
        'ask_permission_please_enter_reason'.tr,
      );
      return;
    }

    try {
      isLoading.value = true;

      final editing =
          editingPermission.value;

      if (editing == null) {
        /*
          កុំ block request ទាំងអស់ក្នុងមួយថ្ងៃ។
          ពិនិត្យតែប្រភេទ request ឬ subject ដូចគ្នា។
        */
        if (_hasDuplicateRequestToday()) {
          CustomSnackbar.error(
            'ask_permission_already_requested_today'
                .tr,
          );
          return;
        }

        await permissionServices
            .createPermission(
          requestType:
              requestTypeApiValue,
          scheduleId:
              isBySubject
                  ? selectedScheduleId.value
                  : null,
          type:
              selectedPermissionType.value,
          reason: reason,
        );

        CustomSnackbar.success(
          'ask_permission_submitted'.tr,
        );
      } else {
        if (!editing.canEdit) {
          CustomSnackbar.error(
            'permission_attendance_locked'.tr,
          );
          return;
        }

        await permissionServices
            .updatePermission(
          permissionId: editing.id,
          requestType:
              requestTypeApiValue,
          scheduleId:
              isBySubject
                  ? selectedScheduleId.value
                  : null,
          type:
              selectedPermissionType.value,
          reason: reason,
        );

        CustomSnackbar.success(
          'permission_updated'.tr,
        );
      }

      clearForm();

      await fetchMyPermissions();
    } catch (error, stackTrace) {
      debugPrint(
        'SUBMIT PERMISSION ERROR: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      CustomSnackbar.error(
        _extractErrorMessage(
          error,
          fallbackKey:
              'ask_permission_failed_submit',
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void startEditPermission(
    PermissionModel permission,
  ) {
    if (!permission.canEdit ||
        permission.attendanceSaved) {
      CustomSnackbar.error(
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

    /*
      ដាក់ក្រោយ request type ដើម្បីកុំឱ្យ worker
      reset schedule id។
    */
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
        'subject';

    selectedScheduleId.value = null;

    selectedPermissionType.value =
        '';

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
      backgroundColor: Colors.transparent,
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
          color: Get.theme.cardColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Get.theme.shadowColor.withOpacity(0.12),
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
                color: Get.theme.colorScheme.error.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
                child: Icon(
                Icons.delete_outline_rounded,
                color: Get.theme.colorScheme.error,
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
                color: Get.theme.textTheme.bodyLarge?.color,
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
                color: Get.theme.hintColor,
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
                          Get.theme.hintColor,
                      side: BorderSide(
                        color: Get.theme.dividerColor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(13),
                      ),
                    ),
                    child: Text(
                      'cancel'.tr,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Get.theme.hintColor,
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
                          Get.theme.colorScheme.error,
                      foregroundColor:
                          Get.theme.colorScheme.onError,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(13),
                      ),
                    ),
                    child: Text(
                      'delete'.tr,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Get.theme.colorScheme.onError,
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

      CustomSnackbar.success(
        'permission_deleted'.tr,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'DELETE PERMISSION ERROR: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      CustomSnackbar.error(
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

        if (requestTypeApiValue ==
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

      if (data != null &&
          data.toString().trim().isNotEmpty) {
        return data.toString();
      }
    }

    return fallbackKey.tr;
  }

  String formatCreatedDate(
    String? rawDate,
  ) {
    if (rawDate == null ||
        rawDate.isEmpty) {
      return '-';
    }

    final parsed =
        DateTime.tryParse(rawDate);

    if (parsed == null) {
      return rawDate;
    }

    final local = parsed.toLocal();

    final year = local.year
        .toString()
        .padLeft(4, '0');

    final month = local.month
        .toString()
        .padLeft(2, '0');

    final day = local.day
        .toString()
        .padLeft(2, '0');

    final hour = local.hour
        .toString()
        .padLeft(2, '0');

    final minute = local.minute
        .toString()
        .padLeft(2, '0');

    return '$year-$month-$day '
        '$hour:$minute';
  }

  String scheduleLabel(
    ScheduleModel item,
  ) {
    return '${item.subjectName} - '
        '${requestDayLabel(item.day)} '
        '(${_formatTime(item.startTime)} - '
        '${_formatTime(item.endTime)})';
  }

  String _formatTime(
    String value,
  ) {
    final text = value.trim();

    if (text.isEmpty) {
      return '-';
    }

    final parts = text.split(':');

    if (parts.length < 2) {
      return text;
    }

    return '${parts[0]}:${parts[1]}';
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

  String requestDayLabel(
    String value,
  ) {
    switch (value
        .trim()
        .toLowerCase()) {
      case 'monday':
        return 'day_monday'.tr;

      case 'tuesday':
        return 'day_tuesday'.tr;

      case 'wednesday':
        return 'day_wednesday'.tr;

      case 'thursday':
        return 'day_thursday'.tr;

      case 'friday':
        return 'day_friday'.tr;

      case 'saturday':
        return 'day_saturday'.tr;

      case 'sunday':
        return 'day_sunday'.tr;

      default:
        return value;
    }
  }

  String formatRequestType(
    String value,
  ) {
    switch (value.toLowerCase()) {
      case 'subject':
      case 'by_subject':
        return 'ask_permission_request_type_by_subject'
            .tr;

      case 'full_day':
        return 'ask_permission_request_type_full_day'
            .tr;

      default:
        return value;
    }
  }

  String requestTypeLabel(
    String value,
  ) {
    switch (value.toLowerCase()) {
      case 'subject':
        return 'ask_permission_request_type_by_subject'
            .tr;

      case 'full_day':
        return 'ask_permission_request_type_full_day'
            .tr;

      default:
        return value;
    }
  }

  String permissionTypeLabel(
    String type,
  ) {
    switch (type.toLowerCase()) {
      case 'sick':
        return 'ask_permission_type_sick'.tr;

      case 'family':
        return 'ask_permission_type_family'.tr;

      case 'personal':
        return 'ask_permission_type_personal'.tr;

      case 'other':
        return 'ask_permission_type_other'.tr;

      default:
        return type;
    }
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

  bool _isToday(
    String? rawDate,
  ) {
    if (rawDate == null ||
        rawDate.isEmpty) {
      return false;
    }

    final parsed =
        DateTime.tryParse(rawDate);

    if (parsed == null) {
      return false;
    }

    final now = DateTime.now();
    final local = parsed.toLocal();

    return local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
  }

  @override
  void onClose() {
    _requestTypeWorker?.dispose();
    reasonController.dispose();
    super.onClose();
  }
}