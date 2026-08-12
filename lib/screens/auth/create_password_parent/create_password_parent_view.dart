import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tamdansers_lv2/app/routes/app_routes.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/core/api/services/auth_services.dart';
import 'package:tamdansers_lv2/core/utils/dio_exception_handler.dart';
import 'package:tamdansers_lv2/core/widgets/appbar/custom_appbar.dart';
import 'package:tamdansers_lv2/core/widgets/button/custom_button.dart';
import 'package:tamdansers_lv2/core/widgets/snackbar/custom_snackbar.dart';
import 'package:tamdansers_lv2/core/widgets/textfield.dart/custom_textfield.dart';

part 'create_password_parent_binding.dart';
part 'create_password_parent_controller.dart';

class CreatePasswordParentView extends GetView<CreatePasswordParentViewController> {
  const CreatePasswordParentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: const CustomAppBar(title: '', showNotification: false),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 28),
              _buildForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.22),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(PhosphorIconsRegular.lock, color: AppColors.white, size: 36),
        ),
        const SizedBox(height: 18),
        Text(
          'create_parent_password'.tr,
          style: Get.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'create_password_description'.tr,
          textAlign: TextAlign.center,
          style: Get.textTheme.bodyMedium?.copyWith(
            // color: AppColors.hintColor,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'password'.tr,
            style: Get.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Obx(
            () => CustomTextField(
              hintText: 'enter_password'.tr,
              controller: controller.newPasswordCtrl,
              prefixIcon: const Icon(PhosphorIconsRegular.lock),
              isPwd: true,
              isHide: controller.isHideNewPwd.value,
              suffixIcon: Bounceable(
                onTap: controller.toggleNewPwd,
                child: Icon(
                  controller.isHideNewPwd.value
                      ? PhosphorIconsRegular.eyeSlash
                      : PhosphorIconsRegular.eye,
                  color: AppColors.dark,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'please_fill_all_fields'.tr;
                }
                if (value.length < 6) {
                  return 'password_min_length'.tr;
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'confirm_password'.tr,
            style: Get.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Obx(
            () => CustomTextField(
              hintText: 'enter_confirm_password'.tr,
              controller: controller.confirmPasswordCtrl,
              prefixIcon: const Icon(PhosphorIconsRegular.lock),
              isPwd: true,
              isHide: controller.isHideCfPwd.value,
              suffixIcon: Bounceable(
                onTap: controller.toggleCfPwd,
                child: Icon(
                  controller.isHideCfPwd.value
                      ? PhosphorIconsRegular.eyeSlash
                      : PhosphorIconsRegular.eye,
                  color: AppColors.dark,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'please_fill_all_fields'.tr;
                }
                if (value != controller.newPasswordCtrl.text) {
                  return 'passwords_mismatch'.tr;
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: Obx(
              () => CustomButton(
                text: 'continue_label'.tr,
                onPressed: controller.createPassword,
                isLoading: controller.isLoading.value,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
