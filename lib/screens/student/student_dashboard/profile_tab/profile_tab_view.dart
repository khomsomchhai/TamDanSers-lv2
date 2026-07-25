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
import 'package:tamdansers_lv2/app/themes/app_colors.dart';
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
      backgroundColor: AppColors.lightBackground,
      appBar: CustomAppBar(
        title: "profile".tr,
        showBackButton: false,
        unreadCount: 2,
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
                          color: AppColors.primary,
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
                          color: AppColors.primary,
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
                          color: AppColors.primary,
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
                          color: AppColors.primary,
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
                          color: AppColors.primary,
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
                          color: AppColors.primary,
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
                          color: AppColors.error,
                          size: 22,
                        ),
                        title: 'logout_action'.tr,
                        subtitle: 'sign_out_account'.tr,
                        onTap: controller.logout,
                        titleColor: AppColors.error,
                        iconColor: AppColors.error,
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
    return Shimmer.fromColors(
      baseColor: AppColors.skeletonBaseColor,
      highlightColor: AppColors.skeletonHighlightColor,
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
        color: Colors.white,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildSkeletonCard({required int itemCount}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                Divider(color: AppColors.border, height: 1),
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
        gradient: const LinearGradient(
          colors: [Color(0xFF7F77DD), Color(0xFF5DCAA5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7F77DD).withValues(alpha: 0.18),
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
                      user.role == "parent" ? 'parent_account'.tr : 'student_account'.tr,
                      style: Get.textTheme.labelLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
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
        Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              startAngle: 2.356, // 135�
              colors: [Color(0xFF7F77DD), Color(0xFF5DCAA5), Color(0xFF7F77DD)],
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
                  backgroundColor: const Color(0xFFEEEDFE),
                  backgroundImage: picked != null
                      ? FileImage(File(picked)) as ImageProvider
                      : (user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                          ? NetworkImage(user.avatarUrl!)
                          : null),
                  child: !hasImage ? _buildFallback(user) : null,
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
                color: const Color(0xFF7F77DD),
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

  Widget _buildFallback(dynamic user) {
    final name = (user.displayName ?? user.name ?? '').trim();
    if (name.isNotEmpty) {
      final parts = name.split(' ');
      final initials = parts.length >= 2
          ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
          : name.substring(0, name.length >= 2 ? 2 : name.length).toUpperCase();
      return Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFFAFA9EC), Color(0xFF7F77DD)],
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
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE9EAF2)),
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
    Color titleColor = AppColors.dark,
    Color iconColor = AppColors.primary,
  }) {
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
                  color: iconColor.withValues(alpha: 0.12),
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
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: AppColors.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                PhosphorIconsRegular.caretRight,
                size: 18,
                color: AppColors.hintColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 18,
      endIndent: 18,
      color: Color(0xFFF3F4F6),
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
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        PhosphorIconsRegular.student,
                        color: AppColors.primary,
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
                              color: AppColors.hintColor,
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
                    color: AppColors.lightBackground,
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
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text('close_button'.tr),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: Get.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.hintColor,
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
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        PhosphorIconsRegular.users,
                        color: AppColors.primary,
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
                              color: AppColors.hintColor,
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
                    color: AppColors.lightBackground,
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
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text('close_button'.tr),
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
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(radius),
      ),
    );
  }
}
