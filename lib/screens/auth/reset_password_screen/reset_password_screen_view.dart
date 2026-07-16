import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:get/get.dart';
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
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        title: 'Reset Password'.tr,
        showNotification: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildHeader(),
                          const SizedBox(height: 24),
                          _buildForm(context),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Enter the 6-digit code sent to your Telegram and choose a new password.'
              .tr,
          textAlign: TextAlign.center,
          style: Get.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: controller.formKey,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                List.generate(6, (index) => _buildOtpBox(context, index)),
          ),
          const SizedBox(height: 20),
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
              prefixIcon: const Icon(Icons.lock_outline),
              isPwd: true,
              isHide: controller.isHideNewPwd.value,
              suffixIcon: Bounceable(
                onTap: () {
                  controller.toggleNewPwd();
                },
                child: Icon(
                  controller.isHideNewPwd.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.dark,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required'.tr;
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
              prefixIcon: const Icon(Icons.lock_outline),
              isPwd: true,
              isHide: controller.isHideCfPwd.value,
              suffixIcon: Bounceable(
                onTap: () {
                  controller.toggleCfPwd();
                },
                child: Icon(
                  controller.isHideCfPwd.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.dark,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required'.tr;
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 20),
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
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            width: double.infinity,
            child: Obx(
              () => CustomButton(
                text: 'Reset Password'.tr,
                onPressed: () {
                  Get.focusScope!.unfocus();
                  controller.resetPassword();
                },
                variant: ButtonVariant.primary,
                isLoading: controller.isLoading.value,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpBox(BuildContext context, int index) {
    return SizedBox(
      width: 50,
      height: 56,
      child: TextFormField(
        controller: controller.otpControllers[index],
        focusNode: controller.otpFocusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
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
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context)
                .requestFocus(controller.otpFocusNodes[index + 1]);
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context)
                .requestFocus(controller.otpFocusNodes[index - 1]);
          }
        },
      ),
    );
  }
}
