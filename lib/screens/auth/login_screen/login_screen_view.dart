import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tamdansers_lv2/app/constants/app_icons.dart';
import 'package:tamdansers_lv2/app/localization/localization_service.dart';
import 'package:tamdansers_lv2/app/routes/app_routes.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
import 'package:tamdansers_lv2/app/themes/app_numbers.dart';
import 'package:tamdansers_lv2/core/api/services/auth_services.dart';
import 'package:tamdansers_lv2/core/widgets/button/custom_button.dart';
import 'package:tamdansers_lv2/core/widgets/snackbar/custom_snackbar.dart';
import 'package:tamdansers_lv2/core/widgets/textfield.dart/custom_textfield.dart';

part 'login_screen_binding.dart';
part 'login_screen_controller.dart';

class LoginScreenView extends GetView<LoginScreenViewController> {
  const LoginScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            left: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -70,
            right: -40,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.info.withValues(alpha: 0.08),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: _buildLanguageSwitcher(),
                        ),
                        const SizedBox(height: 8),
                        _buildHeader(theme),
                        const SizedBox(height: 24),
                        _buildForm(),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: _buildFooter(context, theme),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Hero(
          tag: 'app_logo',
          child: Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 22,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SvgPicture.asset(
                AppIcons.appIconPrimary,
                colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Welcome back'.tr,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Login to continue to your account'.tr,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.hintColor,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSwitcher() {
    return PopupMenuButton<String>(
      onSelected: (lang) => LocalizationService().changeLocale(lang),
      position: PopupMenuPosition.under,
      borderRadius: BorderRadius.circular(AppNumbers.radiusMedium),
      elevation: 4,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'en',
          child: Row(
            children: [
              Image.asset(AppIcons.englishIcon, width: 22),
              const SizedBox(width: 10),
              Text('English', style: Get.textTheme.bodyMedium),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'km',
          child: Row(
            children: [
              Image.asset(AppIcons.khmerIcon, width: 22),
              const SizedBox(width: 10),
              Text('ភាសាខ្មែរ', style: GoogleFonts.kantumruyPro()),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.dark.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              Get.locale?.languageCode == 'km'
                  ? AppIcons.khmerIcon
                  : AppIcons.englishIcon,
              width: 20,
            ),
            const SizedBox(width: 8),
            Text(
              Get.locale?.languageCode == 'km' ? 'ភាសាខ្មែរ' : 'English',
              style: GoogleFonts.kantumruyPro(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppColors.dark.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'login_title'.tr,
            style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          CustomTextField(
            hintText: 'hint_id'.tr,
            controller: controller.idCtrl,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Required'.tr;
              }
              return null;
            },
            prefixIcon: Icon(PhosphorIconsRegular.user),
          ),
          const SizedBox(height: 16),
          Obx(
            () => CustomTextField(
              hintText: 'hint_password'.tr,
              controller: controller.pwdCtrl,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required'.tr;
                }
                return null;
              },
              prefixIcon: Icon(PhosphorIconsRegular.lock),
              isPwd: true,
              isHide: controller.isHidePwd.value,
              suffixIcon: Bounceable(
                onTap: () {
                  controller.togglePwd();
                },
                child: Icon(
                  controller.isHidePwd.value
                      ? PhosphorIconsRegular.eyeSlash
                      : PhosphorIconsRegular.eye,
                  color: AppColors.dark,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Bounceable(
                onTap: () {
                  Get.toNamed(AppRoutes.forgetPasswordScreen);
                },
                child: Text(
                  'forget_password'.tr,
                  style: Get.textTheme.bodyLarge?.copyWith(color: AppColors.info),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Obx(
            () => SizedBox(
              height: 50,
              width: double.infinity,
              child: CustomButton(
                text: 'login_title'.tr,
                onPressed: () {
                  Get.focusScope?.unfocus();
                  controller.login();
                },
                isLoading: controller.isLoading.value,
                variant: ButtonVariant.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'no_account'.tr,
          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.hintColor),
        ),
        const SizedBox(width: 8),
        Bounceable(
          onTap: () {
            _showRegistrationSheet(context);
          },
          child: Text(
            'register'.tr,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.info,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _showRegistrationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Join Tamdansers'.tr,
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose how you would like to use the app.'.tr,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: AppColors.hintColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      Get.toNamed(AppRoutes.registerParentScreen);
                    },
                    borderRadius: BorderRadius.circular(AppNumbers.radiusLarge),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(AppNumbers.radiusLarge),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              PhosphorIconsRegular.usersThree,
                              color: AppColors.primary,
                              size: 25,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'I am a parent'.tr,
                                  style: Get.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Stay connected to your child’s school life.'.tr,
                                  style: Get.textTheme.bodySmall?.copyWith(
                                    color: AppColors.hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            PhosphorIconsRegular.caretRight,
                            color: AppColors.hintColor,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
