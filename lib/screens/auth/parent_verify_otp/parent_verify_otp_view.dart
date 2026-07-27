import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tamdansers_lv2/app/routes/app_routes.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_numbers.dart';
import 'package:tamdansers_lv2/core/api/services/auth_services.dart';
import 'package:tamdansers_lv2/core/utils/dio_exception_handler.dart';
import 'package:tamdansers_lv2/core/widgets/appbar/custom_appbar.dart';
import 'package:tamdansers_lv2/core/widgets/button/custom_button.dart';
import 'package:tamdansers_lv2/core/widgets/snackbar/custom_snackbar.dart';

part 'parent_verify_otp_binding.dart';
part 'parent_verify_otp_controller.dart';

class ParentVerifyOtpView extends GetView<ParentVerifyOtpViewController> {
  const ParentVerifyOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
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
          child: const Icon(PhosphorIconsRegular.shieldCheck, color: AppColors.white, size: 36),
        ),
        const SizedBox(height: 18),
        Text(
          'verification_code_otp'.tr,
          style: Get.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'otp_instructions'.tr,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              6,
              (index) => _buildOtpBox(context, index),
            ),
          ),
          const SizedBox(height: 22),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(controller.timerText.value, style: Get.textTheme.bodySmall),
                TextButton(
                  onPressed: controller.canResend.value ? controller.resendOtp : null,
                  child: Text('resend_otp'.tr),
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
                text: 'continue_label'.tr,
                onPressed: controller.verifyOtp,
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