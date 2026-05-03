/*
##
## OverDrive 2026
## All Technical rights reserved
##
## calendar_page.dart - Calendar screen placeholder.
##
*/

import 'package:flutter/material.dart';

import '../shared/placeholder_page.dart';

const String _calendarPageTitle = 'Calendar';

/// Temporary calendar screen backed by the shared placeholder shell.
class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(title: _calendarPageTitle);
  }
}
