/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## app_button_test.dart - Widget tests for AppButton.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/base/app_button.dart';

import '../../helpers/test_app.dart';

void main() {
  group('AppButton', () {
    testWidgets('calls the callback when enabled', (WidgetTester tester) async {
      var tapCount = 0;

      await pumpTestApp(
        tester,
        Scaffold(
          body: Center(
            child: AppButton(label: 'Save', onPressed: () => tapCount++),
          ),
        ),
      );

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(tapCount, 1);
    });

    testWidgets('ignores taps and shows progress when loading', (
      WidgetTester tester,
    ) async {
      var tapCount = 0;

      await pumpTestApp(
        tester,
        Scaffold(
          body: Center(
            child: AppButton(
              label: 'Save',
              isLoading: true,
              onPressed: () => tapCount++,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(tapCount, 0);
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    });

    testWidgets('renders a leading icon and fills the available width', (
      WidgetTester tester,
    ) async {
      var tapped = false;

      await pumpTestApp(
        tester,
        Scaffold(
          body: AppButton(
            label: 'Monaco 2026',
            icon: Icons.play_arrow_rounded,
            fullWidth: true,
            onPressed: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Monaco 2026'));
      await tester.pump();

      expect(tapped, isTrue);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    });
  });
}
