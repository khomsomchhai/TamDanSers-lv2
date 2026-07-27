import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_text_styles.dart';
import 'package:tamdansers_lv2/core/api/controllers/user_controller.dart';
import 'package:tamdansers_lv2/core/widgets/header/custom_header.dart';
import 'package:tamdansers_lv2/core/widgets/header/custom_header_action.dart';
import 'package:tamdansers_lv2/core/widgets/header/custom_header_placeholder.dart';

part 'parent_home_tab_binding.dart';
part 'parent_home_tab_controller.dart';

class ParentHomeTabView extends GetView<ParentHomeTabViewController> {
  const ParentHomeTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              toolbarHeight: 88,
              expandedHeight: 180,
              automaticallyImplyLeading: false,
              backgroundColor: AppColors.info,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              flexibleSpace: _buildHeader(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
              CustomHeaderAction(),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                "${'hello_parent'.tr} ${controller.childName}",
                style:
                    AppTextStyles.titleMedium.copyWith(color: AppColors.white),
              ),
              Spacer(),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(controller.childCode))
            ],
          )
        ],
      ),
    );
  }
}
