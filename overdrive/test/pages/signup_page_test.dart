/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## signup_page_test.dart - Widget tests for SignupPage.
 ##
 ## Scope: local form validation and in-app navigation only. Submitting a
 ## fully valid form triggers a real AuthService network call, which is out
 ## of scope for these unit tests.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:overdrive/pages/login/login_page.dart';
import 'package:overdrive/pages/signup/signup_page.dart';

import '../helpers/test_app.dart';

/// Pumps a minimal GoRouter with only the login/signup routes so the
/// in-page `context.go(...)` footer link can be exercised without pulling
/// in AuthService or any auth redirect/network logic.
Future<void> _pumpAuthRouterApp(WidgetTester tester, {required String initialLocation}) async {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/signup', builder: (_, _) => const SignupPage()),
    ],
  );

  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
}

void main() {
  group('SignupPage', () {
    testWidgets('validates all required fields before submitting', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(tester, const SignupPage());

      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      expect(find.text('Email is required.'), findsOneWidget);
      expect(find.text('Username is required.'), findsOneWidget);
      expect(find.text('Password is required.'), findsOneWidget);
      expect(find.text('Confirm your password.'), findsOneWidget);
    });

    testWidgets('flags mismatched password confirmation', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(tester, const SignupPage());

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'driver@overdrive.app',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'driver78');
      await tester.enterText(find.byType(TextFormField).at(2), '12345678');
      await tester.enterText(find.byType(TextFormField).at(3), '87654321');
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      expect(find.text('Passwords do not match.'), findsOneWidget);
    });

    testWidgets('rejects a username shorter than 3 characters', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(tester, const SignupPage());

      await tester.enterText(find.byType(TextFormField).at(1), 'ab');
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      expect(
        find.text('Username must be at least 3 characters.'),
        findsOneWidget,
      );
    });

    testWidgets('opens LoginPage from the footer link', (
      WidgetTester tester,
    ) async {
      await _pumpAuthRouterApp(tester, initialLocation: '/signup');

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('Welcome back'), findsOneWidget);
    });
  });
}
