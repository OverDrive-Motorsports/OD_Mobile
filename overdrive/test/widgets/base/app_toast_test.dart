/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## app_toast_test.dart - Widget tests for AppToast.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/base/app_button.dart';
import 'package:overdrive/widgets/base/app_toast.dart';

import '../../helpers/test_app.dart';

void main() {
  group('AppToast', () {
    testWidgets('shows a toast from the overlay helper', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: AppButton(
                  label: 'Toast',
                  onPressed: () {
                    AppToast.show(
                      context,
                      message: 'Saved locally',
                      type: ToastType.success,
                    );
                  },
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Toast'));
      await tester.pump();

      expect(find.text('Saved locally'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });
  });
}
