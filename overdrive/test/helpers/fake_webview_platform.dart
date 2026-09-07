/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## fake_webview_platform.dart - No-op WebView platform for widget tests.
 ##
 ## Widgets that construct a real `WebViewController` (e.g. TvLivePlayer)
 ## need a platform implementation registered, which the widget test
 ## environment doesn't provide. This fake no-ops every controller call and
 ## renders a stand-in widget instead — no network or real platform channel
 ## involved. Call `registerFakeWebViewPlatform()` once in a `setUpAll`.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class _FakeWebViewPlatform extends WebViewPlatform {
  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    return _FakePlatformWebViewController(params);
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) {
    return _FakePlatformWebViewWidget(params);
  }
}

class _FakePlatformWebViewController extends PlatformWebViewController {
  _FakePlatformWebViewController(super.params) : super.implementation();

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {}

  @override
  Future<void> setBackgroundColor(Color color) async {}

  @override
  Future<void> enableZoom(bool enabled) async {}

  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) async {}

  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate handler,
  ) async {}
}

class _FakePlatformWebViewWidget extends PlatformWebViewWidget {
  _FakePlatformWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

/// Registers [_FakeWebViewPlatform] as the active `WebViewPlatform.instance`.
void registerFakeWebViewPlatform() {
  WebViewPlatform.instance = _FakeWebViewPlatform();
}
