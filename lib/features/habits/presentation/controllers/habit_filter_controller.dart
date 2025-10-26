import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/habit.dart';
import '../../domain/models/habit_filter.dart';
import 'habit_controller.dart';

part 'habit_filter_controller.g.dart';

/// Controller for managing habit filtering and sorting
@riverpod
class HabitFilterController extends _$HabitFilterController {
  @override
  HabitFilter build() {
    return const HabitFilter();
  }

  /// Update the current filter
  void updateFilter(HabitFilter filter) {
    state = filter;
  }

  /// Set filter type
  void setFilterType(HabitFilterType type) {
    state = state.copyWith(type: type);
  }

  /// Set sort type
  void setSortType(HabitSortType sortType) {
    state = state.copyWith(sortType: sortType);
  }

  /// Toggle sort order
  void toggleSortOrder() {
    final newOrder = state.sortOrder == SortOrder.ascending 
        ? SortOrder.descending 
        : SortOrder.ascending;
    state = state.copyWith(sortOrder: newOrder);
  }

  /// Set color filter
  void setColorFilter(Color? color) {
    state = state.copyWith(colorFilter: color);
  }

  /// Set recurrence filter
  void setRecurrenceFilter(RecurrenceType? recurrence) {
    state = state.copyWith(recurrenceFilter: recurrence);
  }

  /// Set goal type filter
  void setGoalTypeFilter(GoalType? goalType) {
    state = state.copyWith(goalTypeFilter: goalType);
  }

  /// Clear all filters
  void clearFilters() {
    state = const HabitFilter();
  }
}

/// Provider for filtered and sorted habits
@riverpod
Future<List<Habit>> filteredHabits(FilteredHabitsRef ref) async {
  final habitsAsync = ref.watch(habitControllerProvider);
  final filter = ref.watch(habitFilterControllerProvider);

  return habitsAsync.when(
    data: (habits) {
      final filtered = habits.applyFilter(filter);
      return filtered.applySort(filter);
    },
    loading: () => <Habit>[],
    error: (_, __) => <Habit>[],
  );
}

/// Provider for getting filter options
@riverpod
FilterOptions filterOptions(FilterOptionsRef ref) {
  return const FilterOptions();
}

/// Available filter options
class FilterOptions {
  const FilterOptions();

  List<HabitFilterType> get filterTypes => HabitFilterType.values;
  List<HabitSortType> get sortTypes => HabitSortType.values;
  List<SortOrder> get sortOrders => SortOrder.values;
  
  List<Color> get availableColors => const [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.cyan,
  ];

  List<RecurrenceType> get recurrenceTypes => RecurrenceType.values;
  List<GoalType> get goalTypes => GoalType.values;
}
