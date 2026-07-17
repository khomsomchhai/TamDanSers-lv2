import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tamdansers_lv2/app/constants/app_icons.dart';
import 'package:tamdansers_lv2/app/constants/app_images.dart';
import 'package:tamdansers_lv2/app/routes/app_routes.dart';
import 'package:tamdansers_lv2/core/api/services/auth_services.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: "",
        showNotification: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const SizedBox(height: 32),

                      Center(
                        child: SizedBox(
                          width: 200,
                          height: 200,
                          child: SvgPicture.asset(
                            AppImages.forgetPassword,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Headline
                      Center(
                        child: Text(
                          'Forgot Password?'.tr,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Subtitle
                      Center(
                        child: Text(
                          'Enter your phone number and we will send you a verification code by SMS.'
                              .tr,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7) ??
                                Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

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
                                if (!RegExp(r'^[0-9]{8,10}$').hasMatch(value)) {
                                  return "Invalid phone number".tr;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom-anchored CTA
              Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 12),
                child: Column(
                  children: [
                    SizedBox(
                      height: 52,
                      width: double.infinity,
                      child: Obx(
                        () => CustomButton(
                          text: "Continue".tr,
                          onPressed: () {
                            Get.focusScope?.unfocus();
                            controller.submitPhone();
                          },
                          variant: ButtonVariant.primary,
                          isLoading: controller.isLoading.value,
                        ),
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