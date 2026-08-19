/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## telemetry_widget_menu_test.dart - Widget tests for showTelemetryWidgetMenu.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/telemetry/telemetry_widget_menu.dart';

import '../../helpers/test_app.dart';

void main() {
  group('showTelemetryWidgetMenu', () {
    testWidgets('shows the widget label and reset/remove actions', (
      WidgetTester tester,
    ) async {
      var resetCalled = false;
      var removeCalled = false;

      await pumpTestApp(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showTelemetryWidgetMenu(
                context,
                widgetLabel: 'Speed',
                onReset: () => resetCalled = true,
                onRemove: () => removeCalled = true,
              ),
              child: const Text('Open menu'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open menu'));
      await tester.pumpAndSettle();

      expect(find.text('Speed'), findsOneWidget);
      expect(find.text('Reset size'), findsOneWidget);
      expect(find.text('Remove widget'), findsOneWidget);

      await tester.tap(find.text('Reset size'));
      await tester.pumpAndSettle();

      expect(resetCalled, isTrue);
      expect(removeCalled, isFalse);
    });

    testWidgets('calls onRemove and dismisses the menu', (
      WidgetTester tester,
    ) async {
      var removeCalled = false;

      await pumpTestApp(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showTelemetryWidgetMenu(
                context,
                widgetLabel: 'Tyres',
                onRemove: () => removeCalled = true,
              ),
              child: const Text('Open menu'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open menu'));
      await tester.pumpAndSettle();

      expect(find.text('Remove widget'), findsOneWidget);
      // No reset callback provided → no reset action row.
      expect(find.text('Reset size'), findsNothing);

      await tester.tap(find.text('Remove widget'));
      await tester.pumpAndSettle();

      expect(removeCalled, isTrue);
      expect(find.text('Tyres'), findsNothing);
    });

    testWidgets('dismisses when the barrier is tapped', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showTelemetryWidgetMenu(
                context,
                widgetLabel: 'Fuel',
              ),
              child: const Text('Open menu'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open menu'));
      await tester.pumpAndSettle();

      expect(find.text('Fuel'), findsOneWidget);

      // Tap far away from the centered menu card to hit the barrier.
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(find.text('Fuel'), findsNothing);
    });
  });
}
