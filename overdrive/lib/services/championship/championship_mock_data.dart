/*
##
## OverDrive 2026
## All Technical rights reserved
##
## championship_mock_data.dart - Data-driven championship mocks.
##
*/

// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

import 'championship_circuit.dart';
import 'championship_data.dart';
import 'championship_enums.dart';
import 'championship_live_entry.dart';
import 'championship_session.dart';
import 'championship_standing.dart';

final ChampionshipData championshipFormula1Mock = ChampionshipData(
  id: 'formula_1',
  name: 'Formula 1',
  headline: 'Course',
  accentColor: Color(0xFFE80000),
  state: ChampionshipState.liveSession,
  circuit: ChampionshipCircuit(
    name: 'Circuit de Monaco',
    location: 'Monaco',
    lengthKm: 3.337,
    totalLaps: 78,
  ),
  weather: ChampionshipWeather(
    condition: 'Ensoleille',
    trackTempC: 38,
    airTempC: 24,
    rainChancePercent: 0,
  ),
  liveGroups: <ChampionshipLiveGroup>[
    ChampionshipLiveGroup(
      label: '',
      entries: <ChampionshipLiveEntry>[
        ChampionshipLiveEntry(
          position: 1,
          name: 'Verstappen',
          teamName: 'Red Bull Racing',
          gap: 'Leader',
          lap: 42,
          tyreCompound: 'M',
          teamColor: Color(0xFF3671C6),
        ),
        ChampionshipLiveEntry(
          position: 2,
          name: 'Hamilton',
          teamName: 'Mercedes',
          gap: '+3.4s',
          lap: 42,
          tyreCompound: 'M',
          teamColor: Color(0xFF00D2BE),
        ),
        ChampionshipLiveEntry(
          position: 3,
          name: 'Leclerc',
          teamName: 'Ferrari',
          gap: '+8.1s',
          lap: 42,
          tyreCompound: 'S',
          teamColor: Color(0xFFE8002D),
        ),
        ChampionshipLiveEntry(
          position: 4,
          name: 'Norris',
          teamName: 'McLaren',
          gap: '+12.7s',
          lap: 42,
          tyreCompound: 'S',
          teamColor: Color(0xFFFF8000),
        ),
        ChampionshipLiveEntry(
          position: 5,
          name: 'Sainz',
          teamName: 'Ferrari',
          gap: '+18.3s',
          lap: 41,
          tyreCompound: 'M',
          teamColor: Color(0xFFE8002D),
        ),
        ChampionshipLiveEntry(
          position: 6,
          name: 'Alonso',
          teamName: 'Aston Martin',
          gap: '+24.1s',
          lap: 41,
          tyreCompound: 'H',
          teamColor: Color(0xFF358C75),
        ),
        ChampionshipLiveEntry(
          position: 7,
          name: 'Piastri',
          teamName: 'McLaren',
          gap: '+31.6s',
          lap: 41,
          tyreCompound: 'H',
          teamColor: Color(0xFFFF8000),
        ),
        ChampionshipLiveEntry(
          position: 8,
          name: 'Russell',
          teamName: 'Mercedes',
          gap: '+38.2s',
          lap: 41,
          tyreCompound: 'M',
          teamColor: Color(0xFF00D2BE),
        ),
        ChampionshipLiveEntry(
          position: 9,
          name: 'Perez',
          teamName: 'Red Bull Racing',
          gap: '+45.0s',
          lap: 40,
          tyreCompound: 'H',
          teamColor: Color(0xFF3671C6),
        ),
        ChampionshipLiveEntry(
          position: 10,
          name: 'Gasly',
          teamName: 'Alpine',
          gap: '+52.3s',
          lap: 40,
          tyreCompound: 'M',
          teamColor: Color(0xFF2293D1),
        ),
        ChampionshipLiveEntry(
          position: 11,
          name: 'Ocon',
          teamName: 'Alpine',
          gap: '+58.7s',
          lap: 40,
          tyreCompound: 'H',
          teamColor: Color(0xFF2293D1),
        ),
        ChampionshipLiveEntry(
          position: 12,
          name: 'Stroll',
          teamName: 'Aston Martin',
          gap: '+1 t',
          lap: 39,
          tyreCompound: 'H',
          teamColor: Color(0xFF358C75),
        ),
        ChampionshipLiveEntry(
          position: 13,
          name: 'Tsunoda',
          teamName: 'RB',
          gap: '+1 t',
          lap: 39,
          tyreCompound: 'M',
          teamColor: Color(0xFF6692FF),
        ),
        ChampionshipLiveEntry(
          position: 14,
          name: 'Hulkenberg',
          teamName: 'Haas',
          gap: '+1 t',
          lap: 39,
          tyreCompound: 'H',
          teamColor: Color(0xFFB6BABD),
        ),
        ChampionshipLiveEntry(
          position: 15,
          name: 'Bottas',
          teamName: 'Kick Sauber',
          gap: '+1 t',
          lap: 38,
          tyreCompound: 'H',
          teamColor: Color(0xFF52E252),
        ),
        ChampionshipLiveEntry(
          position: 16,
          name: 'Zhou',
          teamName: 'Kick Sauber',
          gap: '+1 t',
          lap: 38,
          tyreCompound: 'H',
          teamColor: Color(0xFF52E252),
        ),
        ChampionshipLiveEntry(
          position: 17,
          name: 'Sargeant',
          teamName: 'Williams',
          gap: '+1 t',
          lap: 38,
          tyreCompound: 'M',
          teamColor: Color(0xFF37BEDD),
        ),
        ChampionshipLiveEntry(
          position: 18,
          name: 'Albon',
          teamName: 'Williams',
          gap: '+1 t',
          lap: 38,
          tyreCompound: 'M',
          teamColor: Color(0xFF37BEDD),
        ),
        ChampionshipLiveEntry(
          position: 19,
          name: 'Magnussen',
          teamName: 'Haas',
          gap: '+2 t',
          lap: 37,
          tyreCompound: 'H',
          teamColor: Color(0xFFB6BABD),
        ),
        ChampionshipLiveEntry(
          position: 20,
          name: 'De Vries',
          teamName: 'RB',
          gap: '+2 t',
          lap: 37,
          tyreCompound: 'H',
          teamColor: Color(0xFF6692FF),
        ),
      ],
    ),
  ],
  standings: <ChampionshipStandingTable>[
    ChampionshipStandingTable(
      type: StandingType.drivers,
      label: 'Pilotes',
      entries: <ChampionshipStandingEntry>[
        ChampionshipStandingEntry(
          position: 1,
          name: 'Verstappen',
          points: 161,
          teamName: 'Red Bull Racing',
        ),
        ChampionshipStandingEntry(
          position: 2,
          name: 'Hamilton',
          points: 124,
          teamName: 'Mercedes',
        ),
        ChampionshipStandingEntry(
          position: 3,
          name: 'Leclerc',
          points: 112,
          teamName: 'Ferrari',
        ),
        ChampionshipStandingEntry(
          position: 4,
          name: 'Norris',
          points: 98,
          teamName: 'McLaren',
        ),
        ChampionshipStandingEntry(
          position: 5,
          name: 'Sainz',
          points: 85,
          teamName: 'Ferrari',
        ),
      ],
    ),
    ChampionshipStandingTable(
      type: StandingType.teams,
      label: 'Equipes',
      entries: <ChampionshipStandingEntry>[
        ChampionshipStandingEntry(
          position: 1,
          name: 'Red Bull Racing',
          points: 273,
        ),
        ChampionshipStandingEntry(position: 2, name: 'Ferrari', points: 197),
        ChampionshipStandingEntry(position: 3, name: 'Mercedes', points: 181),
        ChampionshipStandingEntry(position: 4, name: 'McLaren', points: 152),
        ChampionshipStandingEntry(
          position: 5,
          name: 'Aston Martin',
          points: 89,
        ),
      ],
    ),
  ],
  replays: ChampionshipReplays(label: 'Bibliotheque de replays'),
);

