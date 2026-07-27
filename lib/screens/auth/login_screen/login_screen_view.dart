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
import 'package:tamdansers_lv2/core/api/controllers/user_controller.dart';
import 'package:tamdansers_lv2/core/api/services/auth_services.dart';
import 'package:tamdansers_lv2/core/utils/dio_exception_handler.dart';
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
                        const SizedBox(height: 46,),
                        _buildAuthTabBar(),
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
            width: 140,
            height: 140,
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
      ],
    );
  }
  Widget _buildAuthTabBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = (constraints.maxWidth - 8) / 2;
          return Obx(
            () => Stack(
              children: [
                // Sliding pill indicator
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: controller.selectedTab.value == 0 ? 3 : (tabWidth + 6),
                  top: 2,
                  child: Container(
                    width: tabWidth,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF5B5FEF),
                          Color(0xFF7B61FF),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5B5FEF).withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
                // Tab buttons
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => controller.changeTab(0),
                          borderRadius: BorderRadius.circular(26),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Container(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedScale(
                                  duration: const Duration(milliseconds: 200),
                                  scale: controller.selectedTab.value == 0 ? 1.1 : 0.95,
                                  child: Icon(
                                    PhosphorIconsRegular.student,
                                    size: 20,
                                    color: controller.selectedTab.value == 0
                                        ? Colors.white
                                        : AppColors.hintColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: Get.textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: controller.selectedTab.value == 0
                                        ? Colors.white
                                        : AppColors.dark,
                                  ),
                                  child: Text('student'.tr),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => controller.changeTab(1),
                          borderRadius: BorderRadius.circular(26),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Container(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedScale(
                                  duration: const Duration(milliseconds: 200),
                                  scale: controller.selectedTab.value == 1 ? 1.1 : 0.95,
                                  child: Icon(
                                    PhosphorIconsRegular.users,
                                    size: 20,
                                    color: controller.selectedTab.value == 1
                                        ? Colors.white
                                        : AppColors.hintColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: Get.textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: controller.selectedTab.value == 1
                                        ? Colors.white
                                        : AppColors.dark,
                                  ),
                                  child: Text('parent'.tr),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
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
              Text('language_english'.tr, style: Get.textTheme.bodyMedium),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'km',
          child: Row(
            children: [
              Image.asset(AppIcons.khmerIcon, width: 22),
              const SizedBox(width: 10),
              Text('language_khmer'.tr, style: GoogleFonts.kantumruyPro()),
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
              Get.locale?.languageCode == 'km' ? 'language_khmer'.tr : 'language_english'.tr,
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
      child: Obx(
        () => AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          transitionBuilder: (child, animation) {
            final direction = controller.selectedTab.value >= controller.previousTab.value ? 1 : -1;
            final slideOffset = Tween<Offset>(
              begin: Offset(direction.toDouble() * 0.3, 0),
              end: Offset.zero,
            );
            final scale = Tween<double>(begin: 0.92, end: 1.0);
            final opacity = Tween<double>(begin: 0.0, end: 1.0);
            
            return SlideTransition(
              position: slideOffset.animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
              ),
              child: ScaleTransition(
                scale: scale.animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
                ),
                child: FadeTransition(
                  opacity: opacity.animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
                  ),
                  child: child,
                ),
              ),
            );
          },
          child: Column(
            key: ValueKey(controller.selectedTab.value),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'sign_in_title'.tr,
                style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: controller.selectedTab.value == 1
                    ? 'hint_parent_student_id'.tr
                    : 'hint_id'.tr,
                controller: controller.idCtrl,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'student_id_required'.tr;
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
                      return 'Password is required'.tr;
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
                    text: 'sign_in_title'.tr,
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
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ThemeData theme) {
    return Obx(
      () {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final isVisibleFooter = child.key == const ValueKey('footer_visible');
            final isOutgoing = animation.status == AnimationStatus.reverse;
            final begin = isVisibleFooter && !isOutgoing
                ? const Offset(0.2, 0)
                : Offset.zero;
            final end = isVisibleFooter && isOutgoing
                ? const Offset(0.2, 0)
                : Offset.zero;

            return SlideTransition(
              position: Tween<Offset>(begin: begin, end: end)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic)),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: controller.selectedTab.value == 0
              ? const SizedBox(key: ValueKey('footer_hidden'))
              : Row(
                  key: const ValueKey('footer_visible'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'no_account'.tr,
                      style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.hintColor),
                    ),
                    const SizedBox(width: 8),
                    Bounceable(
                      onTap: () {
                        Get.toNamed(AppRoutes.registerParentScreen);
                      },
                      child: Text(
                        'sign_up'.tr,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  // void _showRegistrationSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (sheetContext) {
  //       return Container(
  //         decoration: BoxDecoration(
  //           color: Get.theme.colorScheme.surface,
  //           borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
  //         ),
  //         child: SafeArea(
  //           child: Padding(
  //             padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Center(
  //                   child: Container(
  //                     width: 44,
  //                     height: 5,
  //                     decoration: BoxDecoration(
  //                       color: AppColors.border,
  //                       borderRadius: BorderRadius.circular(999),
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 20),
  //                 Text(
  //                   'join_app'.tr,
  //                   style: Get.textTheme.titleLarge?.copyWith(
  //                     fontWeight: FontWeight.w700,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 8),
  //                 Text(
  //                   'choose_how_to_use'.tr,
  //                   style: Get.textTheme.bodyMedium?.copyWith(
  //                     color: AppColors.hintColor,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 20),
  //                 InkWell(
  //                   onTap: () {
  //                     Navigator.of(sheetContext).pop();
  //                     Get.toNamed(AppRoutes.registerParentScreen);
  //                   },
  //                   borderRadius: BorderRadius.circular(AppNumbers.radiusLarge),
  //                   child: Container(
  //                     padding: const EdgeInsets.all(16),
  //                     decoration: BoxDecoration(
  //                       color: AppColors.lightBackground,
  //                       borderRadius: BorderRadius.circular(AppNumbers.radiusLarge),
  //                       border: Border.all(color: AppColors.border),
  //                     ),
  //                     child: Row(
  //                       children: [
  //                         Container(
  //                           width: 48,
  //                           height: 48,
  //                           decoration: BoxDecoration(
  //                             color: AppColors.primary.withValues(alpha: 0.12),
  //                             borderRadius: BorderRadius.circular(14),
  //                           ),
  //                           child: Icon(
  //                             PhosphorIconsRegular.usersThree,
  //                             color: AppColors.primary,
  //                             size: 25,
  //                           ),
  //                         ),
  //                         const SizedBox(width: 14),
  //                         Expanded(
  //                           child: Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               Text(
  //                                 'i_am_parent'.tr,
  //                                 style: Get.textTheme.bodyLarge?.copyWith(
  //                                   fontWeight: FontWeight.w700,
  //                                 ),
  //                               ),
  //                               const SizedBox(height: 3),
  //                               Text(
  //                                 'stay_connected_child'.tr,
  //                                 style: Get.textTheme.bodySmall?.copyWith(
  //                                   color: AppColors.hintColor,
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                         Icon(
  //                           PhosphorIconsRegular.caretRight,
  //                           color: AppColors.hintColor,
  //                           size: 20,
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
}