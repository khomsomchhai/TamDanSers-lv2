import 'package:flutter/material.dart';

class ScoreBar extends StatelessWidget {
  final double score;
  final double maxScore;
  final Color color;

  const ScoreBar({
    super.key,
    required this.score,
    this.maxScore = 100,
    this.color = const Color(0xFFF4C27A),
  });

  @override
  Widget build(BuildContext context) {
    final double percentage =
        maxScore <= 0 ? 0 : (score / maxScore).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "${score.toStringAsFixed(0)} / ${maxScore.toStringAsFixed(0)}",
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 8),

        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 14,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}