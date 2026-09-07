/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## tv_page_test.dart - Widget tests for TvPage.
 ##
 ## Scope: TvPage always embeds TvLivePlayer, which builds a real
 ## WebViewController. There is no platform channel wired up in the widget
 ## test environment, so a minimal fake `WebViewPlatform` is registered
 ## below (no network I/O — it just no-ops the controller calls and renders
 ## a stand-in widget) to let the page build without touching a real
 ## WebView or the network. The close button uses `context.go(...)`, which
 ## requires a GoRouter ancestor and is out of scope here.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/pages/tv/tv_page.dart';

import '../helpers/fake_webview_platform.dart';
import '../helpers/test_app.dart';

void main() {
  setUpAll(registerFakeWebViewPlatform);

  group('TvPage', () {
    testWidgets('renders the primary stream by default', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(tester, const TvPage());
      await tester.pump(const Duration(milliseconds: 950));

      expect(find.text('LIVE'), findsOneWidget);
      expect(find.text('International Feed'), findsOneWidget);
      expect(find.text('Flux principal'), findsOneWidget);
      expect(find.text('Flux'), findsOneWidget);
    });

    testWidgets('switches stream via the stream selector sheet', (
      WidgetTester tester,
    ) async {
      // The stream picker sheet needs a phone-height viewport for all 6
      // options to lay out on-screen — the default 800x600 test surface is
      // too short and pushes the lower row out of the hit-testable area.
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpTestApp(tester, const TvPage());
      await tester.pump(const Duration(milliseconds: 950));

      await tester.tap(find.text('Flux'));
      // TvPage runs its own perpetually-repeating pulse AnimationController
      // (the LIVE dot), so pumpAndSettle would never settle; pump past the
      // modal's transition instead.
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Leclerc'), findsOneWidget);
      await tester.tap(find.text('Leclerc'));
      // TvPage runs its own perpetually-repeating pulse AnimationController
      // (the LIVE dot), so pumpAndSettle would never settle; pump past the
      // modal's transition instead.
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 950));

      expect(find.text('Leclerc Onboard'), findsOneWidget);
    });
  });
}
