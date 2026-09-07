/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## telemetry_widget_style_test.dart - Widget tests for TelemetryCard, TelemetryHeader, TelemetryBar, and telemetryMode.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/core/theme/app_theme.dart';
import 'package:overdrive/widgets/telemetry/telemetry_widget_style.dart';

import '../../helpers/test_app.dart';

void main() {
  group('telemetryMode', () {
    test('returns large when both dimensions meet the 155 threshold', () {
      expect(telemetryMode(155, 155), TelemetryMode.large);
      expect(telemetryMode(200, 200), TelemetryMode.large);
    });

    test('returns small when either dimension is below the threshold', () {
      expect(telemetryMode(154, 200), TelemetryMode.small);
      expect(telemetryMode(200, 154), TelemetryMode.small);
      expect(telemetryMode(100, 100), TelemetryMode.small);
    });
  });

  group('TelemetryCard', () {
    testWidgets('renders its child inside the glass card', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        const Scaffold(
          body: TelemetryCard(child: Text('Card content')),
        ),
      );

      expect(find.text('Card content'), findsOneWidget);
      expect(find.byType(TelemetryCard), findsOneWidget);
    });
  });

  group('TelemetryHeader', () {
    testWidgets('renders only the label when no driver is provided', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        const Scaffold(
          body: TelemetryHeader(label: 'SPEED'),
        ),
      );

      expect(find.text('SPEED'), findsOneWidget);
    });

    testWidgets('renders the driver tag when provided', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        const Scaffold(
          body: TelemetryHeader(label: 'SPEED', driverId: 'VER'),
        ),
      );

      expect(find.text('SPEED'), findsOneWidget);
      expect(find.text('VER'), findsOneWidget);
    });
  });

  group('TelemetryBar', () {
    testWidgets('animates its fraction toward the target width', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        const Scaffold(
          body: SizedBox(
            width: 200,
            child: TelemetryBar(fraction: 0.6, color: AppColors.gold),
          ),
        ),
      );

      expect(find.byType(TelemetryBar), findsOneWidget);

      await tester.pumpAndSettle();

      final fractionallySizedBox = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fractionallySizedBox.widthFactor, closeTo(0.6, 0.001));
    });
  });
}
