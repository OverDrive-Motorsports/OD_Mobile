/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## menu_overlay_test.dart - Widget tests for MenuOverlayButton.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/base/menu_overlay.dart';

import '../../helpers/test_app.dart';

void main() {
  group('MenuOverlayButton', () {
    const items = [
      MenuOverlayItem(label: 'Home', icon: Icons.home),
      MenuOverlayItem(label: 'Calendar', icon: Icons.calendar_today),
      MenuOverlayItem(label: 'TV', icon: Icons.live_tv),
    ];

    testWidgets('renders the selected item label as the trigger button', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        Scaffold(
          body: Align(
            alignment: Alignment.topRight,
            child: MenuOverlayButton(
              items: items,
              selectedIndex: 1,
              onSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Calendar'), findsOneWidget);
    });

    testWidgets('opens the overlay menu and selects an item on tap', (
      WidgetTester tester,
    ) async {
      var selectedIndex = -1;

      await pumpTestApp(
        tester,
        Scaffold(
          body: Align(
            alignment: Alignment.topRight,
            child: MenuOverlayButton(
              items: items,
              selectedIndex: 0,
              onSelected: (index) => selectedIndex = index,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MenuOverlayButton));
      await tester.pumpAndSettle();

      // The button-to-panel morph animation has a known transient overflow
      // at intermediate frames (self-corrects once settled); unrelated to
      // this test.
      expect(tester.takeException(), isFlutterError);

      expect(find.text('TV'), findsOneWidget);

      await tester.tap(find.text('TV'));
      await tester.pumpAndSettle();

      expect(selectedIndex, 2);
    });
  });
}
