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

class HomeworkViewController extends GetxController {
  final selectedTabIndex = 0.obs;

  final ongoingList = <HomeworkItem>[].obs;
  final completedList = <HomeworkItem>[].obs;
  final isLoading = false.obs;
  final submissionMap = <int, SubmissionModel>{}.obs;

  final homeworkServices = HomeworkServices();

  @override
  void onInit() {
    super.onInit();
    fetchHomework();
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
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
    isLoading.value = true;
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

  Future<void> executeSubmitHomework(
      BuildContext context, int homeworkId, String answerText, List<XFile> selectedFiles) async {
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
        Get.snackbar("Error", "Student profile not found.");
        return;
      }

      final List<MultipartFile> fileParts = [];
      for (var file in selectedFiles) {
        fileParts.add(await MultipartFile.fromFile(
          file.path,
          filename: file.name,
        ));
      }

      await homeworkServices.submitHomework(
        homeworkId: homeworkId,
        studentId: studentId,
        answerText: answerText,
        files: fileParts,
      );

      Get.back(); // close loading
      Get.back(); // close details screen page

      Get.snackbar(
        Get.locale?.languageCode == 'km' ? 'ជោគជ័យ' : 'Success',
        Get.locale?.languageCode == 'km'
            ? 'កិច្ចការផ្ទះត្រូវបានប្រគល់ដោយជោគជ័យ!'
            : 'Homework submitted successfully!',
        backgroundColor: AppColors.success.withValues(alpha: 0.1),
        colorText: AppColors.success,
      );

      // Refresh homeworks
      fetchHomework();
    } catch (e) {
      Get.back(); // close loading
      Get.snackbar(
        Get.locale?.languageCode == 'km' ? 'កំហុស' : 'Error',
        Get.locale?.languageCode == 'km'
            ? 'មិនអាចប្រគល់កិច្ចការផ្ទះបានទេ៖ $e'
            : 'Failed to submit homework: $e',
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
      );
    }
  }
}
