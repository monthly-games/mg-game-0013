import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:game/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Game Flow - Basic Navigation', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));
    
    // Verify app launches
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Look for common UI elements
    final scaffoldFinder = find.byType(Scaffold);
    expect(scaffoldFinder, findsWidgets);
  });
}
