/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## base_widgets_test.dart - Widget tests for shared base UI primitives.
 ##
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/widgets/base/od_button.dart';
import 'package:overdrive/widgets/base/od_error_message.dart';
import 'package:overdrive/widgets/base/od_modal.dart';
import 'package:overdrive/widgets/base/od_switch.dart';
import 'package:overdrive/widgets/base/od_text_field.dart';
import 'package:overdrive/widgets/base/od_toast.dart';
import 'package:overdrive/widgets/glass_pill.dart';

import '../helpers/test_app.dart';

void main() {
  group('OdButton', () {
    testWidgets('calls the callback when enabled', (WidgetTester tester) async {
      var tapCount = 0;

      await pumpTestApp(
        tester,
        Scaffold(
          body: Center(
            child: OdButton(label: 'Save', onPressed: () => tapCount++),
          ),
        ),
      );

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(tapCount, 1);
    });

    testWidgets('ignores taps and shows progress when loading', (
      WidgetTester tester,
    ) async {
      var tapCount = 0;

      await pumpTestApp(
        tester,
        Scaffold(
          body: Center(
            child: OdButton(
              label: 'Save',
              isLoading: true,
              onPressed: () => tapCount++,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(tapCount, 0);
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    });
  });

  group('OdTextField', () {
    testWidgets('emits changes and clears through the suffix action', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();
      var lastValue = '';
      var clearCount = 0;

      await pumpTestApp(
        tester,
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: OdTextField(
              controller: controller,
              placeholder: 'Email',
              onChanged: (value) => lastValue = value,
              onClear: () => clearCount++,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(CupertinoTextField), 'driver@od.app');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(lastValue, '');
      expect(clearCount, 1);
      expect(controller.text, isEmpty);
    });

    testWidgets('renders inline error copy when invalid', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(24),
            child: OdTextField(
              placeholder: 'Password',
              errorMessage: 'Password is required.',
            ),
          ),
        ),
      );

      expect(find.text('Password is required.'), findsOneWidget);
      expect(find.byType(OdErrorMessage), findsOneWidget);
    });
  });

  group('Feedback widgets', () {
    testWidgets('renders inline and banner error variants', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        const Scaffold(
          body: Column(
            children: [
              OdErrorMessage(message: 'Inline error'),
              OdErrorMessage(
                message: 'Banner error',
                subtitle: 'More details',
                variant: ErrorMessageVariant.banner,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Inline error'), findsOneWidget);
      expect(find.text('Banner error'), findsOneWidget);
      expect(find.text('More details'), findsOneWidget);
    });

    testWidgets('shows a toast from the overlay helper', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: OdButton(
                  label: 'Toast',
                  onPressed: () {
                    OdToast.show(
                      context,
                      message: 'Saved locally',
                      type: ToastType.success,
                    );
                  },
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Toast'));
      await tester.pump();

      expect(find.text('Saved locally'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('opens a modal with title and content', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: OdButton(
                  label: 'Open modal',
                  onPressed: () {
                    OdModal.show<void>(
                      context,
                      title: 'Storage',
                      child: const Text('Local settings only'),
                    );
                  },
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open modal'));
      await tester.pumpAndSettle();

      expect(find.text('Storage'), findsOneWidget);
      expect(find.text('Local settings only'), findsOneWidget);
    });
  });

  group('Small primitives', () {
    testWidgets('OdSwitch forwards value changes', (WidgetTester tester) async {
      var value = false;

      await pumpTestApp(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: Center(
                child: OdSwitch(
                  label: 'Live alerts',
                  value: value,
                  onChanged: (nextValue) => setState(() => value = nextValue),
                ),
              ),
            );
          },
        ),
      );

      await tester.tap(find.byType(CupertinoSwitch));
      await tester.pump();

      expect(value, isTrue);
      expect(find.text('Live alerts'), findsOneWidget);
    });

    testWidgets('GlassPill renders its child', (WidgetTester tester) async {
      await pumpTestApp(
        tester,
        const Scaffold(
          body: Center(child: GlassPill(child: Text('Pill content'))),
        ),
      );

      expect(find.text('Pill content'), findsOneWidget);
    });
  });
}
