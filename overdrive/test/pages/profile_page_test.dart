/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## profile_page_test.dart - Widget tests for ProfilePage.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/pages/profile/profile_page.dart';

import '../helpers/test_app.dart';

void main() {
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
}
