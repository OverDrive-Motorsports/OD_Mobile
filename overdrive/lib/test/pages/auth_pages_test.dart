/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## auth_pages_test.dart - Widget tests for LoginPage and SignupPage authentication flows.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/core/navigation/app_routes.dart';
import 'package:overdrive/pages/signup/signup_page.dart';

import '../helpers/test_app.dart';

void main() {
  group('LoginPage', () {
    testWidgets('validates malformed credentials before submitting', (
      WidgetTester tester,
    ) async {
      await pumpRoutedTestApp(tester, initialRoute: AppRoutes.login);

      await tester.enterText(find.byType(TextFormField).at(0), 'bad');
      await tester.enterText(find.byType(TextFormField).at(1), '');
      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(find.text('Password is required.'), findsOneWidget);
    });

    testWidgets('rejects a password shorter than 8 characters', (
      WidgetTester tester,
    ) async {
      await pumpRoutedTestApp(tester, initialRoute: AppRoutes.login);

      await tester.enterText(find.byType(TextFormField).at(0), 'driver@od.app');
      await tester.enterText(find.byType(TextFormField).at(1), 'short');
      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(
        find.text('Password must be at least 8 characters.'),
        findsOneWidget,
      );
    });

    testWidgets('renders the sign up footer link', (WidgetTester tester) async {
      await pumpRoutedTestApp(tester, initialRoute: AppRoutes.login);

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Need an account?'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });
  });

  group('SignupPage', () {
    testWidgets('validates all required fields before submitting', (
      WidgetTester tester,
    ) async {
      await pumpRoutedTestApp(tester, initialRoute: AppRoutes.register);

      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      expect(find.text('Email is required.'), findsOneWidget);
      expect(find.text('Username is required.'), findsOneWidget);
      expect(find.text('Password is required.'), findsOneWidget);
      expect(find.text('Confirm your password.'), findsOneWidget);
    });

    testWidgets('flags a password confirmation mismatch', (
      WidgetTester tester,
    ) async {
      await pumpRoutedTestApp(tester, initialRoute: AppRoutes.register);

      await tester.enterText(find.byType(TextFormField).at(0), 'driver@od.app');
      await tester.enterText(find.byType(TextFormField).at(1), 'DriverOne');
      await tester.enterText(find.byType(TextFormField).at(2), '12345678');
      await tester.enterText(find.byType(TextFormField).at(3), '87654321');
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      expect(find.text('Passwords do not match.'), findsOneWidget);
    });

    testWidgets('the login link navigates back to the previous route', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const SignupPage(),
                      ),
                    );
                  },
                  child: const Text('Open signup'),
                ),
              ),
            );
          },
        ),
      );

      await tester.tap(find.text('Open signup'));
      await tester.pumpAndSettle();

      expect(find.byType(SignupPage), findsOneWidget);
      expect(find.text('Create your account'), findsOneWidget);

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.byType(SignupPage), findsNothing);
      expect(find.text('Open signup'), findsOneWidget);
    });
  });
}
