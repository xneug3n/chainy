import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chainy/screens/widgets/habit_list_view.dart';

void main() {
  group('HabitListView', () {
    testWidgets('renders without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(
            home: Scaffold(body: HabitListView()),
          ),
        ),
      );

      // Should render without crashing
      expect(find.byType(HabitListView), findsOneWidget);
    });
  });
}
