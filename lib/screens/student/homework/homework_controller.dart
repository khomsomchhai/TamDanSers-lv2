part of 'homework_view.dart';

enum HomeworkStatus {
  none,
  pending,
  submitted,
  checked,
}

class HomeworkItem {
  final int id;
  final String title;
  final String description;
  final String? filePath;
  final String subjectName;
  final String teacherName;
  final HomeworkStatus status;
  final String date;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  HomeworkItem({
    required this.id,
    required this.title,
    required this.description,
    this.filePath,
    required this.subjectName,
    required this.teacherName,
    required this.status,
    required this.date,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });
}

class SubjectHomeworkGroup {
  final String subjectName;
  final String teacherName;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final List<HomeworkItem> items;

  SubjectHomeworkGroup({
    required this.subjectName,
    required this.teacherName,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.items,
  });

  String get displayDate {
    if (items.isEmpty) return '';
    return items.first.date;
  }
}

class HomeworkViewController extends GetxController {
  final selectedTabIndex = 0.obs;
  final selectedSubject = RxnString();

  final ongoingList = <HomeworkItem>[].obs;
  final completedList = <HomeworkItem>[].obs;
  final isLoading = false.obs;
  final submissionMap = <int, SubmissionModel>{}.obs;

  final homeworkServices = HomeworkServices();

  final GetStorage _box = GetStorage();

  final deletedSubmissionIds = <int>{}.obs;
  final deletedHomeworkIds = <int>{}.obs;

  static const String _cacheKeyOngoing = 'homework_ongoing_cache';
  static const String _cacheKeyCompleted = 'homework_completed_cache';
  static const String _cacheKeyDeletedSubmissions = 'deleted_submission_ids';
  static const String _cacheKeyDeletedHomeworks = 'deleted_homework_ids';

  @override
  void onInit() {
    super.onInit();
    _loadFromCache();
    fetchHomework();
  }

  // =====================================================
  // LOAD FROM CACHE
  //
  // Show cached data immediately so the user doesn't
  // see an empty screen while the API is loading.
  // =====================================================

  void _loadFromCache() {
    try {
      final dynamic delSubRaw = _box.read(_cacheKeyDeletedSubmissions);
      if (delSubRaw is List) {
        deletedSubmissionIds.addAll(delSubRaw.whereType<int>());
      }
      final dynamic delHwRaw = _box.read(_cacheKeyDeletedHomeworks);
      if (delHwRaw is List) {
        deletedHomeworkIds.addAll(delHwRaw.whereType<int>());
      }

      final dynamic ongoingRaw = _box.read(_cacheKeyOngoing);
      final dynamic completedRaw = _box.read(_cacheKeyCompleted);

      if (ongoingRaw is List && ongoingRaw.isNotEmpty) {
        final List<HomeworkItem> cached = ongoingRaw
            .whereType<Map>()
            .map((e) => _homeworkItemFromMap(Map<String, dynamic>.from(e)))
            .toList();
        if (cached.isNotEmpty) {
          ongoingList.assignAll(cached);
        }
      }

      if (completedRaw is List && completedRaw.isNotEmpty) {
        final List<HomeworkItem> cached = completedRaw
            .whereType<Map>()
            .map((e) => _homeworkItemFromMap(Map<String, dynamic>.from(e)))
            .toList();
        if (cached.isNotEmpty) {
          completedList.assignAll(cached);
        }
      }
    } catch (_) {}
  }

  // =====================================================
  // SAVE TO CACHE
  // =====================================================

  void _saveToCache() {
    try {
      _box.write(
        _cacheKeyDeletedSubmissions,
        deletedSubmissionIds.toList(),
      );
      _box.write(
        _cacheKeyDeletedHomeworks,
        deletedHomeworkIds.toList(),
      );
      _box.write(
        _cacheKeyOngoing,
        ongoingList.map((e) => _homeworkItemToMap(e)).toList(),
      );
      _box.write(
        _cacheKeyCompleted,
        completedList.map((e) => _homeworkItemToMap(e)).toList(),
      );
    } catch (_) {}
  }

