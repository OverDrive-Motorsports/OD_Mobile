/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## app_text_field_test.dart - Widget tests for AppTextField.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/base/app_text_field.dart';
import 'package:overdrive/widgets/base/error_message.dart';

import '../../helpers/test_app.dart';

void main() {
  group('AppTextField', () {
    testWidgets('emits changes and clears through the suffix action', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();
      var lastValue = '';
      var clearCount = 0;

      await pumpTestApp(
        tester,
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: AppTextField(
              controller: controller,
              placeholder: 'Email',
              onChanged: (value) => lastValue = value,
              onClear: () => clearCount++,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(CupertinoTextField), 'driver@od.app');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(lastValue, '');
      expect(clearCount, 1);
      expect(controller.text, isEmpty);
    });

    testWidgets('renders inline error copy when invalid', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(24),
            child: AppTextField(
              placeholder: 'Password',
              errorMessage: 'Password is required.',
            ),
          ),
        ),
      );

      expect(find.text('Password is required.'), findsOneWidget);
      expect(find.byType(ErrorMessage), findsOneWidget);
    });
  });
}
