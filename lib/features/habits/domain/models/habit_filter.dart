import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'habit.dart';

part 'habit_filter.freezed.dart';

/// Filter options for habits
@freezed
class HabitFilter with _$HabitFilter {
  const factory HabitFilter({
    @Default(HabitFilterType.all) HabitFilterType type,
    @Default(HabitSortType.dueDate) HabitSortType sortType,
    @Default(SortOrder.ascending) SortOrder sortOrder,
    Color? colorFilter,
    RecurrenceType? recurrenceFilter,
    GoalType? goalTypeFilter,
  }) = _HabitFilter;
}

/// Types of filters available for habits
enum HabitFilterType {
  all,
  due,
  completed,
  incomplete,
  byColor,
  byRecurrence,
  byGoalType,
}

/// Sort types for habits
enum HabitSortType {
  dueDate,
  priority,
  manual,
  name,
  createdAt,
  streak,
}

/// Sort order
enum SortOrder {
  ascending,
  descending,
}

/// Extension methods for habit filtering and sorting
extension HabitFilterExtension on List<Habit> {
  /// Apply filter to the list of habits
  List<Habit> applyFilter(HabitFilter filter) {
    var filtered = this;

    switch (filter.type) {
      case HabitFilterType.all:
        break;
      case HabitFilterType.due:
        // Filter habits that are due today (not completed)
        filtered = filtered.where((habit) {
          // TODO: Implement due date logic based on recurrence
          return true; // Placeholder
        }).toList();
        break;
      case HabitFilterType.completed:
        // Filter completed habits (would need progress service)
        filtered = filtered.where((habit) {
          // TODO: Check completion status via progress service
          return false; // Placeholder
        }).toList();
        break;
      case HabitFilterType.incomplete:
        // Filter incomplete habits
        filtered = filtered.where((habit) {
          // TODO: Check completion status via progress service
          return true; // Placeholder
        }).toList();
        break;
      case HabitFilterType.byColor:
        if (filter.colorFilter != null) {
          filtered = filtered.where((habit) => 
            habit.color.value == filter.colorFilter!.value).toList();
        }
        break;
      case HabitFilterType.byRecurrence:
        if (filter.recurrenceFilter != null) {
          filtered = filtered.where((habit) => 
            habit.recurrenceType == filter.recurrenceFilter).toList();
        }
        break;
      case HabitFilterType.byGoalType:
        if (filter.goalTypeFilter != null) {
          filtered = filtered.where((habit) => 
            habit.goalType == filter.goalTypeFilter).toList();
        }
        break;
    }

    return filtered;
  }

  /// Apply sorting to the list of habits
  List<Habit> applySort(HabitFilter filter) {
    var sorted = List<Habit>.from(this);

    switch (filter.sortType) {
      case HabitSortType.dueDate:
        // TODO: Implement due date sorting based on recurrence
        // For now, sort by creation date
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case HabitSortType.priority:
        // TODO: Implement priority sorting (would need priority field)
        // For now, sort by creation date
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case HabitSortType.manual:
        // Keep original order (no sorting)
        break;
      case HabitSortType.name:
        sorted.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case HabitSortType.createdAt:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case HabitSortType.streak:
        // TODO: Implement streak sorting (would need streak service)
        // For now, sort by creation date
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
    }

    // Apply sort order
    if (filter.sortOrder == SortOrder.descending) {
      sorted = sorted.reversed.toList();
    }

    return sorted;
  }
}
