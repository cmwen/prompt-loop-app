import 'package:flutter/material.dart';

/// App color palette following Material 3 guidelines
class AppColors {
  AppColors._();

  // Primary Colors - Deep Purple (Focus & Growth)
  static const Color primarySeed = Color(0xFF6750A4);

  // Custom semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // Streak colors
  static const Color streakFire = Color(0xFFFF6B35);
  static const Color streakGold = Color(0xFFFFD700);

  // Progress colors
  static const Color progressBeginner = Color(0xFF90CAF9);
  static const Color progressIntermediate = Color(0xFF64B5F6);
  static const Color progressAdvanced = Color(0xFF42A5F5);
  static const Color progressExpert = Color(0xFF1E88E5);

  // Priority colors
  static const Color priorityHigh = Color(0xFFE53935);
  static const Color priorityMedium = Color(0xFFFF9800);
  static const Color priorityLow = Color(0xFF4CAF50);

  // Chart colors
  static const List<Color> chartPalette = [
    Color(0xFF6750A4),
    Color(0xFF03DAC6),
    Color(0xFFFF6B35),
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFFFF9800),
  ];

  // Difficulty gradient
  static Color getDifficultyColor(int difficulty) {
    if (difficulty <= 3) return const Color(0xFF4CAF50);
    if (difficulty <= 6) return const Color(0xFFFF9800);
    return const Color(0xFFE53935);
  }

  // Level color
  static Color getLevelColor(String level) {
    switch (level) {
      case 'beginner':
        return progressBeginner;
      case 'intermediate':
        return progressIntermediate;
      case 'advanced':
        return progressAdvanced;
      case 'expert':
        return progressExpert;
      default:
        return progressBeginner;
    }
  }
}
