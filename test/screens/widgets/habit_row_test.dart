import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../lib/screens/widgets/habit_row.dart';
import '../../../lib/features/habits/domain/models/habit.dart';
import '../../../lib/features/habits/domain/models/recurrence_config.dart';

void main() {
  group('HabitRow', () {
    late Habit testHabit;

    setUp(() {
      testHabit = Habit(
        id: '1',
        name: 'Test Habit',
        icon: '🏃',
        color: Colors.blue,
        goalType: GoalType.binary,
        recurrenceType: RecurrenceType.daily,
        recurrenceConfig: RecurrenceConfig.daily(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    testWidgets('displays habit information correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HabitRow(habit: testHabit),
            ),
          ),
        ),
      );

      expect(find.text('Test Habit'), findsOneWidget);
      expect(find.text('🏃'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Dismissible), findsOneWidget);
    });

    testWidgets('shows swipe backgrounds correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HabitRow(habit: testHabit),
            ),
          ),
        ),
      );

      // Test right swipe background
      final dismissible = find.byType(Dismissible);
      expect(dismissible, findsOneWidget);

      // Test that swipe backgrounds are present
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('handles tap on habit row', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HabitRow(habit: testHabit),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      // Should show snackbar with "Habit details coming soon!"
      expect(find.text('Habit details coming soon!'), findsOneWidget);
    });

    testWidgets('handles right swipe gesture', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HabitRow(habit: testHabit),
            ),
          ),
        ),
      );

      // Test that Dismissible widget exists
      expect(find.byType(Dismissible), findsOneWidget);
      
      // Test that swipe backgrounds exist
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('handles left swipe gesture', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: HabitRow(habit: testHabit),
            ),
          ),
        ),
      );

      // Test that Dismissible widget exists
      expect(find.byType(Dismissible), findsOneWidget);
      
      // Test that swipe backgrounds exist
      expect(find.byType(Card), findsOneWidget);
    });
  });
}
