import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/habit_list_view.dart';
import '../features/habits/presentation/screens/habit_form_bottom_sheet.dart';

/// Home screen with habit tracking overview
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chainy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showHabitFormBottomSheet(context);
            },
          ),
        ],
      ),
      body: const HabitListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHabitDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    showHabitFormBottomSheet(context);
  }
}