final ChampionshipData championshipWecMock = ChampionshipData(
  id: 'wec',
  name: 'WEC',
  headline: 'World Endurance',
  accentColor: Color(0xFF4A90D9),
  state: ChampionshipState.offSeason,
  nextEvent: ChampionshipNextEvent(
    name: '24 Heures du Mans',
    location: 'Circuit de la Sarthe · France',
    startsAt: DateTime(2026, 6, 5, 16, 0),
  ),
  standings: <ChampionshipStandingTable>[
    ChampionshipStandingTable(
      type: StandingType.drivers,
      label: 'Pilotes — Hypercar',
      entries: <ChampionshipStandingEntry>[
        ChampionshipStandingEntry(
          position: 1,
          name: 'Hartley',
          points: 89,
          teamName: 'Toyota Gazoo Racing',
        ),
        ChampionshipStandingEntry(
          position: 2,
          name: 'Conway',
          points: 76,
          teamName: 'Toyota Gazoo Racing',
        ),
        ChampionshipStandingEntry(
          position: 3,
          name: 'Bamber',
          points: 71,
          teamName: 'Porsche Penske',
        ),
        ChampionshipStandingEntry(
          position: 4,
          name: 'Kobayashi',
          points: 65,
          teamName: 'Toyota Gazoo Racing',
        ),
        ChampionshipStandingEntry(
          position: 5,
          name: 'Buemi',
          points: 58,
          teamName: 'Toyota Gazoo Racing',
        ),
      ],
    ),
    ChampionshipStandingTable(
      type: StandingType.teams,
      label: 'Equipes — Hypercar',
      entries: <ChampionshipStandingEntry>[
        ChampionshipStandingEntry(
          position: 1,
          name: 'Toyota Gazoo Racing',
          points: 142,
        ),
        ChampionshipStandingEntry(
          position: 2,
          name: 'Porsche Penske',
          points: 118,
        ),
        ChampionshipStandingEntry(
          position: 3,
          name: 'Ferrari AF Corse',
          points: 97,
        ),
        ChampionshipStandingEntry(
          position: 4,
          name: 'Cadillac Racing',
          points: 84,
        ),
        ChampionshipStandingEntry(
          position: 5,
          name: 'Lamborghini Iron Lynx',
          points: 71,
        ),
      ],
    ),
    ChampionshipStandingTable(
      type: StandingType.drivers,
      label: 'Pilotes — LMP2',
      entries: <ChampionshipStandingEntry>[
        ChampionshipStandingEntry(
          position: 1,
          name: 'Jarvis',
          points: 94,
          teamName: 'United Autosports',
        ),
        ChampionshipStandingEntry(
          position: 2,
          name: 'Lynn',
          points: 81,
          teamName: 'Vector Sport',
        ),
        ChampionshipStandingEntry(
          position: 3,
          name: 'Rast',
          points: 73,
          teamName: 'WRT',
        ),
        ChampionshipStandingEntry(
          position: 4,
          name: 'Frijns',
          points: 67,
          teamName: 'WRT',
        ),
        ChampionshipStandingEntry(
          position: 5,
          name: 'Hanley',
          points: 59,
          teamName: 'United Autosports',
        ),
      ],
    ),
    ChampionshipStandingTable(
      type: StandingType.teams,
      label: 'Equipes — LMP2',
      entries: <ChampionshipStandingEntry>[
        ChampionshipStandingEntry(
          position: 1,
          name: 'United Autosports',
          points: 148,
        ),
        ChampionshipStandingEntry(position: 2, name: 'WRT', points: 126),
        ChampionshipStandingEntry(
          position: 3,
          name: 'Vector Sport',
          points: 109,
        ),
        ChampionshipStandingEntry(
          position: 4,
          name: 'Prema Racing',
          points: 88,
        ),
        ChampionshipStandingEntry(
          position: 5,
          name: 'Inter Europol',
          points: 74,
        ),
      ],
    ),
    ChampionshipStandingTable(
      type: StandingType.drivers,
      label: 'Pilotes — GT3',
      entries: <ChampionshipStandingEntry>[
        ChampionshipStandingEntry(
          position: 1,
          name: 'Cairoli',
          points: 91,
          teamName: 'Manthey EMA',
        ),
        ChampionshipStandingEntry(
          position: 2,
          name: 'Pera',
          points: 84,
          teamName: 'Iron Dames',
        ),
        ChampionshipStandingEntry(
          position: 3,
          name: 'Schiavoni',
          points: 75,
          teamName: 'Vista AF Corse',
        ),
        ChampionshipStandingEntry(
          position: 4,
          name: 'Farfus',
          points: 69,
          teamName: 'WRT BMW',
        ),
        ChampionshipStandingEntry(
          position: 5,
          name: 'Rovera',
          points: 62,
          teamName: 'Vista AF Corse',
        ),
      ],
    ),
    ChampionshipStandingTable(
      type: StandingType.teams,
      label: 'Equipes — GT3',
      entries: <ChampionshipStandingEntry>[
        ChampionshipStandingEntry(
          position: 1,
          name: 'Manthey EMA',
          points: 139,
        ),
        ChampionshipStandingEntry(
          position: 2,
          name: 'Vista AF Corse',
          points: 128,
        ),
        ChampionshipStandingEntry(position: 3, name: 'WRT BMW', points: 111),
        ChampionshipStandingEntry(position: 4, name: 'Iron Dames', points: 97),
        ChampionshipStandingEntry(position: 5, name: 'Akkodis ASP', points: 79),
      ],
    ),
  ],
  replays: ChampionshipReplays(label: 'Bibliotheque de replays'),
);

