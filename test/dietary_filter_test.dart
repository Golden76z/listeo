import 'package:flutter_test/flutter_test.dart';
import 'package:listeo/models/models.dart';
import 'package:listeo/data/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Dietary & Allergen Filters Tests', () {
    test('Recipe tags JSON serialization & deserialization', () {
      final recipe = Recipe(
        id: 'test_r',
        name: 'Veggie Stew',
        servings: 4,
        tone: 'green',
        items: [],
        tags: ['veggie', 'gluten_free'],
      );

      final json = recipe.toJson();
      expect(json['tags'], equals(['veggie', 'gluten_free']));

      final decoded = Recipe.fromJson(json);
      expect(decoded.tags, equals(['veggie', 'gluten_free']));
    });

    test('AppStore active dietary filters state toggling and clearing', () async {
      final store = AppStore();
      await store.init();

      expect(store.activeDietaryFilters, isEmpty);

      store.toggleDietaryFilter('veggie');
      expect(store.activeDietaryFilters, equals(['veggie']));

      store.toggleDietaryFilter('gluten_free');
      expect(store.activeDietaryFilters, containsAll(['veggie', 'gluten_free']));

      store.toggleDietaryFilter('veggie');
      expect(store.activeDietaryFilters, equals(['gluten_free']));

      store.clearDietaryFilters();
      expect(store.activeDietaryFilters, isEmpty);
    });

    test('AppStore saveRecipe saves custom tags', () async {
      final store = AppStore();
      await store.init();

      store.saveRecipe(
        id: 'new_custom_recipe',
        name: 'Vegan Gluten-Free Waffles',
        servings: 2,
        tone: 'yellow',
        items: [],
        tags: ['veggie', 'gluten_free', 'lactose_free'],
      );

      final saved = store.recipeById('new_custom_recipe');
      expect(saved, isNotNull);
      expect(saved!.tags, containsAll(['veggie', 'gluten_free', 'lactose_free']));

      // Modifying tags
      store.saveRecipe(
        existingId: 'new_custom_recipe',
        name: 'Vegan Waffles (Modified)',
        servings: 2,
        tone: 'yellow',
        items: [],
        tags: ['veggie'],
      );

      final modified = store.recipeById('new_custom_recipe');
      expect(modified!.tags, equals(['veggie']));
    });

    test('Recipe filtering with multiple dietary options', () {
      final r1 = Recipe(id: 'r1', name: 'Veggie Soup', servings: 2, tone: 'green', items: [], tags: ['veggie', 'gluten_free']);
      final r2 = Recipe(id: 'r2', name: 'Beef Stew', servings: 4, tone: 'curry', items: [], tags: ['gluten_free']);
      final r3 = Recipe(id: 'r3', name: 'Vegan Cake', servings: 8, tone: 'sucre', items: [], tags: ['veggie', 'lactose_free']);

      final recipes = [r1, r2, r3];

      // Filter: veggie only
      final veggieOnly = recipes.where((r) => r.tags.contains('veggie')).toList();
      expect(veggieOnly.map((r) => r.id), containsAll(['r1', 'r3']));
      expect(veggieOnly.map((r) => r.id), isNot(contains('r2')));

      // Filter: veggie AND gluten_free
      final filters = ['veggie', 'gluten_free'];
      final filteredVeggieGlutenFree = recipes.where((r) {
        return filters.every((tag) => r.tags.contains(tag));
      }).toList();

      expect(filteredVeggieGlutenFree.length, 1);
      expect(filteredVeggieGlutenFree.first.id, 'r1');
    });
  });
}
