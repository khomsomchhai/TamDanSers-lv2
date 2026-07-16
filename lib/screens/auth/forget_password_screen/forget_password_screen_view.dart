import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamdansers_lv2/app/constants/app_icons.dart';
import 'package:tamdansers_lv2/app/routes/app_routes.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/core/api/services/auth_services.dart';
import 'package:tamdansers_lv2/core/api/services/telegram_service.dart';
import 'package:tamdansers_lv2/core/widgets/appbar/custom_appbar.dart';
import 'package:tamdansers_lv2/core/widgets/button/custom_button.dart';
import 'package:tamdansers_lv2/core/widgets/snackbar/custom_snackbar.dart';
import 'package:tamdansers_lv2/core/widgets/textfield.dart/phone_textfield.dart';

part 'forget_password_screen_binding.dart';
part 'forget_password_screen_controller.dart';

class ForgetPasswordScreenView extends GetView<ForgetPasswordScreenViewController> {
  const ForgetPasswordScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Forget Password",
        showNotification: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              const SizedBox(height: 8),
              Text(
                'Enter your phone number and we will send you a verification code via Telegram.',
                style: Get.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PhoneTextField(
                      controller: controller.phoneCtrl,
                      hintText: 'Enter your phone number'.tr,
                      countryCode: '+855',
                      flagAsset: AppIcons.khmerIcon,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Required".tr;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.dark.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 52,
                                width: 52,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.telegram,
                                  color: AppColors.primary,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Telegram Not Connected',
                                  style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'To receive OTP verification codes for password recovery, please connect your Telegram account.',
                            style: Get.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 18),
                          Obx(
                            () => SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: controller.isTelegramLoading.value ? null : controller.connectTelegram,
                                icon: controller.isTelegramLoading.value
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(AppColors.primary),
                                        ),
                                      )
                                    : const Icon(Icons.telegram, color: AppColors.primary),
                                label: controller.isTelegramLoading.value
                                    ? Text(
                                        'Connecting...'.tr,
                                        style: Get.textTheme.bodyMedium?.copyWith(color: AppColors.primary),
                                      )
                                    : Text(
                                        'Connect Telegram',
                                        style: Get.textTheme.bodyMedium?.copyWith(color: AppColors.primary),
                                      ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColors.primary),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                          ),
                        ]
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: Obx(
                        () => CustomButton(
                          text: "Continue",
                          onPressed: () {
                            Get.focusScope?.unfocus();
                            controller.submitPhone();
                          },
                          variant: ButtonVariant.primary,
                          isLoading: controller.isLoading.value,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'By continuing, you agree to our Terms of Service and Privacy Policy.',
                        textAlign: TextAlign.center,
                        style: Get.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}