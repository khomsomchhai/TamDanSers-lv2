import 'package:flutter/material.dart';

class SubjectUi {
  SubjectUi._();

  static IconData icon(String subject) {
    switch (subject) {
      case 'Khmer':
        return Icons.translate;
      case 'Math':
        return Icons.calculate;
      case 'English':
        return Icons.menu_book;
      case 'Biology':
        return Icons.science;
      case 'Physical':
        return Icons.bolt;
      case 'Chemical':
        return Icons.biotech;
      case 'Social':
        return Icons.public;
      case 'History':
        return Icons.account_balance;
      case 'Earth Science':
        return Icons.language;
      case 'Geography':
        return Icons.map;
      case 'Earth':
        return Icons.public;
      default:
        return Icons.book;
    }
  }

  static Color color(String subject) {
    switch (subject) {
      case 'Khmer':
        return const Color.fromARGB(255, 87, 8, 223);
      case 'Math':
        return const Color(0xFF16A34A);
      case 'English':
        return const Color(0xFFEAB308);
      case 'Biology':
        return const Color(0xFF10B981);
      case 'Physical':
        return const Color(0xFF2563EB);
      case 'Chemical':
        return const Color(0xFFF97316);
      case 'Social':
        return const Color(0xFFEC4899);
      case 'History':
        return const Color(0xFFD97706);
      case 'Earth Science':
        return const Color(0xFF06B6D4);
      case 'Geography':
        return const Color(0xFF14B8A6);
      case 'Earth':
        return const Color(0xFF06B6D4);
      default:
        return Colors.grey;
    }
  }

  static Color bgColor(String subject) {
    switch (subject) {
      case 'Khmer':
        return const Color(0xFFF3E8FF);
      case 'Math':
        return const Color(0xFFDCFCE7);
      case 'English':
        return const Color(0xFFFEF9C3);
      case 'Biology':
        return const Color(0xFFD1FAE5);
      case 'Physical':
        return const Color(0xFFDBEAFE);
      case 'Chemical':
        return const Color(0xFFFFEDD5);
      case 'Social':
        return const Color(0xFFFCE7F3);
      case 'History':
        return const Color(0xFFFEF3C7);
      case 'Earth Science':
        return const Color(0xFFCFFAFE);
      case 'Geography':
        return const Color(0xFFCCFBF1);
      case 'Earth':
        return const Color(0xFFCFFAFE);
      default:
        return const Color(0xFFF3F4F6);
    }
  }
}