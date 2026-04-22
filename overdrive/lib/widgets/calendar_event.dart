/*
##
## OverDrive 2026
## All Technical rights reserved
##
## calendar_event.dart - Shared event marker model for calendar widgets.
##
*/

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class CalendarEventMarker {
  const CalendarEventMarker({this.color = AppColors.accent, this.label});

  final Color color;
  final String? label;
}
