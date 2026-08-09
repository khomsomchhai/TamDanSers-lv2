import 'package:tamdansers_lv2/data/model/score_model.dart';
import 'package:tamdansers_lv2/data/model/student_model.dart';
import 'package:tamdansers_lv2/data/model/homework_model.dart';

class ParentDashboardModel {
  final StudentModel student;
  final ScoreModel rank;
  final List<HomeworkModel> homework;

  ParentDashboardModel({
    required this.student,
    required this.rank,
    required this.homework,
  });

  factory ParentDashboardModel.fromMap(Map<String, dynamic> map) {
    final studentData = map['student'] ??
        map['student_info'] ??
        map['user'] ??
        map['profile'] ??
        map;
    final rankData = map['rank'] ?? map['score'] ?? {};

    return ParentDashboardModel(
      student: StudentModel.fromMap(
        studentData is Map<String, dynamic>
            ? studentData
            : Map<String, dynamic>.from(studentData as Map? ?? {}),
      ),
      rank: ScoreModel.fromMap(
        rankData is Map<String, dynamic>
            ? rankData
            : Map<String, dynamic>.from(rankData as Map? ?? {}),
      ),
      homework: (map['homework'] as List? ?? [])
          .map((e) => HomeworkModel.fromJson(e))
          .toList(),
    );
  }
}
