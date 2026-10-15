import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_screen/stopwatch_card.dart';
import 'package:reactive_screen/tap_card.dart';
import 'package:reactive_screen/two_way_counter.dart';

void main() {
  testWidgets('tap card increments and supports cancel and reset', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: TapCard())));

    await tester.tap(find.text('Tap this card'));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    await tester.longPress(find.text('Tap this card'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);

    await tester.longPress(find.text('Tap this card'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('counter disables decrement at zero and saves once', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TwoWayCounter())),
    );

    final decrement = find.widgetWithText(OutlinedButton, '−');
    expect(tester.widget<OutlinedButton>(decrement).onPressed, isNull);

    await tester.tap(find.widgetWithText(FilledButton, '+'));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    expect(tester.widget<OutlinedButton>(decrement).onPressed, isNotNull);

    await tester.tap(decrement);
    await tester.pump();
    expect(tester.widget<OutlinedButton>(decrement).onPressed, isNull);

    final save = find.widgetWithText(FilledButton, 'Save');
    await tester.tap(save);
    await tester.pump();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton).last).onPressed,
      isNull,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Saved'), findsOneWidget);
  });

  testWidgets('stopwatch formats time, stops, resets, and cancels on dispose', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: StopwatchCard())),
    );

    await tester.tap(find.widgetWithText(OutlinedButton, 'Start'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('00:02'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Stop'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('00:02'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Reset'));
    await tester.pump();
    expect(find.text('00:00'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Start'));
    await tester.pump();
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pump(const Duration(seconds: 2));
  });
}
