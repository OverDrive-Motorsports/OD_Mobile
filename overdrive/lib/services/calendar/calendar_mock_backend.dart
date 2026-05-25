/*
##
## OverDrive 2026
## All Technical rights reserved
##
## calendar_mock_backend.dart - Simplified fake backend records for the calendar feature.
##
*/

class CalendarMockChampionshipRecord {
  const CalendarMockChampionshipRecord({
    required this.id,
    required this.name,
    required this.accentHex,
  });

  final String id;
  final String name;
  final String accentHex;
}

class CalendarMockRaceRecord {
  const CalendarMockRaceRecord({
    required this.id,
    required this.championshipId,
    required this.championshipName,
    required this.name,
    required this.startDateIso,
    required this.endDateIso,
    required this.accentHex,
    this.location,
  });

  final String id;
  final String championshipId;
  final String championshipName;
  final String name;
  final String startDateIso;
  final String endDateIso;
  final String accentHex;
  final String? location;
}

class CalendarMockBackend {
  CalendarMockBackend._();

  static final CalendarMockBackend instance = CalendarMockBackend._();

  Future<List<CalendarMockChampionshipRecord>> fetchChampionships() async {
    await Future<void>.delayed(const Duration(milliseconds: 240));

    return _championships;
  }

  Future<List<CalendarMockRaceRecord>> fetchSchedule({
    required int seasonYear,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 320));

    return _raceTemplates
        .map(
          (_CalendarMockRaceTemplate template) =>
              template.toRecord(seasonYear: seasonYear),
        )
        .toList(growable: false);
  }
}

const List<CalendarMockChampionshipRecord> _championships =
    <CalendarMockChampionshipRecord>[
      CalendarMockChampionshipRecord(
        id: 'formula_1',
        name: 'Formula 1',
        accentHex: '#E8002D',
      ),
      CalendarMockChampionshipRecord(
        id: 'wec',
        name: 'WEC',
        accentHex: '#0A84FF',
      ),
      CalendarMockChampionshipRecord(
        id: 'motogp',
        name: 'MotoGP',
        accentHex: '#E8002D',
      ),
      CalendarMockChampionshipRecord(
        id: 'indycar',
        name: 'IndyCar',
        accentHex: '#C9A84C',
      ),
    ];

const List<_CalendarMockRaceTemplate> _raceTemplates =
    <_CalendarMockRaceTemplate>[
      _CalendarMockRaceTemplate(
        id: 'wec-qatar',
        championshipId: 'wec',
        championshipName: 'WEC',
        name: 'Qatar 1812 KM',
        startMonth: 2,
        startDay: 26,
        endMonth: 2,
        endDay: 28,
        location: 'Lusail International Circuit',
        accentHex: '#0A84FF',
      ),
      _CalendarMockRaceTemplate(
        id: 'f1-bahrain',
        championshipId: 'formula_1',
        championshipName: 'Formula 1',
        name: 'Bahrain Grand Prix',
        startMonth: 3,
        startDay: 13,
        endMonth: 3,
        endDay: 15,
        location: 'Sakhir',
        accentHex: '#E8002D',
      ),
      _CalendarMockRaceTemplate(
        id: 'indycar-long-beach',
        championshipId: 'indycar',
        championshipName: 'IndyCar',
        name: 'Acura Grand Prix of Long Beach',
        startMonth: 4,
        startDay: 17,
        endMonth: 4,
        endDay: 19,
        location: 'Long Beach',
        accentHex: '#C9A84C',
      ),
      _CalendarMockRaceTemplate(
        id: 'motogp-jerez',
        championshipId: 'motogp',
        championshipName: 'MotoGP',
        name: 'Grand Prix of Spain',
        startMonth: 4,
        startDay: 24,
        endMonth: 4,
        endDay: 26,
        location: 'Circuito de Jerez',
        accentHex: '#E8002D',
      ),
      _CalendarMockRaceTemplate(
        id: 'wec-spa',
        championshipId: 'wec',
        championshipName: 'WEC',
        name: '6 Hours of Spa',
        startMonth: 5,
        startDay: 8,
        endMonth: 5,
        endDay: 9,
        location: 'Spa-Francorchamps',
        accentHex: '#0A84FF',
      ),
      _CalendarMockRaceTemplate(
        id: 'f1-monaco',
        championshipId: 'formula_1',
        championshipName: 'Formula 1',
        name: 'Monaco Grand Prix',
        startMonth: 5,
        startDay: 22,
        endMonth: 5,
        endDay: 24,
        location: 'Monte-Carlo',
        accentHex: '#E8002D',
      ),
      _CalendarMockRaceTemplate(
        id: 'indycar-indy500',
        championshipId: 'indycar',
        championshipName: 'IndyCar',
        name: 'Indianapolis 500',
        startMonth: 5,
        startDay: 22,
        endMonth: 5,
        endDay: 24,
        location: 'Indianapolis Motor Speedway',
        accentHex: '#C9A84C',
      ),
      _CalendarMockRaceTemplate(
        id: 'wec-le-mans',
        championshipId: 'wec',
        championshipName: 'WEC',
        name: '24 Hours of Le Mans',
        startMonth: 6,
        startDay: 13,
        endMonth: 6,
        endDay: 14,
        location: 'Le Mans',
        accentHex: '#0A84FF',
      ),
      _CalendarMockRaceTemplate(
        id: 'motogp-mugello',
        championshipId: 'motogp',
        championshipName: 'MotoGP',
        name: 'Grand Prix of Italy',
        startMonth: 6,
        startDay: 19,
        endMonth: 6,
        endDay: 21,
        location: 'Mugello',
        accentHex: '#E8002D',
      ),
      _CalendarMockRaceTemplate(
        id: 'f1-singapore',
        championshipId: 'formula_1',
        championshipName: 'Formula 1',
        name: 'Singapore Grand Prix',
        startMonth: 9,
        startDay: 18,
        endMonth: 9,
        endDay: 20,
        location: 'Marina Bay',
        accentHex: '#E8002D',
      ),
    ];

class _CalendarMockRaceTemplate {
  const _CalendarMockRaceTemplate({
    required this.id,
    required this.championshipId,
    required this.championshipName,
    required this.name,
    required this.startMonth,
    required this.startDay,
    required this.endMonth,
    required this.endDay,
    required this.accentHex,
    this.location,
  });

  final String id;
  final String championshipId;
  final String championshipName;
  final String name;
  final int startMonth;
  final int startDay;
  final int endMonth;
  final int endDay;
  final String accentHex;
  final String? location;

  CalendarMockRaceRecord toRecord({required int seasonYear}) {
    return CalendarMockRaceRecord(
      id: id,
      championshipId: championshipId,
      championshipName: championshipName,
      name: name,
      startDateIso: _isoDate(seasonYear, startMonth, startDay),
      endDateIso: _isoDate(seasonYear, endMonth, endDay),
      location: location,
      accentHex: accentHex,
    );
  }
}

String _isoDate(int year, int month, int day) {
  final monthLabel = month.toString().padLeft(2, '0');
  final dayLabel = day.toString().padLeft(2, '0');
  return '$year-$monthLabel-$dayLabel';
}
