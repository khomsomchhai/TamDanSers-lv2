import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tamdansers_lv2/app/constants/app_icons.dart';
import 'package:tamdansers_lv2/app/routes/app_routes.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/core/api/services/auth_services.dart';
import 'package:tamdansers_lv2/core/utils/dio_exception_handler.dart';
import 'package:tamdansers_lv2/core/widgets/appbar/custom_appbar.dart';
import 'package:tamdansers_lv2/core/widgets/button/custom_button.dart';
import 'package:tamdansers_lv2/core/widgets/snackbar/custom_snackbar.dart';
import 'package:tamdansers_lv2/core/widgets/textfield.dart/custom_textfield.dart';
import 'package:tamdansers_lv2/core/widgets/textfield.dart/phone_textfield.dart';

part 'register_parent_screen_binding.dart';
part 'register_parent_screen_controller.dart';

class RegisterParentScreenView
    extends GetView<RegisterParentScreenViewController> {
  const RegisterParentScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: '', showNotification: false),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                  children: [
                    _buildHeader(theme),
                    const SizedBox(height: 28),
                    _buildRegistrationForm(theme),
                    const SizedBox(height: 20),
                    
                  ],
                ),
              ),
            ),
            _buildLoginPrompt(theme),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.22),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            PhosphorIconsRegular.users,
            color: theme.colorScheme.onPrimary,
            size: 38,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'create_parent_account'.tr,
          textAlign: TextAlign.center,
          style: Get.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'link_account_child'.tr,
          textAlign: TextAlign.center,
          style: Get.textTheme.bodyMedium?.copyWith(
            // color: theme.hintColor,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationForm(ThemeData theme) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(
              'account_details'.tr,
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'account_details_hint'.tr,
              style: Get.textTheme.bodySmall?.copyWith(
                // color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 24),
            _FieldLabel(label: 'student_id_label'.tr, required: true),
            const SizedBox(height: 8),
            CustomTextField(
              hintText: 'enter_student_id'.tr,
              controller: controller.studentIdCtrl,
              prefixIcon: Icon(PhosphorIconsRegular.user),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'student_id_required'.tr;
                if (value.trim().length < 3) return 'enter_valid_student_id'.tr;
                return null;
              },
            ),
            const SizedBox(height: 18),
            _FieldLabel(label: 'parent_phone_number'.tr, required: true),
            const SizedBox(height: 8),
            PhoneTextField(
              hintText: 'enter_phone_number'.tr,
              controller: controller.phoneCtrl,
              countryCode: '+855',
              flagAsset: AppIcons.khmerIcon,
              validator: (value) {
                final phone = value?.trim() ?? '';
                if (phone.isEmpty) return 'parent_phone_required'.tr;
                if (!RegExp(r'^[0-9]{8,10}$').hasMatch(phone)) {
                  return 'enter_valid_phone'.tr;
                }
                return null;
              },
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Obx(
                () => CustomButton(
                  text: 'continue_label'.tr,
                  onPressed: controller.continueRegistration,
                  isLoading: controller.isLoading.value,
                  variant: ButtonVariant.primary,
                  
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'already_have_account'.tr,
          style: Get.textTheme.bodyLarge,
        ),
        const SizedBox(width: 8),
        Bounceable(
          onTap: Get.back,
          child: Text(
            'sign_in'.tr,
            style: Get.textTheme.bodyLarge?.copyWith(
              color: AppColors.info,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.required});

  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: label,
        style: Get.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        children: [
          // if (required)
          //   const TextSpan(
          //     text: ' *',
          //   ),
        ],
      ),
    );
  }
}
