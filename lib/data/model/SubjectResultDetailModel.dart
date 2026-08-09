import 'package:flutter/material.dart';
import 'package:tamdansers_lv2/core/widgets/subject_ui.dart';

class SubjectResultDetailModel {
  final int subjectId;
  final String subjectName;
  final double score;
  final double maxScore;

  const SubjectResultDetailModel({
    required this.subjectId,
    required this.subjectName,
    required this.score,
    required this.maxScore,
  });

  double get percentage {
    if (maxScore <= 0) {
      return 0.0;
    }

    return (score / maxScore).clamp(0.0, 1.0);
  }

  double get percentageValue {
    return percentage * 100;
  }

  IconData get icon {
    return SubjectUi.icon(subjectName);
  }

  Color get color {
    return SubjectUi.color(subjectName);
  }
}