final ChampionshipData championshipMotoGpMock = ChampionshipData(
  id: 'motogp',
  name: 'MotoGP',
  headline: 'Gran Premio d’Italia',
  accentColor: Color(0xFFE87722),
  state: ChampionshipState.eventWeekend,
  circuit: ChampionshipCircuit(
    name: 'Autodromo del Mugello',
    location: 'Scarperia e San Piero · Italie',
    lengthKm: 5.245,
    totalLaps: 23,
  ),
  weather: ChampionshipWeather(
    condition: 'Nuageux',
    trackTempC: 28,
    airTempC: 18,
    rainChancePercent: 10,
  ),
  schedule: <ChampionshipSession>[
    ChampionshipSession(
      name: 'EL1',
      scheduledAt: DateTime(2026, 5, 22, 9, 0),
      status: SessionStatus.completed,
    ),
    ChampionshipSession(
      name: 'EL2',
      scheduledAt: DateTime(2026, 5, 22, 13, 30),
      status: SessionStatus.completed,
    ),
    ChampionshipSession(
      name: 'EL3',
      scheduledAt: DateTime(2026, 5, 23, 10, 0),
      status: SessionStatus.upcoming,
    ),
    ChampionshipSession(
      name: 'Qualifications',
      scheduledAt: DateTime(2026, 5, 23, 14, 0),
      status: SessionStatus.upcoming,
    ),
    ChampionshipSession(
      name: 'Course',
      scheduledAt: DateTime(2026, 5, 24, 14, 0),
      status: SessionStatus.upcoming,
    ),
  ],
  standings: <ChampionshipStandingTable>[
    ChampionshipStandingTable(
      type: StandingType.drivers,
      label: 'Pilotes',
      entries: <ChampionshipStandingEntry>[
        ChampionshipStandingEntry(
          position: 1,
          name: 'Bagnaia',
          points: 138,
          teamName: 'Ducati Lenovo',
        ),
        ChampionshipStandingEntry(
          position: 2,
          name: 'Marquez',
          points: 121,
          teamName: 'Gresini Racing',
        ),
        ChampionshipStandingEntry(
          position: 3,
          name: 'Bastianini',
          points: 98,
          teamName: 'Ducati Lenovo',
        ),
        ChampionshipStandingEntry(
          position: 4,
          name: 'Martin',
          points: 87,
          teamName: 'Aprilia Racing',
        ),
        ChampionshipStandingEntry(
          position: 5,
          name: 'Quartararo',
          points: 76,
          teamName: 'Monster Yamaha',
        ),
      ],
    ),
  ],
  replays: ChampionshipReplays(label: 'Bibliotheque de replays'),
);

final List<ChampionshipData> championshipMocks = <ChampionshipData>[
  championshipFormula1Mock,
  championshipWecMock,
  championshipMotoGpMock,
];

ChampionshipData championshipDataById(String id) {
  return championshipMocks.firstWhere(
    (ChampionshipData data) => data.id == id,
    orElse: () => championshipFormula1Mock,
  );
}
