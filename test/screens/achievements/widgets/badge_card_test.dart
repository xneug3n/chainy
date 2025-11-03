import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chainy/screens/achievements/widgets/badge_card.dart';
import 'package:chainy/screens/achievements/models/achievement_interface.dart';

void main() {
  group('BadgeCard', () {
    final testAchievement = Achievement(
      id: 'test-1',
      title: 'Test Achievement',
      description: 'Test description',
      icon: Icons.star,
      category: AchievementCategory.firstSteps,
      targetValue: 1,
    );

    testWidgets('renders unlocked badge correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: BadgeCard(
              achievement: testAchievement,
              isUnlocked: true,
              progress: 1.0,
            ),
          ),
        ),
      );

      expect(find.text('Test Achievement'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byType(BadgeCard), findsOneWidget);
    });

    testWidgets('renders locked badge correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: BadgeCard(
              achievement: testAchievement,
              isUnlocked: false,
              progress: 0.0,
            ),
          ),
        ),
      );

      expect(find.text('Test Achievement'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('shows progress indicator for locked badge with progress',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: BadgeCard(
              achievement: testAchievement,
              isUnlocked: false,
              progress: 0.5,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('opens badge details sheet on tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: BadgeCard(
              achievement: testAchievement,
              isUnlocked: true,
              progress: 1.0,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(BadgeCard));
      await tester.pumpAndSettle();

      // Badge details sheet should be visible
      expect(find.text('Test Achievement'), findsWidgets);
      expect(find.text('Test description'), findsOneWidget);
    });
  });
}

