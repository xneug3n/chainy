import 'package:flutter/material.dart';

/// Achievement category enum matching PRD specifications
enum AchievementCategory {
  firstSteps,
  streakMilestones,
  habitManagement,
  checkInMilestones,
  perfection,
  consistency,
}

/// Minimal Achievement interface for BadgeCard widget
/// Full implementation will be provided in task 7.3 (AchievementProvider)
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final AchievementCategory category;
  final int targetValue;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.targetValue,
  });
}

