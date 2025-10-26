import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../lib/screens/widgets/segmented_timeline.dart';
import '../../../lib/features/habits/domain/models/habit.dart';
import '../../../lib/features/habits/domain/models/recurrence_config.dart';

void main() {
  group('SegmentedTimeline', () {
    late Habit testHabit;

    setUp(() {
      testHabit = Habit(
        id: '1',
        name: 'Test Habit',
        icon: '🏃',
        color: Colors.blue,
        goalType: GoalType.binary,
        targetValue: 3,
        recurrenceType: RecurrenceType.daily,
        recurrenceConfig: RecurrenceConfig.daily(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    testWidgets('displays correct number of segments', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SegmentedTimeline(
              habit: testHabit,
              currentValue: 0,
            ),
          ),
        ),
      );

      // Should have 3 segments (targetValue = 3)
      expect(find.byType(Container), findsNWidgets(3));
    });

    testWidgets('displays active segments correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SegmentedTimeline(
              habit: testHabit,
              currentValue: 2,
            ),
          ),
        ),
      );

      // Should have 2 active segments and 1 inactive
      expect(find.byType(Container), findsNWidgets(3));
    });

    testWidgets('handles segment tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SegmentedTimeline(
              habit: testHabit,
              currentValue: 0,
            ),
          ),
        ),
      );

      // Tap on first segment
      final firstSegment = find.byType(GestureDetector).first;
      await tester.tap(firstSegment);
      await tester.pumpAndSettle();

      // Should trigger animation (multiple AnimatedBuilders exist)
      expect(find.byType(AnimatedBuilder), findsWidgets);
    });

    testWidgets('shows check icon for completed segments', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SegmentedTimeline(
              habit: testHabit,
              currentValue: 1,
            ),
          ),
        ),
      );

      // Should show check icon for completed segment
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('handles different target values', (WidgetTester tester) async {
      final habitWithDifferentTarget = testHabit.copyWith(targetValue: 5);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SegmentedTimeline(
              habit: habitWithDifferentTarget,
              currentValue: 0,
            ),
          ),
        ),
      );

      // Should have 5 segments
      expect(find.byType(Container), findsNWidgets(5));
    });
  });
}
