/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## championship_icon_test.dart - Widget tests for ChampionshipIcon.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/championships/championship_icon.dart';

import '../../helpers/test_app.dart';

void main() {
  group('ChampionshipIcon', () {
    testWidgets('renders asset fallback data and handles taps', (
      WidgetTester tester,
    ) async {
      var tapped = false;

      await pumpTestApp(
        tester,
        Scaffold(
          body: ChampionshipIcon(
            name: 'Formula 1',
            subtitle: 'Live',
            logoAsset: 'F1',
            isFavorite: true,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(ChampionshipIcon));
      await tester.pump();

      expect(tapped, isTrue);
      expect(find.textContaining('Formula 1'), findsOneWidget);
      expect(find.text('F1'), findsOneWidget);
      expect(find.text('Live'), findsOneWidget);
    });
  });
}
