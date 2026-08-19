/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## app_modal_test.dart - Widget tests for AppModal.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/base/app_button.dart';
import 'package:overdrive/widgets/base/app_modal.dart';

import '../../helpers/test_app.dart';

void main() {
  group('AppModal', () {
    testWidgets('opens a modal with title and content', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: AppButton(
                  label: 'Open modal',
                  onPressed: () {
                    AppModal.show<void>(
                      context,
                      title: 'Storage',
                      child: const Text('Local settings only'),
                    );
                  },
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open modal'));
      await tester.pumpAndSettle();

      expect(find.text('Storage'), findsOneWidget);
      expect(find.text('Local settings only'), findsOneWidget);
    });
  });
}