  // =====================================================
  // SERIALIZE / DESERIALIZE HomeworkItem
  // =====================================================

  Map<String, dynamic> _homeworkItemToMap(HomeworkItem item) {
    return {
      'id': item.id,
      'title': item.title,
      'description': item.description,
      'filePath': item.filePath,
      'subjectName': item.subjectName,
      'teacherName': item.teacherName,
      'status': item.status.index,
      'date': item.date,
      'iconCode': item.icon.codePoint,
      'iconColorValue': item.iconColor.toARGB32(),
      'iconBgColorValue': item.iconBgColor.toARGB32(),
    };
  }

  HomeworkItem _homeworkItemFromMap(Map<String, dynamic> map) {
    final int statusIndex = map['status'] is int ? map['status'] : 0;
    final HomeworkStatus status = statusIndex < HomeworkStatus.values.length
        ? HomeworkStatus.values[statusIndex]
        : HomeworkStatus.none;

    final int iconCode = map['iconCode'] is int
        ? map['iconCode']
        : Icons.assignment_outlined.codePoint;

    final int iconColorValue = map['iconColorValue'] is int
        ? map['iconColorValue']
        : 0xff6763EB;

    final int iconBgColorValue = map['iconBgColorValue'] is int
        ? map['iconBgColorValue']
        : 0x1E6763EB;

    return HomeworkItem(
      id: map['id'] ?? 0,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      filePath: map['filePath']?.toString(),
      subjectName: map['subjectName']?.toString() ?? '',
      teacherName: map['teacherName']?.toString() ?? '',
      status: status,
      date: map['date']?.toString() ?? '',
      icon: IconData(iconCode, fontFamily: 'MaterialIcons'),
      iconColor: Color(iconColorValue),
      iconBgColor: Color(iconBgColorValue),
    );
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
    selectedSubject.value = null;
  }

  void openSubject(String subjectName) {
    selectedSubject.value = subjectName;
  }

  void backToSubjectList() {
    selectedSubject.value = null;
  }

  List<SubjectHomeworkGroup> get ongoingSubjectGroups =>
      _groupHomeworkList(ongoingList);

  List<SubjectHomeworkGroup> get completedSubjectGroups =>
      _groupHomeworkList(completedList);

  List<SubjectHomeworkGroup> _groupHomeworkList(List<HomeworkItem> source) {
    final Map<String, List<HomeworkItem>> map = {};
    for (var item in source) {
      final key =
          item.subjectName.trim().isEmpty ? item.title : item.subjectName;
      map.putIfAbsent(key, () => []).add(item);
    }
    return map.entries.map((e) {
      final subjectName = e.key;
      final items = e.value;
      final teacherName = items
          .firstWhere((i) => i.teacherName.isNotEmpty,
              orElse: () => items.first)
          .teacherName;
      return SubjectHomeworkGroup(
        subjectName: subjectName,
        teacherName: teacherName,
        icon: SubjectUi.icon(subjectName),
        iconColor: SubjectUi.color(subjectName),
        iconBgColor: SubjectUi.bgColor(subjectName),
        items: items,
      );
    }).toList();
  }

  List<HomeworkItem> get selectedSubjectHomeworks {
    final subject = selectedSubject.value;
    if (subject == null) return [];
    final currentList =
        selectedTabIndex.value == 0 ? ongoingList : completedList;
    return currentList.where((item) {
      final key =
          item.subjectName.trim().isEmpty ? item.title : item.subjectName;
      return key == subject;
    }).toList();
  }

  void goBackToHome() {
    try {
      final dashboardController = Get.find<StudentDashboardViewController>();
      dashboardController.changeTab(0);
    } catch (e) {
      Get.back();
    }
  }

