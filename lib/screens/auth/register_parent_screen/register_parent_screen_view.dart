import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tamdansers_lv2/app/constants/app_icons.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/core/widgets/appbar/custom_appbar.dart';
import 'package:tamdansers_lv2/core/widgets/button/custom_button.dart';
import 'package:tamdansers_lv2/core/widgets/textfield.dart/custom_textfield.dart';
import 'package:tamdansers_lv2/core/widgets/textfield.dart/phone_textfield.dart';

part 'register_parent_screen_binding.dart';
part 'register_parent_screen_controller.dart';

class RegisterParentScreenView
    extends GetView<RegisterParentScreenViewController> {
  const RegisterParentScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: const CustomAppBar(title: '', showNotification: false),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 28),
              _buildRegistrationForm(),
              const SizedBox(height: 20),
              _buildLoginPrompt(),
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
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.22),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            PhosphorIconsRegular.usersThree,
            color: AppColors.white,
            size: 38,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Create parent account'.tr,
          textAlign: TextAlign.center,
          style: Get.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Link your account to your child using their student ID.'.tr,
          textAlign: TextAlign.center,
          style: Get.textTheme.bodyMedium?.copyWith(
            color: AppColors.hintColor,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationForm() {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(
              'Account details'.tr,
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Enter the details registered with the school.'.tr,
              style: Get.textTheme.bodySmall?.copyWith(
                color: AppColors.hintColor,
              ),
            ),
            const SizedBox(height: 24),
            _FieldLabel(label: 'Student ID'.tr, required: true),
            const SizedBox(height: 8),
            CustomTextField(
              hintText: 'Enter your child’s student ID'.tr,
              controller: controller.studentIdCtrl,
              prefixIcon: Icon(PhosphorIconsRegular.user),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Student ID is required.'.tr;
                if (value.trim().length < 3) return 'Enter a valid student ID.'.tr;
                return null;
              },
            ),
            const SizedBox(height: 18),
            _FieldLabel(label: 'Parent’s phone number'.tr, required: true),
            const SizedBox(height: 8),
            PhoneTextField(
              hintText: 'Enter your phone number'.tr,
              controller: controller.phoneCtrl,
              countryCode: '+855',
              flagAsset: AppIcons.khmerIcon,
              validator: (value) {
                final phone = value?.trim() ?? '';
                if (phone.isEmpty) return 'Phone number is required.'.tr;
                if (!RegExp(r'^[0-9]{8,10}$').hasMatch(phone)) {
                  return 'Enter a valid phone number.'.tr;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _PrivacyNotice(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Obx(
                () => CustomButton(
                  text: 'Continue'.tr,
                  onPressed: controller.continueRegistration,
                  isLoading: controller.isLoading.value,
                  variant: ButtonVariant.primary,
                  suffixIcon: Icon(
                    PhosphorIconsRegular.arrowRight,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account?'.tr,
          style: Get.textTheme.bodyMedium?.copyWith(color: AppColors.hintColor),
        ),
        const SizedBox(width: 8),
        Bounceable(
          onTap: Get.back,
          child: Text(
            'Sign in'.tr,
            style: Get.textTheme.bodyMedium?.copyWith(
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
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: AppColors.error),
            ),
        ],
      ),
    );
  }
}

class _PrivacyNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          PhosphorIconsRegular.shieldCheck,
          color: AppColors.primary,
          size: 19,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Your information is securely used only to verify your parent account.'.tr,
            style: Get.textTheme.bodySmall?.copyWith(
              color: AppColors.hintColor,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
