/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## login_page_test.dart - Widget tests for LoginPage.
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
  group('LoginPage', () {
    testWidgets('validates malformed credentials before submitting', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(tester, const LoginPage());

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
      await pumpTestApp(tester, const LoginPage());

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'driver@overdrive.app',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'short');
      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(
        find.text('Password must be at least 8 characters.'),
        findsOneWidget,
      );
    });

    testWidgets('opens SignupPage from the footer link', (
      WidgetTester tester,
    ) async {
      await _pumpAuthRouterApp(tester, initialLocation: '/login');

      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.byType(SignupPage), findsOneWidget);
      expect(find.text('Create your account'), findsOneWidget);
    });
  });
}
