import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_numbers.dart';
import 'package:tamdansers_lv2/core/api/services/permission_services.dart';
import 'package:tamdansers_lv2/core/widgets/appbar/custom_appbar.dart';
import 'package:tamdansers_lv2/core/widgets/button/custom_button.dart';
import 'package:tamdansers_lv2/core/widgets/snackbar/custom_snackbar.dart';
import 'package:tamdansers_lv2/core/widgets/textfield.dart/custom_textfield.dart';
import 'package:tamdansers_lv2/data/model/permission_model.dart';

part 'ask_permission_screen_binding.dart';
part 'ask_permission_screen_controller.dart';

class AskPermissionScreenView
    extends GetView<AskPermissionScreenViewController> {
  const AskPermissionScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  'My Permission Requests',
                  style: Get.textTheme.titleSmall,
                ),
                const SizedBox(height: AppNumbers.spacingMedium),
                Obx(() {
                  if (controller.permissionRequests.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppNumbers.cardPadding),
                      decoration: BoxDecoration(
                        color: Get.theme.cardColor,
                        borderRadius:
                            BorderRadius.circular(AppNumbers.radiusLarge),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.fact_check_outlined,
                            size: AppNumbers.iconLarge,
                            color: AppColors.grey,
                          ),
                          const SizedBox(height: AppNumbers.spacingSmall),
                          Text(
                            'No permission requests yet',
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

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppNumbers.cardPadding),
                        decoration: BoxDecoration(
                          color: Get.theme.cardColor,
                          borderRadius:
                              BorderRadius.circular(AppNumbers.radiusLarge),
                          border: Border.all(color: AppColors.border),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(28, 28, 30, 0.04),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    request.type,
                                    style: Get.textTheme.titleSmall?.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppNumbers.spacingMedium,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(
                                        AppNumbers.radiusPill),
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
                            const SizedBox(height: AppNumbers.spacingSmall),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: AppNumbers.icon16,
                                  color: AppColors.grey,
                                ),
                                const SizedBox(width: AppNumbers.spacingSmall),
                                Expanded(
                                  child: Text(
                                    '${request.fromDate} - ${request.toDate}',
                                    style: Get.textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppNumbers.spacingSmall),
                            Text(
                              'Reason: ${request.reason}',
                              style: Get.textTheme.bodyMedium,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppNumbers.cardPadding),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(AppNumbers.radiusLarge),
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request Permission',
              style: Get.textTheme.titleSmall,
            ),
            const SizedBox(height: AppNumbers.spacingLarge),
            Text(
              'Permission Type',
              style: Get.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppNumbers.spacingSmall),
            Obx(
              () => DropdownButtonFormField<String>(
                initialValue: controller.selectedType.value,
                hint: Text(
                  'Select permission type',
                  style: Get.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.hintColor),
                ),
                items: controller.permissionTypes
                    .map(
                      (type) => DropdownMenuItem<String>(
                        value: type,
                        child: Text(type, style: Get.textTheme.bodyMedium),
                      ),
                    )
                    .toList(),
                onChanged: (value) => controller.selectedType.value = value,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.white,
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
                dropdownColor: AppColors.white,
                borderRadius: BorderRadius.circular(AppNumbers.radiusMedium),
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
              ),
            ),
            const SizedBox(height: AppNumbers.spacingLarge),
            Obx(
              () => _buildDateField(
                label: 'From Date',
                value: controller.formatDate(controller.fromDate.value),
                onTap: () => controller.pickFromDate(context),
              ),
            ),
            const SizedBox(height: AppNumbers.spacingLarge),
            Obx(
              () => _buildDateField(
                label: 'To Date',
                value: controller.formatDate(controller.toDate.value),
                onTap: () => controller.pickToDate(context),
              ),
            ),
            const SizedBox(height: AppNumbers.spacingLarge),
            Text(
              'Reason',
              style: Get.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppNumbers.spacingSmall),
            CustomTextField(
              hintText: 'Write your reason...',
              controller: controller.reasonCtrl,
              isMultiline: true,
            ),
            const SizedBox(height: AppNumbers.spacingLarge),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(
                () => CustomButton(
                  text: 'Submit Request',
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

  Widget _buildDateField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final isPlaceholder = value == 'Select date';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Get.textTheme.bodyMedium,
        ),
        const SizedBox(height: AppNumbers.spacingSmall),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppNumbers.radiusMedium),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppNumbers.spacingMedium,
              vertical: AppNumbers.spacingMedium,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppNumbers.radiusMedium),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color:
                          isPlaceholder ? AppColors.hintColor : AppColors.dark,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_month_outlined,
                  size: AppNumbers.iconMedium,
                  color: AppColors.grey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }

  String _capitalizeStatus(String status) {
    if (status.isEmpty) {
      return status;
    }

    return '${status[0].toUpperCase()}${status.substring(1).toLowerCase()}';
  }
}
