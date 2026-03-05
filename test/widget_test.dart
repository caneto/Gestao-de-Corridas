import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_corridas/main.dart';
import 'package:gestao_corridas/core/database/database_helper.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(dbHelper: DatabaseHelper.instance));

    // Verify app starts.
    expect(find.text('Gestão de Corridas F1'), findsOneWidget);
  });
}
