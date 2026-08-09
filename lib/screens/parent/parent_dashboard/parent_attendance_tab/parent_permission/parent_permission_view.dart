import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_numbers.dart';
import 'package:tamdansers_lv2/app/themes/app_text_styles.dart';
import 'package:tamdansers_lv2/core/api/services/permission_services.dart';
import 'package:tamdansers_lv2/core/widgets/appbar/custom_appbar.dart';
import 'package:tamdansers_lv2/core/widgets/button/custom_button.dart';
import 'package:tamdansers_lv2/core/widgets/snackbar/custom_snackbar.dart';
import 'package:tamdansers_lv2/core/widgets/textfield.dart/custom_textfield.dart';
import 'package:tamdansers_lv2/data/model/permission_model.dart';
import 'package:tamdansers_lv2/screens/parent/parent_dashboard/'
    'parent_home_tab/parent_home_tab_view.dart';

part 'parent_permission_binding.dart';
part 'parent_permission_controller.dart';

class ParentPermissionView extends GetView<ParentPermissionController> {
  const ParentPermissionView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: CustomAppBar(
        title: 'ask_permission'.tr,
        showNotification: false,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppNumbers.screenPadding,
              16,
              AppNumbers.screenPadding,
              100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStudentCard(),
                const SizedBox(height: 16),
                _buildPermissionForm(),
                const SizedBox(height: 24),
                _buildHistoryHeader(),
                const SizedBox(height: 12),
                _buildPermissionHistory(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.16),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ask_permission_for'.tr,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white.withValues(alpha: 0.80),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Obx(
                  () => Text(
                    controller.childName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Obx(
                  () => Text(
                    controller.childCode,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white.withValues(alpha: 0.84),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionForm() {
    return Obx(() {
      final isEditing = controller.isEditing;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isEditing
                ? AppColors.primary.withValues(alpha: 0.35)
                : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.dark.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      isEditing
                          ? Icons.edit_note_rounded
                          : Icons.edit_calendar_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      isEditing
                          ? 'permission_edit_title'.tr
                          : 'ask_permission_request_permission'.tr,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.dark,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isEditing)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'edit'.tr,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 16),
              _buildRequestTypeField(),
              const SizedBox(height: 14),
              if (controller.isBySubject) _buildScheduleField(),
              if (controller.isBySubject) const SizedBox(height: 14),
              _buildPermissionTypeField(),
              const SizedBox(height: 14),
              _buildReasonField(),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: AppNumbers.buttonHeight,
                child: CustomButton(
                  text: isEditing
                      ? 'edit'.tr
                      : 'ask_permission_submit_request'.tr,
                  isLoading: controller.isSubmitting.value,
                  onPressed: controller.submitPermission,
                ),
              ),
              if (isEditing) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: controller.cancelEditPermission,
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                    ),
                    label: Text(
                      'cancel'.tr,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildRequestTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('ask_permission_request_type'.tr),
        const SizedBox(height: 7),
        Obx(
          () => DropdownButtonFormField<String>(
            key: ValueKey(controller.selectedRequestType.value),
            initialValue: controller.selectedRequestType.value,
            isExpanded: true,
            style: _dropdownTextStyle(),
            items: controller.requestTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(
                  controller.requestTypeLabel(type),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _dropdownTextStyle(),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                controller.changeRequestType(value);
              }
            },
            decoration: _inputDecoration(),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 21,
              color: AppColors.hintColor,
            ),
            dropdownColor: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  // SCHEDULE FIELD WITH MON-SAT DAY FILTER BAR & CLEAN TIME DISPLAY
  Widget _buildScheduleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('ask_permission_subject'.tr),
        const SizedBox(height: 8),

        // MON - SAT DAY SELECTION BAR
        Obx(() {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.days.map((day) {
                final isSelected = controller.selectedDay.value == day;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () {
                      controller.selectedDay.value = day;
                      controller.selectedScheduleId.value = null;
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              isSelected ? AppColors.primary : AppColors.border,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        day,
                        style: TextStyle(
                          color: isSelected ? AppColors.white : AppColors.dark,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }),

        const SizedBox(height: 10),

        // FILTERED SCHEDULE DROPDOWN
        Obx(() {
          final scheduleList = controller.filteredSchedules;
          final selectedId = controller.selectedScheduleId.value;
          final hasSelected = scheduleList.any(
            (schedule) => controller.parseId(schedule['id']) == selectedId,
          );

          return DropdownButtonFormField<int>(
            key: ValueKey('${controller.selectedDay.value}_$selectedId'),
            initialValue: hasSelected ? selectedId : null,
            isExpanded: true,
            style: _dropdownTextStyle(),
            hint: Text(
              'ask_permission_select_subject'.tr,
              style: _hintTextStyle(),
            ),
            items: scheduleList
                .map((schedule) {
                  final id = controller.parseId(schedule['id']);
                  if (id == null) return null;

                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text(
                      controller.scheduleLabel(schedule),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _dropdownTextStyle(),
                    ),
                  );
                })
                .whereType<DropdownMenuItem<int>>()
                .toList(),
            onChanged: (value) {
              controller.selectedScheduleId.value = value;
            },
            decoration: _inputDecoration(),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 21,
              color: AppColors.hintColor,
            ),
            dropdownColor: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          );
        }),
      ],
    );
  }

  Widget _buildPermissionTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('ask_permission_permission_type'.tr),
        const SizedBox(height: 7),
        Obx(
          () => DropdownButtonFormField<String>(
            key: ValueKey(controller.selectedPermissionType.value),
            initialValue: controller.permissionTypes
                    .contains(controller.selectedPermissionType.value)
                ? controller.selectedPermissionType.value
                : null,
            isExpanded: true,
            style: _dropdownTextStyle(),
            hint: Text(
              'ask_permission_select_permission_type'.tr,
              style: _hintTextStyle(),
            ),
            items: controller.permissionTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(
                  controller.permissionTypeLabel(type),
                  style: _dropdownTextStyle(),
                ),
              );
            }).toList(),
            onChanged: (value) {
              controller.selectedPermissionType.value = value ?? '';
            },
            decoration: _inputDecoration(),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 21,
              color: AppColors.hintColor,
            ),
            dropdownColor: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  Widget _buildReasonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('ask_permission_reason'.tr),
        const SizedBox(height: 7),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomTextField(
            hintText: 'ask_permission_write_reason'.tr,
            controller: controller.reasonController,
            isMultiline: true,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.dark,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'ask_permission_my_requests'.tr,
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.dark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Obx(
          () => Text(
            '${controller.permissionRequests.length}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.hintColor,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionHistory() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(28),
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
        );
      }

      if (controller.permissionRequests.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.permissionRequests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          return _buildPermissionCard(
            controller.permissionRequests[index],
          );
        },
      );
    });
  }

  Widget _buildPermissionCard(PermissionModel request) {
    final status = request.status.trim().toLowerCase();
    final statusColor = controller.statusColor(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: request.attendanceSaved
              ? AppColors.grey.withValues(alpha: 0.25)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.dark.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.fact_check_outlined,
                  color: statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  controller.formatRequestType(request.requestType),
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.dark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildStatusBadge(status, statusColor),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),
          if (request.requestType == 'subject' &&
              request.subjectName.isNotEmpty)
            _historyRow(
              icon: Icons.menu_book_rounded,
              label: '${'ask_permission_subject'.tr}: ${request.subjectName}',
            ),
          _historyRow(
            icon: Icons.label_outline_rounded,
            label:
                '${'ask_permission_permission_type'.tr}: ${controller.permissionTypeLabel(request.type)}',
          ),
          _historyRow(
            icon: Icons.notes_outlined,
            label: '${'ask_permission_reason'.tr}: ${request.reason}',
          ),
          _historyRow(
            icon: Icons.schedule_rounded,
            label:
                '${'ask_permission_created'.tr}: ${controller.formatCreatedDate(request.createdAt)}',
          ),
          const SizedBox(height: 6),
          _buildPermissionActions(request),
        ],
      ),
    );
  }

  Widget _buildPermissionActions(PermissionModel request) {
    if (request.attendanceSaved || (!request.canEdit && !request.canDelete)) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: AppColors.grey.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: 17,
              color: AppColors.grey,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                'permission_attendance_locked'.tr,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: request.canEdit
                ? () => controller.startEditPermission(request)
                : null,
            icon: const Icon(Icons.edit_outlined, size: 17),
            label: Text(
              'edit'.tr,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(42),
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: request.canDelete
                ? () => controller.confirmDeletePermission(request)
                : null,
            icon: const Icon(Icons.delete_outline, size: 17),
            label: Text(
              'delete'.tr,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(42),
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        controller.statusLabel(status),
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _historyRow({
    required IconData icon,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.hintColor,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.hintColor,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 44,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fact_check_outlined,
              size: 34,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'ask_permission_no_requests'.tr,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.dark,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _dropdownTextStyle() {
    return AppTextStyles.bodySmall.copyWith(
      color: AppColors.dark,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );
  }

  TextStyle _hintTextStyle() {
    return AppTextStyles.bodySmall.copyWith(
      color: AppColors.hintColor,
      fontSize: 14,
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.lightBackground,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      hintStyle: _hintTextStyle(),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
