class ScoreModel {
  final int semester;
  final int month;
  final double score;
  final double totalScore;
  final double maxScore;
  final String subjectName;
  final String teacherName;
  final String rank;
  final String average ;

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
    return ScoreModel(
      semester: map['semester'] ?? 0,
      month: map['month'] ?? 0,
      score: (map['score'] ?? map['average'] ?? 0).toDouble(),
      totalScore: (map['total_score'] ?? 0).toDouble(),
      maxScore: (map['max_score'] ?? map['total_max'] ?? 0).toDouble(),
      subjectName: map['subject_name'] ?? '',
      teacherName: map['teacher_name'] ?? '',
      rank: map['rank']?.toString() ?? '',
      average: map['average']?.toString() ?? '',
    );
  }
}