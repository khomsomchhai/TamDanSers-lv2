import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tamdansers_lv2/app/routes/app_routes.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_numbers.dart';
import 'package:tamdansers_lv2/core/api/services/auth_services.dart';
import 'package:tamdansers_lv2/core/widgets/appbar/custom_appbar.dart';
import 'package:tamdansers_lv2/core/widgets/button/custom_button.dart';
import 'package:tamdansers_lv2/core/widgets/snackbar/custom_snackbar.dart';
import 'package:tamdansers_lv2/core/widgets/textfield.dart/custom_textfield.dart';

part 'reset_password_screen_binding.dart';
part 'reset_password_screen_controller.dart';

class ResetPasswordScreenView
    extends GetView<ResetPasswordScreenViewController> {
  const ResetPasswordScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        title: '',
        showNotification: false,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 28),
              _buildForm(context),
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
                color: AppColors.primary.withValues(alpha: 0.22),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.lock_reset_rounded, color: AppColors.white, size: 36),
        ),
        const SizedBox(height: 18),
        Text(
          'Create a new password'.tr,
          style: Get.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the 6-digit code sent to your phone by SMS and choose a new password.'
              .tr,
          textAlign: TextAlign.center,
          style: Get.textTheme.bodyMedium?.copyWith(
            color: AppColors.hintColor,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            'Verification Code(OTP)'.tr,
            style: Get.textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              6,
              (index) => _buildOtpBox(context, index),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'New Password'.tr,
            style: Get.textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Obx(
            () => CustomTextField(
              hintText: 'Enter new password'.tr,
              controller: controller.newPasswordCtrl,
              prefixIcon: Icon(PhosphorIconsRegular.lock),
              isPwd: true,
              isHide: controller.isHideNewPwd.value,
              suffixIcon: Bounceable(
                onTap: () {
                  controller.toggleNewPwd();
                },
                child: Icon(
                  controller.isHideNewPwd.value
                      ? PhosphorIconsRegular.eyeSlash
                      : PhosphorIconsRegular.eye,
                  color: AppColors.dark,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required'.tr;
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters'.tr;
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Confirm Password'.tr,
            style: Get.textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Obx(
            () => CustomTextField(
              hintText: 'Confirm new password'.tr,
              controller: controller.confirmPasswordCtrl,
              prefixIcon: Icon(PhosphorIconsRegular.lock),
              isPwd: true,
              isHide: controller.isHideCfPwd.value,
              suffixIcon: Bounceable(
                onTap: () {
                  controller.toggleCfPwd();
                },
                child: Icon(
                  controller.isHideCfPwd.value
                      ? PhosphorIconsRegular.eyeSlash
                      : PhosphorIconsRegular.eye,
                  color: AppColors.dark,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required'.tr;
                }
                if (value != controller.newPasswordCtrl.text) {
                  return 'Passwords do not match'.tr;
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.timerText.value,
                  style: Get.textTheme.bodySmall,
                ),
                TextButton(
                  onPressed: controller.canResend.value
                      ? controller.resendOtp
                      : null,
                  child: Text('Resend OTP'.tr),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 50,
            width: double.infinity,
            child: Obx(
              () => CustomButton(
                text: 'Reset Password'.tr,
                onPressed: () {
                  Get.focusScope?.unfocus();
                  controller.resetPassword();
                },
                variant: ButtonVariant.primary,
                isLoading: controller.isLoading.value,
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpBox(BuildContext context, int index) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: index < 5 ? 8 : 0),
        child: SizedBox(
          height: 56,
          child: TextFormField(
            controller: controller.otpControllers[index],
            focusNode: controller.otpFocusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppNumbers.radiusMedium),
                borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.25)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppNumbers.radiusMedium),
                borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.25)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppNumbers.radiusMedium),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
            onChanged: (value) => controller.handleOtpChanged(context, index, value),
          ),
        ),
      ),
    );
  }
}
