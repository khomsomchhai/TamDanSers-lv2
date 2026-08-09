class ScoreModel {
  final int semester;
  final int month;
  final double score;
  final double totalScore;
  final double maxScore;
  final String subjectName;
  final String teacherName;
  final String rank;
  final String average;

  ScoreModel({
    required this.semester,
    required this.month,
    required this.score,
    required this.totalScore,
    required this.maxScore,
    required this.subjectName,
    required this.teacherName,
    required this.rank,
    required this.average,
  });

  factory ScoreModel.fromMap(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return ScoreModel(
        semester: 0,
        month: 0,
        score: 0.0,
        totalScore: 0.0,
        maxScore: 0.0,
        subjectName: '',
        teacherName: '',
        rank: '',
        average: '',
      );
    }

    double parseDouble(dynamic value) {
      if (value == null) {
        return 0.0;
      }

      if (value is num) {
        return value.toDouble();
      }

      return double.tryParse(value.toString()) ?? 0.0;
    }

    int parseInt(dynamic value) {
      if (value is int) {
        return value;
      }

      if (value is num) {
        return value.toInt();
      }

      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    Map<String, dynamic> asMap(dynamic value) {
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }

      return <String, dynamic>{};
    }

    // =====================================================
    // SUMMARY
    // =====================================================

    final Map<String, dynamic> summary = asMap(map['summary']);

    final Map<String, dynamic> rankMap = asMap(map['rank']);

    final Map<String, dynamic> yearlySummary = asMap(map['yearly_summary']);

    // =====================================================
    // IMPORTANT:
    // TOP LEVEL RESULT MAY NOT HAVE subject_name.
    //
    // API example:
    //
    // {
    //   "results": [
    //      {
    //        "subject_name": "Math"
    //      }
    //   ]
    // }
    // =====================================================

    Map<String, dynamic> subjectMap = {};

    final dynamic results = map['results'];

    if (results is List && results.isNotEmpty) {
      final dynamic first = results.first;

      if (first is Map) {
        subjectMap = Map<String, dynamic>.from(first);
      }
    }

    // Also support direct result maps.
    if (subjectMap.isEmpty) {
      subjectMap = map;
    }

    // =====================================================
    // SEMESTER RESULTS
    // =====================================================

    if (subjectMap.isEmpty) {
      final dynamic monthlyResults = map['monthly_results'];

      if (monthlyResults is List && monthlyResults.isNotEmpty) {
        final dynamic firstMonth = monthlyResults.first;

        if (firstMonth is Map) {
          final dynamic subjectResults = firstMonth['subject_results'];

          if (subjectResults is List &&
              subjectResults.isNotEmpty &&
              subjectResults.first is Map) {
            subjectMap = Map<String, dynamic>.from(
              subjectResults.first,
            );
          }
        }
      }
    }

    // =====================================================
    // SUBJECT NAME
    // =====================================================

    final String subjectName = subjectMap['subject_name']?.toString().trim() ??
        subjectMap['subjectName']?.toString().trim() ??
        map['subject_name']?.toString().trim() ??
        map['subjectName']?.toString().trim() ??
        '';

    // =====================================================
    // TEACHER NAME
    // =====================================================

    final String teacherName = subjectMap['teacher_name']?.toString().trim() ??
        subjectMap['teacherName']?.toString().trim() ??
        map['teacher_name']?.toString().trim() ??
        map['teacherName']?.toString().trim() ??
        '';

    // =====================================================
    // TOTAL SCORE
    // =====================================================

    final double totalScore = parseDouble(
      map['total_score'] ??
          map['totalScore'] ??
          summary['total_score'] ??
          summary['totalScore'] ??
          summary['semester_result'] ??
          yearlySummary['average'] ??
          rankMap['total_score'] ??
          rankMap['totalScore'],
    );

    // =====================================================
    // MAX SCORE
    // =====================================================

    final double maxScore = parseDouble(
      subjectMap['max_score'] ??
          subjectMap['maxScore'] ??
          map['max_score'] ??
          map['total_max'] ??
          summary['max_score'] ??
          summary['total_max'] ??
          rankMap['total_max'],
    );

    // =====================================================
    // INDIVIDUAL SCORE
    // =====================================================

    final double score = parseDouble(
      subjectMap['total_score'] ??
          subjectMap['totalScore'] ??
          map['score'] ??
          summary['score'],
    );

    // =====================================================
    // AVERAGE
    // =====================================================

    final double averageValue = parseDouble(
      map['average'] ??
          summary['average'] ??
          summary['semester_result'] ??
          summary['monthly_average'] ??
          yearlySummary['average'] ??
          rankMap['average'] ??
          map['gpa'],
    );

    final String average = averageValue == 0
        ? ''
        : averageValue == averageValue.roundToDouble()
            ? averageValue.toInt().toString()
            : averageValue.toStringAsFixed(1);

    // =====================================================
    // RANK
    // =====================================================

    final String rank =
        map['rank']?.toString() ?? rankMap['rank']?.toString() ?? '';

    // =====================================================
    // SEMESTER
    // =====================================================

    final int semester = parseInt(
      subjectMap['semester'] ?? map['semester'],
    );

    // =====================================================
    // MONTH
    // =====================================================

    final int month = parseInt(
      subjectMap['month'] ?? map['month'],
    );

    return ScoreModel(
      semester: semester,
      month: month,
      score: score,
      totalScore: totalScore,
      maxScore: maxScore,
      subjectName: subjectName,
      teacherName: teacherName,
      rank: rank,
      average: average,
    );
  }

  factory ScoreModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ScoreModel.fromMap(json);
  }

  @override
  String toString() {
    return 'ScoreModel('
        'semester: $semester, '
        'month: $month, '
        'score: $score, '
        'totalScore: $totalScore, '
        'maxScore: $maxScore, '
        'subjectName: "$subjectName", '
        'teacherName: "$teacherName", '
        'rank: "$rank", '
        'average: "$average"'
        ')';
  }
}
