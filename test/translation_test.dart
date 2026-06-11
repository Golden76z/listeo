import 'package:flutter_test/flutter_test.dart';
import 'package:listeo/models/models.dart';
import 'package:listeo/data/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Dynamic Data Translation Tests', () {
    test('Translates inventory, staples, recipes, and lists on locale toggle', () async {
      SharedPreferences.setMockInitialValues({'listeo.locale': 'fr'});
      final store = AppStore();
      await store.init();

      // Verify initial state is FR
      expect(store.locale, 'fr');
      expect(store.staples, contains('Lait'));
      expect(store.inventory.map((e) => e.name), contains('Œufs'));

      // Create a list with French items
      final listId = store.createList('Ma liste', [], 'blue');
      store.addLooseItem(listId, name: 'Beurre', qty: 1, unit: 'g');
      
      // Let's add a recipe block to the list
      final recipe = store.recipes.firstWhere((r) => r.name == 'Salade César');
      store.addRecipeBlock(listId, recipe, recipe.servings);

      // Verify recipe details before toggle
      expect(store.recipes.firstWhere((r) => r.id == recipe.id).name, 'Salade César');
      expect(store.recipes.firstWhere((r) => r.id == recipe.id).items.map((i) => i.name), contains('Salade romaine'));

      // Toggle locale to EN
      store.toggleLocale();

      expect(store.locale, 'en');

      // Verify staples are translated
      expect(store.staples, contains('Milk'));

      // Verify inventory is translated
      expect(store.inventory.map((e) => e.name), contains('Eggs'));

      // Verify loose list items are translated
      final updatedList = store.listById(listId)!;
      final looseBlock = updatedList.blocks.firstWhere((b) => b.type == BlockType.loose);
      expect(looseBlock.items.map((i) => i.name), contains('Butter'));

      // Verify recipe blocks in lists are translated
      final recipeBlock = updatedList.blocks.firstWhere((b) => b.type == BlockType.recipe);
      expect(recipeBlock.name, 'Caesar Salad');
      expect(recipeBlock.items.map((i) => i.name), contains('Romaine lettuce'));

      // Verify store recipes are translated
      final updatedRecipe = store.recipes.firstWhere((r) => r.id == recipe.id);
      expect(updatedRecipe.name, 'Caesar Salad');
      expect(updatedRecipe.items.map((i) => i.name), contains('Romaine lettuce'));
      expect(updatedRecipe.instructions.first, contains('Wash and cut the romaine lettuce into pieces.'));

      // Toggle back to FR
      store.toggleLocale();
      expect(store.locale, 'fr');

      // Verify everything is back to FR
      expect(store.staples, contains('Lait'));
      expect(store.inventory.map((e) => e.name), contains('Œufs'));
      
      final listBack = store.listById(listId)!;
      final looseBlockBack = listBack.blocks.firstWhere((b) => b.type == BlockType.loose);
      expect(looseBlockBack.items.map((i) => i.name), contains('Beurre'));

      final recipeBlockBack = listBack.blocks.firstWhere((b) => b.type == BlockType.recipe);
      expect(recipeBlockBack.name, 'Salade césar');
      expect(recipeBlockBack.items.map((i) => i.name), contains('Salade romaine'));

      final recipeBack = store.recipes.firstWhere((r) => r.id == recipe.id);
      expect(recipeBack.name, 'Salade césar');
      expect(recipeBack.items.map((i) => i.name), contains('Salade romaine'));
      expect(recipeBack.instructions.first, contains('Laver et couper la salade romaine en morceaux.'));
    });

    test('Preserves unknown/custom ingredients without breaking', () async {
      SharedPreferences.setMockInitialValues({'listeo.locale': 'fr'});
      final store = AppStore();
      await store.init();

      final listId = store.createList('Ma liste', [], 'blue');
      store.addLooseItem(listId, name: 'IngredientMystere', qty: 2, unit: 'pcs');

      store.toggleLocale();
      
      final updatedList = store.listById(listId)!;
      final looseBlock = updatedList.blocks.firstWhere((b) => b.type == BlockType.loose);
      expect(looseBlock.items.map((i) => i.name), contains('IngredientMystere'));
    });
  });
}
