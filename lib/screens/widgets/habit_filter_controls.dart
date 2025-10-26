import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/habits/domain/models/habit_filter.dart';
import '../../features/habits/domain/models/habit.dart';
import '../../features/habits/presentation/controllers/habit_filter_controller.dart';

/// Widget for displaying filter and sort controls
class HabitFilterControls extends ConsumerWidget {
  const HabitFilterControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(habitFilterControllerProvider);
    final filterOptions = ref.watch(filterOptionsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Filter dropdown
          Expanded(
            flex: 2,
            child: _FilterDropdown(
              value: filter.type,
              onChanged: (type) => ref
                  .read(habitFilterControllerProvider.notifier)
                  .setFilterType(type),
              options: filterOptions.filterTypes,
            ),
          ),
          const SizedBox(width: 4),
          
          // Sort dropdown
          Expanded(
            flex: 2,
            child: _SortDropdown(
              value: filter.sortType,
              onChanged: (sortType) => ref
                  .read(habitFilterControllerProvider.notifier)
                  .setSortType(sortType),
              options: filterOptions.sortTypes,
            ),
          ),
          const SizedBox(width: 4),
          
          // Sort order toggle
          SizedBox(
            width: 40,
            child: IconButton(
              onPressed: () => ref
                  .read(habitFilterControllerProvider.notifier)
                  .toggleSortOrder(),
              icon: Icon(
                filter.sortOrder == SortOrder.ascending
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                size: 20,
              ),
              tooltip: 'Sort ${filter.sortOrder == SortOrder.ascending ? 'Ascending' : 'Descending'}',
              padding: EdgeInsets.zero,
            ),
          ),
          
          // Clear filters button
          if (filter.type != HabitFilterType.all)
            SizedBox(
              width: 40,
              child: IconButton(
                onPressed: () => ref
                    .read(habitFilterControllerProvider.notifier)
                    .clearFilters(),
                icon: const Icon(Icons.clear, size: 20),
                tooltip: 'Clear Filters',
                padding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
    );
  }
}

/// Dropdown widget for filter selection
class _FilterDropdown extends StatelessWidget {
  final HabitFilterType value;
  final ValueChanged<HabitFilterType> onChanged;
  final List<HabitFilterType> options;

  const _FilterDropdown({
    required this.value,
    required this.onChanged,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<HabitFilterType?>(
      value: value,
      onChanged: (type) => onChanged(type ?? HabitFilterType.all),
      decoration: const InputDecoration(
        labelText: 'Filter',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        isDense: true,
        labelStyle: TextStyle(fontSize: 12),
      ),
      style: const TextStyle(fontSize: 12),
      items: options.map((type) {
        return DropdownMenuItem<HabitFilterType?>(
          value: type,
          child: Text(
            _getFilterDisplayName(type),
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }

  String _getFilterDisplayName(HabitFilterType type) {
    switch (type) {
      case HabitFilterType.all:
        return 'All';
      case HabitFilterType.due:
        return 'Due';
      case HabitFilterType.completed:
        return 'Done';
      case HabitFilterType.incomplete:
        return 'Pending';
      case HabitFilterType.byColor:
        return 'Color';
      case HabitFilterType.byRecurrence:
        return 'Type';
      case HabitFilterType.byGoalType:
        return 'Goal';
    }
  }
}

/// Dropdown widget for sort selection
class _SortDropdown extends StatelessWidget {
  final HabitSortType value;
  final ValueChanged<HabitSortType> onChanged;
  final List<HabitSortType> options;

  const _SortDropdown({
    required this.value,
    required this.onChanged,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<HabitSortType?>(
      value: value,
      onChanged: (type) => onChanged(type ?? HabitSortType.dueDate),
      decoration: const InputDecoration(
        labelText: 'Sort',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        isDense: true,
        labelStyle: TextStyle(fontSize: 12),
      ),
      style: const TextStyle(fontSize: 12),
      items: options.map((type) {
        return DropdownMenuItem<HabitSortType?>(
          value: type,
          child: Text(
            _getSortDisplayName(type),
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }

  String _getSortDisplayName(HabitSortType type) {
    switch (type) {
      case HabitSortType.dueDate:
        return 'Due';
      case HabitSortType.priority:
        return 'Priority';
      case HabitSortType.manual:
        return 'Manual';
      case HabitSortType.name:
        return 'Name';
      case HabitSortType.createdAt:
        return 'Created';
      case HabitSortType.streak:
        return 'Streak';
    }
  }
}

/// Advanced filter panel (can be expanded later)
class AdvancedFilterPanel extends ConsumerWidget {
  const AdvancedFilterPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(habitFilterControllerProvider);
    final filterOptions = ref.watch(filterOptionsProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advanced Filters',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // Color filter
            Wrap(
              spacing: 8,
              children: filterOptions.availableColors.map((color) {
                final isSelected = filter.colorFilter?.value == color.value;
                return GestureDetector(
                  onTap: () {
                    ref
                        .read(habitFilterControllerProvider.notifier)
                        .setColorFilter(isSelected ? null : color);
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // Recurrence filter
            DropdownButtonFormField<RecurrenceType?>(
              value: filter.recurrenceFilter,
              onChanged: (value) => ref
                  .read(habitFilterControllerProvider.notifier)
                  .setRecurrenceFilter(value),
              decoration: const InputDecoration(
                labelText: 'Recurrence',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<RecurrenceType?>(
                  value: null,
                  child: Text('All Recurrences'),
                ),
                ...filterOptions.recurrenceTypes.map((type) {
                  return DropdownMenuItem<RecurrenceType?>(
                    value: type,
                    child: Text(_getRecurrenceDisplayName(type)),
                  );
                }),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Goal type filter
            DropdownButtonFormField<GoalType?>(
              value: filter.goalTypeFilter,
              onChanged: (value) => ref
                  .read(habitFilterControllerProvider.notifier)
                  .setGoalTypeFilter(value),
              decoration: const InputDecoration(
                labelText: 'Goal Type',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<GoalType?>(
                  value: null,
                  child: Text('All Goal Types'),
                ),
                ...filterOptions.goalTypes.map((type) {
                  return DropdownMenuItem<GoalType?>(
                    value: type,
                    child: Text(_getGoalTypeDisplayName(type)),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getRecurrenceDisplayName(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.multiplePerDay:
        return 'Multiple Per Day';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.custom:
        return 'Custom';
    }
  }

  String _getGoalTypeDisplayName(GoalType type) {
    switch (type) {
      case GoalType.binary:
        return 'Binary (Yes/No)';
      case GoalType.quantitative:
        return 'Quantitative';
    }
  }
}
