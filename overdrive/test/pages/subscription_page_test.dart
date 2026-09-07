/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## subscription_page_test.dart - Widget tests for SubscriptionBody.
 ##
 ## Scope: SubscriptionBody is currently an empty placeholder body (tier
 ## cards and CTA are not implemented yet), so this only smoke-tests that it
 ## renders without throwing.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/pages/subscription/subscription_page.dart';

import '../helpers/test_app.dart';

void main() {
  group('SubscriptionBody', () {
    testWidgets('renders an empty placeholder body without throwing', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(tester, const SubscriptionBody());

      expect(find.byType(SubscriptionBody), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}
