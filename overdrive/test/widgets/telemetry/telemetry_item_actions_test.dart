/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## telemetry_item_actions_test.dart - Widget tests for TelemetryItemActions.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/telemetry/telemetry_item_actions.dart';

import '../../helpers/test_app.dart';

void main() {
  group('TelemetryItemActions', () {
    testWidgets('exposes onRemove/onReset callbacks to descendants', (
      WidgetTester tester,
    ) async {
      var removeCalled = false;
      var resetCalled = false;

      await pumpTestApp(
        tester,
        Scaffold(
          body: TelemetryItemActions(
            onRemove: () => removeCalled = true,
            onReset: () => resetCalled = true,
            child: Builder(
              builder: (context) {
                final actions = TelemetryItemActions.maybeOf(context);
                return ElevatedButton(
                  onPressed: () {
                    actions?.onRemove?.call();
                    actions?.onReset?.call();
                  },
                  child: const Text('Trigger'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger'));
      await tester.pump();

      expect(removeCalled, isTrue);
      expect(resetCalled, isTrue);
    });

    testWidgets('maybeOf returns null when there is no ancestor', (
      WidgetTester tester,
    ) async {
      TelemetryItemActions? found;

      await pumpTestApp(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) {
              found = TelemetryItemActions.maybeOf(context);
              return const Text('No ancestor');
            },
          ),
        ),
      );

      expect(found, isNull);
    });
  });
}
