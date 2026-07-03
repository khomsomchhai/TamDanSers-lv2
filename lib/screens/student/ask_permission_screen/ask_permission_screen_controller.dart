part of 'ask_permission_screen_view.dart';

class AskPermissionScreenViewController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final reasonCtrl = TextEditingController();
  final PermissionServices permissionServices = PermissionServices();

  final selectedType = RxnString();
  final fromDate = Rxn<DateTime>();
  final toDate = Rxn<DateTime>();
  final isLoading = false.obs;

  final permissionRequests = <PermissionModel>[].obs;

  final List<String> permissionTypes = const [
    'Sick',
    'Family Matter',
    'Personal',
    'Other',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchMyPermissions();
  }

  Future<void> pickFromDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: fromDate.value ?? now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      fromDate.value = picked;
      if (toDate.value != null && toDate.value!.isBefore(picked)) {
        toDate.value = null;
      }
    }
  }

  Future<void> pickToDate(BuildContext context) async {
    final now = DateTime.now();
    final start = fromDate.value ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: toDate.value ?? start,
      firstDate: start,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      toDate.value = picked;
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) {
      return 'Select date';
    }

    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> fetchMyPermissions() async {
    try {
      final result = await permissionServices.fetchMyPermissions();
      permissionRequests.assignAll(result);
    } catch (_) {
      permissionRequests.clear();
    }
  }

  Future<void> submitPermission() async {
    if (selectedType.value == null || selectedType.value!.trim().isEmpty) {
      CustomSnackbar.error('Please select permission type');
      return;
    }

    if (fromDate.value == null) {
      CustomSnackbar.error('Please select from date');
      return;
    }

    if (toDate.value == null) {
      CustomSnackbar.error('Please select to date');
      return;
    }

    final reason = reasonCtrl.text.trim();
    if (reason.isEmpty) {
      CustomSnackbar.error('Please enter a reason');
      return;
    }

    if (toDate.value!.isBefore(fromDate.value!)) {
      CustomSnackbar.error('To date cannot be before from date');
      return;
    }

    isLoading.value = true;
    try {
      await permissionServices.createPermission(
        type: selectedType.value!,
        fromDate: formatDate(fromDate.value),
        toDate: formatDate(toDate.value),
        reason: reason,
      );

      CustomSnackbar.success('Permission request submitted');

      selectedType.value = null;
      fromDate.value = null;
      toDate.value = null;
      reasonCtrl.clear();

      await fetchMyPermissions();
    } catch (_) {
      CustomSnackbar.error('Failed to submit permission request');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    reasonCtrl.dispose();
    super.onClose();
  }
}
