part of 'profile_tab_view.dart';

class ProfileTabViewController extends GetxController {
  var userController = Get.find<UserController>();

  var box = GetStorage();

  // Local picked image path (not uploaded yet)
  var pickedImagePath = RxnString();

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    if (userController.user == null && userController.profile == null) {
      userController.getProfile();
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? xfile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
      );
      if (xfile != null) {
        pickedImagePath.value = xfile.path;
        await userController.uploadAvatar(File(xfile.path));
      }
    } catch (e) {
      debugPrint('pickImage error: $e');
      Get.snackbar(
        'Upload failed'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void showImagePickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
                  const SizedBox(height: 16),
                  Text(
                    'Update photo'.tr,
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a new profile photo'.tr,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: AppColors.hintColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildImageOption(
                    icon: PhosphorIconsRegular.camera,
                    title: 'Take Photo'.tr,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      pickImage(ImageSource.camera);
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildImageOption(
                    icon: PhosphorIconsRegular.image,
                    title: 'Choose from Gallery'.tr,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.lightBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Get.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Icon(
              PhosphorIconsRegular.caretRight,
              color: AppColors.hintColor,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void showThemeSheet(BuildContext context) {
    final isDark = Get.isDarkMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
                  const SizedBox(height: 16),
                  Text(
                    'Theme'.tr,
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose the look that fits your style'.tr,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: AppColors.hintColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildThemeOption(
                    context: ctx,
                    icon: PhosphorIconsRegular.sun,
                    title: 'Light Mode'.tr,
                    isSelected: !isDark,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      ThemeService().box.write('isDarkMode', false);
                      Get.changeThemeMode(ThemeMode.light);
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildThemeOption(
                    context: ctx,
                    icon: PhosphorIconsRegular.moon,
                    title: 'Dark Mode'.tr,
                    isSelected: isDark,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      ThemeService().box.write('isDarkMode', true);
                      Get.changeThemeMode(ThemeMode.dark);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.lightBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.25) : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.hintColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Get.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primary : AppColors.dark,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                PhosphorIconsRegular.checkCircle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void showLanguageSheet(BuildContext context) {
    final currentLang = Get.locale?.languageCode ?? LocalizationService().getLocale().languageCode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
                  const SizedBox(height: 16),
                  Text(
                    'Language'.tr,
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose your preferred language'.tr,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: AppColors.hintColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLanguageOption(
                    context: ctx,
                    icon: AppIcons.englishIcon,
                    title: 'English'.tr,
                    isSelected: currentLang == 'en',
                    onTap: () {
                      Navigator.of(ctx).pop();
                      LocalizationService().changeLocale('en');
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildLanguageOption(
                    context: ctx,
                    icon: AppIcons.khmerIcon,
                    title: 'ភាសាខ្មែរ',
                    isSelected: currentLang == 'km',
                    onTap: () {
                      Navigator.of(ctx).pop();
                      LocalizationService().changeLocale('km');
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.lightBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.25) : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Image.asset(
                icon,
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Get.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primary : AppColors.dark,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                PhosphorIconsRegular.checkCircle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void showFAQSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
                  const SizedBox(height: 16),
                  Text(
                    'FAQ'.tr,
                    style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Common questions and quick answers'.tr,
                    style: Get.textTheme.bodyMedium?.copyWith(color: AppColors.hintColor),
                  ),
                  const SizedBox(height: 16),
                  _buildFAQItem(
                    title: 'How do I reset my password?'.tr,
                    content: 'Use the Forgot Password link on the login screen to request a reset.'.tr,
                  ),
                  const SizedBox(height: 10),
                  _buildFAQItem(
                    title: 'How do I change my language?'.tr,
                    content: 'Open the Language option in your profile and select your preferred language.'.tr,
                  ),
                  const SizedBox(height: 10),
                  _buildFAQItem(
                    title: 'Who do I contact for support?'.tr,
                    content: 'Contact your school administrator or support team for account help.'.tr,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFAQItem({required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIconsRegular.question,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Get.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Get.textTheme.bodyMedium?.copyWith(color: AppColors.hintColor),
          ),
        ],
      ),
    );
  }

  void logout() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      PhosphorIconsRegular.signOut,
                      color: AppColors.error,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Logout".tr,
                          style: Get.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Sign out of your account".tr,
                          style: Get.textTheme.bodySmall?.copyWith(
                            color: AppColors.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "Are you sure you want to log out?".tr,
                textAlign: TextAlign.center,
                style: Get.textTheme.bodyMedium?.copyWith(color: AppColors.hintColor),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text("No".tr),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        box.remove("token");
                        Get.offAllNamed(AppRoutes.loginScreen);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text("Yes".tr),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}