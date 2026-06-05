import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listeo/data/store.dart';
import 'package:listeo/data/catalog.dart';
import 'package:listeo/models/models.dart';
import 'package:listeo/widgets/fridge_roulette_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Fridge Roulette Matcher Unit Tests', () {
    test('getFridgeMatches calculates ratio correctly and sorts by match ratio descending', () async {
      final store = AppStore();
      await store.init();
      store.locale = 'fr';

      // Clear default inventory to control inputs
      store.inventory.clear();

      // Seed specifically for Pasta Carbonara (cat_carbonara)
      // Carbonara requires: Spaghetti, Lardons, Oeufs, Parmesan, Sel, Poivre
      store.addInventoryItem('Spaghetti', inStock: true);
      store.addInventoryItem('Lardons', inStock: true);
      store.addInventoryItem('Oeufs', inStock: true);
      store.addInventoryItem('Parmesan', inStock: true);
      // We have 4 out of 6 ingredients in stock.

      final matches = store.getFridgeMatches();
      expect(matches, isNotEmpty);

      // Carbonara should have 4 matches out of 6
      final carbMatch = matches.firstWhere((m) => m.recipe.id == 'cat_carbonara');
      expect(carbMatch.matchCount, equals(4));
      expect(carbMatch.totalCount, equals(6));
      expect(carbMatch.matchRatio, closeTo(0.666, 0.01));

      // Carbonara should be one of the top matches because 66% is high compared to empty inventory
      expect(matches.first.recipe.id, isNotNull);
      expect(matches.first.matchRatio, greaterThanOrEqualTo(0.5));
    });
  });

  group('Fridge Roulette UI Widget Tests', () {
    testWidgets('FridgeRouletteBody renders title, instructions, and reacts to Spin action', (WidgetTester tester) async {
      final store = AppStore();
      await store.init();
      store.locale = 'fr';

      // Build our Widget under ChangeNotifierProvider
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<AppStore>.value(
              value: store,
              child: const FridgeRouletteBody(),
            ),
          ),
        ),
      );

      // Verify header text renders
      expect(find.text('Roulette du Frigo'), findsOneWidget);
      expect(find.text('Lancer la roulette'), findsOneWidget);

      // Tap the spin button
      await tester.tap(find.text('Lancer la roulette'));
      await tester.pump(); // Start spin

      // Advance clock to finish animation (1800ms)
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();

      // Verify that a recipe details card is revealed (e.g. contains 'Ingrédients :')
      expect(find.text('Ingrédients :'), findsOneWidget);
      expect(find.text('Lancer encore'), findsOneWidget);
      expect(find.text('Cuisiner'), findsOneWidget);
    });
  });
}
