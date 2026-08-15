part of 'profile_tab_view.dart';

class ProfileTabViewController extends GetxController {
  var userController = Get.find<UserController>();

  var box = GetStorage();

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

        // Ask user to confirm before uploading the selected image
        final confirmed = await Get.dialog<bool>(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('update_photo'.tr),
            content: Text('confirm_upload_photo'.tr),
            actions: [
              OutlinedButton(
                onPressed: () => Get.back(result: false),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Get.theme.dividerColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                child: Text(
                  'no'.tr,
                  style: Get.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Get.theme.colorScheme.primary,
                  foregroundColor: Get.theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                child: Text(
                  'yes'.tr,
                  style: Get.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: Get.theme.colorScheme.onPrimary),
                ),
              ),
            ],
          ),
          barrierDismissible: false,
        );

        if (confirmed == true) {
          await userController.uploadAvatar(File(xfile.path));
        } else {
          // User cancelled — clear the picked image
          pickedImagePath.value = null;
        }
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
                        color: Get.theme.dividerColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'update_photo'.tr,
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'choose_new_profile_photo'.tr,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: Get.theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildImageOption(
                    icon: PhosphorIconsRegular.camera,
                    title: 'take_photo'.tr,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      pickImage(ImageSource.camera);
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildImageOption(
                    icon: PhosphorIconsRegular.image,
                    title: 'choose_from_gallery'.tr,
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
    final theme = Get.theme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 22),
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
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
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
                        color: Get.theme.dividerColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'theme'.tr,
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'choose_look_fits_style'.tr,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: Get.theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildThemeOption(
                    context: ctx,
                    icon: PhosphorIconsRegular.sun,
                    title: 'light_mode'.tr,
                    isSelected: !isDark,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      ThemeService().setThemeMode(ThemeMode.light);
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildThemeOption(
                    context: ctx,
                    icon: PhosphorIconsRegular.moon,
                    title: 'dark_mode'.tr,
                    isSelected: isDark,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      ThemeService().setThemeMode(ThemeMode.dark);
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
    final theme = Get.theme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withOpacity(0.08) : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary.withOpacity(0.25) : theme.dividerColor,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary.withOpacity(0.12) : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Get.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                PhosphorIconsRegular.checkCircle,
                color: theme.colorScheme.primary,
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
                        color: Get.theme.dividerColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'language'.tr,
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'choose_preferred_language'.tr,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: Get.theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLanguageOption(
                    context: ctx,
                    icon: AppIcons.englishIcon,
                    title: 'language_english'.tr,
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
                    title: 'language_khmer'.tr,
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
    final theme = Get.theme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withOpacity(0.08) : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary.withOpacity(0.25) : theme.dividerColor,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary.withOpacity(0.12) : theme.colorScheme.surface,
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
                  color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                PhosphorIconsRegular.checkCircle,
                color: theme.colorScheme.primary,
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
                        color: Get.theme.dividerColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'faq'.tr,
                    style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'common_questions_answers'.tr,
                    style: Get.textTheme.bodyMedium?.copyWith(color: Get.theme.textTheme.bodySmall?.color?.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 16),
                  _buildFAQItem(
                    title: 'how_reset_password'.tr,
                    content: 'forgot_password_link_login'.tr,
                  ),
                  const SizedBox(height: 10),
                  _buildFAQItem(
                    title: 'how_change_language'.tr,
                    content: 'open_language_option'.tr,
                  ),
                  const SizedBox(height: 10),
                  _buildFAQItem(
                    title: 'who_contact_support'.tr,
                    content: 'contact_school_administrator'.tr,
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
    final theme = Get.theme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIconsRegular.question,
                color: theme.colorScheme.primary,
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
            style: Get.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

void logout() {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.error
                        .withOpacity(0.12),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: Icon(
                    PhosphorIconsRegular.signOut,
                    color:
                        Get.theme.colorScheme.error,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'logout_action'.tr,
                    style: Get.textTheme.titleMedium
                        ?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              'are_sure_logout'.tr,
              textAlign: TextAlign.center,
              style:
                  Get.textTheme.bodyMedium?.copyWith(
                color: Get
                    .theme.textTheme.bodySmall?.color
                    ?.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style:
                        OutlinedButton.styleFrom(
                      side: BorderSide(
                        color:
                            Get.theme.dividerColor,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'no'.tr,
                      style: Get
                          .textTheme.bodyLarge
                          ?.copyWith(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        // =====================================
                        // 1. REMOVE FCM TOKEN FROM OLD ACCOUNT
                        //
                        // IMPORTANT:
                        // Must happen BEFORE removing auth token.
                        // =====================================

                        try {
                          final notificationApi =
                              NotificationApi();

                          await notificationApi
                              .removeFcmToken();

                          debugPrint(
                            'FCM TOKEN REMOVED FROM OLD ACCOUNT',
                          );
                        } catch (e) {
                          debugPrint(
                            'REMOVE FCM TOKEN ERROR: $e',
                          );
                        }

                        await AuthSessionService().clearSessionData(
                          navigateToLogin: true,
                        );
                      } catch (e, stackTrace) {
                        debugPrint(
                          'LOGOUT ERROR: $e',
                        );

                        debugPrintStack(
                          stackTrace: stackTrace,
                        );
                      }
                    },
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Get.theme.colorScheme.error,
                      foregroundColor: Get
                          .theme.colorScheme.onError,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'yes'.tr,
                      style: Get
                          .textTheme.bodyLarge
                          ?.copyWith(
                        fontWeight:
                            FontWeight.w600,
                        color: Get.theme
                            .colorScheme.onError,
                      ),
                    ),
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