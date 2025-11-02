import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/habits/presentation/controllers/check_in_controller.dart';

/// Compact week strip indicator (Mo-Su) for habit tracking
class WeekStripIndicator extends ConsumerWidget {
  final String habitId;
  
  const WeekStripIndicator({
    super.key,
    required this.habitId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(weekCompletionStatusProvider(habitId)).when(
      data: (weekStatus) => Row(
        mainAxisSize: MainAxisSize.min,
        children: _buildWeekDays(context, weekStatus),
      ),
      loading: () => Row(
        mainAxisSize: MainAxisSize.min,
        children: _buildWeekDays(context, List.filled(7, false)),
      ),
      error: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: _buildWeekDays(context, List.filled(7, false)),
      ),
    );
  }

  List<Widget> _buildWeekDays(BuildContext context, List<bool> weekStatus) {
    const weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    
    return weekDays.asMap().entries.map((entry) {
      final index = entry.key;
      final day = entry.value;
      final isCompleted = weekStatus[index];
      
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: isCompleted 
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCompleted 
                ? Theme.of(context).primaryColor
                : Colors.grey.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w500,
              color: isCompleted 
                  ? Colors.white
                  : Colors.grey[600],
            ),
          ),
        ),
      );
    }).toList();
  }
}
