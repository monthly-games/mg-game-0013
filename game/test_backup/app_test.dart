import 'package:flutter_test/flutter_test.dart';
import 'package:game/main.dart' as app;

void main() {
  testWidgets('App smoke test - loads without crashing', (WidgetTester tester) async {
    // Build the app and trigger a frame
    await tester.pumpWidget(app.MyApp() ?? const app.MaterialApp(home: app.Scaffold()));
    
    // Verify the app builds
    expect(find.byType(app.MaterialApp), findsOneWidget);
  });
}
