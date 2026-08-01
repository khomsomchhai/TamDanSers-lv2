part of 'parent_homework_tab_view.dart';

enum ParentHomeworkStatus {
  done,
  notComplete,
  missing,
}

class SubjectGroupItem {
  final String name;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final int totalHomeworkCount;
  final int doneCount;
  final int notCompleteCount;
  final int missingCount;
  final double overallProgress;
  final String totalScore; // Dynamic score e.g., '95 / 100'

  SubjectGroupItem({
    required this.name,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.totalHomeworkCount,
    required this.doneCount,
    required this.notCompleteCount,
    required this.missingCount,
    required this.overallProgress,
    required this.totalScore,
  });
}

class ParentHomeworkItem {
  final int id;
  final String category;
  final String title;
  final String teacherName;
  final String dueDate;
  final double progress;
  final ParentHomeworkStatus status;
  final String description;
  final String score; // e.g. '95 / 100', 'Pending', '0 / 100'
  final String teacherComment; // Message / feedback from teacher

  ParentHomeworkItem({
    required this.id,
    required this.category,
    required this.title,
    required this.teacherName,
    required this.dueDate,
    required this.progress,
    required this.status,
    this.description = '',
    this.score = '-',
    this.teacherComment = '',
  });

  IconData get icon => SubjectUi.icon(category);
  Color get iconColor => SubjectUi.color(category);
  Color get iconBgColor => SubjectUi.bgColor(category);

  String get statusLabel {
    final isKm = Get.locale?.languageCode == 'km';
    switch (status) {
      case ParentHomeworkStatus.done:
        return isKm ? 'បានបញ្ចប់' : 'Done';
      case ParentHomeworkStatus.notComplete:
        return isKm ? 'មិនទាន់រួច' : 'Not Complete';
      case ParentHomeworkStatus.missing:
        return isKm ? 'ហួសកំណត់' : 'Missing';
    }
  }

  Color get statusTextColor {
    switch (status) {
      case ParentHomeworkStatus.done:
        return const Color(0xFF16A34A);
      case ParentHomeworkStatus.notComplete:
        return const Color(0xFF2563EB);
      case ParentHomeworkStatus.missing:
        return const Color(0xFFDC2626);
    }
  }

  Color get statusBgColor {
    switch (status) {
      case ParentHomeworkStatus.done:
        return const Color(0xFFDCFCE7);
      case ParentHomeworkStatus.notComplete:
        return const Color(0xFFDBEAFE);
      case ParentHomeworkStatus.missing:
        return const Color(0xFFFEE2E2);
    }
  }
}

class ParentHomeworkTabViewController extends GetxController {
  final UserController userController = Get.find<UserController>();
  final HomeworkServices _homeworkServices = HomeworkServices();
  final GetStorage box = GetStorage();

  final isLoading = false.obs;
  final students = <Map<String, dynamic>>[].obs;
  final Rxn<Map<String, dynamic>> selectedChild = Rxn<Map<String, dynamic>>();

  final allHomeworkList = <ParentHomeworkItem>[].obs;
  final subjectGroupList = <SubjectGroupItem>[].obs;
  final filteredHomeworkList = <ParentHomeworkItem>[].obs;

  // Navigation State: null = Subject Cards Overview Grid, Non-null = "1 Subject" Homework View
  final RxnString selectedSubject = RxnString(null);

  // Tab Index inside 1 Subject: 0 = All, 1 = Done, 2 = Not Complete, 3 = Missing
  final selectedTabIndex = 0.obs;
  final searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadStudents();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void loadStudents() {
    final data = box.read('students');

    if (data is List && data.isNotEmpty) {
      students.assignAll(
        data.map((item) => Map<String, dynamic>.from(item as Map)),
      );
      selectedChild.value = students.first;
      final studentId = _parseStudentId(students.first['id']);
      if (studentId != null) {
        fetchHomework(studentId);
        return;
      }
    }

    fetchHomework();
  }

  void selectChild(Map<String, dynamic> child) {
    selectedChild.value = child;
    selectedSubject.value = null; // reset to subjects overview
    final studentId = _parseStudentId(child['id']);
    fetchHomework(studentId);
  }

