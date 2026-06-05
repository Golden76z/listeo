import 'package:flutter_test/flutter_test.dart';
import 'package:listeo/models/models.dart';

void main() {
  group('Smart Ingredient Aggregation Tests', () {
    test('consolidateItems should group and sum identical items', () {
      final block1 = Block(
        id: 'b1',
        type: BlockType.recipe,
        name: 'Recipe A',
        items: [
          Item(id: 'i1', name: 'Beurre', qty: 200, unit: 'g'),
          Item(id: 'i2', name: 'Sucre', qty: 100, unit: 'g'),
        ],
      );

      final block2 = Block(
        id: 'b2',
        type: BlockType.recipe,
        name: 'Recipe B',
        items: [
          Item(id: 'i3', name: 'beurre ', qty: 150, unit: 'g'), // spaces & casing
          Item(id: 'i4', name: 'Farine', qty: 250, unit: 'g'),
        ],
      );

      final block3 = Block(
        id: 'b3',
        type: BlockType.loose,
        name: 'En vrac',
        items: [
          Item(id: 'i5', name: 'Beurre', qty: 50, unit: 'g'),
        ],
      );

      final consolidated = consolidateItems([block1, block2, block3]);

      // There should be 3 unique consolidated items: Beurre (200 + 150 + 50 = 400g), Sucre (100g), Farine (250g)
      expect(consolidated.length, equals(3));

      final beurre = consolidated.firstWhere((c) => c.name.toLowerCase().trim() == 'beurre');
      expect(beurre.totalQty, equals(400.0));
      expect(beurre.items.length, equals(3));
      expect(beurre.blocks.length, equals(3));
      expect(beurre.checked, isFalse);

      final sucre = consolidated.firstWhere((c) => c.name.toLowerCase().trim() == 'sucre');
      expect(sucre.totalQty, equals(100.0));
      expect(sucre.items.length, equals(1));
    });

    test('ConsolidatedItem checked status should reflect constituent items', () {
      final item1 = Item(id: 'i1', name: 'Lait', qty: 1, unit: 'L', checked: true);
      final item2 = Item(id: 'i2', name: 'Lait', qty: 2, unit: 'L', checked: false);

      final block = Block(
        id: 'b1',
        type: BlockType.recipe,
        name: 'Recipe',
        items: [item1, item2],
      );

      final consolidated = consolidateItems([block]);
      expect(consolidated.length, equals(1));
      
      final milk = consolidated.first;
      expect(milk.checked, isFalse); // not all are checked

      item2.checked = true;
      expect(milk.checked, isTrue); // now all are checked
    });
  });
}
