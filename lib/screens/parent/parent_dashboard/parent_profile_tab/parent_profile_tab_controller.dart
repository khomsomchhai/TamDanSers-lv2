import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tamdansers_lv2/app/constants/app_icons.dart';
import 'package:tamdansers_lv2/app/localization/localization_service.dart';
import 'package:tamdansers_lv2/core/api/controllers/user_controller.dart';
import 'package:tamdansers_lv2/core/api/services/notication_api.dart';
import 'package:tamdansers_lv2/core/services/auth_session_service.dart';
import 'package:tamdansers_lv2/core/services/theme_service.dart';
import 'package:tamdansers_lv2/screens/parent/parent_dashboard/'
    'parent_home_tab/parent_home_tab_view.dart';

class ParentProfileTabViewController extends GetxController {
  final UserController userController =
      Get.find<UserController>();

  final GetStorage box = GetStorage();

  final ImagePicker _picker = ImagePicker();

  // Local selected avatar
  final RxnString pickedImagePath = RxnString();

  // Linked children
  final linkedChildren =
      <Map<String, dynamic>>[].obs;

  final isChildrenLoading = false.obs;
  final childrenError = ''.obs;

  ParentHomeTabViewController? get homeController {
    if (Get.isRegistered<ParentHomeTabViewController>()) {
      return Get.find<ParentHomeTabViewController>();
    }

    return null;
  }

  @override
  void onInit() {
    super.onInit();

    loadProfileData();
  }

  // =====================================================
  // Profile and children
  // =====================================================

  Future<void> loadProfileData() async {
    try {
      if (userController.user == null) {
        await userController.getProfile();
      }

      await loadLinkedChildren();
    } catch (e) {
      debugPrint(
        'Parent profile initialization error: $e',
      );
    }
  }

  Future<void> refreshProfile() async {
    try {
      await userController.getProfile();

      await loadLinkedChildren();
    } catch (e) {
      debugPrint(
        'Refresh parent profile error: $e',
      );
    }
  }

  Future<void> loadLinkedChildren() async {
    try {
      isChildrenLoading.value = true;
      childrenError.value = '';

      final parentHomeController = homeController;

      if (parentHomeController == null) {
        linkedChildren.clear();

        childrenError.value =
            'Parent home controller not found';

        debugPrint(
          'ParentHomeTabViewController is not registered',
        );

        return;
      }

      if (parentHomeController.students.isEmpty) {
        await parentHomeController.loadStudents();
      }

      linkedChildren.assignAll(
        parentHomeController.students.map(
          (student) {
            return Map<String, dynamic>.from(
              student,
            );
          },
        ),
      );

      debugPrint(
        'Linked children count: ${linkedChildren.length}',
      );
    } catch (e) {
      linkedChildren.clear();
      childrenError.value = e.toString();

      debugPrint(
        'Load linked children error: $e',
      );
    } finally {
      isChildrenLoading.value = false;
    }
  }

  // =====================================================
  // Avatar
  // =====================================================

