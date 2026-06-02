import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/main.dart';

void main() {
  testWidgets('Arena Legend app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const ArenaLegendApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('ARENA LEGEND'), findsOneWidget);
  });
}
