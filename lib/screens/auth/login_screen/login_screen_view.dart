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

class _AuthTabData {
  const _AuthTabData({required this.icon, required this.labelKey});

  final IconData icon;
  final String labelKey;
}

const List<_AuthTabData> _kAuthTabs = [
  _AuthTabData(icon: PhosphorIconsRegular.student, labelKey: 'student'),
  _AuthTabData(icon: PhosphorIconsRegular.users, labelKey: 'parent'),
];

class LoginScreenView extends GetView<LoginScreenViewController> {
  const LoginScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            left: -50,
            child: _BackgroundBlob(
              size: 220,
              color: theme.colorScheme.primary.withOpacity(0.08),
            ),
          ),
          Positioned(
            bottom: -70,
            right: -40,
            child: _BackgroundBlob(
              size: 240,
              color: theme.colorScheme.secondary.withOpacity(0.08),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: _buildLanguageSwitcher(theme),
                        ),
                        const SizedBox(height: 8),
                        _buildHeader(theme),
                        const SizedBox(height: 46),
                        _AuthTabBar(controller: controller, theme: theme),
                        const SizedBox(height: 24),
                        _buildForm(theme),
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
    return Hero(
      tag: 'app_logo',
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.primary,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.18),
              blurRadius: 22,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SvgPicture.asset(
            AppIcons.appIconPrimary,
            colorFilter:
                ColorFilter.mode(theme.colorScheme.onPrimary, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSwitcher(ThemeData theme) {
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
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: AppColors.dark.withOpacity(0.05),
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
              Get.locale?.languageCode == 'km'
                  ? 'language_khmer'.tr
                  : 'language_english'.tr,
              style: GoogleFonts.kantumruyPro(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: theme.iconTheme.color?.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(ThemeData theme) {
    return Form(
      key: controller.formKey,
      child: Obx(
        () => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            final isOutgoing = animation.status == AnimationStatus.reverse;
            final direction =
                controller.selectedTab.value >= controller.previousTab.value
                    ? 1.0
                    : -1.0;
            final begin = isOutgoing ? Offset.zero : Offset(direction * 0.2, 0);
            final end = isOutgoing ? Offset(direction * 0.2, 0) : Offset.zero;

            return SlideTransition(
              position: Tween<Offset>(begin: begin, end: end).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
              ),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          layoutBuilder: (currentChild, previousChildren) => Stack(
            alignment: Alignment.topCenter,
            children: [...previousChildren, if (currentChild != null) currentChild],
          ),
          child: Column(
            key: ValueKey(controller.selectedTab.value),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'sign_in_title'.tr,
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: controller.selectedTab.value == 1
                    ? 'hint_parent_student_id'.tr
                    : 'hint_id'.tr,
                controller: controller.currentIdCtrl,
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
                  controller: controller.currentPwdCtrl,
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
                    onTap: controller.togglePwd,
                    child: Icon(
                      controller.isHidePwd.value
                          ? PhosphorIconsRegular.eyeSlash
                          : PhosphorIconsRegular.eye,
                      color: theme.iconTheme.color,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Bounceable(
                    onTap: () => Get.toNamed(AppRoutes.forgetPasswordScreen),
                    child: Text(
                      'forget_password'.tr,
                      style: Get.textTheme.bodyLarge?.copyWith(
                        color: AppColors.info,
                      ),
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
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final isVisibleFooter = child.key == const ValueKey('footer_visible');
            final isOutgoing = animation.status == AnimationStatus.reverse;
            final begin =
                isVisibleFooter && !isOutgoing ? const Offset(0.2, 0) : Offset.zero;
            final end =
                isVisibleFooter && isOutgoing ? const Offset(0.2, 0) : Offset.zero;

            return SlideTransition(
              position: Tween<Offset>(begin: begin, end: end).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
              ),
              child: FadeTransition(opacity: animation, child: child),
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
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Bounceable(
                      onTap: () => Get.toNamed(AppRoutes.registerParentScreen),
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
}

class _BackgroundBlob extends StatelessWidget {
  const _BackgroundBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _AuthTabBar extends StatelessWidget {
  const _AuthTabBar({required this.controller, required this.theme});

  final LoginScreenViewController controller;
  final ThemeData theme;

  static const double _height = 56;
  static const double _padding = 4;
  static const double _indicatorHeight = 42;
  static const Duration _duration = Duration(milliseconds: 450);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      padding: const EdgeInsets.all(_padding),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: theme.dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.dark.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth =
              (constraints.maxWidth - _padding * 2) / _kAuthTabs.length;

          return Obx(
            () => Stack(
              children: [
                _TabIndicator(
                  selectedIndex: controller.selectedTab.value,
                  tabWidth: tabWidth,
                  height: _indicatorHeight,
                  color: theme.colorScheme.primary,
                  duration: _duration,
                ),
                Row(
                  children: [
                    for (var i = 0; i < _kAuthTabs.length; i++)
                      Expanded(
                        child: _TabButton(
                          data: _kAuthTabs[i],
                          isSelected: controller.selectedTab.value == i,
                          inactiveColor: theme.hintColor,
                          textStyle: Get.textTheme.bodyLarge,
                          duration: _duration,
                          onTap: () => controller.changeTab(i),
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
}

class _TabIndicator extends StatelessWidget {
  const _TabIndicator({
    required this.selectedIndex,
    required this.tabWidth,
    required this.height,
    required this.color,
    required this.duration,
  });

  final int selectedIndex;
  final double tabWidth;
  final double height;
  final Color color;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: duration,
      curve: Curves.easeOutCubic,
      left: 3 + (selectedIndex * (tabWidth + 3)),
      top: 2,
      child: Container(
        width: tabWidth,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.9)],
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
    );
  }
}
class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.data,
    required this.isSelected,
    required this.inactiveColor,
    required this.textStyle,
    required this.duration,
    required this.onTap,
  });

  final _AuthTabData data;
  final bool isSelected;
  final Color inactiveColor;
  final TextStyle? textStyle;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final contentColor = isSelected ? AppColors.white : inactiveColor;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        splashColor: AppColors.transparent,
        highlightColor: AppColors.transparent,
        child: Container(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                duration: duration,
                curve: Curves.easeOutCubic,
                scale: isSelected ? 1.1 : 0.95,
                child: Icon(data.icon, size: 20, color: contentColor),
              ),
              const SizedBox(width: 8),
              AnimatedDefaultTextStyle(
                duration: duration,
                curve: Curves.easeOutCubic,
                style: (textStyle ?? const TextStyle()).copyWith(
                  fontWeight: FontWeight.w700,
                  color: contentColor,
                ),
                child: Text(data.labelKey.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}