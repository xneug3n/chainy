import 'package:flutter/material.dart';

/// Compact week strip indicator (Mo-Su) for habit tracking
class WeekStripIndicator extends StatelessWidget {
  final String habitId;
  
  const WeekStripIndicator({
    super.key,
    required this.habitId,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _buildWeekDays(context),
    );
  }

  List<Widget> _buildWeekDays(BuildContext context) {
    const weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    
    return weekDays.asMap().entries.map((entry) {
      final index = entry.key;
      final day = entry.value;
      final isCompleted = _isDayCompleted(index); // TODO: Get from check-ins
      
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

  bool _isDayCompleted(int dayIndex) {
    // TODO: Implement logic to check if habit was completed on this day
    // This should check against check-ins for the current week
    return false;
  }
}
