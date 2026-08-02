/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## tv_live_player.dart - Embedded YouTube live player for the TV page.
 ##
 */

import 'package:cupertino_liquid_glass/cupertino_liquid_glass.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../services/tv/tv_stream.dart';

// ── Glass theme — unavailable player card ─────────────────────────────────

const _kUnavailableEdge = Color(0x28FFFFFF);

final _kUnavailableTheme = LiquidGlassThemeData.dark().copyWith(
  tintOpacity: 0.14,
  blurSigma: 22.0,
  noiseOpacity: 0.0,
  specularOpacity: 0.10,
  vibrancyIntensity: 0.04,
  edgeLightColor: _kUnavailableEdge,
  edgeShadowColor: _kUnavailableEdge,
);

/// Embedded live video player used by the TV page.
class TvLivePlayer extends StatefulWidget {
  const TvLivePlayer({required this.stream, super.key});

  final TvStream stream;

  @override
  State<TvLivePlayer> createState() => _TvLivePlayerState();
}

/// Owns WebView setup and stream loading for a single TV stream.
class _TvLivePlayerState extends State<TvLivePlayer> {
  late final WebViewController _controller;
  bool _isPlayerReady = false;

  bool get _hasVideo => widget.stream.videoUrl != null;

  @override
  void initState() {
    super.initState();
    _controller = _buildController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadCurrentStream();
      }
    });
  }

  @override
  void didUpdateWidget(covariant TvLivePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.stream.id != widget.stream.id) {
      _loadCurrentStream();
    }
  }

  /// Creates the configured WebView controller used by the embedded player.
  WebViewController _buildController() {
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.black)
      ..enableZoom(false);
  }

  /// Loads the current stream into the WebView and toggles loading state.
  Future<void> _loadCurrentStream() async {
    final embedUri = _buildYouTubeEmbedUri(widget.stream.videoUrl);

    if (!mounted) {
      return;
    }

    setState(() => _isPlayerReady = false);

    if (embedUri == null) {
      return;
    }

    try {
      await _controller.loadHtmlString(
        _buildEmbeddedYouTubeHtml(embedUri),
        baseUrl: _kEmbedBaseUrl,
      );
      if (mounted) {
        Future<void>.delayed(const Duration(milliseconds: 900), () {
          if (mounted) {
            setState(() => _isPlayerReady = true);
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isPlayerReady = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasVideo || _buildYouTubeEmbedUri(widget.stream.videoUrl) == null) {
      return const _UnavailablePlayerState();
    }

    return Stack(
      children: <Widget>[
        Positioned.fill(child: WebViewWidget(controller: _controller)),
        if (!_isPlayerReady)
          const Positioned.fill(
            child: ColoredBox(
              color: AppColors.black,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.gold,
                  strokeWidth: 2.2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Fallback state displayed when a stream has no usable video URL.
class _UnavailablePlayerState extends StatelessWidget {
  const _UnavailablePlayerState();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, 0.76),
          radius: 1.05,
          colors: <Color>[
            AppColors.gold.withValues(alpha: 0.14),
            AppColors.white.withValues(alpha: 0.03),
            AppColors.black,
          ],
          stops: const <double>[0, 0.24, 0.9],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: CupertinoTheme(
            data: const CupertinoThemeData(brightness: Brightness.dark),
            child: CupertinoLiquidGlass(
              theme: _kUnavailableTheme,
              borderRadius: BorderRadius.circular(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.live_tv_outlined,
                        color: AppColors.gold.withValues(alpha: 0.72),
                        size: 34,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Flux video indisponible',
                        style: AppTextStyles.bodyBold().copyWith(
                          fontSize: 18,
                          color: AppColors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ce canal n a pas encore de source live active.',
                        style: AppTextStyles.body(
                          color: AppColors.gold.withValues(alpha: 0.78),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const String _kEmbedBaseUrl = 'https://overdrive.app/';

/// Converts supported YouTube URLs into an embeddable player URI.
Uri? _buildYouTubeEmbedUri(String? url) {
  final videoId = _extractYouTubeVideoId(url);
  if (videoId == null) {
    return null;
  }

  return Uri.parse('https://www.youtube.com/embed/$videoId').replace(
    queryParameters: <String, String>{
      'autoplay': '1',
      'mute': '1',
      'playsinline': '1',
      'controls': '1',
      'rel': '0',
      'modestbranding': '1',
      'origin': _kEmbedBaseUrl,
    },
  );
}

/// Extracts the video identifier from regular, short, live, and embed URLs.
String? _extractYouTubeVideoId(String? url) {
  if (url == null || url.isEmpty) {
    return null;
  }

  final uri = Uri.tryParse(url);
  if (uri == null) {
    return null;
  }

  if (uri.host.contains('youtu.be')) {
    return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
  }

  if (uri.queryParameters.containsKey('v')) {
    return uri.queryParameters['v'];
  }

  final segments = uri.pathSegments;
  if (segments.length >= 2 &&
      (segments.first == 'live' || segments.first == 'embed')) {
    return segments[1];
  }

  return null;
}

/// Builds the minimal HTML document used by the embedded WebView player.
String _buildEmbeddedYouTubeHtml(Uri embedUri) {
  return '''
<!DOCTYPE html>
<html lang="fr">
  <head>
    <meta charset="utf-8">
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no"
    >
    <meta name="referrer" content="origin">
    <style>
      html, body {
        margin: 0;
        padding: 0;
        width: 100%;
        height: 100%;
        overflow: hidden;
        background: #000000;
      }

      .frame {
        position: fixed;
        inset: 0;
        width: 100%;
        height: 100%;
        border: 0;
      }
    </style>
  </head>
  <body>
    <iframe
      class="frame"
      src="$embedUri"
      title="YouTube live player"
      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
      referrerpolicy="origin"
      allowfullscreen
    ></iframe>
  </body>
</html>
''';
}
