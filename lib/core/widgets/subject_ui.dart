import 'package:flutter/material.dart';

class SubjectUi {
  SubjectUi._();

  static String _normalize(String subject) => subject.trim().toLowerCase();

  static IconData icon(String subject) {
    final s = _normalize(subject);
    if (s.contains('khmer') || s.contains('ខ្មែរ')) return Icons.translate_rounded;
    if (s.contains('math') || s.contains('គណិត')) return Icons.calculate_rounded;
    if (s.contains('eng') || s.contains('អង់គ្លេស')) return Icons.menu_book_rounded;
    if (s.contains('bio') || s.contains('ជីវ')) return Icons.science_rounded;
    if (s.contains('physic') || s.contains('រូប')) return Icons.bolt_rounded;
    if (s.contains('chem') || s.contains('គីមី')) return Icons.biotech_rounded;
    if (s.contains('social') || s.contains('សង្គម')) return Icons.public_rounded;
    if (s.contains('hist') || s.contains('ប្រវត្តិ')) return Icons.account_balance_rounded;
    if (s.contains('earth') || s.contains('ផែនដី')) return Icons.language_rounded;
    if (s.contains('geog') || s.contains('ភូមិ')) return Icons.map_rounded;
    if (s.contains('civic') || s.contains('ពលរដ្ឋ')) return Icons.gavel_rounded;
    if (s.contains('ict') || s.contains('computer') || s.contains('ព័ត៌មាន')) {
      return Icons.computer_rounded;
    }
    return Icons.auto_stories_rounded;
  }

  static Color color(String subject) {
    final s = _normalize(subject);
    if (s.contains('khmer') || s.contains('ខ្មែរ')) return const Color(0xFF6D28D9);
    if (s.contains('math') || s.contains('គណិត')) return const Color(0xFF16A34A);
    if (s.contains('eng') || s.contains('អង់គ្លេស')) return const Color(0xFFD97706);
    if (s.contains('bio') || s.contains('ជីវ')) return const Color(0xFF059669);
    if (s.contains('physic') || s.contains('រូប')) return const Color(0xFF2563EB);
    if (s.contains('chem') || s.contains('គីមី')) return const Color(0xFFEA580C);
    if (s.contains('social') || s.contains('សង្គម')) return const Color(0xFFDB2777);
    if (s.contains('hist') || s.contains('ប្រវត្តិ')) return const Color(0xFFB45309);
    if (s.contains('earth') || s.contains('ផែនដី')) return const Color(0xFF0891B2);
    if (s.contains('geog') || s.contains('ភូមិ')) return const Color(0xFF0D9488);
    if (s.contains('civic') || s.contains('ពលរដ្ឋ')) return const Color(0xFF4F46E5);
    if (s.contains('ict') || s.contains('computer') || s.contains('ព័ត៌មាន')) {
      return const Color(0xFF0284C7);
    }
    return const Color(0xFF4B5563);
  }

  static Color bgColor(String subject) {
    final s = _normalize(subject);
    if (s.contains('khmer') || s.contains('ខ្មែរ')) return const Color(0xFFF3E8FF);
    if (s.contains('math') || s.contains('គណិត')) return const Color(0xFFDCFCE7);
    if (s.contains('eng') || s.contains('អង់គ្លេស')) return const Color(0xFFFEF9C3);
    if (s.contains('bio') || s.contains('ជីវ')) return const Color(0xFFD1FAE5);
    if (s.contains('physic') || s.contains('រូប')) return const Color(0xFFDBEAFE);
    if (s.contains('chem') || s.contains('គីមី')) return const Color(0xFFFFEDD5);
    if (s.contains('social') || s.contains('សង្គម')) return const Color(0xFFFCE7F3);
    if (s.contains('hist') || s.contains('ប្រវត្តិ')) return const Color(0xFFFEF3C7);
    if (s.contains('earth') || s.contains('ផែនដី')) return const Color(0xFFCFFAFE);
    if (s.contains('geog') || s.contains('ភូមិ')) return const Color(0xFFCCFBF1);
    if (s.contains('civic') || s.contains('ពលរដ្ឋ')) return const Color(0xFFE0E7FF);
    if (s.contains('ict') || s.contains('computer') || s.contains('ព័ត៌មាន')) {
      return const Color(0xFFE0F2FE);
    }
    return const Color(0xFFF3F4F6);
  }
}