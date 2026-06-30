/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## auth_pages_test.dart - Widget tests for LoginPage and RegisterPage authentication flows.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/core/navigation/app_routes.dart';
import 'package:overdrive/pages/auth/register_page.dart';
import 'package:overdrive/pages/home/home_page.dart';

import '../helpers/test_app.dart';

void main() {
  group('LoginPage', () {
    testWidgets('validates malformed credentials before submitting', (
      WidgetTester tester,
    ) async {
      await pumpRoutedTestApp(tester, initialRoute: AppRoutes.login);

      await tester.enterText(find.byType(CupertinoTextField).at(0), 'bad');
      await tester.enterText(find.byType(CupertinoTextField).at(1), '');
      await tester.tap(find.text('Sign in'));
      await tester.pump();

      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(find.text('Enter your password.'), findsOneWidget);
    });

    testWidgets('navigates to home with the seeded demo credentials', (
      WidgetTester tester,
    ) async {
      await pumpRoutedTestApp(tester, initialRoute: AppRoutes.login);

      await tester.tap(find.text('Sign in'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      expect(
        find.text('Signed in successfully. Welcome to OverDrive.'),
        findsOneWidget,
      );
    });

    testWidgets('opens registration from the footer link', (
      WidgetTester tester,
    ) async {
      await pumpRoutedTestApp(tester, initialRoute: AppRoutes.login);

      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      expect(find.byType(RegisterPage), findsOneWidget);
      expect(find.text('Welcome, sign up.'), findsOneWidget);
    });
  });

  group('RegisterPage', () {
    testWidgets('validates all required fields before submitting', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(tester, const RegisterPage());

      await tester.tap(find.text('Create account'));
      await tester.pump();

      expect(find.text('Enter your name or username.'), findsOneWidget);
      expect(find.text('Enter your email address.'), findsOneWidget);
      expect(find.text('Choose a password.'), findsOneWidget);
      expect(find.text('Confirm your password.'), findsOneWidget);
    });

    testWidgets('returns created credentials to the caller on success', (
      WidgetTester tester,
    ) async {
      Object? returnedResult;

      await pumpTestApp(
        tester,
        Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    returnedResult = await Navigator.of(context).push<Object?>(
                      MaterialPageRoute<Object?>(
                        builder: (_) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text('Open register'),
                ),
              ),
            );
          },
        ),
      );

      await tester.tap(find.text('Open register'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(CupertinoTextField).at(0),
        'Test Driver',
      );
      await tester.enterText(
        find.byType(CupertinoTextField).at(1),
        'driver_${DateTime.now().microsecondsSinceEpoch}@od.app',
      );
      await tester.enterText(find.byType(CupertinoTextField).at(2), '12345678');
      await tester.enterText(find.byType(CupertinoTextField).at(3), '12345678');
      await tester.tap(find.text('Create account'));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      expect(returnedResult, isA<Map<String, String>>());
      expect((returnedResult! as Map<String, String>)['password'], '12345678');
    });
  });
}