  Future<void> fetchHomework() async {
    // Only show loading spinner if there's no cached data to display.
    final bool hasCache = ongoingList.isNotEmpty || completedList.isNotEmpty;
    if (!hasCache) {
      isLoading.value = true;
    }
    final logBuffer = StringBuffer();
    logBuffer.writeln("=== FETCH HOMEWORK LOG at ${DateTime.now()} ===");
    try {
      final userController = Get.find<UserController>();
      if (userController.profile == null) {
        await userController.getProfile();
      }
      final studentClassId = userController.profile?.classId;
      final studentId = userController.profile?.id;

      logBuffer.writeln("Logged in studentId: $studentId");
      logBuffer.writeln("Logged in classId: $studentClassId");

      List<dynamic> responseList = [];
      bool isFromStudentEndpoint = false;
      if (studentId != null) {
        try {
          responseList =
              await homeworkServices.fetchStudentHomeworkList(studentId);
          isFromStudentEndpoint = responseList.isNotEmpty;
          logBuffer.writeln(
              "Fetched homework list using studentId: ${responseList.length}");
        } catch (e) {
          logBuffer.writeln("Failed fetching homeworks using studentId: $e");
        }
      }

      if (responseList.isEmpty) {
        try {
          responseList = await homeworkServices.fetchHomeworkList();
          logBuffer.writeln(
              "Fetched fallback global homework list: ${responseList.length}");
        } catch (e) {
          logBuffer.writeln("Failed fetching fallback homeworks: $e");
        }
      }

      submissionMap.clear();
      if (studentId != null) {
        List<dynamic> submissionList = [];
        try {
          submissionList =
              await homeworkServices.fetchStudentSubmissions(studentId);
          logBuffer.writeln(
              "Submissions fetched for studentId $studentId: ${submissionList.length}");
        } catch (e) {
          logBuffer.writeln(
              "Error fetching submissions for studentId $studentId: $e");
        }

        final userId = userController.profile?.userId;
        if (submissionList.isEmpty && userId != null && userId != studentId) {
          try {
            logBuffer.writeln(
                "Submissions list was empty. Trying fallback userId $userId...");
            submissionList =
                await homeworkServices.fetchStudentSubmissions(userId);
            logBuffer.writeln(
                "Submissions fetched for fallback userId $userId: ${submissionList.length}");
          } catch (e) {
            logBuffer.writeln(
                "Error fetching submissions for fallback userId $userId: $e");
          }
        }

        if (submissionList.isEmpty) {
          try {
            logBuffer.writeln(
                "Submissions list was empty. Trying global /submissions/ endpoint...");
            final response =
                await homeworkServices.baseApi.get(endpoint: "/submissions/");
            List<dynamic> rawList = [];
            if (response is List) {
              rawList = response;
            } else if (response is Map) {
              if (response.containsKey('data') && response['data'] is List) {
                rawList = response['data'] as List;
              } else if (response.containsKey('submissions') &&
                  response['submissions'] is List) {
                rawList = response['submissions'] as List;
              }
            }
            if (rawList.isNotEmpty) {
              logBuffer.writeln(
                  "Fetched ${rawList.length} global submissions. Filtering for studentId $studentId...");
              for (var subJson in rawList) {
                final sub = SubmissionModel.fromJson(subJson);
                if (sub.studentId == studentId || sub.studentId == userId) {
                  submissionList.add(subJson);
                }
              }
              logBuffer.writeln(
                  "Filtered to ${submissionList.length} submissions for student.");
            }
          } catch (e) {
            logBuffer.writeln("Error fetching global submissions: $e");
          }
        }

        for (var subJson in submissionList) {
          final sub = SubmissionModel.fromJson(subJson);
          if (deletedSubmissionIds.contains(sub.id) ||
              deletedHomeworkIds.contains(sub.homeworkId)) {
            logBuffer.writeln(
                "  -> Skipping deleted submission: ID=${sub.id}, homeworkId=${sub.homeworkId}");
            continue;
          }
          logBuffer.writeln(
              "  - Submission: ID=${sub.id}, homeworkId=${sub.homeworkId}, status=${sub.status}, studentId=${sub.studentId}");
          submissionMap[sub.homeworkId] = sub;
        }
      }

      final List<HomeworkItem> ongoing = [];
      final List<HomeworkItem> completed = [];

      for (var json in responseList) {
        final homework = HomeworkModel.fromJson(json);
        logBuffer.writeln(
            "Homework from API: ID=${homework.id}, title=${homework.title}, classId=${homework.classId}, subjectName=${homework.subjectName}");

        // Only filter by classId if fetched from global fallback list AND classId is not 0
        if (!isFromStudentEndpoint &&
            studentClassId != null &&
            homework.classId != 0 &&
            homework.classId != studentClassId) {
          logBuffer.writeln(
              "  -> Skipped (Class mismatch: homework class is ${homework.classId}, student is $studentClassId)");
          continue;
        }

        HomeworkStatus status = HomeworkStatus.none;

        // Check if there is a matching submission in our map
        final submission = submissionMap[homework.id];

        // Also check if homework JSON has inline status
        String? inlineStatus;
        if (json is Map<String, dynamic>) {
          inlineStatus = json['status']?.toString() ??
              json['submission_status']?.toString();
        }

        if (submission != null) {
          final subStatus = submission.status.toLowerCase();
          logBuffer.writeln("  -> Match in submissions! status: $subStatus");
          if (subStatus == 'checked' || subStatus == 'check') {
            status = HomeworkStatus.checked;
          } else {
            status = HomeworkStatus.submitted;
          }
        } else if (inlineStatus != null) {
          final subStatus = inlineStatus.toLowerCase();
          logBuffer.writeln("  -> Match in inline status! status: $subStatus");
          if (subStatus == 'checked' || subStatus == 'check') {
            status = HomeworkStatus.checked;
          } else if (subStatus == 'submitted' || subStatus == 'pending') {
            status = HomeworkStatus.submitted;
          }
        } else {
          logBuffer.writeln(
              "  -> No submission found for homework ID ${homework.id}");
        }

        String displayDate = homework.dueDate;
        if (submission != null) {
          final submittedAt = submission.submittedAt;
          if (submittedAt.contains('T')) {
            displayDate = submittedAt.split('T')[0];
          } else if (submittedAt.isNotEmpty) {
            displayDate = submittedAt;
          }
        }

        IconData icon = Icons.assignment_outlined;
        Color iconColor = const Color(0xff6763EB);

        String nameLower = homework.subjectName.toLowerCase();
        if (nameLower.contains('khmer')) {
          icon = Icons.translate_rounded;
          iconColor = const Color(0xffC95EDB);
        } else if (nameLower.contains('math')) {
          icon = Icons.calculate_outlined;
          iconColor = const Color(0xff6763EB);
        } else if (nameLower.contains('physic')) {
          icon = Icons.science_outlined;
          iconColor = const Color(0xff10B981);
        } else if (nameLower.contains('histor')) {
          icon = Icons.menu_book_rounded;
          iconColor = const Color(0xffEF4444);
        } else if (nameLower.contains('geograph')) {
          icon = Icons.public_rounded;
          iconColor = const Color(0xffF59E0B);
        }

        final item = HomeworkItem(
          id: homework.id,
          title: homework.title,
          description: homework.description,
          filePath: homework.filePath,
          subjectName: homework.subjectName,
          teacherName: homework.teacherName,
          status: status,
          date: displayDate,
          icon: icon,
          iconColor: iconColor,
          iconBgColor: iconColor.withValues(alpha: 0.12),
        );

        if (status == HomeworkStatus.checked) {
          completed.add(item);
        } else {
          ongoing.add(item);
        }
      }

      // Sort newest homework to top
      ongoing.sort((a, b) => b.id.compareTo(a.id));
      completed.sort((a, b) => b.id.compareTo(a.id));

      ongoingList.assignAll(ongoing);
      completedList.assignAll(completed);

      // Save to cache for instant display on next visit.
      _saveToCache();
    } catch (e) {
      logBuffer.writeln("CRITICAL ERROR: $e");
    } finally {
      isLoading.value = false;
      final logStr = logBuffer.toString();
      try {
        GetStorage().write("fetch_log", logStr);
      } catch (_) {}
    }
  }

