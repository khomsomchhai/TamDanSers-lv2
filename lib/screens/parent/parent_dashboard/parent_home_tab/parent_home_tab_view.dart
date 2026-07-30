import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_text_styles.dart';
import 'package:tamdansers_lv2/core/api/controllers/user_controller.dart';
import 'package:tamdansers_lv2/core/api/services/result_api.dart';
import 'package:tamdansers_lv2/core/widgets/card/parent_card_progress.dart';
import 'package:tamdansers_lv2/core/widgets/header/custom_header.dart';
import 'package:tamdansers_lv2/core/widgets/header/custom_header_action.dart';
import 'package:tamdansers_lv2/core/widgets/header/custom_header_placeholder.dart';
import 'package:tamdansers_lv2/data/model/parent_model.dart';

part 'parent_home_tab_binding.dart';
part 'parent_home_tab_controller.dart';

class ParentHomeTabView extends GetView<ParentHomeTabViewController> {
  const ParentHomeTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              toolbarHeight: 88,
              expandedHeight: screenHeight * 0.43,
              backgroundColor: AppColors.primary,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: _buildHeader(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'attendance'.tr,
                        style: AppTextStyles.titleSmall
                            .copyWith(color: AppColors.dark),
                      ),
                      const SizedBox(height: 14),
                    ]),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        16,
        14,
        16,
        22,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopHeader(),
          const SizedBox(height: 14),
          Text(
            controller.getCurrentDate(),
            style: Get.textTheme.bodyLarge?.copyWith(
              color: AppColors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 18),
          _buildChildSection(),
          const SizedBox(height: 20),
          ParentCardProgress(),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => controller.isLoading.value
                ? const CustomHeaderPlaceholder()
                : CustomHeader(
                    controller: controller.userController,
                  ),
          ),
        ),
        const SizedBox(width: 12),
        const CustomHeaderAction(),
      ],
    );
  }

  Widget _buildChildSection() {
    return Obx(() {
      if (controller.students.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.30),
            ),
          ),
          child: Text(
            'dont_have_child'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hello parent and student code
          Row(
            children: [
              Expanded(
                child: Text(
                  '${'hello_parent'.tr} ${controller.childName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  controller.childCode,
                  style: TextStyle(
                    color: AppColors.info,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Child dropdown
          Container(
            width: double.infinity,
            height: 62,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Map<String, dynamic>>(
                value: controller.selectedChild.value,
                isExpanded: true,
                menuMaxHeight: 300,
                dropdownColor: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.info,
                  size: 28,
                ),
                selectedItemBuilder: (context) {
                  return controller.students.map((student) {
                    return _buildSelectedChild(student);
                  }).toList();
                },
                items: controller.students.map((student) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: student,
                    child: _buildDropdownChild(student),
                  );
                }).toList(),
                onChanged: (child) {
                  if (child != null) {
                    controller.selectChild(child);
                  }
                },
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSelectedChild(
    Map<String, dynamic> student,
  ) {
    final name = student['student_name']?.toString() ?? '-';

    final code = student['student_code']?.toString() ?? '-';

    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.info.withValues(alpha: 0.12),
          child: Icon(
            Icons.person_outline_rounded,
            color: AppColors.info,
            size: 21,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                code,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownChild(
    Map<String, dynamic> student,
  ) {
    final name = student['student_name']?.toString() ?? '-';

    final code = student['student_code']?.toString() ?? '-';

    final selectedId = controller.selectedChild.value?['id'];

    final isSelected = selectedId?.toString() == student['id']?.toString();

    return SizedBox(
      height: 58,
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: isSelected
                ? AppColors.info
                : AppColors.info.withValues(alpha: 0.12),
            child: Icon(
              Icons.person_outline_rounded,
              color: isSelected ? AppColors.white : AppColors.info,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? AppColors.info : Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  code,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check_circle_rounded,
              color: AppColors.info,
              size: 20,
            ),
        ],
      ),
    );
  }
}
