class ScoreModel {
  final int id;

  final int semester;
  final int month;

  final double score;
  final double totalScore;
  final double maxScore;

  final String subjectName;
  final String teacherName;

  final String rank;
  final String average;

  const ScoreModel({
    this.id = 0,
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

  factory ScoreModel.fromMap(
    Map<String, dynamic> map,
  ) {
    // =====================================================
    // EMPTY
    // =====================================================

    if (map.isEmpty) {
      return const ScoreModel(
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

    // =====================================================
    // HELPERS
    // =====================================================

    double parseDouble(dynamic value) {
      if (value == null) {
        return 0.0;
      }

      if (value is num) {
        return value.toDouble();
      }

      return double.tryParse(
            value.toString(),
          ) ??
          0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) {
        return 0;
      }

      if (value is int) {
        return value;
      }

      if (value is num) {
        return value.toInt();
      }

      return int.tryParse(
            value.toString(),
          ) ??
          0;
    }

    Map<String, dynamic> asMap(dynamic value) {
      if (value is Map) {
        return Map<String, dynamic>.from(
          value,
        );
      }

      return <String, dynamic>{};
    }

    String formatNumber(double value) {
      if (value == value.roundToDouble()) {
        return value.toInt().toString();
      }

      return value.toStringAsFixed(2);
    }

    // =====================================================
    // NESTED MAPS
    // =====================================================

    final Map<String, dynamic> summary =
        asMap(
      map['summary'],
    );

    final Map<String, dynamic> rankMap =
        map['rank'] is Map
            ? asMap(map['rank'])
            : <String, dynamic>{};

    final Map<String, dynamic> yearlySummary =
        asMap(
      map['yearly_summary'],
    );

    // =====================================================
    // SUBJECT MAP
    // =====================================================

    Map<String, dynamic> subjectMap =
        <String, dynamic>{};

    final dynamic results = map['results'];

    if (results is List &&
        results.isNotEmpty &&
        results.first is Map) {
      subjectMap =
          Map<String, dynamic>.from(
        results.first,
      );
    }

    // Direct monthly score object.
    if (subjectMap.isEmpty &&
        (map['subject_name'] != null ||
            map['subjectName'] != null)) {
      subjectMap = map;
    }

    // =====================================================
    // SEMESTER MONTHLY RESULT SUBJECT
    // =====================================================

    if (subjectMap.isEmpty) {
      final dynamic monthlyResults =
          map['monthly_results'];

      if (monthlyResults is List &&
          monthlyResults.isNotEmpty) {
        final dynamic firstMonth =
            monthlyResults.first;

        if (firstMonth is Map) {
          final dynamic subjectResults =
              firstMonth['subject_results'];

          if (subjectResults is List &&
              subjectResults.isNotEmpty &&
              subjectResults.first is Map) {
            subjectMap =
                Map<String, dynamic>.from(
              subjectResults.first,
            );
          }
        }
      }
    }

    // =====================================================
    // SUBJECT NAME
    // =====================================================

    final String subjectName =
        subjectMap['subject_name']
                ?.toString()
                .trim() ??
            subjectMap['subjectName']
                ?.toString()
                .trim() ??
            map['subject_name']
                ?.toString()
                .trim() ??
            map['subjectName']
                ?.toString()
                .trim() ??
            '';

    // =====================================================
    // TEACHER NAME
    // =====================================================

    final String teacherName =
        subjectMap['teacher_name']
                ?.toString()
                .trim() ??
            subjectMap['teacherName']
                ?.toString()
                .trim() ??
            map['teacher_name']
                ?.toString()
                .trim() ??
            map['teacherName']
                ?.toString()
                .trim() ??
            '';

    final bool isSubjectModel =
        subjectName.isNotEmpty;

    // =====================================================
    // DETECT API TYPE
    //
    // Semester rank response:
    //
    // {
    //   "student_id": 2,
    //   "semester": 1,
    //   "rank": 3,
    //   "total_students": 6,
    //   "semester_result": 40.09,
    //   "monthly_average": 39.19,
    //   "exam_average": 41,
    //   "complete": true
    // }
    // =====================================================

    final bool isSemesterRank =
        map.containsKey('semester_result') &&
            map.containsKey('monthly_average') &&
            map.containsKey('rank');

    // =====================================================
    // SUBJECT SCORE
    // =====================================================

    final double subjectScore =
        parseDouble(
      subjectMap['total_score'] ??
          subjectMap['totalScore'] ??
          subjectMap['score'] ??
          map['total_score'] ??
          map['totalScore'] ??
          map['score'],
    );

    // =====================================================
    // TOTAL SCORE
    //
    // Semester rank:
    // semester_result => totalScore
    // =====================================================

    final double totalScore =
        parseDouble(
      map['semester_result'] ??
          summary['semester_result'] ??
          summary['total_score'] ??
          summary['totalScore'] ??
          rankMap['total_score'] ??
          rankMap['totalScore'] ??
          map['total_score'] ??
          map['totalScore'] ??
          yearlySummary['average'] ??
          (isSubjectModel
              ? subjectScore
              : 0),
    );

    // =====================================================
    // MAX SCORE
    //
    // Semester rank doesn't return max.
    // We use 100 for progress bar.
    // =====================================================

    double maxScore = parseDouble(
      subjectMap['max_score'] ??
          subjectMap['maxScore'] ??
          map['max_score'] ??
          map['maxScore'] ??
          map['total_max'] ??
          summary['max_score'] ??
          summary['total_max'] ??
          rankMap['total_max'],
    );

    if (isSemesterRank &&
        maxScore <= 0) {
      maxScore = 100;
    }

    // =====================================================
    // SCORE
    // =====================================================

    final double score =
        isSemesterRank
            ? parseDouble(
                map['semester_result'],
              )
            : isSubjectModel
                ? subjectScore
                : parseDouble(
                    map['score'] ??
                        summary['score'] ??
                        map['semester_result'],
                  );

    // =====================================================
    // AVERAGE
    //
    // IMPORTANT:
    // Semester rank uses monthly_average.
    // =====================================================

    final double averageValue =
        parseDouble(
      map['monthly_average'] ??
          map['average'] ??
          summary['average'] ??
          summary['monthly_average'] ??
          summary['semester_result'] ??
          yearlySummary['average'] ??
          rankMap['average'] ??
          map['gpa'],
    );

    final String average =
        averageValue == 0
            ? ''
            : formatNumber(
                averageValue,
              );

    // =====================================================
    // RANK
    // =====================================================

    dynamic parsedRank;

    // Normal semester rank API:
    //
    // "rank": 3
    //
    // Monthly / other API may return:
    //
    // "rank": {
    //    "rank": 3
    // }

    if (map['rank'] is Map) {
      parsedRank =
          map['rank']['rank'];
    } else if (map['rank'] != null) {
      parsedRank =
          map['rank'];
    }

    if (parsedRank == null &&
        rankMap['rank'] != null) {
      parsedRank =
          rankMap['rank'];
    }

    if (parsedRank == null &&
        summary['rank'] != null) {
      parsedRank =
          summary['rank'];
    }

    if (parsedRank == null &&
        summary['yearly_rank'] != null) {
      parsedRank =
          summary['yearly_rank'];
    }

    if (parsedRank == null &&
        yearlySummary['rank'] != null) {
      parsedRank =
          yearlySummary['rank'];
    }

    if (parsedRank == null &&
        yearlySummary['yearly_rank'] != null) {
      parsedRank =
          yearlySummary['yearly_rank'];
    }

    // =====================================================
    // SEMESTER RANK MAP
    // =====================================================

    if (parsedRank == null) {
      final dynamic semesterRank =
          map['semester_rank'];

      if (semesterRank is Map) {
        parsedRank =
            semesterRank['rank'];
      } else if (semesterRank != null) {
        parsedRank =
            semesterRank;
      }
    }

    // =====================================================
    // YEARLY RANK
    // =====================================================

    if (parsedRank == null) {
      final dynamic yearlyRank =
          map['yearly_rank'];

      if (yearlyRank is Map) {
        parsedRank =
            yearlyRank['rank'];
      } else if (yearlyRank != null) {
        parsedRank =
            yearlyRank;
      }
    }

    // Safety
    if (parsedRank is Map) {
      parsedRank =
          parsedRank['rank'];
    }

    final String rank =
        parsedRank != null &&
                parsedRank
                    .toString()
                    .trim()
                    .isNotEmpty &&
                parsedRank
                        .toString()
                        .trim() !=
                    'null'
            ? parsedRank
                .toString()
                .trim()
            : '';

    // =====================================================
    // SEMESTER
    // =====================================================

    final int semester =
        parseInt(
      subjectMap['semester'] ??
          map['semester'],
    );

    // =====================================================
    // MONTH
    // =====================================================

    final int month =
        parseInt(
      subjectMap['month'] ??
          map['month'],
    );

    // =====================================================
    // ID
    // =====================================================

    final int id =
        parseInt(
      map['id'] ??
          map['student_id'],
    );

    // =====================================================
    // DEBUG
    // =====================================================

    /*
    print(
      'ScoreModel => '
      'semester=$semester, '
      'month=$month, '
      'rank=$rank, '
      'totalScore=$totalScore, '
      'average=$average, '
      'maxScore=$maxScore',
    );
    */

    return ScoreModel(
      id: id,
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
    return ScoreModel.fromMap(
      json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'semester': semester,
      'month': month,
      'score': score,
      'totalScore': totalScore,
      'maxScore': maxScore,
      'subjectName': subjectName,
      'teacherName': teacherName,
      'rank': rank,
      'average': average,
    };
  }

  @override
  String toString() {
    return 'ScoreModel('
        'id: $id, '
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