  void showHomeworkDetails(BuildContext context, HomeworkItem item) {
    Get.to(() => HomeworkDetailView(item: item, controller: this));
  }

  Future<void> executeSubmitHomework(BuildContext context, int homeworkId,
      String answerText, List<XFile> selectedFiles) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final userController = Get.find<UserController>();
      if (userController.profile == null) {
        await userController.getProfile();
      }
      final studentId = userController.profile?.id ?? 0;

      if (studentId == 0) {
        Get.back(); // close loading
        CustomSnackbar.error(
          Get.locale?.languageCode == 'km'
              ? 'រកមិនឃើញព័ត៌មានសិស្ស'
              : 'Student profile not found.',
          title: Get.locale?.languageCode == 'km' ? 'កំហុស' : 'Error',
        );
        return;
      }

      final List<MultipartFile> fileParts = [];

      for (int index = 0; index < selectedFiles.length; index++) {
        final file = selectedFiles[index];

        final uploadFileName = _buildUploadFileName(file);

        fileParts.add(
          await MultipartFile.fromFile(
            file.path,
            filename: uploadFileName,
          ),
        );

        debugPrint('Original file name: ${file.name}');
        debugPrint('Upload file name: $uploadFileName');
      }

      await homeworkServices.submitHomework(
        homeworkId: homeworkId,
        studentId: studentId,
        answerText: answerText,
        files: fileParts,
      );

