import 'package:flutter/material.dart';

class SkeletonTheme extends ThemeExtension<SkeletonTheme> {
  final Color baseColor;
  final Color highlightColor;

  const SkeletonTheme({
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  SkeletonTheme copyWith({
    Color? baseColor,
    Color? highlightColor,
  }) {
    return SkeletonTheme(
      baseColor: baseColor ?? this.baseColor,
      highlightColor: highlightColor ?? this.highlightColor,
    );
  }

  @override
  SkeletonTheme lerp(SkeletonTheme? other, double t) {
    if (other is! SkeletonTheme) {
      return this;
    }
    return SkeletonTheme(
      baseColor: Color.lerp(baseColor, other.baseColor, t) ?? baseColor,
      highlightColor:
          Color.lerp(highlightColor, other.highlightColor, t) ?? highlightColor,
    );
  }
}
