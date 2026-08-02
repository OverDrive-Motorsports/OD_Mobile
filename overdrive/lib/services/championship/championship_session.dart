/*
##
## OverDrive 2026
## All Technical rights reserved
##
## championship_session.dart - Weekend schedule models for championship pages.
##
*/

import 'package:flutter/foundation.dart';

import 'championship_enums.dart';

@immutable
class ChampionshipSession {
  const ChampionshipSession({
    required this.name,
    required this.scheduledAt,
    required this.status,
  });

  final String name;
  final DateTime scheduledAt;
  final SessionStatus status;
}
