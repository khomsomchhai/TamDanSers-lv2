import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
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
                  const SizedBox(height: 20,),
                  Center(child: Obx(() => _buildAvatar(user, context))),
                  const SizedBox(height: 16),
                  Center(child: _buildUserName(user)),
                  const SizedBox(height: 32),
                  _buildSectionTitle("PERSONAL INFORMATION"),
                  const SizedBox(height: 12),
                  _buildCard(
                    children: [
                      _buildOptionItem(
                        icon: Icons.person_outline,
                        title: "Student's Information",
                        subtitle: "Your information",
                        onTap: () => _showStudentInformationDialog(context, user, profile),
                      ),
                      _buildDivider(),
                      _buildOptionItem(
                        icon: Icons.person_outline,
                        title: "Parent's Information",
                        subtitle: "Your parent's information",
                        onTap: () => _showParentInformationDialog(context, profile),
                      ),
                      _buildDivider(),
                      _buildOptionItem(
                        icon: Icons.lock_outline,
                        title: "Forget Password",
                        subtitle: "Reset your password",
                        onTap: () => Get.toNamed(AppRoutes.forgetPasswordScreen),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle("GENERAL"),
                  const SizedBox(height: 12),
                  _buildCard(
                    children: [
                      _buildOptionItem(
                        icon: Icons.dark_mode_outlined,
                        title: "Change Theme",
                        subtitle: "Toggle app theme",
                        onTap: () {
                          ThemeService().switchTheme();
                        },
                      ),
                      _buildDivider(),
                      _buildOptionItem(
                        icon: Icons.language_outlined,
                        title: "Language",
                        subtitle: "Change app language",
                        onTap: () => controller.showLanguageSheet(context),
                      ),
                      _buildDivider(),
                      _buildOptionItem(
                        icon: Icons.help_outline,
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
                        icon: Icons.logout,
                        title: "Logout",
                        subtitle: "Sign out of your account",
                        onTap: controller.logout,
                        titleColor: AppColors.error,
                        iconColor: AppColors.error,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20,),
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
                Icons.camera_alt_rounded,
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
      Icons.person_rounded,
      size: 44,
      color: Color(0xFFAFA9EC),
    );
  }

  Widget _buildUserName(dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          user.fullName,
          style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: Get.textTheme.bodySmall,
        )
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Get.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
        color: AppColors.hintColor,
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color titleColor = AppColors.dark,
    Color iconColor = AppColors.primary,
  }) {
    return Material(
      color: Colors.transparent,
      child: Bounceable(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 20),
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
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
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

  void _showStudentInformationDialog(BuildContext context, dynamic user, dynamic profile) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Student's Information".tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow("Full Name".tr, user.fullName ?? ''),
              const SizedBox(height: 8),
              _buildInfoRow("Email".tr, user.email ?? ''),
              const SizedBox(height: 8),
              _buildInfoRow("Student Code".tr, profile.studentCode ?? ''),
              const SizedBox(height: 8),
              _buildInfoRow("Class".tr, profile.className ?? ''),
              const SizedBox(height: 8),
              _buildInfoRow("Gender".tr, profile.gender ?? ''),
              const SizedBox(height: 8),
              _buildInfoRow("Guardian Phone".tr, profile.guardianPhone ?? ''),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Close'.tr),
            ),
          ],
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
        return AlertDialog(
          title: Text("Parent's Information".tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow("Guardian Name".tr, profile.guardianName ?? ''),
              const SizedBox(height: 8),
              _buildInfoRow("Guardian Phone".tr, profile.guardianPhone ?? ''),
              const SizedBox(height: 8),
              _buildInfoRow("Address".tr, profile.address ?? ''),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Close'.tr),
            ),
          ],
        );
      },
    );
  }

}

