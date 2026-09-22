import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_class_04/main.dart';

void main() {
  testWidgets('records reps and toggles theme', (tester) async {
    await tester.pumpWidget(const WorkoutChallengeApp());
    expect(find.text('0'), findsNWidgets(2));
    await tester.tap(find.byKey(const Key('squat-button')));
    await tester.pump();
    expect(find.text('5'), findsOneWidget);
    expect(find.text('SQUATS COMPLETE'), findsOneWidget);
    await tester.tap(find.byKey(const Key('theme-toggle')));
    await tester.pump();
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
  });

  testWidgets('slider is present and interactive', (tester) async {
    await tester.pumpWidget(const WorkoutChallengeApp());
    expect(find.byKey(const Key('intensity-slider')), findsOneWidget);
    await tester.tap(find.byKey(const Key('intensity-slider')));
    await tester.pump();
    expect(find.textContaining('%'), findsWidgets);
  });
}
