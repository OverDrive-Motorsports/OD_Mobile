/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## tv_live_player_test.dart - Widget tests for TvLivePlayer.
 ##
 ## Scope: TvLivePlayer always constructs a real WebViewController in
 ## initState (even without a video URL), which needs a platform channel
 ## that widget tests don't provide. A no-op fake WebView platform is
 ## registered (see helpers/fake_webview_platform.dart) so the controller
 ## can be built and driven without a real WebView or any network access.
 ## Only the "no video URL" / unparsable-URL fallback states are exercised
 ## here — loading a real embedded YouTube player is out of scope.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/services/tv/tv_stream.dart';
import 'package:overdrive/widgets/tv/tv_live_player.dart';

import '../../helpers/fake_webview_platform.dart';
import '../../helpers/test_app.dart';

void main() {
  setUpAll(registerFakeWebViewPlatform);

  group('TvLivePlayer', () {
    testWidgets('shows the unavailable state when there is no video URL', (
      WidgetTester tester,
    ) async {
      const stream = TvStream(
        id: 'main',
        label: 'Main',
        title: 'Main Feed',
        icon: Icons.live_tv,
      );

      await pumpTestApp(
        tester,
        const Scaffold(body: TvLivePlayer(stream: stream)),
      );

      expect(find.text('Flux video indisponible'), findsOneWidget);
      expect(
        find.text('Ce canal n a pas encore de source live active.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.live_tv_outlined), findsOneWidget);
    });

    testWidgets('shows the unavailable state for an unparsable video URL', (
      WidgetTester tester,
    ) async {
      const stream = TvStream(
        id: 'main',
        label: 'Main',
        title: 'Main Feed',
        icon: Icons.live_tv,
        videoUrl: 'https://example.com/not-a-youtube-link',
      );

      await pumpTestApp(
        tester,
        const Scaffold(body: TvLivePlayer(stream: stream)),
      );

      expect(find.text('Flux video indisponible'), findsOneWidget);
    });
  });
}
