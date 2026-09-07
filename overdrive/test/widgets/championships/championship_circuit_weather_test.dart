/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## championship_circuit_weather_test.dart - Widget tests for ChampionshipCircuitWeatherCard.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/services/championship/championship_circuit.dart';
import 'package:overdrive/widgets/championships/championship_circuit_weather.dart';

import '../../helpers/test_app.dart';

void main() {
  group('ChampionshipCircuitWeatherCard', () {
    testWidgets('renders circuit metrics and rain chance', (
      WidgetTester tester,
    ) async {
      const circuit = ChampionshipCircuit(
        name: 'Circuit de Monaco',
        location: 'Monte Carlo',
        lengthKm: 3.337,
        totalLaps: 78,
      );
      const weather = ChampionshipWeather(
        condition: 'Cloudy',
        trackTempC: 32,
        airTempC: 24,
        rainChancePercent: 40,
      );

      await pumpTestApp(
        tester,
        const Scaffold(
          body: ChampionshipCircuitWeatherCard(
            circuit: circuit,
            weather: weather,
          ),
        ),
      );

      expect(find.text('CIRCUIT · METEO'), findsOneWidget);
      expect(find.text('Longueur'), findsOneWidget);
      expect(find.text('3.337 km'), findsOneWidget);
      expect(find.text('Tours'), findsOneWidget);
      expect(find.text('78'), findsOneWidget);
      expect(find.text('Meteo'), findsOneWidget);
      expect(find.text('40%'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_rounded), findsOneWidget);
    });

    testWidgets('shows the sunny icon when there is no rain chance', (
      WidgetTester tester,
    ) async {
      const circuit = ChampionshipCircuit(
        name: 'Silverstone',
        location: 'United Kingdom',
        lengthKm: 5.891,
        totalLaps: 52,
      );
      const weather = ChampionshipWeather(
        condition: 'Sunny',
        trackTempC: 28,
        airTempC: 21,
        rainChancePercent: 0,
      );

      await pumpTestApp(
        tester,
        const Scaffold(
          body: ChampionshipCircuitWeatherCard(
            circuit: circuit,
            weather: weather,
          ),
        ),
      );

      expect(find.byIcon(Icons.wb_sunny_rounded), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
    });
  });
}
