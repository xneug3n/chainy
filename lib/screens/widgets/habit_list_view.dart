import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/habits/presentation/controllers/habit_controller.dart';
import 'habit_row.dart';
import 'add_new_habit_row.dart';

/// ListView widget for displaying habits
class HabitListView extends ConsumerWidget {
  const HabitListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitControllerProvider);

    return habitsAsync.when(
      data: (habits) {
        if (habits.isEmpty) {
          return const _EmptyHabitsView();
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: habits.length + 1, // +1 for Add New row
          itemBuilder: (context, index) {
            if (index == habits.length) {
              return const AddNewHabitRow();
            }
            return HabitRow(habit: habits[index]);
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading habits',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(habitControllerProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state view when no habits exist
class _EmptyHabitsView extends StatelessWidget {
  const _EmptyHabitsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.psychology,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome to Chainy',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start building your habits today',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to add habit screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add habit functionality coming soon!')),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Habit'),
          ),
        ],
      ),
    );
  }
}
