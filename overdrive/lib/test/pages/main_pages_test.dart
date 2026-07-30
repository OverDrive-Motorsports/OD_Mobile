/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## main_pages_test.dart - Widget tests covering the main navigation pages (Home, Championship, Calendar, Search, Profile).
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/core/navigation/app_routes.dart';
import 'package:overdrive/pages/calendar/calendar_page.dart';
import 'package:overdrive/pages/championship/championship_page.dart';
import 'package:overdrive/pages/profile/profile_page.dart';
import 'package:overdrive/pages/replay/replay_page.dart';
import 'package:overdrive/pages/search/search_page.dart';
import 'package:overdrive/pages/settings/settings_page.dart';
import 'package:overdrive/pages/telemetry/telemetry_page.dart';
import 'package:overdrive/services/championship/championship_mock_data.dart';
import '../helpers/test_app.dart';

void main() {
  group('Routed pages', () {
    testWidgets('ReplayPage only lists the Bahrein 2024 replay', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(tester, const ReplayPage());

      expect(find.text('Rechercher un replay'), findsOneWidget);
      expect(find.text('Grand Prix de Bahrein 2024'), findsOneWidget);

      await pumpTestApp(tester, const TelemetryPage());

      expect(find.text('TELEMETRIE'), findsOneWidget);
    });

    testWidgets('search page owns a reusable search bar controller', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(tester, const SearchPage());

      expect(find.byType(SearchPage), findsOneWidget);
      expect(find.text('Search'), findsWidgets);
      expect(find.text('Rechercher'), findsOneWidget);
    });
  });

  group('ProfilePage', () {
    testWidgets('renders account data and opens action modals', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        const ProfilePage(data: profilePagePreviewData),
      );

      expect(find.text('Pilote OverDrive'), findsOneWidget);
      expect(find.text('profil.local@overdrive.app'), findsOneWidget);
      expect(find.text('ACTIONS RAPIDES'), findsOneWidget);

      await tester.ensureVisible(find.text('Supprimer le compte'));
      await tester.tap(find.text('Supprimer le compte'));
      await tester.pumpAndSettle();

      expect(find.text('Supprimer le compte'), findsWidgets);
      expect(find.textContaining('definitive'), findsOneWidget);
    });
  });

  group('SettingsPage', () {
    testWidgets('renders sections and shows save feedback', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(tester, const SettingsPage());

      expect(find.text('NOTIFICATIONS'), findsOneWidget);
      expect(find.text('EXPERIENCE'), findsOneWidget);
      expect(find.text('ACTIONS'), findsOneWidget);

      await tester.ensureVisible(find.text('Enregistrer'));
      await tester.tap(find.text('Enregistrer'));
      await tester.pump();

      expect(find.text('Reglages enregistres localement.'), findsOneWidget);
    });
  });

  group('CalendarPage', () {
    testWidgets('loads championship filters and schedule content', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(tester, const CalendarPage());

      expect(find.text('Chargement du calendrier'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('Championships'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Formula 1'), findsWidgets);
      expect(find.text('Courses'), findsOneWidget);
    });
  });

  group('ChampionshipPage', () {
    testWidgets('renders live blocks from Formula 1 mock data', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        ChampionshipPage(data: championshipFormula1Mock),
        onGenerateRoute: buildAppRoute,
      );

      expect(find.text('DIRECT'), findsOneWidget);
      expect(find.text('TV Live'), findsOneWidget);
      expect(find.text('Bibliotheque de replays'), findsOneWidget);
    });
  });

}
