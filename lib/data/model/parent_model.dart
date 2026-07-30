import 'package:tamdansers_lv2/data/model/student_model.dart';
import 'package:tamdansers_lv2/data/model/score_model.dart';
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
    return ParentDashboardModel(
      student: StudentModel.fromMap(map['student']),
      rank: ScoreModel.fromMap(map['rank']),
      homework: (map['homework'] as List? ?? [])
          .map((e) => HomeworkModel.fromJson(e))
          .toList(),
    );
  }
}