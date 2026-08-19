/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## app_switch_test.dart - Widget tests for AppSwitch.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/base/app_switch.dart';

import '../../helpers/test_app.dart';

void main() {
  group('AppSwitch', () {
    testWidgets('forwards value changes', (WidgetTester tester) async {
      var value = false;

      await pumpTestApp(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: Center(
                child: AppSwitch(
                  label: 'Live alerts',
                  value: value,
                  onChanged: (nextValue) => setState(() => value = nextValue),
                ),
              ),
            );
          },
        ),
      );

      await tester.tap(
        find.descendant(
          of: find.byType(AppSwitch),
          matching: find.byType(GestureDetector),
        ),
      );
      await tester.pump();

      expect(value, isTrue);
      expect(find.text('Live alerts'), findsOneWidget);
    });
  });
}