  int? _parseStudentId(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  // Fetch homework and submissions from API
  Future<void> fetchHomework([int? studentId]) async {
    try {
      isLoading.value = true;
      final id = studentId ?? _parseStudentId(selectedChild.value?['id']);

      List<dynamic> rawHomework = [];
      List<dynamic> rawSubmissions = [];

      if (id != null) {
        final results = await Future.wait([
          _homeworkServices.fetchStudentHomeworkList(id),
          _homeworkServices.fetchStudentSubmissions(id),
        ]);
        rawHomework = results[0];
        rawSubmissions = results[1];
      }

      // Fallback to general homework list API if student-specific endpoint is empty
      if (rawHomework.isEmpty) {
        rawHomework = await _homeworkServices.fetchHomeworkList();
      }

      if (rawHomework.isNotEmpty) {
        final submissionsMap = <int, Map<String, dynamic>>{};
        for (final sub in rawSubmissions) {
          if (sub is Map<String, dynamic>) {
            final hwId = _parseStudentId(sub['homework_id']);
            if (hwId != null) {
              submissionsMap[hwId] = sub;
            }
          }
        }

        final items = rawHomework.map((json) {
          final model = HomeworkModel.fromJson(json as Map<String, dynamic>);
          final sub = submissionsMap[model.id];
          return _mapHomeworkModelToItem(model, sub);
        }).toList();

        allHomeworkList.assignAll(items);
        _computeSubjectGroups();
        applyFilters();
        return;
      }

      loadDefaultHomeworkItems();
    } catch (e) {
      debugPrint('Error fetching parent homework API: $e');
      loadDefaultHomeworkItems();
    } finally {
      isLoading.value = false;
    }
  }

  ParentHomeworkItem _mapHomeworkModelToItem(
    HomeworkModel model,
    Map<String, dynamic>? submission,
  ) {
    final subject = model.subjectName.isNotEmpty ? model.subjectName : 'Khmer';
    final category = _normalizeSubjectName(subject);

    ParentHomeworkStatus status = ParentHomeworkStatus.notComplete;
    double progress = 0.5;
    String score = 'Pending';
    String teacherComment = '';

    DateTime? dueDateTime = DateTime.tryParse(model.dueDate);

    if (submission != null) {
      final subStatus = submission['status']?.toString().toLowerCase() ?? '';
      final rawScore = submission['score'];
      teacherComment = submission['teacher_comment']?.toString() ??
          submission['comment']?.toString() ??
          submission['feedback']?.toString() ??
          submission['remark']?.toString() ??
          '';

      if (subStatus == 'checked' ||
          subStatus == 'graded' ||
          subStatus == 'submitted' ||
          rawScore != null) {
        status = ParentHomeworkStatus.done;
        progress = 1.0;
        if (rawScore != null) {
          score = '$rawScore / 100';
        } else {
          score = 'Completed';
        }
      }
    } else if (dueDateTime != null && DateTime.now().isAfter(dueDateTime)) {
      status = ParentHomeworkStatus.missing;
      progress = 0.0;
      score = '0 / 100';
    }

    return ParentHomeworkItem(
      id: model.id,
      category: category,
      title: model.title.isNotEmpty ? model.title : model.subjectName,
      teacherName: model.teacherName.isNotEmpty ? model.teacherName : 'Teacher',
      dueDate: model.dueDate.isNotEmpty ? model.dueDate : 'Due soon',
      progress: progress,
      status: status,
      description: model.description,
      score: score,
      teacherComment: teacherComment,
    );
  }

  void loadDefaultHomeworkItems() {
    allHomeworkList.assignAll([
      // Khmer Subject
      ParentHomeworkItem(
        id: 1,
        category: 'Khmer',
        title: 'Literature: Reamker Analysis',
        teacherName: 'Mr. Sokha',
        dueDate: 'Due tomorrow',
        progress: 0.75,
        status: ParentHomeworkStatus.notComplete,
        description:
            'Read Chapter 4 of Reamker and analyze character motivations.',
        score: 'Pending',
        teacherComment:
            'សូមយកចិត្តទុកដាក់លើការវិភាគអត្ថន័យអត្ថបទនៅជំពូកទី៤។ (Please analyze character motivations carefully.)',
      ),
      ParentHomeworkItem(
        id: 2,
        category: 'Khmer',
        title: 'Poetry Composition & Essay',
        teacherName: 'Mr. Sokha',
        dueDate: 'Overdue (Yesterday)',
        progress: 0.20,
        status: ParentHomeworkStatus.missing,
        description:
            'Write a 3-paragraph poem exploring Khmer traditional metaphors.',
        score: '0 / 100',
        teacherComment:
            'កិច្ចការនេះហួសកំណត់ហើយ! សូមប្រញាប់ផ្ញើមកគ្រូឡើងវិញ។ (Overdue! Please submit as soon as possible.)',
      ),
      ParentHomeworkItem(
        id: 3,
        category: 'Khmer',
        title: 'Grammar & Vocabulary Quiz',
        teacherName: 'Mr. Sokha',
        dueDate: 'Completed Nov 20',
        progress: 1.0,
        status: ParentHomeworkStatus.done,
        description: 'Submitted 10-page vocabulary exercise sheet.',
        score: '95 / 100',
        teacherComment:
            'ធ្វើបានល្អណាស់! សរសេរបានត្រឹមត្រូវ និងស្អាតបាត។ (Great job! Accurate grammar and neat handwriting.)',
      ),

      // Math Subject
      ParentHomeworkItem(
        id: 4,
        category: 'Math',
        title: 'Calculus: Derivatives',
        teacherName: 'Ms. Priya',
        dueDate: 'Due Fri, 22 Nov',
        progress: 0.25,
        status: ParentHomeworkStatus.notComplete,
        description:
            'Complete exercises 15 through 30 on implicit differentiation.',
        score: 'Pending',
        teacherComment:
            'Review step 3 of implicit differentiation formulas before submitting.',
      ),
      ParentHomeworkItem(
        id: 5,
        category: 'Math',
        title: 'Algebra: Matrix Multiplication',
        teacherName: 'Ms. Priya',
        dueDate: 'Completed Nov 18',
        progress: 1.0,
        status: ParentHomeworkStatus.done,
        description: 'Solve determinants and inverses problem set.',
        score: '90 / 100',
        teacherComment: 'Well done! Clear step-by-step matrix row operations.',
      ),
      ParentHomeworkItem(
        id: 6,
        category: 'Math',
        title: 'Trigonometric Identities Sheet',
        teacherName: 'Ms. Priya',
        dueDate: 'Overdue (3 days ago)',
        progress: 0.10,
        status: ParentHomeworkStatus.missing,
        description: 'Prove 10 trigonometric identities and submit PDF.',
        score: '0 / 100',
        teacherComment:
            'Please contact me if you need help with proving identities.',
      ),

      // Biology Subject
      ParentHomeworkItem(
        id: 7,
        category: 'Biology',
        title: 'Cell Structure Lab Report',
        teacherName: 'Dr. Chan',
        dueDate: 'Due Mon, 25 Nov',
        progress: 0.45,
        status: ParentHomeworkStatus.notComplete,
        description:
            'Submit detailed observation report of plant cell mitosis.',
        score: 'Pending',
        teacherComment:
            'Do not forget to include labeled diagrams of plant cell mitosis.',
      ),
      ParentHomeworkItem(
        id: 8,
        category: 'Biology',
        title: 'Genetics & DNA Diagram',
        teacherName: 'Dr. Chan',
        dueDate: 'Completed Nov 15',
        progress: 1.0,
        status: ParentHomeworkStatus.done,
        description: 'Submitted DNA double helix model diagram.',
        score: '88 / 100',
        teacherComment:
            'Excellent double helix structure diagram and color coding!',
      ),

      // Physics Subject
      ParentHomeworkItem(
        id: 9,
        category: 'Physical',
        title: 'Newtonian Mechanics Problems',
        teacherName: 'Dr. Vance',
        dueDate: 'Due Wed, 27 Nov',
        progress: 0.85,
        status: ParentHomeworkStatus.notComplete,
        description:
            'Solve force vector and friction coefficient calculation sheet.',
        score: 'Pending',
        teacherComment: 'Double check force vector direction signs.',
      ),
      ParentHomeworkItem(
        id: 10,
        category: 'Physical',
        title: 'Thermodynamics Worksheet',
        teacherName: 'Dr. Vance',
        dueDate: 'Overdue (4 days ago)',
        progress: 0.0,
        status: ParentHomeworkStatus.missing,
        description: 'Calculate heat transfer efficiency in closed system.',
        score: '0 / 100',
        teacherComment: 'Heat transfer calculations missing. Please re-submit.',
      ),

      // English Subject
      ParentHomeworkItem(
        id: 11,
        category: 'English',
        title: 'Essay: Modern Literature',
        teacherName: 'Mrs. Davis',
        dueDate: 'Completed Nov 18',
        progress: 1.0,
        status: ParentHomeworkStatus.done,
        description: 'Submit 500-word critical review of 20th century poetry.',
        score: '96 / 100',
        teacherComment:
            'Outstanding critical essay! Excellent vocabulary and structure.',
      ),

      // Chemical Subject
      ParentHomeworkItem(
        id: 12,
        category: 'Chemical',
        title: 'Chemical Bonding & Reactions',
        teacherName: 'Mr. Kim',
        dueDate: 'Due Thu, 28 Nov',
        progress: 0.20,
        status: ParentHomeworkStatus.notComplete,
        description: 'Balance equation worksheets and ionic bond diagrams.',
        score: 'Pending',
        teacherComment:
            'Remember to balance both sides of ionic reaction equations.',
      ),
    ]);
    _computeSubjectGroups();
    applyFilters();
  }

  void _computeSubjectGroups() {
    final Map<String, List<ParentHomeworkItem>> groups = {};

    for (final item in allHomeworkList) {
      groups.putIfAbsent(item.category, () => []).add(item);
    }

    final list = <SubjectGroupItem>[];

    groups.forEach((subject, items) {
      final doneCount =
          items.where((i) => i.status == ParentHomeworkStatus.done).length;
      final notCompleteCount = items
          .where((i) => i.status == ParentHomeworkStatus.notComplete)
          .length;
      final missingCount =
          items.where((i) => i.status == ParentHomeworkStatus.missing).length;
      final totalProgress = items.fold<double>(0, (sum, i) => sum + i.progress);
      final avgProgress = items.isNotEmpty ? totalProgress / items.length : 0.0;

      // Calculate subject average score dynamically from graded/completed items
      final gradedOrMissingItems = items
          .where((i) =>
              i.score.contains('/') ||
              i.status == ParentHomeworkStatus.done ||
              i.status == ParentHomeworkStatus.missing)
          .toList();
      String totalScoreStr = '0 / 100';

      if (gradedOrMissingItems.isNotEmpty) {
        int sumScore = 0;
        int validCount = 0;
        for (final item in gradedOrMissingItems) {
          if (item.score.contains('/')) {
            final parts = item.score.split('/');
            if (parts.isNotEmpty) {
              final parsed = int.tryParse(parts[0].trim());
              if (parsed != null) {
                sumScore += parsed;
                validCount++;
              }
            }
          } else if (item.status == ParentHomeworkStatus.missing) {
            sumScore += 0;
            validCount++;
          }
        }
        if (validCount > 0) {
          final avgScore = (sumScore / validCount).round();
          totalScoreStr = '$avgScore / 100';
        }
      }

      list.add(
        SubjectGroupItem(
          name: subject,
          icon: SubjectUi.icon(subject),
          color: SubjectUi.color(subject),
          bgColor: SubjectUi.bgColor(subject),
          totalHomeworkCount: items.length,
          doneCount: doneCount,
          notCompleteCount: notCompleteCount,
          missingCount: missingCount,
          overallProgress: avgProgress,
          totalScore: totalScoreStr,
        ),
      );
    });

    subjectGroupList.assignAll(list);
  }

  void openSubject(String subjectName) {
    selectedSubject.value = subjectName;
    selectedTabIndex.value = 0; // default to All inside subject
    applyFilters();
  }

  void backToSubjectList() {
    selectedSubject.value = null;
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
    applyFilters();
  }

  void onSearch(String value) {
    searchQuery.value = value;
    applyFilters();
  }

  void applyFilters() {
    if (selectedSubject.value == null) {
      filteredHomeworkList.clear();
      return;
    }

    var result = allHomeworkList
        .where((i) => i.category == selectedSubject.value)
        .toList();

    // Tab Filter: 0 = All, 1 = Done, 2 = Not Complete, 3 = Missing
    if (selectedTabIndex.value == 1) {
      result = result
          .where((item) => item.status == ParentHomeworkStatus.done)
          .toList();
    } else if (selectedTabIndex.value == 2) {
      result = result
          .where((item) => item.status == ParentHomeworkStatus.notComplete)
          .toList();
    } else if (selectedTabIndex.value == 3) {
      result = result
          .where((item) => item.status == ParentHomeworkStatus.missing)
          .toList();
    }

    if (searchQuery.value.trim().isNotEmpty) {
      final query = searchQuery.value.toLowerCase().trim();
      result = result.where((item) {
        return item.title.toLowerCase().contains(query) ||
            item.teacherName.toLowerCase().contains(query);
      }).toList();
    }

    // Sort missing (overdue) items first at the top of the list
    result.sort((a, b) {
      if (a.status == ParentHomeworkStatus.missing &&
          b.status != ParentHomeworkStatus.missing) {
        return -1;
      }
      if (a.status != ParentHomeworkStatus.missing &&
          b.status == ParentHomeworkStatus.missing) {
        return 1;
      }
      return 0;
    });

    filteredHomeworkList.assignAll(result);
  }

  // Subject-specific getters for dashboard stats
  int get subjectAllCount {
    if (selectedSubject.value == null) return 0;
    return allHomeworkList
        .where((i) => i.category == selectedSubject.value)
        .length;
  }

  int get subjectDoneCount {
    if (selectedSubject.value == null) return 0;
    return allHomeworkList
        .where((i) =>
            i.category == selectedSubject.value &&
            i.status == ParentHomeworkStatus.done)
        .length;
  }

  int get subjectNotCompleteCount {
    if (selectedSubject.value == null) return 0;
    return allHomeworkList
        .where((i) =>
            i.category == selectedSubject.value &&
            i.status == ParentHomeworkStatus.notComplete)
        .length;
  }

  int get subjectMissingCount {
    if (selectedSubject.value == null) return 0;
    return allHomeworkList
        .where((i) =>
            i.category == selectedSubject.value &&
            i.status == ParentHomeworkStatus.missing)
        .length;
  }

  String get subjectTotalScore {
    if (selectedSubject.value == null) return '0 / 100';
    final group = subjectGroupList
        .firstWhereOrNull((g) => g.name == selectedSubject.value);
    return group?.totalScore ?? '0 / 100';
  }

  int get totalAssignmentsCount => allHomeworkList.length;

  int get totalDoneCount => allHomeworkList
      .where((i) => i.status == ParentHomeworkStatus.done)
      .length;

  int get totalNotCompleteCount => allHomeworkList
      .where((i) => i.status == ParentHomeworkStatus.notComplete)
      .length;

  int get totalMissingCount => allHomeworkList
      .where((i) => i.status == ParentHomeworkStatus.missing)
      .length;

  double get overallCompletionRate {
    if (allHomeworkList.isEmpty) return 0.0;
    final sum =
        allHomeworkList.fold<double>(0, (acc, item) => acc + item.progress);
    return sum / allHomeworkList.length;
  }

  String _normalizeSubjectName(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('khmer')) return 'Khmer';
    if (s.contains('math')) return 'Math';
    if (s.contains('bio')) return 'Biology';
    if (s.contains('physic')) return 'Physical';
    if (s.contains('chem')) return 'Chemical';
    if (s.contains('eng')) return 'English';
    if (s.contains('hist')) return 'History';
    if (s.contains('geog')) return 'Geography';
    return subject;
  }

  String get childName {
    return selectedChild.value?['student_name']?.toString() ??
        'dont_have_child'.tr;
  }
}
