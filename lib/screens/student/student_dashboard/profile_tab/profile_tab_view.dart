import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tamdansers_lv2/app/constants/app_icons.dart';
import 'package:tamdansers_lv2/app/localization/localization_service.dart';
import 'package:tamdansers_lv2/app/routes/app_routes.dart';
import 'package:tamdansers_lv2/core/api/controllers/user_controller.dart';
import 'package:tamdansers_lv2/core/services/theme_service.dart';
import 'package:tamdansers_lv2/core/widgets/appbar/custom_appbar.dart';

part 'profile_tab_binding.dart';
part 'profile_tab_controller.dart';

class ProfileTabView extends GetView<ProfileTabViewController> {
  const ProfileTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: "profile".tr,
        showBackButton: false
      ),
      body: SafeArea(
        child: Obx(
          () {
            if (controller.userController.isLoading.value) {
              return _buildLoadingSkeleton(context);
            }

            final user = controller.userController.user;
            final profile = controller.userController.profile;

            if (user == null || profile == null) {
              return Center(
                child: Text(
                  'profile_no_data'.tr,
                  style: Get.textTheme.bodyLarge,
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildProfileHero(user, context),
                  const SizedBox(height: 24),
                  _buildSectionTitle('personal_information'.tr),
                  const SizedBox(height: 12),
                  _buildCard(
                    children: [
                      _buildOptionItem(
                        icon: Icon(
                          PhosphorIconsRegular.student,
                          color: Get.theme.colorScheme.primary,
                          size: 22,
                        ),
                        title: 'students_information'.tr,
                        subtitle: 'your_information'.tr,
                        onTap: () => _showStudentInformationDialog(
                            context, user, profile),
                      ),
                      _buildDivider(),
                      _buildOptionItem(
                        icon: Icon(
                          PhosphorIconsRegular.users,
                          color: Get.theme.colorScheme.primary,
                          size: 22,
                        ),
                        title: 'parents_information'.tr,
                        subtitle: 'your_parents_information'.tr,
                        onTap: () =>
                            _showParentInformationDialog(context, profile),
                      ),
                      _buildDivider(),
                      _buildOptionItem(
                        icon: Icon(
                          PhosphorIconsRegular.lockKey,
                          color: Get.theme.colorScheme.primary,
                          size: 22,
                        ),
                        title: 'forget_password_action'.tr,
                        subtitle: 'reset_your_password'.tr,
                        onTap: () =>
                            Get.toNamed(AppRoutes.forgetPasswordScreen),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('general_section'.tr),
                  const SizedBox(height: 12),
                  _buildCard(
                    children: [
                      _buildOptionItem(
                        icon: Icon(
                          PhosphorIconsRegular.sun,
                          color: Get.theme.colorScheme.primary,
                          size: 22,
                        ),
                        title: 'change_theme'.tr,
                        subtitle: 'toggle_app_theme'.tr,
                        onTap: () => controller.showThemeSheet(context),
                      ),
                      _buildDivider(),
                      _buildOptionItem(
                        icon: Icon(
                          PhosphorIconsRegular.translate,
                          color: Get.theme.colorScheme.primary,
                          size: 22,
                        ),
                        title: 'language_khmer'.tr,
                        subtitle: 'change_app_language'.tr,
                        onTap: () => controller.showLanguageSheet(context),
                      ),
                      _buildDivider(),
                      _buildOptionItem(
                        icon: Icon(
                          PhosphorIconsRegular.question,
                          color: Get.theme.colorScheme.primary,
                          size: 22,
                        ),
                        title: 'faq'.tr,
                        subtitle: 'read_frequently_asked_questions'.tr,
                        onTap: () => controller.showFAQSheet(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('legal_section'.tr),
                  const SizedBox(height: 12),
                  _buildCard(
                    children: [
                      _buildOptionItem(
                        icon: Icon(
                          PhosphorIconsRegular.signOut,
                          color: Get.theme.colorScheme.error,
                          size: 22,
                        ),
                        title: 'logout_action'.tr,
                        subtitle: 'sign_out_account'.tr,
                        onTap: controller.logout,
                        titleColor: Get.theme.colorScheme.error,
                        iconColor: Get.theme.colorScheme.error,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    final theme = Theme.of(context);
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceContainerHighest,
      highlightColor: theme.colorScheme.surface,
      period: const Duration(milliseconds: 1300),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildProfileHeroSkeleton(),
            const SizedBox(height: 24),
            _buildSkeletonSectionTitle(),
            const SizedBox(height: 12),
            _buildSkeletonCard(itemCount: 3),
            const SizedBox(height: 24),
            _buildSkeletonSectionTitle(),
            const SizedBox(height: 12),
            _buildSkeletonCard(itemCount: 3),
            const SizedBox(height: 24),
            _buildSkeletonSectionTitle(),
            const SizedBox(height: 12),
            _buildSkeletonCard(itemCount: 1),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeroSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const _SkeletonBlock(width: 64, height: 64, isCircle: true),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _SkeletonBlock(width: 88, height: 11),
                    SizedBox(height: 9),
                    _SkeletonBlock(width: 155, height: 18),
                    SizedBox(height: 8),
                    _SkeletonBlock(width: 120, height: 12),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _SkeletonBlock(width: 142, height: 34, radius: 999),
        ],
      ),
    );
  }

  Widget _buildSkeletonSectionTitle() {
    return Container(
      width: 140,
      height: 16,
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildSkeletonCard({required int itemCount}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(
          itemCount,
          (index) => Column(
            children: [
              _buildSkeletonOption(),
              if (index < itemCount - 1) ...[
                const SizedBox(height: 14),
                Divider(color: Get.theme.dividerColor, height: 1),
                const SizedBox(height: 14),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonOption() {
    return const Row(
      children: [
        _SkeletonBlock(width: 44, height: 44, radius: 14),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SkeletonBlock(width: 128, height: 14),
              SizedBox(height: 8),
              _SkeletonBlock(width: 184, height: 11),
            ],
          ),
        ),
        _SkeletonBlock(width: 16, height: 16, radius: 8),
      ],
    );
  }

  Widget _buildProfileHero(dynamic user, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary, const Color(0xFF5DCAA5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Obx(() => _buildAvatar(user, context)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: Get.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  PhosphorIconsRegular.sparkle,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'manage_account_confidence'.tr,
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(dynamic user, BuildContext context) {
    final picked = controller.pickedImagePath.value;
    final hasImage = picked != null ||
        (user.avatarUrl != null && user.avatarUrl!.isNotEmpty);

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: hasImage ? () => _showFullImageViewer(user) : null,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                startAngle: 2.356, // 135°
                colors: [
                  Theme.of(context).colorScheme.primary,
                  const Color(0xFF5DCAA5),
                  Theme.of(context).colorScheme.primary,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: CircleAvatar(
                    radius: 52,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    backgroundImage: picked != null
                        ? FileImage(File(picked)) as ImageProvider
                        : (user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                            ? NetworkImage(user.avatarUrl!)
                            : null),
                    child: !hasImage ? _buildFallback(user, context) : null,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 2,
          right: 2,
          child: GestureDetector(
            onTap: () => controller.showImagePickerSheet(context),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 2.5,
                ),
              ),
              child: const Icon(
                PhosphorIconsRegular.camera,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showFullImageViewer(dynamic user) {
    final picked = controller.pickedImagePath.value;
    final imageProvider = picked != null
        ? FileImage(File(picked)) as ImageProvider
        : NetworkImage(user.avatarUrl!);

    Get.dialog(
      GestureDetector(
        onTap: Get.back,
        child: Container(
          color: Colors.black.withOpacity(0.85),
          child: Center(
            child: InteractiveViewer(
              child: Image(
                image: imageProvider,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black54,
    );
  }

  Widget _buildFallback(dynamic user, BuildContext context) {
    final name = (user.displayName ?? user.name ?? '').trim();
    if (name.isNotEmpty) {
      final parts = name.split(' ');
      final initials = parts.length >= 2
          ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
          : name.substring(0, name.length >= 2 ? 2 : name.length).toUpperCase();
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              const Color(0xFFAFA9EC),
              Theme.of(context).colorScheme.primary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Text(
            initials,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ),
      );
    }
    return const Icon(
      PhosphorIconsRegular.userCircle,
      size: 44,
      color: Color(0xFFAFA9EC),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Get.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: Get.theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    final theme = Get.theme;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        // border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildOptionItem({
    required Widget icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    final theme = Get.theme;
    final effectiveTitleColor = titleColor ?? theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface;
    final effectiveIconColor = iconColor ?? theme.colorScheme.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: effectiveIconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: icon,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Get.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: effectiveTitleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                PhosphorIconsRegular.caretRight,
                size: 18,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 18,
      endIndent: 18,
      color: Get.theme.dividerColor,
    );
  }

  void _showStudentInformationDialog(
      BuildContext context, dynamic user, dynamic profile) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Get.theme.colorScheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        PhosphorIconsRegular.student,
                        color: Get.theme.colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'students_information'.tr,
                            style: Get.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'academic_profile_details'.tr,
                            style: Get.textTheme.bodySmall?.copyWith(
                              color: Get.theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('full_name'.tr, user.fullName ?? ''),
                      const SizedBox(height: 10),
                      _buildInfoRow('email'.tr, user.email ?? ''),
                      const SizedBox(height: 10),
                      _buildInfoRow('student_code'.tr, profile.studentCode ?? ''),
                      const SizedBox(height: 10),
                      _buildInfoRow('class_label'.tr, profile.className ?? ''),
                      const SizedBox(height: 10),
                      _buildInfoRow('gender'.tr, profile.gender ?? ''),
                      const SizedBox(height: 10),
                      _buildInfoRow('guardian_phone'.tr, profile.guardianPhone ?? ''),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Get.theme.colorScheme.primary,
                      foregroundColor: Get.theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(
                      'close_button'.tr,
                      style: Get.textTheme.bodyLarge?.copyWith(color: Get.theme.colorScheme.onPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Get.theme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: Get.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: Text(
            value.isNotEmpty ? value : '-'.tr,
            style: Get.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  void _showParentInformationDialog(BuildContext context, dynamic profile) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Get.theme.colorScheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        PhosphorIconsRegular.users,
                        color: Get.theme.colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'parents_information'.tr,
                            style: Get.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'guardian_contact_details'.tr,
                            style: Get.textTheme.bodySmall?.copyWith(
                              color: Get.theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('guardian_name'.tr, profile.guardianName ?? ''),
                      const SizedBox(height: 10),
                      _buildInfoRow('guardian_phone'.tr, profile.guardianPhone ?? ''),
                      const SizedBox(height: 10),
                      _buildInfoRow('address'.tr, profile.address ?? ''),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Get.theme.colorScheme.primary,
                      foregroundColor: Get.theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text('close_button'.tr,
                    style: Get.textTheme.bodyLarge?.copyWith(color: Get.theme.colorScheme.onPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({
    required this.width,
    required this.height,
    this.radius = 8,
    this.isCircle = false,
  });

  final double width;
  final double height;
  final double radius;
  final bool isCircle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(radius),
      ),
    );
  }
}
