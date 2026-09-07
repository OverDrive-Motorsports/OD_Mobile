/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## navigation_shell_test.dart - Widget tests for NavigationShell.
 ##
 ## Scope: NavigationShell wraps GoRouter's StatefulNavigationShell, which is
 ## only constructible via StatefulShellRoute. A minimal local GoRouter with
 ## five dummy branches is built here (mirroring the app's real branch
 ## layout) instead of pulling in AuthService or any page/network logic.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:overdrive/widgets/navigation/navigation_shell.dart';

/// Builds a minimal GoRouter with five branches (matching the real app's
/// home/championship/calendar/search/profile layout) so NavigationShell can
/// be exercised with a real StatefulNavigationShell.
GoRouter _buildTestRouter() {
  return GoRouter(
    initialLocation: '/branch-0',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => NavigationShell(navigationShell: shell),
        branches: [
          for (var i = 0; i < 5; i++)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/branch-$i',
                  builder: (_, _) => Center(child: Text('Branch $i')),
                ),
              ],
            ),
        ],
      ),
    ],
  );
}

void main() {
  group('NavigationShell', () {
    testWidgets('renders the current branch content and nav icons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: _buildTestRouter()));
      await tester.pumpAndSettle();

      expect(find.text('Branch 0'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.house_fill), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.flag), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.calendar), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.search), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.person), findsOneWidget);
    });

    testWidgets('switches branches when a tab icon is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: _buildTestRouter()));
      await tester.pumpAndSettle();

      expect(find.text('Branch 0'), findsOneWidget);

      // Tap the second tab (Championship / flag icon).
      await tester.tap(find.byIcon(CupertinoIcons.flag));
      await tester.pumpAndSettle();

      expect(find.text('Branch 1'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.flag_fill), findsOneWidget);
    });
  });
}