  Future<void> pickImage(
    ImageSource source,
  ) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
      );

      if (image == null) {
        return;
      }

      pickedImagePath.value = image.path;

      await userController.uploadAvatar(
        File(image.path),
      );

      await userController.getProfile();

      pickedImagePath.value = null;
    } catch (e) {
      debugPrint(
        'Pick image error: $e',
      );

      Get.snackbar(
        'upload_failed'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void showImagePickerSheet(
    BuildContext context,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildBottomSheetHandle(),

                  const SizedBox(height: 16),

                  Text(
                    'update_photo'.tr,
                    style: Get
                        .textTheme.titleLarge
                        ?.copyWith(
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'choose_new_profile_photo'.tr,
                    style: Get
                        .textTheme.bodyMedium
                        ?.copyWith(
                      color: Get
                          .theme
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(
                            alpha: 0.70,
                          ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildImageOption(
                    icon:
                        PhosphorIconsRegular.camera,
                    title: 'take_photo'.tr,
                    onTap: () {
                      Navigator.of(
                        sheetContext,
                      ).pop();

                      pickImage(
                        ImageSource.camera,
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  _buildImageOption(
                    icon:
                        PhosphorIconsRegular.image,
                    title:
                        'choose_from_gallery'.tr,
                    onTap: () {
                      Navigator.of(
                        sheetContext,
                      ).pop();

                      pickImage(
                        ImageSource.gallery,
                      );
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(16),
        child: Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius:
                BorderRadius.circular(16),
            border: Border.all(
              color: theme.dividerColor,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary
                      .withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color:
                      theme.colorScheme.primary,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style: Get
                      .textTheme.bodyLarge
                      ?.copyWith(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),

              Icon(
                PhosphorIconsRegular.caretRight,
                color: theme
                    .textTheme.bodySmall?.color
                    ?.withValues(
                      alpha: 0.70,
                    ),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // Theme
  // =====================================================

  void showThemeSheet(
    BuildContext context,
  ) {
    final isDarkMode = Get.isDarkMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildBottomSheetHandle(),

                  const SizedBox(height: 16),

                  Text(
                    'theme'.tr,
                    style: Get
                        .textTheme.titleLarge
                        ?.copyWith(
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'choose_look_fits_style'.tr,
                    style: Get
                        .textTheme.bodyMedium
                        ?.copyWith(
                      color: Get
                          .theme
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(
                            alpha: 0.70,
                          ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildThemeOption(
                    icon:
                        PhosphorIconsRegular.sun,
                    title: 'light_mode'.tr,
                    isSelected: !isDarkMode,
                    onTap: () {
                      Navigator.of(
                        sheetContext,
                      ).pop();

                      ThemeService().setThemeMode(
                        ThemeMode.light,
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  _buildThemeOption(
                    icon:
                        PhosphorIconsRegular.moon,
                    title: 'dark_mode'.tr,
                    isSelected: isDarkMode,
                    onTap: () {
                      Navigator.of(
                        sheetContext,
                      ).pop();

                      ThemeService().setThemeMode(
                        ThemeMode.dark,
                      );
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
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Get.theme;
    final primary =
        theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(16),
        child: Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? primary.withValues(
                    alpha: 0.08,
                  )
                : theme.colorScheme.surface,
            borderRadius:
                BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? primary.withValues(
                      alpha: 0.25,
                    )
                  : theme.dividerColor,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? primary.withValues(
                          alpha: 0.12,
                        )
                      : theme
                          .colorScheme.surface,
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? primary
                      : theme
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withValues(
                            alpha: 0.80,
                          ),
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style: Get
                      .textTheme.bodyLarge
                      ?.copyWith(
                    fontWeight:
                        FontWeight.w600,
                    color: isSelected
                        ? primary
                        : theme
                            .textTheme
                            .bodyMedium
                            ?.color,
                  ),
                ),
              ),

              if (isSelected)
                Icon(
                  PhosphorIconsRegular
                      .checkCircle,
                  color: primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // Language
  // =====================================================

  void showLanguageSheet(
    BuildContext context,
  ) {
    final currentLanguage =
        Get.locale?.languageCode ??
            LocalizationService()
                .getLocale()
                .languageCode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildBottomSheetHandle(),

                  const SizedBox(height: 16),

                  Text(
                    'language'.tr,
                    style: Get
                        .textTheme.titleLarge
                        ?.copyWith(
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'choose_preferred_language'.tr,
                    style: Get
                        .textTheme.bodyMedium
                        ?.copyWith(
                      color: Get
                          .theme
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(
                            alpha: 0.70,
                          ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildLanguageOption(
                    icon: AppIcons.englishIcon,
                    title:
                        'language_english'.tr,
                    isSelected:
                        currentLanguage == 'en',
                    onTap: () {
                      Navigator.of(
                        sheetContext,
                      ).pop();

                      LocalizationService()
                          .changeLocale('en');
                    },
                  ),

                  const SizedBox(height: 10),

                  _buildLanguageOption(
                    icon: AppIcons.khmerIcon,
                    title:
                        'language_khmer'.tr,
                    isSelected:
                        currentLanguage == 'km',
                    onTap: () {
                      Navigator.of(
                        sheetContext,
                      ).pop();

                      LocalizationService()
                          .changeLocale('km');
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
    required String icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Get.theme;
    final primary =
        theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(16),
        child: Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? primary.withValues(
                    alpha: 0.08,
                  )
                : theme.colorScheme.surface,
            borderRadius:
                BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? primary.withValues(
                      alpha: 0.25,
                    )
                  : theme.dividerColor,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                padding:
                    const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primary.withValues(
                          alpha: 0.12,
                        )
                      : theme
                          .colorScheme.surface,
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Image.asset(
                  icon,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style: Get
                      .textTheme.bodyLarge
                      ?.copyWith(
                    fontWeight:
                        FontWeight.w600,
                    color: isSelected
                        ? primary
                        : theme
                            .textTheme
                            .bodyMedium
                            ?.color,
                  ),
                ),
              ),

              if (isSelected)
                Icon(
                  PhosphorIconsRegular
                      .checkCircle,
                  color: primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // FAQ
  // =====================================================

  void showFAQSheet(
    BuildContext context,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  24,
                ),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _buildBottomSheetHandle(),

                    const SizedBox(height: 16),

                    Text(
                      'faq'.tr,
                      style: Get
                          .textTheme.titleLarge
                          ?.copyWith(
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'common_questions_answers'.tr,
                      style: Get
                          .textTheme.bodyMedium
                          ?.copyWith(
                        color: Get
                            .theme
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(
                              alpha: 0.70,
                            ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildFAQItem(
                      title:
                          'how_reset_password'.tr,
                      content:
                          'forgot_password_link_login'
                              .tr,
                    ),

                    const SizedBox(height: 10),

                    _buildFAQItem(
                      title:
                          'how_change_language'.tr,
                      content:
                          'open_language_option'.tr,
                    ),

                    const SizedBox(height: 10),

                    _buildFAQItem(
                      title:
                          'who_contact_support'.tr,
                      content:
                          'contact_school_administrator'
                              .tr,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFAQItem({
    required String title,
    required String content,
  }) {
    final theme = Get.theme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Icon(
                PhosphorIconsRegular.question,
                color:
                    theme.colorScheme.primary,
                size: 18,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  title,
                  style: Get
                      .textTheme.bodyLarge
                      ?.copyWith(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            content,
            style: Get
                .textTheme.bodyMedium
                ?.copyWith(
              color: theme
                  .textTheme.bodySmall?.color
                  ?.withValues(
                    alpha: 0.70,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // Logout
  // =====================================================

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
                      color: Get.theme.colorScheme.error.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      PhosphorIconsRegular.signOut,
                      color: Get.theme.colorScheme.error,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'logout_action'.tr,
                          style: Get.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'are_sure_logout'.tr,
                textAlign: TextAlign.center,
                style: Get.textTheme.bodyMedium?.copyWith(color: Get.theme.textTheme.bodySmall?.color?.withOpacity(0.7)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Get.theme.dividerColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'no'.tr,
                        style: Get.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
  try {
    // 1. Remove FCM token from current parent account
    try {
      final NotificationApi notificationApi =
          NotificationApi();

      await notificationApi.removeFcmToken();

      debugPrint(
        'PARENT FCM TOKEN REMOVED',
      );
    } catch (e) {
      debugPrint(
        'REMOVE PARENT FCM TOKEN ERROR: $e',
      );
    }

    linkedChildren.clear();
    pickedImagePath.value = null;

    await AuthSessionService().clearSessionData(
      navigateToLogin: true,
    );
  } catch (e, stackTrace) {
    debugPrint(
      'PARENT LOGOUT ERROR: $e',
    );

    debugPrintStack(
      stackTrace: stackTrace,
    );
  }
},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.theme.colorScheme.error,
                        foregroundColor: Get.theme.colorScheme.onError,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'yes'.tr,
                        style: Get.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: Get.theme.colorScheme.onError),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true
    );
  }

  // =====================================================
  // Shared bottom sheet UI
  // =====================================================

  Widget _buildBottomSheetHandle() {
    return Center(
      child: Container(
        width: 44,
        height: 5,
        decoration: BoxDecoration(
          color: Get.theme.dividerColor,
          borderRadius:
              BorderRadius.circular(999),
        ),
      ),
    );
  }
}