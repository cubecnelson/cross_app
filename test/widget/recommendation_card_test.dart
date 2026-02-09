import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cross/features/workouts/widgets/recommendation_card.dart';
import 'package:cross/models/workout_recommendation.dart';
import 'package:cross/models/exercise.dart';

void main() {
  // Mock data
  final mockRecommendation = WorkoutRecommendation(
    id: 'test-rec-1',
    exerciseId: 'test-exercise-1',
    type: RecommendationType.progression,
    priority: RecommendationPriority.high,
    title: 'Test Recommendation',
    description: 'This is a test recommendation for unit testing.',
    createdAt: DateTime.now(),
  );

  final mockExercise = Exercise(
    id: 'test-exercise-1',
    name: 'Bench Press',
    category: 'Chest',
    exerciseType: ExerciseType.strength,
    description: 'Standard bench press',
    targetMuscles: const ['Chest', 'Triceps', 'Shoulders'],
    createdAt: DateTime.now(),
  );

  final mockRecommendationWithExercise = mockRecommendation.copyWith(
    exercise: mockExercise,
  );

  testWidgets('RecommendationCard renders correctly without exercise', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecommendationCard(
            recommendation: mockRecommendation,
          ),
        ),
      ),
    );

    // Verify title is displayed
    expect(find.text('Test Recommendation'), findsOneWidget);
    
    // Verify description is displayed
    expect(find.text('This is a test recommendation for unit testing.'), findsOneWidget);
    
    // Verify priority badge is shown (high priority)
    expect(find.text('HIGH'), findsOneWidget);
    
    // Verify card is present
    expect(find.byType(Card), findsOneWidget);
  });

  testWidgets('RecommendationCard renders correctly with exercise', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecommendationCard(
            recommendation: mockRecommendationWithExercise,
          ),
        ),
      ),
    );

    // Verify title is displayed
    expect(find.text('Test Recommendation'), findsOneWidget);
    
    // Verify exercise name might be shown somewhere
    expect(find.text('Bench Press'), findsOneWidget);
    
    // Verify card is present
    expect(find.byType(Card), findsOneWidget);
  });

  testWidgets('RecommendationCard calls onTap when tapped', (WidgetTester tester) async {
    bool wasTapped = false;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecommendationCard(
            recommendation: mockRecommendation,
            onTap: () {
              wasTapped = true;
            },
          ),
        ),
      ),
    );

    // Find and tap the card
    final card = find.byType(InkWell).first;
    await tester.tap(card);
    await tester.pump();

    // Verify callback was called
    expect(wasTapped, isTrue);
  });

  testWidgets('RecommendationCard shows different priority badges', (WidgetTester tester) async {
    // Test high priority
    final highPriorityRec = mockRecommendation.copyWith(
      priority: RecommendationPriority.high,
    );
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecommendationCard(
            recommendation: highPriorityRec,
          ),
        ),
      ),
    );
    
    expect(find.text('HIGH'), findsOneWidget);

    // Test medium priority
    final mediumPriorityRec = mockRecommendation.copyWith(
      priority: RecommendationPriority.medium,
    );
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecommendationCard(
            recommendation: mediumPriorityRec,
          ),
        ),
      ),
    );
    
    expect(find.text('MEDIUM'), findsOneWidget);

    // Test low priority
    final lowPriorityRec = mockRecommendation.copyWith(
      priority: RecommendationPriority.low,
    );
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecommendationCard(
            recommendation: lowPriorityRec,
          ),
        ),
      ),
    );
    
    expect(find.text('LOW'), findsOneWidget);
  });
}