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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text('Take Photo'.tr),
                onTap: () {
                  Navigator.of(ctx).pop();
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text('Choose from Gallery'.tr),
                onTap: () {
                  Navigator.of(ctx).pop();
                  pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showLanguageSheet(BuildContext context) {
    final currentLang = Get.locale?.languageCode ?? LocalizationService().getLocale().languageCode;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Image.asset(
                  AppIcons.englishIcon,
                  width: 28,
                  height: 28,
                ),
                title: Text('English'.tr),
                trailing: currentLang == 'en' ? const Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  Navigator.of(ctx).pop();
                  LocalizationService().changeLocale('en');
                },
              ),
              ListTile(
                leading: Image.asset(
                  AppIcons.khmerIcon,
                  width: 28,
                  height: 28,
                ),
                title: Text('ភាសាខ្មែរ'),
                trailing: currentLang == 'km' ? const Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  Navigator.of(ctx).pop();
                  LocalizationService().changeLocale('km');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showFAQSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FAQ'.tr,
                  style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ExpansionTile(
                  title: Text('How do I reset my password?'.tr),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Use the Forgot Password link on the login screen to request a reset.'.tr,
                        style: Get.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                ExpansionTile(
                  title: Text('How do I change my language?'.tr),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Open the Language option in your profile and select your preferred language.'.tr,
                        style: Get.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                ExpansionTile(
                  title: Text('Who do I contact for support?'.tr),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Contact your school administrator or support team for account help.'.tr,
                        style: Get.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void logout() {
    Get.dialog(
      AlertDialog(
        title: Text("Logout".tr),
        content: Text(
          "Are you sure?".tr,
        ),
        actions: [
          ElevatedButton(onPressed: () {
            Get.back();
          }, child: Text("No".tr)),
          ElevatedButton(onPressed: () {
            box.remove("token");
            Get.offAllNamed(AppRoutes.loginScreen);
          }, child: Text("Yes".tr))
        ],
      ),
    );
  }

}