import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamdansers_lv2/app/themes/app_numbers.dart';
import 'package:tamdansers_lv2/core/api/services/permission_services.dart';
import 'package:tamdansers_lv2/core/api/services/schedule_services.dart';
import 'package:tamdansers_lv2/core/widgets/appbar/custom_appbar.dart';
import 'package:tamdansers_lv2/core/widgets/button/custom_button.dart';
import 'package:tamdansers_lv2/core/widgets/snackbar/custom_snackbar.dart';
import 'package:tamdansers_lv2/core/widgets/textfield.dart/custom_textfield.dart';
import 'package:tamdansers_lv2/data/model/permission_model.dart';
import 'package:tamdansers_lv2/data/model/schedule_model.dart';

part 'ask_permission_screen_binding.dart';
part 'ask_permission_screen_controller.dart';

class AskPermissionScreenView
    extends GetView<AskPermissionScreenViewController> {
  const AskPermissionScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'ask_permission'.tr,
        showNotification: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppNumbers.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormCard(context),
                const SizedBox(height: AppNumbers.spacingXLarge),
                Text(
                  'ask_permission_my_requests'.tr,
                  style: Get.textTheme.titleSmall,
                ),
                const SizedBox(height: AppNumbers.spacingMedium),
                Obx(() {
                  if (controller.permissionRequests.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppNumbers.cardPadding),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius:
                            BorderRadius.circular(AppNumbers.radiusLarge),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.fact_check_outlined,
                            size: AppNumbers.iconLarge,
                            color: theme.iconTheme.color?.withOpacity(0.7),
                          ),
                          const SizedBox(height: AppNumbers.spacingSmall),
                          Text(
                            'ask_permission_no_requests'.tr,
                            style: Get.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: controller.permissionRequests.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppNumbers.spacingMedium),
                    itemBuilder: (_, index) {
                      final request = controller.permissionRequests[index];
                      final status = request.status.toLowerCase();
                      final subjectLine = request.subjectName.isNotEmpty
                          ? request.subjectName
                          : '-';

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppNumbers.cardPadding,
                          vertical: AppNumbers.cardPadding,
                        ),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius:
                              BorderRadius.circular(AppNumbers.radiusRounded),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.03),
                              blurRadius: AppNumbers.shadowBlur,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: AppNumbers.avatarMedium,
                                  height: AppNumbers.avatarMedium,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(
                                        AppNumbers.radiusMedium),
                                  ),
                                  child: Icon(
                                    Icons.fact_check_outlined,
                                    color: theme.colorScheme.onPrimaryContainer,
                                    size: AppNumbers.iconSmall,
                                  ),
                                ),
                                const SizedBox(width: AppNumbers.spacingMedium),
                                Expanded(
                                  child: Text(
                                    controller.formatRequestType(
                                      request.requestType,
                                    ),
                                    style: Get.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppNumbers.spacingSmall,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(
                                      AppNumbers.radiusMedium,
                                    ),
                                  ),
                                  child: Text(
                                    _capitalizeStatus(status),
                                    style: Get.textTheme.bodySmall?.copyWith(
                                      color: _getStatusColor(status),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppNumbers.spacingMedium),
                            Divider(height: 1, color: theme.dividerColor),
                            const SizedBox(height: AppNumbers.spacingSmall),
                            if (subjectLine != '-') ...[
                              Row(
                                children: [
                                  Icon(
                                    Icons.menu_book_rounded,
                                    size: AppNumbers.icon16,
                                    color: theme.iconTheme.color?.withOpacity(0.7),
                                  ),
                                  const SizedBox(
                                      width: AppNumbers.spacingSmall),
                                  Expanded(
                                    child: Text(
                                      '${'ask_permission_subject'.tr}: $subjectLine',
                                      style: Get.textTheme.bodySmall?.copyWith(
                                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.75),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                            Row(
                              children: [
                                Icon(
                                  Icons.label_outline_rounded,
                                  size: AppNumbers.icon16,
                                  color: theme.iconTheme.color?.withOpacity(0.7),
                                ),
                                const SizedBox(width: AppNumbers.spacingSmall),
                                Expanded(
                                  child: Text(
                                    '${'ask_permission_permission_type'.tr}: ${request.type}',
                                    style: Get.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.75),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.notes_outlined,
                                  size: AppNumbers.icon16,
                                  color: theme.iconTheme.color?.withOpacity(0.7),
                                ),
                                const SizedBox(width: AppNumbers.spacingSmall),
                                Expanded(
                                  child: Text(
                                    '${'ask_permission_reason'.tr}: ${request.reason}',
                                    style: Get.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.75),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: AppNumbers.icon16,
                                  color: theme.iconTheme.color?.withOpacity(0.7),
                                ),
                                const SizedBox(width: AppNumbers.spacingSmall),
                                Text(
                                  '${'ask_permission_created'.tr}: ${controller.formatCreatedDate(request.createdAt)}',
                                  style: Get.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.75),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppNumbers.cardPadding,
        vertical: AppNumbers.cardPadding,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppNumbers.radiusRounded),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: AppNumbers.shadowBlur,
            offset: Offset(0, 6),
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
                  width: AppNumbers.buttonHeight,
                  height: AppNumbers.buttonHeight,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius:
                        BorderRadius.circular(AppNumbers.radiusMedium),
                  ),
                  child: Icon(
                    Icons.assignment_rounded,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: AppNumbers.iconMedium,
                  ),
                ),
                const SizedBox(width: AppNumbers.spacingMedium),
                Expanded(
                  child: Text(
                    'ask_permission_request_permission'.tr,
                    style: Get.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppNumbers.spacingMedium),
            Divider(height: 1, color: theme.dividerColor),
            const SizedBox(height: AppNumbers.spacingLarge),
            Text(
              'ask_permission_request_type'.tr,
              style: Get.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppNumbers.spacingSmall),
            Obx(
              () => DropdownButtonFormField<String>(
                key: ValueKey(controller.selectedRequestType.value),
                initialValue: controller.selectedRequestType.value,
                items: controller.requestTypes
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          controller.requestTypeLabel(item),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedRequestType.value = value;
                  }
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: theme.cardColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppNumbers.spacingMedium,
                    vertical: AppNumbers.spacingMedium,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius:
                        BorderRadius.circular(AppNumbers.radiusMedium),
                  ),
                ),
                dropdownColor: theme.cardColor,
                borderRadius: BorderRadius.circular(AppNumbers.radiusMedium),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: theme.iconTheme.color,
                ),
              ),
            ),
            const SizedBox(height: AppNumbers.spacingLarge),
            Obx(() {
              if (!controller.isBySubject) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ask_permission_subject'.tr,
                    style: Get.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppNumbers.spacingSmall),
                  DropdownButtonFormField<String>(
                    key: ValueKey(controller.selectedScheduleId.value),
                    initialValue: controller.schedules.any(
                      (item) => item.id == controller.selectedScheduleId.value,
                    )
                        ? controller.selectedScheduleId.value?.toString()
                        : null,
                    hint: Text(
                      'ask_permission_select_subject'.tr,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.hintColor),
                    ),
                    items: controller.schedules
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item.id.toString(),
                            child: Text(
                              controller.scheduleLabel(item),
                              style: Get.textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => controller.selectedScheduleId.value =
                        int.tryParse(value ?? ''),
                    isExpanded: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: theme.cardColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppNumbers.spacingMedium,
                        vertical: AppNumbers.spacingMedium,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius:
                            BorderRadius.circular(AppNumbers.radiusMedium),
                      ),
                    ),
                    dropdownColor: theme.cardColor,
                    borderRadius:
                        BorderRadius.circular(AppNumbers.radiusMedium),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                  const SizedBox(height: AppNumbers.spacingLarge),
                ],
              );
            }),
            Text(
              'ask_permission_permission_type'.tr,
              style: Get.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppNumbers.spacingSmall),
            Obx(
              () => DropdownButtonFormField<String>(
                key: ValueKey(controller.selectedPermissionType.value),
                initialValue: controller.permissionTypes
                        .contains(controller.selectedPermissionType.value)
                    ? controller.selectedPermissionType.value
                    : null,
                hint: Text(
                  'ask_permission_select_permission_type'.tr,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.hintColor),
                ),
                items: controller.permissionTypes
                    .map(
                      (type) => DropdownMenuItem<String>(
                        value: type,
                        child: Text(type, style: Get.textTheme.bodyMedium),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    controller.selectedPermissionType.value = value ?? '',
                decoration: InputDecoration(
                  filled: true,
                  fillColor: theme.cardColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppNumbers.spacingMedium,
                    vertical: AppNumbers.spacingMedium,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius:
                        BorderRadius.circular(AppNumbers.radiusMedium),
                  ),
                ),
                dropdownColor: theme.cardColor,
                borderRadius: BorderRadius.circular(AppNumbers.radiusMedium),
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
              ),
            ),
            const SizedBox(height: AppNumbers.spacingLarge),
            Text(
              'ask_permission_reason'.tr,
              style: Get.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppNumbers.spacingSmall),
            CustomTextField(
              hintText: 'ask_permission_write_reason'.tr,
              controller: controller.reasonController,
              isMultiline: true,
            ),
            const SizedBox(height: AppNumbers.spacingLarge),
            SizedBox(
              width: double.infinity,
              height: AppNumbers.buttonHeight,
              child: Obx(
                () => CustomButton(
                  text: 'ask_permission_submit_request'.tr,
                  isLoading: controller.isLoading.value,
                  onPressed: controller.submitPermission,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B); // amber/warning
      case 'approved':
        return const Color(0xFF22C55E); // green/success
      case 'rejected':
        return const Color(0xFFEF4444); // red/error
      default:
        return const Color(0xFF6B7280); // grey
    }
  }

  String _capitalizeStatus(String status) {
    if (status.isEmpty) {
      return status;
    }

    return '${status[0].toUpperCase()}${status.substring(1).toLowerCase()}';
  }
}
