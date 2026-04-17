import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/pages/home/home_page.dart';

void main() {
  testWidgets('home page displays OD and menu button', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    expect(find.text('OD'), findsOneWidget);
    expect(find.text('Menu'), findsOneWidget);
  });
}
