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
  final double average;

  final int totalStudents;

  final double finalAverage;
  final double semester1Result;
  final double semester2Result;

  final bool complete;

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

    this.totalStudents = 0,

    this.finalAverage = 0,
    this.semester1Result = 0,
    this.semester2Result = 0,

    this.complete = false,
  });

  factory ScoreModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return ScoreModel(
      id: _toInt(
        map['id'],
      ),

      semester: _toInt(
        map['semester'],
      ),

      month: _toInt(
        map['month'],
      ),

      score: _toDouble(
        map['score'] ??
            map['average'],
      ),

      totalScore: _toDouble(
        map['total_score'],
      ),

      maxScore: _toDouble(
        map['max_score'] ??
            map['total_max'],
      ),

      subjectName:
          map['subject_name']
                  ?.toString() ??
              '',

      teacherName:
          map['teacher_name']
                  ?.toString() ??
              '',

      rank:
          map['rank']
                  ?.toString() ??
              '',

      average: _toDouble(
        map['average'],
      ),

      totalStudents: _toInt(
        map['total_students'],
      ),

      finalAverage: _toDouble(
        map['final_average'],
      ),

      semester1Result: _toDouble(
        map['semester_1_result'],
      ),

      semester2Result: _toDouble(
        map['semester_2_result'],
      ),

      complete:
          map['complete'] == true,
    );
  }

  // =========================================================
  // SAFE DOUBLE
  // =========================================================

  static double _toDouble(
    dynamic value,
  ) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }

  // =========================================================
  // SAFE INT
  // =========================================================

  static int _toInt(
    dynamic value,
  ) {
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
}