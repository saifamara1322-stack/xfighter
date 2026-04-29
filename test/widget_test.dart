// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xfighter/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const XFighterApp());
    expect(find.byType(MaterialApp), findsNothing); // GetMaterialApp
    expect(find.byType(Container), findsAny);
  });
}
