import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listeo/models/models.dart';
import 'package:listeo/widgets/sheets.dart';
import 'package:provider/provider.dart';
import 'package:listeo/data/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('formatListForSharing unit tests', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = AppStore();
    await store.init();
    store.locale = 'fr';

    final block1 = Block(
      id: 'b1',
      type: BlockType.recipe,
      name: 'Pancakes',
      servings: 4,
      items: [
        Item(id: 'i1', name: 'Farine', qty: 250, unit: 'g', checked: true),
        Item(id: 'i2', name: 'Lait', qty: 300, unit: 'ml', checked: false),
      ],
    );

    final list = ShoppingList(
      id: 'l1',
      name: 'Courses Courses',
      tone: 'green',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      blocks: [block1],
    );

    // Build helper widget to provide context for localization and store
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppStore>.value(value: store),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              // 1. Test Recipe format including all items
              final t1 = formatListForSharing(
                context: context,
                list: list,
                groupByAisle: false,
                excludeChecked: false,
                locale: 'fr',
              );
              expect(t1, contains('🛒 Courses Courses'));
              expect(t1, contains('🍳 Pancakes (4 pers.) :'));
              expect(t1, contains('✓ Farine (250 g)'));
              expect(t1, contains('☐ Lait (300 ml)'));

              // 2. Test Recipe format excluding checked items
              final t2 = formatListForSharing(
                context: context,
                list: list,
                groupByAisle: false,
                excludeChecked: true,
                locale: 'fr',
              );
              expect(t2, contains('☐ Lait (300 ml)'));
              expect(t2, isNot(contains('Farine')));

              // 3. Test Aisle format including all items
              final t3 = formatListForSharing(
                context: context,
                list: list,
                groupByAisle: true,
                excludeChecked: false,
                locale: 'fr',
              );
              expect(t3, contains('📦 ÉPICERIE :'));
              expect(t3, contains('✓ Farine (250 g) [Pancakes]'));
              expect(t3, contains('📦 PRODUITS LAITIERS & ŒUFS :'));
              expect(t3, contains('☐ Lait (300 ml) [Pancakes]'));

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  });
}
