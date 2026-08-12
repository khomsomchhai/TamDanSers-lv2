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
  final String totalScore;

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
  final String score;
  final String teacherComment;
  final DateTime? date;

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
    this.date,
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

  // Navigation State: null = Subject Cards Overview Grid, Non-null = "1 Subject" View
  final RxnString selectedSubject = RxnString(null);

  // Month Filter State: null = All Months (គ្រប់ខែ), 1..12 = Specific Month
  final RxnInt selectedMonth = RxnInt(null);

  // Tab Index inside 1 Subject: 0 = All, 1 = Done, 2 = Not Complete, 3 = Missing
  final selectedTabIndex = 0.obs;
  final searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    syncMonthFromHomeTab();
    _setupAutoRefreshListeners();
    loadStudents();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // =========================================================
  // HOME TAB MONTH SYNC & AUTO REFRESH LISTENERS
  // =========================================================

  void syncMonthFromHomeTab() {
    if (Get.isRegistered<ParentHomeTabViewController>()) {
      final homeController = Get.find<ParentHomeTabViewController>();
      final subResult = homeController.selectedSubResult.value;
      final month = _parseMonthFromKhmerString(subResult);
      if (month != null) {
        selectedMonth.value = month;
      }
    }
  }

  int? _parseMonthFromKhmerString(String subResult) {
    const khmerMonths = [
      'ខែមករា',
      'ខែកុម្ភៈ',
      'ខែមីនា',
      'ខែមេសា',
      'ខែឧសភា',
      'ខែមិថុនា',
      'ខែកក្កដា',
      'ខែសីហា',
      'ខែកញ្ញា',
      'ខែតុលា',
      'ខែវិច្ឆិកា',
      'ខែធ្នូ'
    ];
    const shortMonths = [
      'មករា',
      'កុម្ភៈ',
      'មីនា',
      'មេសា',
      'ឧសភា',
      'មិថុនា',
      'កក្កដា',
      'សីហា',
      'កញ្ញា',
      'តុលា',
      'វិច្ឆិកា',
      'ធ្នូ'
    ];

    int idx = khmerMonths.indexOf(subResult.trim());
    if (idx < 0) idx = shortMonths.indexOf(subResult.trim());
    if (idx < 0) {
      final clean = subResult.replaceAll('ខែ', '').trim();
      idx = shortMonths.indexOf(clean);
    }
    if (idx >= 0) return idx + 1;
    return null;
  }

  void _setupAutoRefreshListeners() {
    if (Get.isRegistered<ParentHomeTabViewController>()) {
      final homeTabController = Get.find<ParentHomeTabViewController>();

      // 1. Listen to child changes
      ever(homeTabController.selectedChild, (dynamic child) {
        if (child != null) {
          final studentId = _parseStudentId(child);
          debugPrint('🔄 AUTO REFRESH: Child switched to ID $studentId');
          selectedSubject.value = null; // Reset view to subject overview grid
          fetchHomework(studentId);
        }
      });

      // 2. Listen to month selection from home_tab
      ever(homeTabController.selectedSubResult, (String subResult) {
        final month = _parseMonthFromKhmerString(subResult);
        if (month != null) {
          debugPrint('📅 HOME TAB MONTH CHANGED: $subResult -> Month $month');
          selectedMonth.value = month;
          _computeSubjectGroups();
          applyFilters();
        }
      });
    }
  }

  void selectMonth(int? month) {
    selectedMonth.value = month;
    _computeSubjectGroups();
    applyFilters();
  }

  String get selectedMonthName {
    final isKm = Get.locale?.languageCode == 'km';
    if (selectedMonth.value == null) {
      return isKm ? 'គ្រប់ខែ' : 'All Months';
    }

    const khmerMonths = [
      'មករា',
      'កុម្ភៈ',
      'មីនា',
      'មេសា',
      'ឧសភា',
      'មិថុនា',
      'កក្កដា',
      'សីហា',
      'កញ្ញា',
      'តុលា',
      'វិច្ឆិកា',
      'ធ្នូ'
    ];
    const englishMonths = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    final idx = (selectedMonth.value! - 1).clamp(0, 11);
    return isKm ? 'ខែ${khmerMonths[idx]}' : englishMonths[idx];
  }

  void loadStudents() {
    final data = box.read('students');

    if (data is List && data.isNotEmpty) {
      students.assignAll(
        data.map((item) => Map<String, dynamic>.from(item as Map)),
      );
      selectedChild.value = students.first;
    }

    final activeId = getActiveStudentId();
    fetchHomework(activeId);
  }

  void selectChild(Map<String, dynamic> child) {
    selectedChild.value = child;
    selectedSubject.value = null; // Reset to subjects overview
    final studentId = _parseStudentId(child);
    fetchHomework(studentId);
  }

  // =========================================================
  // RELIABLE STUDENT ID RESOLVER
  // =========================================================

  int? getActiveStudentId() {
    int? studentId;

    if (Get.isRegistered<ParentHomeTabViewController>()) {
      final homeTabController = Get.find<ParentHomeTabViewController>();
      final dynamic homeChild = homeTabController.selectedChild.value;

      studentId = _parseStudentId(homeChild);

      if (studentId != null) {
        if (homeChild is Map) {
          selectedChild.value = Map<String, dynamic>.from(homeChild);
        }
        return studentId;
      }
    }

    if (selectedChild.value != null) {
      studentId = _parseStudentId(selectedChild.value);
      if (studentId != null) return studentId;
    }

    final storageStudents = box.read('students');
    if (storageStudents is List && storageStudents.isNotEmpty) {
      final firstStudent =
          Map<String, dynamic>.from(storageStudents.first as Map);
      selectedChild.value = firstStudent;
      studentId = _parseStudentId(firstStudent);
      if (studentId != null) return studentId;
    }

    final directChild = box.read('selected_child') ??
        box.read('student') ??
        box.read('student_id');
    studentId = _parseStudentId(directChild);
    if (studentId != null) return studentId;

    return null;
  }

  int? _parseStudentId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();

    if (value is Map) {
      final keys = [
        'id',
        'student_id',
        'studentId',
        'child_id',
        'childId',
        'user_id',
        'userId',
      ];

      for (final key in keys) {
        final parsed = _parseStudentId(value[key]);
        if (parsed != null) return parsed;
      }

      final nestedStudent = _parseStudentId(value['student']) ??
          _parseStudentId(value['child']) ??
          _parseStudentId(value['user']);

      if (nestedStudent != null) return nestedStudent;
    }

    return int.tryParse(value.toString().trim());
  }

  // =========================================================
  // FETCH HOMEWORK AND SUBMISSIONS FROM API
  // =========================================================

  Future<void> fetchHomework([int? studentId]) async {
    try {
      isLoading.value = true;
      final int? id = studentId ?? getActiveStudentId();

      dynamic rawHomeworkResp;
      dynamic rawSubmissionsResp;

      if (id != null) {
        rawHomeworkResp = await _homeworkServices.fetchStudentHomeworkList(id);
        rawSubmissionsResp =
            await _homeworkServices.fetchStudentSubmissions(id);
      }

      List<dynamic> rawHomework = _unwrapList(rawHomeworkResp);
      List<dynamic> rawSubmissions = _unwrapList(rawSubmissionsResp);

      if (rawHomework.isEmpty) {
        final generalResp = await _homeworkServices.fetchHomeworkList();
        rawHomework = _unwrapList(generalResp);
      }

      if (rawHomework.isNotEmpty) {
        final submissionsMap = <int, Map<String, dynamic>>{};
        for (final sub in rawSubmissions) {
          if (sub is Map) {
            final subMap = Map<String, dynamic>.from(sub);
            final hwId = _extractHomeworkId(subMap);
            if (hwId != null) {
              submissionsMap[hwId] = subMap;
            }
          }
        }

        final items = rawHomework
            .map((json) {
              if (json is Map) {
                final model =
                    HomeworkModel.fromJson(Map<String, dynamic>.from(json));
                final modelId = _parseStudentId(model.id) ?? model.id;
                final sub = submissionsMap[modelId] ?? submissionsMap[model.id];
                return _mapHomeworkModelToItem(model, sub);
              }
              return null;
            })
            .whereType<ParentHomeworkItem>()
            .toList();

        if (items.isNotEmpty) {
          allHomeworkList.assignAll(items);
          _computeSubjectGroups();
          applyFilters();
          return;
        }
      }

      loadDefaultHomeworkItems();
    } catch (e, stackTrace) {
      debugPrint('Error fetching parent homework API: $e');
      debugPrintStack(stackTrace: stackTrace);
      loadDefaultHomeworkItems();
    } finally {
      isLoading.value = false;
    }
  }

  int? _extractHomeworkId(Map<String, dynamic> sub) {
    final possibleKeys = [
      'homework_id',
      'homeworkId',
      'assignment_id',
      'assignmentId',
      'task_id',
      'taskId',
      'homework',
      'assignment',
    ];

    for (final key in possibleKeys) {
      final val = sub[key];
      if (val != null) {
        if (val is num) return val.toInt();
        if (val is String) {
          final parsed = int.tryParse(val.trim());
          if (parsed != null) return parsed;
        }
        if (val is Map) {
          final nestedId = val['id'] ?? val['homework_id'] ?? val['homeworkId'];
          if (nestedId != null) {
            final parsed = int.tryParse(nestedId.toString().trim());
            if (parsed != null) return parsed;
          }
        }
      }
    }

    return null;
  }

  List<dynamic> _unwrapList(dynamic response) {
    if (response == null) return [];
    if (response is List) return response;
    if (response is Map) {
      final keys = [
        'data',
        'submissions',
        'homeworks',
        'assignments',
        'results',
        'list'
      ];
      for (final key in keys) {
        if (response[key] is List) {
          return response[key] as List<dynamic>;
        }
      }
    }
    try {
      final dynamic data = (response as dynamic).data;
      if (data != null) return _unwrapList(data);
    } catch (_) {}

    return [];
  }

  ParentHomeworkItem _mapHomeworkModelToItem(
    HomeworkModel model,
    Map<String, dynamic>? submission,
  ) {
    final subject = model.subjectName.isNotEmpty ? model.subjectName : 'Khmer';
    final category = _normalizeSubjectName(subject);

    ParentHomeworkStatus status = ParentHomeworkStatus.notComplete;
    double progress = 0.0;
    String score = 'Pending';
    String teacherComment = '';

    DateTime? dueDateTime =
        DateTime.tryParse(model.dueDate) ?? _parseDateFromText(model.dueDate);

    if (submission != null) {
      final subStatus = submission['status']?.toString().toLowerCase() ?? '';
      final rawScore =
          submission['score'] ?? submission['grade'] ?? submission['mark'];
      final rawMaxScore = submission['max_score'] ??
          submission['maxScore'] ??
          submission['total_score'] ??
          submission['totalScore'] ??
          submission['out_of'] ??
          submission['outOf'];

      teacherComment = submission['teacher_comment']?.toString() ??
          submission['comment']?.toString() ??
          submission['feedback']?.toString() ??
          submission['remark']?.toString() ??
          '';

      final isGraded = subStatus == 'checked' ||
          subStatus == 'graded' ||
          subStatus == 'approved' ||
          subStatus == 'completed' ||
          rawScore != null;

      if (isGraded) {
        status = ParentHomeworkStatus.done;
        progress = 1.0;
        if (rawScore != null) {
          final scoreStr = rawScore.toString().trim();
          if (scoreStr.contains('/')) {
            score = scoreStr;
          } else if (rawMaxScore != null) {
            score = '$scoreStr / $rawMaxScore';
          } else {
            final numVal = double.tryParse(scoreStr);
            if (numVal != null && numVal <= 10) {
              score = '$scoreStr / 10';
            } else {
              score = '$scoreStr / 100';
            }
          }
        } else {
          score = 'Completed';
        }
      } else {
        status = ParentHomeworkStatus.notComplete;
        progress = 0.5;
        score = 'Submitted';
      }
    } else if (dueDateTime != null && DateTime.now().isAfter(dueDateTime)) {
      status = ParentHomeworkStatus.missing;
      progress = 0.0;
      score = '0 / 100';
    } else {
      status = ParentHomeworkStatus.notComplete;
      progress = 0.0;
      score = 'Pending';
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
      date: dueDateTime,
    );
  }

  DateTime? _parseDateFromText(String text) {
    if (text.isEmpty) return null;
    final parsed = DateTime.tryParse(text);
    if (parsed != null) return parsed;

    final lower = text.toLowerCase();
    final months = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
      'មករា': 1,
      'កុម្ភៈ': 2,
      'មីនា': 3,
      'មេសា': 4,
      'ឧសភា': 5,
      'មិថុនា': 6,
      'កក្កដា': 7,
      'សីហា': 8,
      'កញ្ញា': 9,
      'តុលា': 10,
      'វិច្ឆិកា': 11,
      'ធ្នូ': 12,
    };

    for (final entry in months.entries) {
      if (lower.contains(entry.key)) {
        final now = DateTime.now();
        return DateTime(now.year, entry.value, 15);
      }
    }
    return null;
  }

  void loadDefaultHomeworkItems() {
    allHomeworkList.assignAll([
      // Khmer Subject (August & November)
      ParentHomeworkItem(
        id: 1,
        category: 'Khmer',
        title: 'Literature: Reamker Analysis',
        teacherName: 'Mr. Sokha',
        dueDate: 'Due tomorrow',
        progress: 0.0,
        status: ParentHomeworkStatus.notComplete,
        description:
            'Read Chapter 4 of Reamker and analyze character motivations.',
        score: 'Pending',
        teacherComment:
            'សូមយកចិត្តទុកដាក់លើការវិភាគអត្ថន័យអត្ថបទនៅជំពូកទី៤។ (Please analyze character motivations carefully.)',
        date: DateTime(2026, 8, 11),
      ),
      ParentHomeworkItem(
        id: 2,
        category: 'Khmer',
        title: 'Poetry Composition & Essay',
        teacherName: 'Mr. Sokha',
        dueDate: 'Overdue (Yesterday)',
        progress: 0.0,
        status: ParentHomeworkStatus.missing,
        description:
            'Write a 3-paragraph poem exploring Khmer traditional metaphors.',
        score: '0 / 100',
        teacherComment:
            'កិច្ចការនេះហួសកំណត់ហើយ! សូមប្រញាប់ផ្ញើមកគ្រូឡើងវិញ។ (Overdue! Please submit as soon as possible.)',
        date: DateTime(2026, 8, 9),
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
        date: DateTime(2026, 11, 20),
      ),

      // Math Subject
      ParentHomeworkItem(
        id: 4,
        category: 'Math',
        title: 'Calculus: Derivatives',
        teacherName: 'Ms. Priya',
        dueDate: 'Due Fri, 22 Nov',
        progress: 0.5,
        status: ParentHomeworkStatus.notComplete,
        description:
            'Complete exercises 15 through 30 on implicit differentiation.',
        score: 'Submitted',
        teacherComment:
            'Review step 3 of implicit differentiation formulas before submitting.',
        date: DateTime(2026, 11, 22),
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
        date: DateTime(2026, 11, 18),
      ),
      ParentHomeworkItem(
        id: 6,
        category: 'Math',
        title: 'Trigonometric Identities Sheet',
        teacherName: 'Ms. Priya',
        dueDate: 'Overdue (3 days ago)',
        progress: 0.0,
        status: ParentHomeworkStatus.missing,
        description: 'Prove 10 trigonometric identities and submit PDF.',
        score: '0 / 100',
        teacherComment:
            'Please contact me if you need help with proving identities.',
        date: DateTime(2026, 8, 7),
      ),

      // Biology Subject
      ParentHomeworkItem(
        id: 7,
        category: 'Biology',
        title: 'Cell Structure Lab Report',
        teacherName: 'Dr. Chan',
        dueDate: 'Due Mon, 25 Nov',
        progress: 0.0,
        status: ParentHomeworkStatus.notComplete,
        description:
            'Submit detailed observation report of plant cell mitosis.',
        score: 'Pending',
        teacherComment:
            'Do not forget to include labeled diagrams of plant cell mitosis.',
        date: DateTime(2026, 11, 25),
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
        date: DateTime(2026, 11, 15),
      ),

      // Physics Subject
      ParentHomeworkItem(
        id: 9,
        category: 'Physical',
        title: 'Newtonian Mechanics Problems',
        teacherName: 'Dr. Vance',
        dueDate: 'Submitted (Awaiting Grade)',
        progress: 0.5,
        status: ParentHomeworkStatus.notComplete,
        description:
            'Solve force vector and friction coefficient calculation sheet.',
        score: 'Submitted',
        teacherComment: 'Submitted by student. Pending teacher evaluation.',
        date: DateTime(2026, 8, 10),
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
        date: DateTime(2026, 8, 6),
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
        date: DateTime(2026, 11, 18),
      ),

      // Chemical Subject
      ParentHomeworkItem(
        id: 12,
        category: 'Chemical',
        title: 'Chemical Bonding & Reactions',
        teacherName: 'Mr. Kim',
        dueDate: 'Due Thu, 28 Nov',
        progress: 0.0,
        status: ParentHomeworkStatus.notComplete,
        description: 'Balance equation worksheets and ionic bond diagrams.',
        score: 'Pending',
        teacherComment:
            'Remember to balance both sides of ionic reaction equations.',
        date: DateTime(2026, 11, 28),
      ),
    ]);
    _computeSubjectGroups();
    applyFilters();
  }

  List<ParentHomeworkItem> get _activeMonthHomeworkList {
    if (selectedMonth.value == null) {
      return allHomeworkList;
    }
    return allHomeworkList.where((item) {
      if (item.date == null) return true;
      return item.date!.month == selectedMonth.value;
    }).toList();
  }

  void _computeSubjectGroups() {
    final activeItems = _activeMonthHomeworkList;
    final Map<String, List<ParentHomeworkItem>> groups = {};

    for (final item in activeItems) {
      groups.putIfAbsent(item.category, () => []).add(item);
    }

    final list = <SubjectGroupItem>[];

    groups.forEach((subject, items) {
      if (items.isEmpty) return;

      final doneCount =
          items.where((i) => i.status == ParentHomeworkStatus.done).length;
      final notCompleteCount = items
          .where((i) => i.status == ParentHomeworkStatus.notComplete)
          .length;
      final missingCount =
          items.where((i) => i.status == ParentHomeworkStatus.missing).length;
      final totalProgress = items.fold<double>(0, (sum, i) => sum + i.progress);
      final avgProgress = items.isNotEmpty ? totalProgress / items.length : 0.0;

      double sumEarnedScore = 0;
      double sumMaxScore = 0;
      int validCount = 0;

      for (final item in items) {
        if (item.score.contains('/')) {
          final parts = item.score.split('/');
          if (parts.length >= 2) {
            final earned = double.tryParse(parts[0].trim());
            final max = double.tryParse(parts[1].trim());
            if (earned != null && max != null && max > 0) {
              sumEarnedScore += earned;
              sumMaxScore += max;
              validCount++;
            }
          }
        } else if (item.status == ParentHomeworkStatus.missing) {
          sumEarnedScore += 0;
          sumMaxScore += 10;
          validCount++;
        }
      }

      String totalScoreStr = '0 / 100';
      if (validCount > 0 && sumMaxScore > 0) {
        final earnedStr = (sumEarnedScore % 1 == 0)
            ? sumEarnedScore.toInt().toString()
            : sumEarnedScore.toStringAsFixed(1);
        final maxStr = (sumMaxScore % 1 == 0)
            ? sumMaxScore.toInt().toString()
            : sumMaxScore.toStringAsFixed(1);

        totalScoreStr = '$earnedStr / $maxStr';
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
    selectedTabIndex.value = 0;
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

    // Month Filter
    if (selectedMonth.value != null) {
      result = result.where((item) {
        if (item.date == null) return true;
        return item.date!.month == selectedMonth.value;
      }).toList();
    }

    // Status Tab Filter
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

  int get subjectAllCount {
    if (selectedSubject.value == null) return 0;
    return _activeMonthHomeworkList
        .where((i) => i.category == selectedSubject.value)
        .length;
  }

  int get subjectDoneCount {
    if (selectedSubject.value == null) return 0;
    return _activeMonthHomeworkList
        .where((i) =>
            i.category == selectedSubject.value &&
            i.status == ParentHomeworkStatus.done)
        .length;
  }

  int get subjectNotCompleteCount {
    if (selectedSubject.value == null) return 0;
    return _activeMonthHomeworkList
        .where((i) =>
            i.category == selectedSubject.value &&
            i.status == ParentHomeworkStatus.notComplete)
        .length;
  }

  int get subjectMissingCount {
    if (selectedSubject.value == null) return 0;
    return _activeMonthHomeworkList
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

  int get totalAssignmentsCount => _activeMonthHomeworkList.length;

  int get totalDoneCount => _activeMonthHomeworkList
      .where((i) => i.status == ParentHomeworkStatus.done)
      .length;

  int get totalNotCompleteCount => _activeMonthHomeworkList
      .where((i) => i.status == ParentHomeworkStatus.notComplete)
      .length;

  int get totalMissingCount => _activeMonthHomeworkList
      .where((i) => i.status == ParentHomeworkStatus.missing)
      .length;

  double get overallCompletionRate {
    final list = _activeMonthHomeworkList;
    if (list.isEmpty) return 0.0;
    final sum = list.fold<double>(0, (acc, item) => acc + item.progress);
    return sum / list.length;
  }

  String _normalizeSubjectName(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('khmer') || s.contains('ភាសាខ្មែរ')) return 'Khmer';
    if (s.contains('math') || s.contains('គណិត')) return 'Math';
    if (s.contains('bio') || s.contains('ជីវ')) return 'Biology';
    if (s.contains('physic') || s.contains('រូប')) return 'Physical';
    if (s.contains('chem') || s.contains('គីមី')) return 'Chemical';
    if (s.contains('eng') || s.contains('អង់គ្លេស')) return 'English';
    if (s.contains('hist') || s.contains('ប្រវត្តិ')) return 'History';
    if (s.contains('geog') || s.contains('ភូមិ')) return 'Geography';
    return subject;
  }
}
