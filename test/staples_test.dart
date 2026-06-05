import 'package:flutter_test/flutter_test.dart';
import 'package:listeo/models/models.dart';
import 'package:listeo/data/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Pantry Staples Manager Tests', () {
    test('Staples seeding based on locale in init()', () async {
      final store = AppStore();
      
      // Default (EN)
      await store.init();
      expect(store.staples, containsAll(['Milk', 'Eggs', 'Butter', 'Bread', 'Coffee', 'Pasta', 'Rice', 'Salt']));

      // Test FR by setting preference
      SharedPreferences.setMockInitialValues({'listeo.locale': 'fr'});
      final storeFr = AppStore();
      await storeFr.init();
      expect(storeFr.staples, containsAll(['Lait', 'Œufs', 'Beurre', 'Pain', 'Café', 'Pâtes', 'Riz', 'Sel']));
    });

    test('Add/Remove global staples', () async {
      final store = AppStore();
      await store.init();

      final initialCount = store.staples.length;

      // Add a staple
      store.addStaple('Chocolat');
      expect(store.staples.length, initialCount + 1);
      expect(store.staples, contains('Chocolat'));

      // Avoid duplicates
      store.addStaple('Chocolat');
      expect(store.staples.length, initialCount + 1);

      // Remove the staple
      store.removeStaple('Chocolat');
      expect(store.staples.length, initialCount);
      expect(store.staples, isNot(contains('Chocolat')));
    });

    test('Add and remove staples to/from shopping lists', () async {
      final store = AppStore();
      await store.init();

      final listId = store.createList('Test List', [], 'green');
      final list = store.listById(listId)!;
      expect(list.blocks, isEmpty);

      // Add staple as a loose item
      store.addLooseItem(listId, name: 'Lait', qty: 1.0, unit: 'pc');
      
      final updatedList = store.listById(listId)!;
      expect(updatedList.blocks.length, 1);
      expect(updatedList.blocks.first.type, BlockType.loose);
      expect(updatedList.blocks.first.items.first.name, 'Lait');

      // Remove staple by name
      store.removeLooseItemByName(listId, 'Lait');

      final finalList = store.listById(listId)!;
      expect(finalList.blocks, isEmpty);
    });
  });
}
