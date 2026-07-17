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
                  "No profile data available".tr,
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
                  _buildSectionTitle("PERSONAL INFORMATION"),
                  const SizedBox(height: 12),
                  _buildCard(
                    children: [
                      _buildOptionItem(
                        icon: Icon(
                          PhosphorIconsRegular.student,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        title: "Student's Information",
                        subtitle: "Your information",
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
                        title: "Parent's Information",
                        subtitle: "Your parent's information",
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
                        title: "Forget Password",
                        subtitle: "Reset your password",
                        onTap: () =>
                            Get.toNamed(AppRoutes.forgetPasswordScreen),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle("GENERAL"),
                  const SizedBox(height: 12),
                  _buildCard(
                    children: [
                      _buildOptionItem(
                        icon: Icon(
                          PhosphorIconsRegular.sun,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        title: "Change Theme",
                        subtitle: "Toggle app theme",
                        onTap: () => controller.showThemeSheet(context),
                      ),
                      _buildDivider(),
                      _buildOptionItem(
                        icon: Icon(
                          PhosphorIconsRegular.translate,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        title: "Language",
                        subtitle: "Change app language",
                        onTap: () => controller.showLanguageSheet(context),
                      ),
                      _buildDivider(),
                      _buildOptionItem(
                        icon: Icon(
                          PhosphorIconsRegular.question,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        title: "FAQ",
                        subtitle: "Read frequently asked questions",
                        onTap: () => controller.showFAQSheet(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle("LEGAL"),
                  const SizedBox(height: 12),
                  _buildCard(
                    children: [
                      _buildOptionItem(
                        icon: Icon(
                          PhosphorIconsRegular.signOut,
                          color: AppColors.error,
                          size: 22,
                        ),
                        title: "Logout",
                        subtitle: "Sign out of your account",
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: 160,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildSkeletonSectionTitle(),
            const SizedBox(height: 12),
            _buildSkeletonCard(),
            const SizedBox(height: 24),
            _buildSkeletonSectionTitle(),
            const SizedBox(height: 12),
            _buildSkeletonCard(),
            const SizedBox(height: 24),
            _buildSkeletonSectionTitle(),
            const SizedBox(height: 12),
            _buildSkeletonCard(),
            const SizedBox(height: 20),
          ],
        ),
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

  Widget _buildSkeletonCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
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
                      user.role == "parent" ? "Parent account" : "Student account",
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
                  "Manage your account with confidence",
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
                            "Student's Information".tr,
                            style: Get.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Your academic profile details'.tr,
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
                      _buildInfoRow("Full Name".tr, user.fullName ?? ''),
                      const SizedBox(height: 10),
                      _buildInfoRow("Email".tr, user.email ?? ''),
                      const SizedBox(height: 10),
                      _buildInfoRow("Student Code".tr, profile.studentCode ?? ''),
                      const SizedBox(height: 10),
                      _buildInfoRow("Class".tr, profile.className ?? ''),
                      const SizedBox(height: 10),
                      _buildInfoRow("Gender".tr, profile.gender ?? ''),
                      const SizedBox(height: 10),
                      _buildInfoRow("Guardian Phone".tr, profile.guardianPhone ?? ''),
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
                    child: Text('Close'.tr),
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
                            "Parent's Information".tr,
                            style: Get.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Guardian and contact details'.tr,
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
                      _buildInfoRow("Guardian Name".tr, profile.guardianName ?? ''),
                      const SizedBox(height: 10),
                      _buildInfoRow("Guardian Phone".tr, profile.guardianPhone ?? ''),
                      const SizedBox(height: 10),
                      _buildInfoRow("Address".tr, profile.address ?? ''),
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
                    child: Text('Close'.tr),
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
