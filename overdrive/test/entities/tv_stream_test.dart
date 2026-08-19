/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## tv_stream_test.dart - Unit tests for the TvStream data model.
 ##
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/services/tv/tv_stream.dart';

void main() {
  group('TvStream', () {
    test('stores all constructor fields', () {
      const stream = TvStream(
        id: 'main-feed',
        label: 'Main Feed',
        title: 'World Feed',
        icon: Icons.live_tv,
        videoUrl: 'https://example.com/stream.m3u8',
        isPrimary: true,
        isLive: true,
      );

      expect(stream.id, 'main-feed');
      expect(stream.label, 'Main Feed');
      expect(stream.title, 'World Feed');
      expect(stream.icon, Icons.live_tv);
      expect(stream.videoUrl, 'https://example.com/stream.m3u8');
      expect(stream.isPrimary, isTrue);
      expect(stream.isLive, isTrue);
    });

    test('videoUrl defaults to null and isPrimary/isLive have sane defaults', () {
      const stream = TvStream(
        id: 'onboard-cam',
        label: 'Onboard',
        title: 'Driver Onboard',
        icon: Icons.camera_alt,
      );

      expect(stream.videoUrl, isNull);
      expect(stream.isPrimary, isFalse);
      expect(stream.isLive, isTrue);
    });
  });
}
