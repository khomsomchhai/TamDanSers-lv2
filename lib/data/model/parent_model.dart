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
    final dynamic studentData = map['student'] ??
        map['student_info'] ??
        map['user'] ??
        map['profile'] ??
        map;

    Map<String, dynamic> rankMap = <String, dynamic>{};

    final dynamic rawRank = map['rank'] ?? map['score'] ?? map['summary'];

    if (rawRank is Map) {
      rankMap = Map<String, dynamic>.from(rawRank);
    } else if (rawRank != null) {
      rankMap = <String, dynamic>{'rank': rawRank.toString()};
    } else {
      rankMap = map;
    }

    return ParentDashboardModel(
      student: StudentModel.fromMap(
        studentData is Map<String, dynamic>
            ? studentData
            : studentData is Map
                ? Map<String, dynamic>.from(studentData)
                : <String, dynamic>{},
      ),
      rank: ScoreModel.fromMap(rankMap),
      homework: (map['homework'] as List? ?? <dynamic>[])
          .map((dynamic e) => HomeworkModel.fromJson(e))
          .toList(),
    );
  }
}
