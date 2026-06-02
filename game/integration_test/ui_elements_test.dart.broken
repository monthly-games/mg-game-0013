import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:game/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('UI Elements - Basic Components', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));
    
    // Verify material app is present
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Verify basic widget tree is built
    expect(find.byType(Widget), findsWidgets);
  });
}