      deletedHomeworkIds.remove(homeworkId);
      _saveToCache();

      Get.back(); // close loading
      Get.back(); // close details screen page

      CustomSnackbar.success(
        Get.locale?.languageCode == 'km'
            ? 'កិច្ចការផ្ទះត្រូវបានប្រគល់ដោយជោគជ័យ!'
            : 'Homework submitted successfully!',
        title: Get.locale?.languageCode == 'km' ? 'ជោគជ័យ' : 'Success',
      );

      // Refresh homeworks
      fetchHomework();
    } catch (e) {
      Get.back(); // close loading
      CustomSnackbar.error(
        Get.locale?.languageCode == 'km'
            ? 'មិនអាចប្រគល់កិច្ចការផ្ទះបានទេ៖ $e'
            : 'Failed to submit homework: $e',
        title: Get.locale?.languageCode == 'km' ? 'កំហុស' : 'Error',
      );
    }
  }

  String _buildUploadFileName(XFile file) {
    final originalName = file.name.trim();
    final lowerName = originalName.toLowerCase();

    // File already has a valid extension
    if (lowerName.endsWith('.jpg') ||
        lowerName.endsWith('.jpeg') ||
        lowerName.endsWith('.png') ||
        lowerName.endsWith('.webp') ||
        lowerName.endsWith('.pdf')) {
      return originalName;
    }

    // Check MIME type
    final mimeType = file.mimeType?.toLowerCase();

    String extension;

    switch (mimeType) {
      case 'image/png':
        extension = '.png';
        break;

      case 'image/webp':
        extension = '.webp';
        break;

      case 'application/pdf':
        extension = '.pdf';
        break;

      case 'image/jpeg':
      case 'image/jpg':
      default:
        extension = '.jpg';
        break;
    }

    return 'homework_${DateTime.now().millisecondsSinceEpoch}$extension';
  }

  Future<void> executeUpdateSubmission({
    required BuildContext context,
    required int submissionId,
    required String answerText,
    required List<XFile> selectedFiles,
    required bool keepOldFiles,
  }) async {
    final isKm = Get.locale?.languageCode == 'km';

    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      final userController = Get.find<UserController>();

      if (userController.profile == null) {
        await userController.getProfile();
      }

      final studentId = userController.profile?.id ?? 0;

      if (studentId == 0) {
        Get.back();

        CustomSnackbar.error(
          isKm ? 'រកមិនឃើញព័ត៌មានសិស្ស' : 'Student profile not found',
          title: isKm ? 'កំហុស' : 'Error',
        );

        return;
      }

      final List<MultipartFile> fileParts = [];

      for (final file in selectedFiles) {
        final fileName = _buildUploadFileName(file);

        fileParts.add(
          await MultipartFile.fromFile(
            file.path,
            filename: fileName,
          ),
        );
      }

      await homeworkServices.updateSubmission(
        submissionId: submissionId,
        studentId: studentId,
        answerText: answerText,
        keepOldFiles: keepOldFiles,
        files: fileParts,
      );

      Get.back();
      Get.back();

      CustomSnackbar.success(
        isKm
            ? 'កិច្ចការត្រូវបានកែប្រែដោយជោគជ័យ'
            : 'Submission updated successfully',
        title: isKm ? 'ជោគជ័យ' : 'Success',
      );

      await fetchHomework();
    } catch (error) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      CustomSnackbar.error(
        isKm
            ? 'មិនអាចកែប្រែកិច្ចការបានទេ៖ $error'
            : 'Failed to update submission: $error',
        title: isKm ? 'កំហុស' : 'Error',
      );
    }
  }

  void _removeSubmissionLocally(int submissionId) {
    try {
      int? foundHomeworkId;
      submissionMap.removeWhere((key, value) {
        if (value.id == submissionId) {
          foundHomeworkId = key;
          return true;
        }
        return false;
      });

      if (foundHomeworkId != null) {
        final index =
            completedList.indexWhere((item) => item.id == foundHomeworkId);
        if (index != -1) {
          final oldItem = completedList.removeAt(index);
          final newItem = HomeworkItem(
            id: oldItem.id,
            title: oldItem.title,
            description: oldItem.description,
            filePath: oldItem.filePath,
            subjectName: oldItem.subjectName,
            teacherName: oldItem.teacherName,
            status: HomeworkStatus.none,
            date: oldItem.date,
            icon: oldItem.icon,
            iconColor: oldItem.iconColor,
            iconBgColor: oldItem.iconBgColor,
          );
          ongoingList.add(newItem);
        }
      }

      submissionMap.refresh();
      ongoingList.refresh();
      completedList.refresh();
      _saveToCache();
    } catch (e) {
      debugPrint('REMOVE SUBMISSION LOCALLY ERROR: $e');
    }
  }

  Future<void> executeDeleteSubmission({
    required int submissionId,
  }) async {
    final isKm = Get.locale?.languageCode == 'km';

    try {
      final userController = Get.find<UserController>();

      if (userController.profile == null) {
        await userController.getProfile();
      }

      final studentId = userController.profile?.id ?? 0;

      if (studentId == 0) {
        CustomSnackbar.error(
          isKm ? 'រកមិនឃើញព័ត៌មានសិស្ស' : 'Student profile not found',
          title: isKm ? 'កំហុស' : 'Error',
        );

        return;
      }

      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      try {
        await homeworkServices.deleteSubmission(
          submissionId: submissionId,
          studentId: studentId,
        );
      } catch (apiError) {
        debugPrint('DELETE SUBMISSION API FALLBACK: $apiError');
      }

      _removeSubmissionLocally(submissionId);

      if (Get.isDialogOpen == true) {
        Get.back();
      }
      Get.back();

      CustomSnackbar.success(
        isKm
            ? 'កិច្ចការត្រូវបានលុបដោយជោគជ័យ'
            : 'Submission deleted successfully',
        title: isKm ? 'ជោគជ័យ' : 'Success',
      );

      await fetchHomework();
    } catch (error) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      CustomSnackbar.error(
        isKm
            ? 'មិនអាចលុបកិច្ចការបានទេ៖ $error'
            : 'Failed to delete submission: $error',
        title: isKm ? 'កំហុស' : 'Error',
      );
    }
  }
}
