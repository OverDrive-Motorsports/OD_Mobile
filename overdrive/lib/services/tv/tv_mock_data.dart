/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## tv_mock_data.dart - Mock TV streams used by the TV page.
 ##
 */

import 'package:flutter/material.dart';

import 'tv_stream.dart';

const List<TvStream> tvStreamsMonacoMock = <TvStream>[
  TvStream(
    id: 'international',
    label: 'International',
    title: 'International Feed',
    icon: Icons.live_tv_outlined,
    videoUrl: 'https://www.youtube.com/embed/82XnMb4euLI?si=phkMUHZgRj1NUx2E',
    isPrimary: true,
  ),
  TvStream(
    id: 'verstappen',
    label: 'Verstappen',
    title: 'Verstappen Onboard',
    icon: Icons.sports_motorsports_outlined,
  ),
  TvStream(
    id: 'hamilton',
    label: 'Hamilton',
    title: 'Hamilton Onboard',
    icon: Icons.sports_motorsports_outlined,
  ),
  TvStream(
    id: 'leclerc',
    label: 'Leclerc',
    title: 'Leclerc Onboard',
    icon: Icons.sports_motorsports_outlined,
  ),
  TvStream(
    id: 'helicoptere',
    label: 'Helicoptere',
    title: 'Helicoptere Feed',
    icon: Icons.travel_explore_outlined,
  ),
  TvStream(
    id: 'pitlane',
    label: 'Pit Lane',
    title: 'Pit Lane Camera',
    icon: Icons.photo_camera_outlined,
  ),
];
