import 'package:flutter/material.dart';
import 'package:chainy/features/habits/presentation/screens/habit_form_bottom_sheet.dart';

/// Row widget for adding a new habit
class AddNewHabitRow extends StatelessWidget {
  const AddNewHabitRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            Icons.add,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          'Add New Habit',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: const Text('Start building a new habit'),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).primaryColor,
        ),
        onTap: () => _showAddHabitDialog(context),
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    showHabitFormBottomSheet(context);
  }
}
