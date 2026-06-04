import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:listeo/main.dart';
import 'package:listeo/data/store.dart';

void main() {
  testWidgets('ListeoApp smoke test', (WidgetTester tester) async {
    // Set initial mock preferences
    SharedPreferences.setMockInitialValues({});

    final store = AppStore();
    await store.init();
    store.locale = 'fr';

    // Build our app and trigger a frame.
    await tester.pumpWidget(ListeoApp(store: store));
    await tester.pumpAndSettle();

    // Verify that the brand name or main header "mes listes" is shown
    expect(find.text('mes listes'), findsOneWidget);

    // Verify that the tab "recettes" exists
    expect(find.text('recettes'), findsOneWidget);
  });
}
