/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## tv_stream.dart - Data model for TV streams shown in the live TV experience.
 ##
 */

import 'package:flutter/material.dart';

class TvStream {
  const TvStream({
    required this.id,
    required this.label,
    required this.title,
    required this.icon,
    this.videoUrl,
    this.isPrimary = false,
    this.isLive = true,
  });

  final String id;
  final String label;
  final String title;
  final IconData icon;
  final String? videoUrl;
  final bool isPrimary;
  final bool isLive;
}
