/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## demo_liquid_test.dart - Widget tests for DemoLiquid.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/base/demo_liquid.dart';

import '../../helpers/test_app.dart';

void main() {
  group('DemoLiquid', () {
    testWidgets('renders with default sizing', (WidgetTester tester) async {
      await pumpTestApp(
        tester,
        const Scaffold(body: Center(child: DemoLiquid())),
      );

      expect(find.byType(DemoLiquid), findsOneWidget);

      final sizedBoxFinder = find.descendant(
        of: find.byType(DemoLiquid),
        matching: find.byType(SizedBox),
      );
      final sizedBox = tester.widget<SizedBox>(sizedBoxFinder.first);
      expect(sizedBox.height, 72.0);
    });

    testWidgets('renders a solid fill colour when provided', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        const Scaffold(
          body: Center(
            child: DemoLiquid(
              fillColor: Colors.red,
              height: 100,
              width: 200,
              borderRadius: 12,
            ),
          ),
        ),
      );

      expect(find.byType(DemoLiquid), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(DemoLiquid),
          matching: find.byType(ColoredBox),
        ),
        findsOneWidget,
      );
    });
  });
}
