import 'package:flutter_test/flutter_test.dart';
import 'package:listeo/data/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Pantry Inventory & Profile Integration Tests', () {
    test('Inventory seeding and initialization based on locale', () async {
      final store = AppStore();
      
      // Default English
      await store.init();
      expect(store.inventory, isNotEmpty);
      expect(
        store.inventory.map((it) => it.name).toList(),
        containsAll(['Milk', 'Eggs', 'Butter', 'Salt', 'Sugar', 'Coffee', 'Rice', 'Pasta']),
      );

      // French seeding
      SharedPreferences.setMockInitialValues({'listeo.locale': 'fr'});
      final storeFr = AppStore();
      await storeFr.init();
      expect(storeFr.inventory, isNotEmpty);
      expect(
        storeFr.inventory.map((it) => it.name).toList(),
        containsAll(['Lait', 'Œufs', 'Beurre', 'Sel', 'Sucre', 'Café', 'Riz', 'Pâtes']),
      );
    });

    test('Add, toggle, rename, and delete inventory items', () async {
      final store = AppStore();
      await store.init();

      final initialLength = store.inventory.length;

      // Add unique item
      store.addInventoryItem('Chocolat');
      expect(store.inventory.length, initialLength + 1);
      expect(store.inventory.any((it) => it.name == 'Chocolat'), isTrue);

      // Add duplicate (should be ignored)
      store.addInventoryItem('chocolat');
      expect(store.inventory.length, initialLength + 1);

      // Find item and verify default state is in stock
      final added = store.inventory.firstWhere((it) => it.name == 'Chocolat');
      expect(added.inStock, isTrue);

      // Toggle stock
      store.toggleInventoryItemStock(added.id);
      expect(store.inventory.firstWhere((it) => it.name == 'Chocolat').inStock, isFalse);

      // Rename item
      store.renameInventoryItem(added.id, 'Chocolat Noir');
      expect(store.inventory.any((it) => it.name == 'Chocolat Noir'), isTrue);
      expect(store.inventory.any((it) => it.name == 'Chocolat'), isFalse);

      // Delete item
      store.deleteInventoryItem(added.id);
      expect(store.inventory.length, initialLength);
      expect(store.inventory.any((it) => it.name == 'Chocolat Noir'), isFalse);
    });

    test('Shopping list useInventory toggle and stock matching lookup', () async {
      final store = AppStore();
      await store.init();

      final listId = store.createList('Test List', [], 'green');
      final list = store.listById(listId)!;

      // Initial state
      expect(list.useInventory, isFalse);

      // Toggle useInventory setting
      store.toggleListUseInventory(listId);
      final listUpdated = store.listById(listId)!;
      expect(listUpdated.useInventory, isTrue);

      // Add item to inventory and check lookup
      store.addInventoryItem('Tomato paste', inStock: true);
      expect(store.isItemInStock('Tomato paste'), isTrue);
      expect(store.isItemInStock('tomato paste '), isTrue); // trimmed case-insensitive match
      expect(store.isItemInStock('Milk'), isTrue); // seeded item

      // Set seeded item to out of stock and verify lookup change
      final milk = store.inventory.firstWhere((it) => it.name == 'Milk' || it.name == 'Lait');
      store.toggleInventoryItemStock(milk.id);
      expect(store.isItemInStock(milk.name), isFalse);
    });

    test('computeDeduction logic - quantity subtraction, full deduction, binary fallback', () async {
      final store = AppStore();
      await store.init();

      // Seed inventory with specific items for our test
      // 1. TestButter: having 200g, in stock
      store.addInventoryItem('TestButter', inStock: true, qty: 200.0, unit: 'g');
      // 2. TestCheese: having 300g, in stock
      store.addInventoryItem('TestCheese', inStock: true, qty: 300.0, unit: 'g');
      // 3. TestEggs: having 12 pc, in stock
      store.addInventoryItem('TestEggs', inStock: true, qty: 12.0, unit: 'pc');

      // Test Case 1: Quantity subtraction when units match (need 500g butter, have 200g -> displays 300g)
      final ded1 = store.computeDeduction(
        itemName: 'TestButter',
        neededQty: 500.0,
        neededUnit: 'g',
        useInventory: true,
      );
      expect(ded1.displayQty, equals(300.0));
      expect(ded1.inStock, isFalse);
      expect(ded1.subtractionLabel, contains('-200 g'));

      // Test Case 2: Full deduction when stock exceeds need (need 100g cheese, have 300g -> displays 0g, inStock true)
      final ded2 = store.computeDeduction(
        itemName: 'TestCheese',
        neededQty: 100.0,
        neededUnit: 'g',
        useInventory: true,
      );
      expect(ded2.displayQty, equals(0.0));
      expect(ded2.inStock, isTrue);
      expect(ded2.subtractionLabel, isEmpty);

      // Test Case 3: Binary fallback when units mismatch (need 6 box eggs, have 12 pc in inventory -> inStock true)
      final ded3 = store.computeDeduction(
        itemName: 'TestEggs',
        neededQty: 6.0,
        neededUnit: 'box',
        useInventory: true,
      );
      expect(ded3.displayQty, equals(6.0));
      expect(ded3.inStock, isTrue);
      expect(ded3.subtractionLabel, isEmpty);

      // Test Case 4: When useInventory is false, no deduction should happen
      final ded4 = store.computeDeduction(
        itemName: 'TestButter',
        neededQty: 500.0,
        neededUnit: 'g',
        useInventory: false,
      );
      expect(ded4.displayQty, equals(500.0));
      expect(ded4.inStock, isFalse);
      expect(ded4.subtractionLabel, isEmpty);

      // Test Case 5: When item is out of stock in inventory, no deduction should happen
      // Find the butter inventory item and mark it out of stock
      final butterInv = store.getMatchingInventoryItem('TestButter')!;
      store.toggleInventoryItemStock(butterInv.id);
      final ded5 = store.computeDeduction(
        itemName: 'TestButter',
        neededQty: 500.0,
        neededUnit: 'g',
        useInventory: true,
      );
      expect(ded5.displayQty, equals(500.0));
      expect(ded5.inStock, isFalse);
      expect(ded5.subtractionLabel, isEmpty);
    });
  });
}
