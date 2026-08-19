/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## error_message_test.dart - Widget tests for ErrorMessage.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/base/error_message.dart';

import '../../helpers/test_app.dart';

void main() {
  group('ErrorMessage', () {
    testWidgets('renders inline and banner variants', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        const Scaffold(
          body: Column(
            children: [
              ErrorMessage(message: 'Inline error'),
              ErrorMessage(
                message: 'Banner error',
                subtitle: 'More details',
                variant: ErrorMessageVariant.banner,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Inline error'), findsOneWidget);
      expect(find.text('Banner error'), findsOneWidget);
      expect(find.text('More details'), findsOneWidget);
    });
  });
}
