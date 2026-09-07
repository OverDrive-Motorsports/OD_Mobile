/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## live_race_page_test.dart - Widget tests for LiveRacePage.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/pages/tv/live_race_page.dart';

import '../helpers/test_app.dart';

void main() {
  group('LiveRacePage', () {
    testWidgets('renders the coming-soon placeholder content', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(tester, const LiveRacePage());

      expect(find.text('Live Race'), findsNWidgets(2));
      expect(find.text('Live race screen content coming soon'), findsOneWidget);
      expect(find.byIcon(Icons.live_tv_rounded), findsOneWidget);
    });

    testWidgets('pops the route when the back button is tapped', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const LiveRacePage()),
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(LiveRacePage), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(LiveRacePage), findsNothing);
    });
  });
}
