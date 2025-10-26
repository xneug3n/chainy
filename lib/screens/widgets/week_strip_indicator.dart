import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/habits/domain/services/progress_service.dart';

/// Compact week strip indicator (Mo-Su) for habit tracking
class WeekStripIndicator extends ConsumerWidget {
  final String habitId;
  
  const WeekStripIndicator({
    super.key,
    required this.habitId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<bool>>(
      future: _getWeekCompletionStatus(ref),
      builder: (context, snapshot) {
        final weekStatus = snapshot.data ?? List.filled(7, false);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: _buildWeekDays(context, weekStatus),
        );
      },
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
                : Colors.grey.withOpacity(0.3),
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

  Future<List<bool>> _getWeekCompletionStatus(WidgetRef ref) async {
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    return await ref.read(progressServiceProvider.notifier)
        .getWeekCompletionStatus(habitId, weekStart);
  }
}
