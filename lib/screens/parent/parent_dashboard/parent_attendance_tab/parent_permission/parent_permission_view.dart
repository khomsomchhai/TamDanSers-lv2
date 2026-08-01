import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tamdansers_lv2/app/themes/app_numbers.dart';
import 'package:tamdansers_lv2/core/api/services/permission_services.dart';
import 'package:tamdansers_lv2/core/widgets/appbar/custom_appbar.dart';
import 'package:tamdansers_lv2/core/widgets/button/custom_button.dart';
import 'package:tamdansers_lv2/core/widgets/textfield.dart/custom_textfield.dart';
import 'package:tamdansers_lv2/data/model/permission_model.dart';

import 'package:tamdansers_lv2/screens/parent/parent_dashboard/'
    'parent_home_tab/parent_home_tab_view.dart';

part 'parent_permission_binding.dart';
part 'parent_permission_controller.dart';

class ParentPermissionView
    extends GetView<ParentPermissionController> {
  const ParentPermissionView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'ask_permission'.tr,
        showNotification: false,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.loadData,
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(
              AppNumbers.screenPadding,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _buildStudentCard(context),

                const SizedBox(
                  height:
                      AppNumbers.spacingMedium,
                ),

                _buildPermissionForm(context),

                const SizedBox(
                  height:
                      AppNumbers.spacingXLarge,
                ),

                Text(
                  'ask_permission_my_requests'.tr,
                  style: Get.textTheme.titleSmall
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height:
                      AppNumbers.spacingMedium,
                ),

                _buildPermissionHistory(
                  context,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // Selected child card
  // =====================================================
  Widget _buildStudentCard(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppNumbers.cardPadding,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(
          AppNumbers.radiusRounded,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary
                  .withValues(alpha: 0.15),
              borderRadius:
                  BorderRadius.circular(
                AppNumbers.radiusMedium,
              ),
            ),
            child: Icon(
              Icons.person_rounded,
              color:
                  theme.colorScheme.onPrimary,
              size: 28,
            ),
          ),

          const SizedBox(
            width: AppNumbers.spacingMedium,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'ask_permission_for'.tr,
                  style: Get.textTheme.bodySmall
                      ?.copyWith(
                    color: theme
                        .colorScheme.onPrimary
                        .withValues(
                      alpha: 0.80,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                Obx(
                  () => Text(
                    controller.childName,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: Get
                        .textTheme.titleMedium
                        ?.copyWith(
                      color: theme
                          .colorScheme.onPrimary,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 2),

                Obx(
                  () => Text(
                    controller.childCode,
                    style: Get
                        .textTheme.bodySmall
                        ?.copyWith(
                      color: theme
                          .colorScheme.onPrimary
                          .withValues(
                        alpha: 0.85,
                      ),
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

  // =====================================================
  // Permission form
  // =====================================================
  Widget _buildPermissionForm(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppNumbers.cardPadding,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(
          AppNumbers.radiusRounded,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(
              0,
              0,
              0,
              0.04,
            ),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme
                        .primaryContainer,
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: Icon(
                    Icons.edit_calendar_rounded,
                    color: theme.colorScheme
                        .onPrimaryContainer,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    'ask_permission_request_permission'
                        .tr,
                    style: Get
                        .textTheme.titleSmall
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height:
                  AppNumbers.spacingMedium,
            ),

            Divider(
              color: theme.dividerColor,
            ),

            const SizedBox(
              height:
                  AppNumbers.spacingMedium,
            ),

            // =================================================
            // Request Type
            // =================================================
            Text(
              'ask_permission_request_type'.tr,
              style:
                  Get.textTheme.bodyMedium,
            ),

            const SizedBox(
              height:
                  AppNumbers.spacingSmall,
            ),

            Obx(
              () =>
                  DropdownButtonFormField<
                      String>(
                key: ValueKey(
                  controller
                      .selectedRequestType
                      .value,
                ),
                initialValue: controller
                    .selectedRequestType.value,
                isExpanded: true,
                items: controller.requestTypes
                    .map(
                      (type) =>
                          DropdownMenuItem<
                              String>(
                        value: type,
                        child: Text(
                          controller
                              .requestTypeLabel(
                            type,
                          ),
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style: Get
                              .textTheme.bodyMedium
                              ?.copyWith(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller
                        .changeRequestType(
                      value,
                    );
                  }
                },
                decoration:
                    _inputDecoration(
                  context,
                ),
                icon: const Icon(
                  Icons
                      .keyboard_arrow_down_rounded,
                  size: 24,
                ),
                dropdownColor:
                    theme.cardColor,
              ),
            ),

            const SizedBox(
              height:
                  AppNumbers.spacingLarge,
            ),

            // =================================================
            // Subject Schedule
            // =================================================
            Obx(
              () {
                if (!controller
                    .isBySubject) {
                  return const SizedBox
                      .shrink();
                }

                return Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ask_permission_subject'.tr,
                      style: Get
                          .textTheme.bodyMedium,
                    ),

                    const SizedBox(
                      height: AppNumbers
                          .spacingSmall,
                    ),

                    DropdownButtonFormField<
                        int>(
                      key: ValueKey(
                        controller
                            .selectedScheduleId
                            .value,
                      ),
                      initialValue: controller
                          .selectedScheduleId
                          .value,
                      isExpanded: true,
                      hint: Text(
                        'ask_permission_select_subject'
                            .tr,
                        style: Get
                            .textTheme.bodyMedium
                            ?.copyWith(
                          fontSize: 16,
                          color:
                              theme.hintColor,
                        ),
                      ),
                      items: controller.schedules
                          .map(
                            (
                              schedule,
                            ) =>
                                DropdownMenuItem<
                                    int>(
                              value: controller
                                  .parseId(
                                schedule['id'],
                              ),
                              child: Text(
                                controller
                                    .scheduleLabel(
                                  schedule,
                                ),
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style: Get
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight
                                          .w500,
                                ),
                              ),
                            ),
                          )
                          .where(
                            (item) =>
                                item.value !=
                                null,
                          )
                          .toList(),
                      onChanged: (value) {
                        controller
                            .selectedScheduleId
                            .value = value;
                      },
                      decoration:
                          _inputDecoration(
                        context,
                      ),
                      icon: const Icon(
                        Icons
                            .keyboard_arrow_down_rounded,
                        size: 24,
                      ),
                      dropdownColor:
                          theme.cardColor,
                    ),

                    const SizedBox(
                      height: AppNumbers
                          .spacingLarge,
                    ),
                  ],
                );
              },
            ),

            // =================================================
            // Permission Type
            // =================================================
            Text(
              'ask_permission_permission_type'
                  .tr,
              style:
                  Get.textTheme.bodyMedium,
            ),

            const SizedBox(
              height:
                  AppNumbers.spacingSmall,
            ),

            Obx(
              () =>
                  DropdownButtonFormField<
                      String>(
                key: ValueKey(
                  controller
                      .selectedPermissionType
                      .value,
                ),
                initialValue: controller
                    .selectedPermissionType
                    .value,
                isExpanded: true,
                items: controller
                    .permissionTypes
                    .map(
                      (type) =>
                          DropdownMenuItem<
                              String>(
                        value: type,
                        child: Text(
                          controller
                              .permissionTypeLabel(
                            type,
                          ),
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style: Get
                              .textTheme.bodyMedium
                              ?.copyWith(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller
                        .selectedPermissionType
                        .value = value;
                  }
                },
                decoration:
                    _inputDecoration(
                  context,
                ),
                icon: const Icon(
                  Icons
                      .keyboard_arrow_down_rounded,
                  size: 24,
                ),
                dropdownColor:
                    theme.cardColor,
              ),
            ),

            const SizedBox(
              height:
                  AppNumbers.spacingLarge,
            ),

            // =================================================
            // Reason
            // =================================================
            Text(
              'ask_permission_reason'.tr,
              style:
                  Get.textTheme.bodyMedium,
            ),

            const SizedBox(
              height:
                  AppNumbers.spacingSmall,
            ),

            CustomTextField(
              hintText:
                  'ask_permission_write_reason'
                      .tr,
              controller:
                  controller.reasonController,
              isMultiline: true,
            ),

            const SizedBox(
              height:
                  AppNumbers.spacingLarge,
            ),

            SizedBox(
              width: double.infinity,
              height:
                  AppNumbers.buttonHeight,
              child: Obx(
                () => CustomButton(
                  text:
                      'ask_permission_submit_request'
                          .tr,
                  isLoading: controller
                      .isSubmitting.value,
                  onPressed: controller
                      .submitPermission,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // Permission history
  // =====================================================
  Widget _buildPermissionHistory(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return Obx(
      () {
        if (controller.isLoading.value) {
          return const Center(
            child:
                CircularProgressIndicator(),
          );
        }

        if (controller
            .permissionRequests.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(
              AppNumbers.cardPadding,
            ),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius:
                  BorderRadius.circular(
                AppNumbers.radiusLarge,
              ),
              border: Border.all(
                color: theme.dividerColor,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.fact_check_outlined,
                  size: 42,
                  color: theme.iconTheme.color
                      ?.withValues(
                    alpha: 0.6,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'ask_permission_no_requests'
                      .tr,
                  textAlign:
                      TextAlign.center,
                  style: Get
                      .textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          itemCount: controller
              .permissionRequests.length,
          separatorBuilder: (_, __) =>
              const SizedBox(
            height: 12,
          ),
          itemBuilder: (_, index) {
            final request = controller
                .permissionRequests[index];

            final status =
                request.status.toLowerCase();

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(
                AppNumbers.cardPadding,
              ),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius:
                    BorderRadius.circular(
                  AppNumbers.radiusRounded,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(
                      0,
                      0,
                      0,
                      0.03,
                    ),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: theme
                              .colorScheme
                              .primaryContainer,
                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: Icon(
                          Icons
                              .assignment_turned_in_outlined,
                          color: theme
                              .colorScheme
                              .onPrimaryContainer,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          controller
                              .formatRequestType(
                            request.requestType,
                          ),
                          style: Get
                              .textTheme.titleSmall
                              ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets
                            .symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: controller
                              .statusColor(
                                status,
                              )
                              .withValues(
                            alpha: 0.12,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),
                        child: Text(
                          controller
                              .statusLabel(
                            status,
                          ),
                          style: TextStyle(
                            color: controller
                                .statusColor(
                              status,
                            ),
                            fontWeight:
                                FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Divider(
                    color: theme.dividerColor,
                  ),

                  const SizedBox(height: 8),

                  if (request.requestType ==
                          'subject' &&
                      request.subjectName
                          .isNotEmpty)
                    _historyRow(
                      icon:
                          Icons.menu_book_rounded,
                      label:
                          '${'ask_permission_subject'.tr}: '
                          '${request.subjectName}',
                    ),

                  _historyRow(
                    icon:
                        Icons.label_outline,
                    label:
                        '${'ask_permission_permission_type'.tr}: '
                        '${controller.permissionTypeLabel(request.type)}',
                  ),

                  _historyRow(
                    icon:
                        Icons.notes_outlined,
                    label:
                        '${'ask_permission_reason'.tr}: '
                        '${request.reason}',
                  ),

                  _historyRow(
                    icon: Icons
                        .calendar_today_outlined,
                    label:
                        '${'ask_permission_created'.tr}: '
                        '${controller.formatCreatedDate(request.createdAt)}',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _historyRow({
    required IconData icon,
    required String label,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 8,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 17,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              label,
              style:
                  Get.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return InputDecoration(
      filled: true,
      fillColor:
          theme.scaffoldBackgroundColor,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius:
            BorderRadius.circular(
          AppNumbers.radiusMedium,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius:
            BorderRadius.circular(
          AppNumbers.radiusMedium,
        ),
      ),
      focusedBorder:
          OutlineInputBorder(
        borderSide: BorderSide(
          color: theme
              .colorScheme.primary,
          width: 1.4,
        ),
        borderRadius:
            BorderRadius.circular(
          AppNumbers.radiusMedium,
        ),
      ),
    );
  }
}