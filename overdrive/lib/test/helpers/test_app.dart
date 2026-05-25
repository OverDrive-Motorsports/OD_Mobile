/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## test_app.dart - Shared widget-test harness for OverDrive pages and widgets.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overdrive/core/navigation/app_routes.dart';
import 'package:overdrive/core/theme/app_theme.dart';

/// Pumps a themed Material app around the widget under test.
Future<void> pumpTestApp(
  WidgetTester tester,
  Widget child, {
  Map<String, WidgetBuilder> routes = const <String, WidgetBuilder>{},
  RouteFactory? onGenerateRoute,
  NavigatorObserver? navigatorObserver,
}) async {
  GoogleFonts.config.allowRuntimeFetching = false;

  Route<dynamic>? resolveRoute(RouteSettings settings) {
    final generatedRoute = onGenerateRoute?.call(settings);
    if (generatedRoute != null) {
      return generatedRoute;
    }

    final builder = routes[settings.name];
    if (builder == null) {
      return null;
    }

    return MaterialPageRoute<void>(settings: settings, builder: builder);
  }

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: child,
      onGenerateRoute: resolveRoute,
      navigatorObservers: [?navigatorObserver],
    ),
  );
}

/// Pumps the real app router from a chosen initial route.
Future<void> pumpRoutedTestApp(
  WidgetTester tester, {
  String initialRoute = AppRoutes.home,
}) async {
  GoogleFonts.config.allowRuntimeFetching = false;

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: initialRoute,
      onGenerateRoute: buildAppRoute,
    ),
  );
}

/// Captures route pushes and replacements for navigation assertions.
class RecordingNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = <Route<dynamic>>[];
  final List<Route<dynamic>> replacedRoutes = <Route<dynamic>>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      replacedRoutes.add(newRoute);
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
