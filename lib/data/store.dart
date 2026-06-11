import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import '../models/unit.dart';
import 'seed.dart';
import 'catalog.dart';

const _storeKey = 'listeo.v1';

/// Single source of truth for app data + all mutating actions.
/// Mirrors the actions object from the prototype's app.jsx.
class AppStore extends ChangeNotifier {
  List<ShoppingList> lists = [];
  List<Recipe> recipes = [];
  SharedPreferences? _prefs;
  String locale = 'en';
  List<String> activeDietaryFilters = [];
  List<String> staples = [];
  List<InventoryItem> inventory = [];

  Map<String, List<MealPlanItem>> mealPlan = {
    'monday': [],
    'tuesday': [],
    'wednesday': [],
    'thursday': [],
    'friday': [],
    'saturday': [],
    'sunday': [],
  };

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final deviceLang = PlatformDispatcher.instance.locale.languageCode.toLowerCase();
    final defaultLocale = (deviceLang == 'fr') ? 'fr' : 'en';
    locale = _prefs?.getString('listeo.locale') ?? defaultLocale;
    final raw = _prefs?.getString(_storeKey);
    if (raw != null) {
      try {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        lists = (j['lists'] as List)
            .map((e) => ShoppingList.fromJson(e as Map<String, dynamic>))
            .toList();
        recipes = (j['recipes'] as List)
            .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
            .toList();
        final existingIds = recipes.map((r) => r.id).toSet();
        bool dirty = false;
        for (final sr in seedRecipes()) {
          if (!existingIds.contains(sr.id)) {
            if (locale == 'en') {
              _translateRecipe(sr, 'fr', 'en');
            }
            recipes.add(sr);
            dirty = true;
          }
        }
        if (dirty) {
          _persist();
        }
        final mp = j['mealPlan'] as Map<String, dynamic>?;
        if (mp != null) {
          mealPlan = mp.map((key, value) => MapEntry(
                key,
                (value as List)
                    .map((e) => MealPlanItem.fromJson(e as Map<String, dynamic>))
                    .toList(),
              ));
        }
        final filters = j['activeDietaryFilters'] as List?;
        if (filters != null) {
          activeDietaryFilters = filters.map((e) => e as String).toList();
        }
        final st = j['staples'] as List?;
        if (st != null) {
          staples = st.map((e) => e as String).toList();
        } else {
          staples = locale == 'fr'
              ? ['Lait', 'Œufs', 'Beurre', 'Pain', 'Café', 'Pâtes', 'Riz', 'Sel']
              : ['Milk', 'Eggs', 'Butter', 'Bread', 'Coffee', 'Pasta', 'Rice', 'Salt'];
        }
        final inv = j['inventory'] as List?;
        if (inv != null) {
          inventory = inv.map((e) => InventoryItem.fromJson(e as Map<String, dynamic>)).toList();
        } else {
          inventory = _seedInventory();
        }
        notifyListeners();
        return;
      } catch (_) {/* fall through to seed */}
    }
    lists = seedLists();
    recipes = seedRecipes();
    if (locale == 'en') {
      _translateAllData('fr', 'en');
    }
    staples = locale == 'fr'
        ? ['Lait', 'Œufs', 'Beurre', 'Pain', 'Café', 'Pâtes', 'Riz', 'Sel']
        : ['Milk', 'Eggs', 'Butter', 'Bread', 'Coffee', 'Pasta', 'Rice', 'Salt'];
    inventory = _seedInventory();
    notifyListeners();
  }

  void _persist() {
    _prefs?.setString('listeo.locale', locale);
    _prefs?.setString(
      _storeKey,
      jsonEncode({
        'lists': lists.map((l) => l.toJson()).toList(),
        'recipes': recipes.map((r) => r.toJson()).toList(),
        'mealPlan': mealPlan.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList())),
        'activeDietaryFilters': activeDietaryFilters,
        'staples': staples,
        'inventory': inventory.map((e) => e.toJson()).toList(),
      }),
    );
  }

  void toggleLocale() {
    final oldLocale = locale;
    locale = locale == 'fr' ? 'en' : 'fr';
    _translateAllData(oldLocale, locale);
    _changed();
  }

  void toggleDietaryFilter(String tag) {
    if (activeDietaryFilters.contains(tag)) {
      activeDietaryFilters.remove(tag);
    } else {
      activeDietaryFilters.add(tag);
    }
    _changed();
  }

  void clearDietaryFilters() {
    activeDietaryFilters.clear();
    _changed();
  }

  void _changed() {
    notifyListeners();
    _persist();
  }


  // ── lookups ───────────────────────────────────────────────
  ShoppingList? listById(String id) =>
      lists.cast<ShoppingList?>().firstWhere((l) => l?.id == id, orElse: () => null);
  Recipe? recipeById(String id) =>
      recipes.cast<Recipe?>().firstWhere((r) => r?.id == id, orElse: () => null);
  Block? _block(String listId, String blockId) {
    final l = listById(listId);
    if (l == null) return null;
    return l.blocks.cast<Block?>().firstWhere((b) => b?.id == blockId, orElse: () => null);
  }

  List<Block> _ordered(List<Block> blocks) => [
        ...blocks.where((b) => b.isRecipe),
        ...blocks.where((b) => !b.isRecipe),
      ];

  // ── item actions ──────────────────────────────────────────
  void toggleItem(String listId, String blockId, String itemId) {
    final b = _block(listId, blockId);
    final it = b?.items.cast<Item?>().firstWhere((i) => i?.id == itemId, orElse: () => null);
    if (it == null) return;
    it.checked = !it.checked;
    _changed();
  }

  void updateItem(String listId, String blockId, String itemId,
      {String? name, double? qty, String? unit, String? customCategory}) {
    final b = _block(listId, blockId);
    final it = b?.items.cast<Item?>().firstWhere((i) => i?.id == itemId, orElse: () => null);
    if (b == null || it == null) return;
    if (name != null) it.name = name;
    if (unit != null) it.unit = unit;
    if (qty != null) {
      it.qty = qty;
      if (b.isRecipe) it.baseQty = qty * b.baseServings / b.servings;
    }
    it.customCategory = customCategory;
    _changed();
  }

  void deleteItem(String listId, String blockId, String itemId) {
    final b = _block(listId, blockId);
    if (b == null) return;
    b.items.removeWhere((i) => i.id == itemId);
    _changed();
  }

  void deleteConsolidatedItem(String listId, List<String> blockIds, List<String> itemIds) {
    final l = listById(listId);
    if (l == null) return;
    for (var i = 0; i < itemIds.length; i++) {
      final b = l.blocks.firstWhere((blk) => blk.id == blockIds[i], orElse: () => Block(id: '', type: BlockType.loose, name: '', items: []));
      b.items.removeWhere((it) => it.id == itemIds[i]);
    }
    l.blocks.removeWhere((b) => b.items.isEmpty);
    _changed();
  }

  void toggleConsolidatedItem(String listId, List<String> itemIds, bool checked) {
    final l = listById(listId);
    if (l == null) return;
    for (final b in l.blocks) {
      for (final it in b.items) {
        if (itemIds.contains(it.id)) {
          it.checked = checked;
        }
      }
    }
    _changed();
  }

  void updateConsolidatedItem(
    String listId,
    List<String> blockIds,
    List<String> itemIds,
    String name,
    List<double> quantities,
    String unit,
    String category,
  ) {
    final l = listById(listId);
    if (l == null) return;
    
    for (var i = 0; i < itemIds.length; i++) {
      final b = l.blocks.firstWhere((blk) => blk.id == blockIds[i], orElse: () => Block(id: '', type: BlockType.loose, name: '', items: []));
      final it = b.items.firstWhere((item) => item.id == itemIds[i], orElse: () => Item(id: '', name: '', qty: 0, unit: ''));
      if (it.id.isNotEmpty) {
        it.name = name;
        it.qty = quantities[i];
        it.unit = unit;
        it.customCategory = category;
        if (b.isRecipe) {
          it.baseQty = quantities[i] * b.baseServings / b.servings;
        }
      }
    }
    _changed();
  }



  void addLooseItem(String listId, {required String name, required double qty, required String unit}) {
    final l = listById(listId);
    if (l == null) return;
    final newItem = Item(id: uid('it'), name: name, qty: qty, unit: unit);
    final loose = l.blocks.cast<Block?>().firstWhere((b) => b?.type == BlockType.loose, orElse: () => null);
    if (loose != null) {
      loose.items.add(newItem);
    } else {
      l.blocks = _ordered([
        ...l.blocks,
        Block(id: uid('blk'), type: BlockType.loose, name: 'En vrac', items: [newItem]),
      ]);
    }
    _changed();
  }

  void addItemToBlock(String listId, String blockId,
      {required String name, required double qty, required String unit}) {
    final b = _block(listId, blockId);
    if (b == null) return;
    final newItem = Item(id: uid('it'), name: name, qty: qty, unit: unit);
    if (b.isRecipe) newItem.baseQty = qty * b.baseServings / b.servings;
    b.items.add(newItem);
    _changed();
  }

  // ── recipe blocks ─────────────────────────────────────────
  void addRecipeBlock(String listId, Recipe recipe, int servings) {
    final l = listById(listId);
    if (l == null) return;
    l.blocks = _ordered([...l.blocks, recipeToBlock(recipe, servings)]);
    _changed();
  }

  void addAdhocDish(String listId, {required String name, required int servings, required String tone, required List<Item> items, required bool saveLib}) {
    final recipe = Recipe(
      id: uid('r'),
      name: name.trim(),
      servings: servings,
      tone: tone,
      items: items.map((it) => Item(id: uid(), name: it.name, qty: it.qty, unit: it.unit)).toList(),
    );
    final l = listById(listId);
    if (l != null) {
      l.blocks = _ordered([...l.blocks, recipeToBlock(recipe, servings)]);
    }
    if (saveLib) recipes.insert(0, recipe);
    _changed();
  }

  void setBlockServings(String listId, String blockId, int servings) {
    final l = listById(listId);
    if (l == null) return;
    final idx = l.blocks.indexWhere((b) => b.id == blockId);
    if (idx < 0) return;
    l.blocks[idx] = rescaleBlock(l.blocks[idx], servings);
    _changed();
  }

  void renameBlock(String listId, String blockId, String name) {
    final b = _block(listId, blockId);
    if (b == null) return;
    b.name = name;
    _changed();
  }

  void deleteBlock(String listId, String blockId) {
    final l = listById(listId);
    if (l == null) return;
    l.blocks.removeWhere((b) => b.id == blockId);
    _changed();
  }

  void saveBlockAsRecipe(String listId, Block block) {
    recipes.insert(0, blockToRecipe(block));
    _changed();
  }

  // ── lists ─────────────────────────────────────────────────
  String createList(String name, List<String> recipeIds, String tone) {
    final id = uid('l');
    final chosen = recipeIds.map(recipeById).whereType<Recipe>().toList();
    final blocks = chosen.map((r) => recipeToBlock(r, r.servings)).toList();
    lists.insert(0, ShoppingList(
      id: id,
      name: name,
      tone: tone,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      blocks: blocks,
    ));
    _changed();
    return id;
  }

  void renameList(String listId, String name) {
    final l = listById(listId);
    if (l == null) return;
    l.name = name;
    _changed();
  }

  void changeListTone(String listId, String tone) {
    final l = listById(listId);
    if (l == null) return;
    l.tone = tone;
    _changed();
  }

  void deleteList(String listId) {
    lists.removeWhere((l) => l.id == listId);
    _changed();
  }

  void duplicateList(String listId) {
    final idx = lists.indexWhere((l) => l.id == listId);
    if (idx < 0) return;
    final src = lists[idx];
    final copy = ShoppingList.fromJson(jsonDecode(jsonEncode(src.toJson())) as Map<String, dynamic>);
    copy.id = uid('l');
    copy.name = '${src.name} (copie)';
    copy.createdAt = DateTime.now().millisecondsSinceEpoch;
    for (final b in copy.blocks) {
      b.id = uid('blk');
      for (final it in b.items) {
        it.id = uid('it');
        it.checked = false;
      }
    }
    lists.insert(idx + 1, copy);
    _changed();
  }

  void clearCheckedItems(String listId) {
    final l = listById(listId);
    if (l == null) return;
    for (final b in l.blocks) {
      b.items.removeWhere((it) => it.checked);
    }
    l.blocks.removeWhere((b) => b.items.isEmpty);
    _changed();
  }

  void uncheckAllItems(String listId) {
    final l = listById(listId);
    if (l == null) return;
    for (final b in l.blocks) {
      for (final it in b.items) {
        it.checked = false;
      }
    }
    _changed();
  }

  // ── recipes ───────────────────────────────────────────────
  void saveRecipe({String? id, String? existingId, required String name, required int servings, required String tone, required List<Item> items, List<String>? instructions, List<String>? tags}) {
    if (existingId != null) {
      final r = recipeById(existingId);
      if (r != null) {
        r.name = name.trim();
        r.servings = servings;
        r.tone = tone;
        r.items = items.map((it) => Item(id: uid(), name: it.name, qty: it.qty, unit: it.unit)).toList();
        if (instructions != null) {
          r.instructions = instructions;
        }
        if (tags != null) {
          r.tags = tags;
        }
      }
    } else {
      recipes.insert(0, Recipe(
        id: id ?? uid('r'),
        name: name.trim(),
        servings: servings,
        tone: tone,
        items: items.map((it) => Item(id: uid(), name: it.name, qty: it.qty, unit: it.unit)).toList(),
        instructions: instructions ?? const [],
        tags: tags ?? const [],
      ));
    }
    _changed();
  }

  void deleteRecipe(String id) {
    recipes.removeWhere((r) => r.id == id);
    _changed();
  }

  // ── meal plan actions ─────────────────────────────────────
  void planMeal(String day, String recipeId, int servings) {
    mealPlan.putIfAbsent(day, () => []).add(MealPlanItem(recipeId: recipeId, servings: servings));
    _changed();
  }

  void removeMeal(String day, int index) {
    final list = mealPlan[day];
    if (list != null && index >= 0 && index < list.length) {
      list.removeAt(index);
      _changed();
    }
  }

  void updateMealServings(String day, int index, int servings) {
    final list = mealPlan[day];
    if (list != null && index >= 0 && index < list.length) {
      list[index] = MealPlanItem(recipeId: list[index].recipeId, servings: servings);
      _changed();
    }
  }

  void clearMealPlan() {
    for (final day in mealPlan.keys) {
      mealPlan[day] = [];
    }
    _changed();
  }

  String generateListFromPlanner(String name, String tone) {
    final id = uid('l');
    final List<Block> blocks = [];

    const dayOrder = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    for (final day in dayOrder) {
      final items = mealPlan[day] ?? [];
      for (final scheduled in items) {
        final r = recipeById(scheduled.recipeId);
        if (r != null) {
          blocks.add(recipeToBlock(r, scheduled.servings));
        }
      }
    }

    lists.insert(
      0,
      ShoppingList(
        id: id,
        name: name,
        tone: tone,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        blocks: blocks,
      ),
    );
    _changed();
    return id;
  }

  List<String> getRecipeInstructions(String recipeId) {
    final r = recipeById(recipeId);
    if (r != null && r.instructions.isNotEmpty) return r.instructions;

    try {
      final cr = kCatalogRecipes.firstWhere((x) => x.id == recipeId);
      return locale == 'fr' ? cr.instructionsFr : cr.instructionsEn;
    } catch (_) {}

    return const [];
  }

  void addStaple(String name) {
    final clean = name.trim();
    if (clean.isNotEmpty && !staples.contains(clean)) {
      staples.add(clean);
      _changed();
    }
  }

  void removeStaple(String name) {
    if (staples.contains(name)) {
      staples.remove(name);
      _changed();
    }
  }

  void removeLooseItemByName(String listId, String name) {
    final l = listById(listId);
    if (l == null) return;
    final nameLower = name.toLowerCase().trim();
    for (final b in l.blocks) {
      b.items.removeWhere((it) => it.name.toLowerCase().trim() == nameLower);
    }
    l.blocks.removeWhere((b) => b.items.isEmpty);
    _changed();
  }

  List<InventoryItem> _seedInventory() {
    if (locale == 'fr') {
      return [
        InventoryItem(id: uid('inv'), name: 'Lait', qty: 1.0, unit: 'L', inStock: true),
        InventoryItem(id: uid('inv'), name: 'Œufs', qty: 6.0, unit: 'pc', inStock: true),
        InventoryItem(id: uid('inv'), name: 'Beurre', qty: 250.0, unit: 'g', inStock: true),
        InventoryItem(id: uid('inv'), name: 'Sel', qty: 500.0, unit: 'g', inStock: true),
        InventoryItem(id: uid('inv'), name: 'Sucre', qty: 1.0, unit: 'kg', inStock: true),
        InventoryItem(id: uid('inv'), name: 'Café', qty: 250.0, unit: 'g', inStock: true),
        InventoryItem(id: uid('inv'), name: 'Riz', qty: 1.0, unit: 'kg', inStock: true),
        InventoryItem(id: uid('inv'), name: 'Pâtes', qty: 500.0, unit: 'g', inStock: true),
      ];
    } else {
      return [
        InventoryItem(id: uid('inv'), name: 'Milk', qty: 1.0, unit: 'L', inStock: true),
        InventoryItem(id: uid('inv'), name: 'Eggs', qty: 6.0, unit: 'pc', inStock: true),
        InventoryItem(id: uid('inv'), name: 'Butter', qty: 250.0, unit: 'g', inStock: true),
        InventoryItem(id: uid('inv'), name: 'Salt', qty: 500.0, unit: 'g', inStock: true),
        InventoryItem(id: uid('inv'), name: 'Sugar', qty: 1.0, unit: 'kg', inStock: true),
        InventoryItem(id: uid('inv'), name: 'Coffee', qty: 250.0, unit: 'g', inStock: true),
        InventoryItem(id: uid('inv'), name: 'Rice', qty: 1.0, unit: 'kg', inStock: true),
        InventoryItem(id: uid('inv'), name: 'Pasta', qty: 500.0, unit: 'g', inStock: true),
      ];
    }
  }

  void seedFullPantry() {
    final List<Map<String, dynamic>> items = locale == 'fr' ? [
      {'name': 'Spaghetti', 'qty': 500.0, 'unit': 'g'},
      {'name': 'Lardons', 'qty': 200.0, 'unit': 'g'},
      {'name': 'Oeufs', 'qty': 12.0, 'unit': 'pc'},
      {'name': 'Parmesan', 'qty': 150.0, 'unit': 'g'},
      {'name': 'Sel', 'qty': 500.0, 'unit': 'g'},
      {'name': 'Poivre', 'qty': 50.0, 'unit': 'g'},
      {'name': 'Filet de poulet', 'qty': 600.0, 'unit': 'g'},
      {'name': 'Oignon', 'qty': 4.0, 'unit': 'pc'},
      {'name': 'Lait de coco', 'qty': 400.0, 'unit': 'ml'},
      {'name': 'Pâte de curry', 'qty': 1.0, 'unit': 'cas'},
      {'name': 'Huile d\'olive', 'qty': 1.0, 'unit': 'L'},
      {'name': 'Riz', 'qty': 1.0, 'unit': 'kg'},
      {'name': 'Salade', 'qty': 2.0, 'unit': 'pc'},
      {'name': 'Tomates', 'qty': 6.0, 'unit': 'pc'},
      {'name': 'Concombre', 'qty': 2.0, 'unit': 'pc'},
      {'name': 'Avocat', 'qty': 4.0, 'unit': 'pc'},
      {'name': 'Citron', 'qty': 3.0, 'unit': 'pc'},
      {'name': 'Pois chiches', 'qty': 400.0, 'unit': 'g'},
      {'name': 'Ail', 'qty': 1.0, 'unit': 'tête'},
      {'name': 'Eau', 'qty': 1.0, 'unit': 'L'},
      {'name': 'Chocolat', 'qty': 400.0, 'unit': 'g'},
      {'name': 'Beurre', 'qty': 500.0, 'unit': 'g'},
      {'name': 'Sucre', 'qty': 1.0, 'unit': 'kg'},
      {'name': 'Farine', 'qty': 1.0, 'unit': 'kg'},
      {'name': 'Pain', 'qty': 2.0, 'unit': 'pc'},
      {'name': 'Café', 'qty': 250.0, 'unit': 'g'},
      {'name': 'Lait', 'qty': 1.0, 'unit': 'L'},
    ] : [
      {'name': 'Spaghetti', 'qty': 500.0, 'unit': 'g'},
      {'name': 'Bacon', 'qty': 200.0, 'unit': 'g'},
      {'name': 'Eggs', 'qty': 12.0, 'unit': 'pc'},
      {'name': 'Parmesan cheese', 'qty': 150.0, 'unit': 'g'},
      {'name': 'Salt', 'qty': 500.0, 'unit': 'g'},
      {'name': 'Black pepper', 'qty': 50.0, 'unit': 'g'},
      {'name': 'Chicken breast', 'qty': 600.0, 'unit': 'g'},
      {'name': 'Onion', 'qty': 4.0, 'unit': 'pc'},
      {'name': 'Coconut milk', 'qty': 400.0, 'unit': 'ml'},
      {'name': 'Curry paste', 'qty': 1.0, 'unit': 'cas'},
      {'name': 'Olive oil', 'qty': 1.0, 'unit': 'L'},
      {'name': 'Rice', 'qty': 1.0, 'unit': 'kg'},
      {'name': 'Salad', 'qty': 2.0, 'unit': 'pc'},
      {'name': 'Tomatoes', 'qty': 6.0, 'unit': 'pc'},
      {'name': 'Cucumber', 'qty': 2.0, 'unit': 'pc'},
      {'name': 'Avocado', 'qty': 4.0, 'unit': 'pc'},
      {'name': 'Lemon', 'qty': 3.0, 'unit': 'pc'},
      {'name': 'Chickpeas', 'qty': 400.0, 'unit': 'g'},
      {'name': 'Garlic', 'qty': 1.0, 'unit': 'head'},
      {'name': 'Water', 'qty': 1.0, 'unit': 'L'},
      {'name': 'Chocolate', 'qty': 400.0, 'unit': 'g'},
      {'name': 'Butter', 'qty': 500.0, 'unit': 'g'},
      {'name': 'Sugar', 'qty': 1.0, 'unit': 'kg'},
      {'name': 'Flour', 'qty': 1.0, 'unit': 'kg'},
      {'name': 'Bread', 'qty': 2.0, 'unit': 'pc'},
      {'name': 'Coffee', 'qty': 250.0, 'unit': 'g'},
      {'name': 'Milk', 'qty': 1.0, 'unit': 'L'},
    ];

    for (final item in items) {
      final name = item['name'] as String;
      final qty = item['qty'] as double;
      final unit = item['unit'] as String;
      final idx = inventory.indexWhere((it) => it.name.toLowerCase().trim() == name.toLowerCase().trim());
      if (idx != -1) {
        inventory[idx].inStock = true;
        inventory[idx].qty = qty;
        inventory[idx].unit = unit;
      } else {
        inventory.add(InventoryItem(
          id: uid('inv'),
          name: name,
          qty: qty,
          unit: unit,
          inStock: true,
        ));
      }
    }
    _changed();
  }

  void clearInventory() {
    inventory.clear();
    _changed();
  }

  void addInventoryItem(String name, {bool inStock = true, double qty = 1.0, String unit = 'pc'}) {
    final clean = name.trim();
    if (clean.isEmpty) return;
    final nameLower = clean.toLowerCase();
    final exists = inventory.any((it) => it.name.toLowerCase() == nameLower);
    if (!exists) {
      inventory.add(InventoryItem(id: uid('inv'), name: clean, inStock: inStock, qty: qty, unit: unit));
      _changed();
    }
  }

  void toggleInventoryItemStock(String id) {
    final idx = inventory.indexWhere((it) => it.id == id);
    if (idx != -1) {
      final newInStock = !inventory[idx].inStock;
      inventory[idx].inStock = newInStock;
      if (newInStock && inventory[idx].qty <= 0) {
        inventory[idx].qty = 1.0;
      }
      _changed();
    }
  }

  void renameInventoryItem(String id, String name) {
    updateInventoryItem(id, name: name);
  }

  void updateInventoryItem(String id, {String? name, double? qty, String? unit, bool? inStock}) {
    final idx = inventory.indexWhere((it) => it.id == id);
    if (idx != -1) {
      if (name != null && name.trim().isNotEmpty) inventory[idx].name = name.trim();
      if (qty != null) {
        inventory[idx].qty = qty;
        if (qty <= 0) {
          inventory[idx].inStock = false;
        } else if (qty > 0 && !inventory[idx].inStock) {
          inventory[idx].inStock = true;
        }
      }
      if (unit != null) inventory[idx].unit = unit;
      if (inStock != null) {
        inventory[idx].inStock = inStock;
        if (inStock && inventory[idx].qty <= 0) {
          inventory[idx].qty = 1.0;
        }
      }
      _changed();
    }
  }

  void deleteInventoryItem(String id) {
    inventory.removeWhere((it) => it.id == id);
    _changed();
  }

  void toggleListUseInventory(String listId) {
    final l = listById(listId);
    if (l != null) {
      l.useInventory = !l.useInventory;
      _changed();
    }
  }

  bool isItemInStock(String name) {
    final clean = name.toLowerCase().trim();
    return inventory.any((it) => it.inStock && it.name.toLowerCase().trim() == clean);
  }

  InventoryItem? getMatchingInventoryItem(String name) {
    final clean = name.toLowerCase().trim();
    try {
      return inventory.firstWhere((it) => it.name.toLowerCase().trim() == clean);
    } catch (_) {
      return null;
    }
  }

  InventoryDeduction computeDeduction({
    required String itemName,
    required double neededQty,
    required String neededUnit,
    required bool useInventory,
  }) {
    if (!useInventory) {
      return InventoryDeduction(
        displayQty: neededQty,
        inStock: false,
        subtractionLabel: '',
      );
    }

    final invItem = getMatchingInventoryItem(itemName);
    if (invItem != null && invItem.inStock) {
      final unitMatches = invItem.unit.trim().toLowerCase() == neededUnit.trim().toLowerCase();
      if (unitMatches) {
        final displayQty = (neededQty - invItem.qty).clamp(0.0, double.infinity);
        if (displayQty == 0.0) {
          return const InventoryDeduction(
            displayQty: 0.0,
            inStock: true,
            subtractionLabel: '',
          );
        } else {
          final f = fmtQty(invItem.qty, neededUnit);
          final subtractionLabel = locale == 'fr'
              ? '(-${f.value}${f.suffix} de l\'inventaire)'
              : '(-${f.value}${f.suffix} from inventory)';
          return InventoryDeduction(
            displayQty: displayQty,
            inStock: false,
            subtractionLabel: subtractionLabel,
          );
        }
      } else {
        return InventoryDeduction(
          displayQty: neededQty,
          inStock: true,
          subtractionLabel: '',
        );
      }
    }

    return InventoryDeduction(
      displayQty: neededQty,
      inStock: false,
      subtractionLabel: '',
    );
  }

  List<FridgeMatch> getFridgeMatches() {
    final List<FridgeMatch> matches = [];

    for (final recipe in kCatalogRecipes) {
      int matchCount = 0;
      final List<CatalogIngredient> missing = [];

      for (final ing in recipe.ingredients) {
        final hasFr = isItemInStock(ing.nameFr);
        final hasEn = isItemInStock(ing.nameEn);
        if (hasFr || hasEn) {
          matchCount++;
        } else {
          missing.add(ing);
        }
      }

      final total = recipe.ingredients.length;
      final ratio = total > 0 ? matchCount / total : 0.0;

      matches.add(FridgeMatch(
        recipe: recipe,
        matchCount: matchCount,
        totalCount: total,
        matchRatio: ratio,
        missingIngredients: missing,
      ));
    }

    matches.sort((a, b) {
      final cmp = b.matchRatio.compareTo(a.matchRatio);
      if (cmp != 0) return cmp;
      return b.totalCount.compareTo(a.totalCount);
    });

    return matches;
  }

  final Map<String, String> _recipeFrToEn = {};
  final Map<String, String> _recipeEnToFr = {};
  final Map<String, String> _ingFrToEn = {};
  final Map<String, String> _ingEnToFr = {};
  final Map<String, String> _instFrToEn = {};
  final Map<String, String> _instEnToFr = {};
  bool _translationDictsInitialized = false;

  void _initTranslationDictionaries() {
    if (_translationDictsInitialized) return;
    _translationDictsInitialized = true;

    for (final cr in kCatalogRecipes) {
      final rFr = cr.nameFr.trim();
      final rEn = cr.nameEn.trim();
      if (rFr.isNotEmpty && rEn.isNotEmpty) {
        _recipeFrToEn[rFr.toLowerCase()] = rEn;
        _recipeEnToFr[rEn.toLowerCase()] = rFr;
      }
      for (final ing in cr.ingredients) {
        final iFr = ing.nameFr.trim();
        final iEn = ing.nameEn.trim();
        if (iFr.isNotEmpty && iEn.isNotEmpty) {
          _ingFrToEn[iFr.toLowerCase()] = iEn;
          _ingEnToFr[iEn.toLowerCase()] = iFr;
        }
      }
      final len = cr.instructionsFr.length < cr.instructionsEn.length
          ? cr.instructionsFr.length
          : cr.instructionsEn.length;
      for (int i = 0; i < len; i++) {
        final instFr = cr.instructionsFr[i].trim();
        final instEn = cr.instructionsEn[i].trim();
        if (instFr.isNotEmpty && instEn.isNotEmpty) {
          _instFrToEn[instFr.toLowerCase()] = instEn;
          _instEnToFr[instEn.toLowerCase()] = instFr;
        }
      }
    }

    final seedManualTranslations = {
      'spaghetti bolognaise': 'Spaghetti Bolognese',
      'salade césar': 'Caesar Salad',
      'pancakes': 'Pancakes',
      'curry de pois chiches': 'Chickpea Curry',
      'quiche lorraine': 'Quiche Lorraine',
      'lasagnes bolognaise': 'Beef Lasagne',
      'risotto aux champignons': 'Mushroom Risotto',
      'poulet rôti aux pommes de terre': 'Roast Chicken with Potatoes',
      'ratatouille niçoise': 'Ratatouille',
      'gratin dauphinois': 'Potato Gratin',
      'boeuf bourguignon': 'Beef Bourguignon',
      'cookies aux pépites de chocolat': 'Chocolate Chip Cookies',
      'mousse au chocolat': 'Chocolate Mousse',
      'tarte tatin': 'Tarte Tatin',
      'croque-monsieur': 'Croque-Monsieur',
      'soupe à l\'oignon': 'French Onion Soup',
      'salade niçoise': 'Niçoise Salad',
      'chili con carne': 'Chili con Carne',
      'curry de poulet au coco': 'Coconut Chicken Curry',
      'pâtes au pesto': 'Pesto Pasta',
      'taboulé libanais': 'Lebanese Tabouleh',
      'chow mein aux légumes': 'Vegetable Chow Mein',
      'courses de la semaine': 'Weekly groceries',
      'apéro samedi': 'Saturday apéro',
      'copie': 'copy',
      'en vrac': 'Loose items',
    };

    seedManualTranslations.forEach((fr, en) {
      _recipeFrToEn[fr] = en;
      _recipeEnToFr[en.toLowerCase()] = fr;
    });

    final manualIngs = {
      'viande hachée': 'ground beef',
      'oignon': 'onion',
      'tomates concassées': 'crushed tomatoes',
      'ail': 'garlic',
      'parmesan': 'parmesan cheese',
      'salade romaine': 'romaine lettuce',
      'filet de poulet': 'chicken breast',
      'croûtons': 'croutons',
      'œuf': 'egg',
      'œufs': 'eggs',
      'sucre': 'sugar',
      'levure': 'baking powder',
      'pois chiches': 'chickpeas',
      'lait de coco': 'coconut milk',
      'pâte de curry': 'curry paste',
      'épinards': 'spinach',
      'pâte brisée': 'pie crust',
      'lardons': 'bacon',
      'crème fraîche': 'heavy cream',
      'gruyère râpé': 'grated gruyere',
      'noix de muscade': 'nutmeg',
      'plaques de lasagne': 'lasagna sheets',
      'sauce tomate': 'tomato sauce',
      'beurre': 'butter',
      'farine': 'flour',
      'lait': 'milk',
      'riz arborio': 'arborio rice',
      'champignons': 'mushrooms',
      'bouillon de légumes': 'vegetable broth',
      'vin blanc': 'white wine',
      'poulet entier': 'whole chicken',
      'pommes de terre': 'potatoes',
      'gousses d\'ail': 'garlic cloves',
      'herbes de provence': 'herbs de provence',
      'huile d\'olive': 'olive oil',
      'courgettes': 'zucchini',
      'aubergines': 'eggplants',
      'poivrons': 'bell peppers',
      'tomates': 'tomatoes',
      'crème fraîche liquide': 'heavy whipping cream',
      'gousse d\'ail': 'garlic clove',
      'viande de bœuf': 'beef meat',
      'vin rouge': 'red wine',
      'carottes': 'carrots',
      'oignons': 'onions',
      'bouquet garni': 'bouquet garni',
      'pépites de chocolat': 'chocolate chips',
      'beurre mou': 'softened butter',
      'sucre roux': 'brown sugar',
      'levure chimique': 'baking powder',
      'extrait de vanille': 'vanilla extract',
      'chocolat noir': 'dark chocolate',
      'pommes': 'apples',
      'pâte feuilletée': 'puff pastry',
      'pain de mie': 'sandwich bread',
      'jambon blanc': 'ham',
      'bouillon de bœuf': 'beef broth',
      'thon en boîte': 'canned tuna',
      'haricots verts': 'green beans',
      'anchois': 'anchovies',
      'olives noires': 'black olives',
      'vinaigrette': 'vinaigrette dressing',
      'bœuf haché': 'ground beef',
      'haricots rouges': 'kidney beans',
      'poivron rouge': 'red bell pepper',
      'épices chili': 'chili powder',
      'huile': 'vegetable oil',
      'poivron jaune': 'yellow bell pepper',
      'curry en poudre': 'curry powder',
      'gingembre': 'ginger',
      'pâtes': 'pasta',
      'sauce pesto': 'pesto sauce',
      'tomates cerises': 'cherry tomatoes',
      'pignons de pin': 'pine nuts',
      'boulghour': 'bulgur',
      'persil plat': 'flat-leaf parsley',
      'menthe fraîche': 'fresh mint',
      'oignons nouveaux': 'scallions',
      'jus de citron': 'lemon juice',
      'nouilles chinoises': 'chinese noodles',
      'chou chinois': 'napa cabbage',
      'carotte': 'carrot',
      'sauce soja': 'soy sauce',
      'huile de sésame': 'sesame oil',
      'bananes': 'bananas',
      'café moulu': 'ground coffee',
      'pain complet': 'whole wheat bread',
      'yaourts nature': 'plain yogurts',
      'chips': 'potato chips',
      'olives': 'olives',
      'houmous': 'hummus',
      'citrons': 'lemons',
      'pain': 'bread',
      'café': 'coffee',
    };

    manualIngs.forEach((fr, en) {
      _ingFrToEn[fr] = en;
      _ingEnToFr[en.toLowerCase()] = fr;
    });

    final manualInstructions = {
      'faire cuire le spaghetti dans de l\'eau bouillante salée.': 'Cook the spaghetti in boiling salted water.',
      'faire revenir l\'oignon et l\'ail hachés dans une poêle avec un filet d\'huile.': 'Sauté the chopped onion and garlic in a pan with a drizzle of oil.',
      'ajouter la viande hachée et la faire dorer.': 'Add the ground beef and brown it.',
      'verser les tomates concassées et laisser mijoter 15 minutes à feu doux.': 'Pour in the crushed tomatoes and simmer for 15 minutes over low heat.',
      'mélanger les pâtes avec la sauce et parsemer généreusement de parmesan.': 'Mix the pasta with the sauce and sprinkle generously with parmesan.',
      'laver et couper la salade romaine en morceaux.': 'Wash and cut the romaine lettuce into pieces.',
      'faire cuire le filet de poulet à la poêle puis le couper en tranches.': 'Cook the chicken breast in a pan and then slice it.',
      'faire cuire les œufs durs (9 minutes dans l\'eau bouillante).': 'Boil the eggs until hard-boiled (9 minutes in boiling water).',
      'dans un grand bol, mélanger la salade, le poulet, les croûtons et le parmesan.': 'In a large bowl, mix the lettuce, chicken, croutons, and parmesan.',
      'ajouter les œufs coupés en deux et assaisonner avec la sauce César.': 'Add the halved eggs and season with Caesar dressing.',
      'mélanger la farine, le sucre et la levure dans un saladier.': 'Mix the flour, sugar, and baking powder in a bowl.',
      'ajouter les œufs et verser le lait petit à petit en fouettant.': 'Add the eggs and pour in the milk gradually while whisking.',
      'faire chauffer une poêle légèrement huilée à feu moyen.': 'Heat a lightly oiled pan over medium heat.',
      'verser une petite louche de pâte et laisser cuire jusqu\'à apparition de bulles.': 'Pour a small ladle of batter and cook until bubbles appear.',
      'retourner le pancake et laisser dorer l\'autre face pendant 1 minute.': 'Flip the pancake and brown the other side for 1 minute.',
      'émincer l\'oignon et le faire revenir dans une sauteuse.': 'Chop the onion and sauté it in a pan.',
      'ajouter la pâte de curry et mélanger pendant 1 minute.': 'Add the curry paste and mix for 1 minute.',
      'ajouter les pois chiches rincés et égouttés, puis verser le lait de coco.': 'Add the rinsed and drained chickpeas, then pour in the coconut milk.',
      'laisser mijoter à feu doux pendant 15 minutes.': 'Simmer over low heat for 15 minutes.',
      'ajouter les épinards en fin de cuisson et mélanger jusqu\'à ce qu\'ils tombent.': 'Add the spinach at the end of cooking and mix until wilted.',
      'préchauffer le four à 180°c. étaler la pâte dans un moule.': 'Preheat the oven to 180°C. Roll out the dough in a pie dish.',
      'faire rissoler les lardons dans une poêle sans matière grasse.': 'Brown the bacon in a pan without any fat.',
      'fouetter les œufs, la crème, le lait et la muscade dans un bol.': 'Whisk the eggs, cream, milk, and nutmeg in a bowl.',
      'disposer les lardons et le fromage sur la pâte, puis verser le mélange.': 'Arrange the bacon and cheese on the dough, then pour the mixture over.',
      'cuire au four pendant 35 minutes jusqu\'à ce qu\'elle soit bien dorée.': 'Bake for 35 minutes until golden brown.',
      'préparer la béchamel en faisant fondre le beurre, ajouter la farine puis incorporer le lait.': 'Prepare the bechamel by melting the butter, adding the flour, then whisking in the milk.',
      'faire revenir l\'oignon et la viande hachée dans une poêle avec un filet d\'huile.': 'Sauté the onion and ground beef in a pan with a drizzle of oil.',
      'ajouter la sauce tomate à la viande et laisser mijoter 10 minutes.': 'Add the tomato sauce to the meat and simmer for 10 minutes.',
      'dans un plat, alterner les couches de lasagnes, bolognaise et béchamel.': 'In a baking dish, alternate layers of lasagna sheets, bolognese sauce, and bechamel.',
      'parsemer de fromage râpé et cuire au four pendant 35 minutes à 180°c.': 'Sprinkle with grated cheese and bake for 35 minutes at 180°C.',
      'faire revenir l\'oignon ciselé dans une casserole avec du beurre.': 'Sauté the chopped onion in a pot with butter.',
      'ajouter les champignons émincés et les faire dorer.': 'Add the sliced mushrooms and brown them.',
      'ajouter le riz arborio et le faire nacrer pendant 2 minutes.': 'Add the Arborio rice and cook until translucent for 2 minutes.',
      'verser le vin blanc, puis ajouter le bouillon chaud louche par louche.': 'Pour in the white wine, then add the hot broth ladle by ladle.',
      'incorporer le parmesan et le reste du beurre hors du feu en fin de cuisson.': 'Stir in the parmesan and the remaining butter off the heat at the end of cooking.',
      'préchauffer le four à 200°c.': 'Preheat the oven to 200°C.',
      'placer le poulet dans un grand plat et répartir des noisettes de beurre dessus.': 'Place the chicken in a large baking dish and dot with butter.',
      'couper les pommes de terre en morceaux et les disposer tout autour du poulet.': 'Cut the potatoes into chunks and arrange them around the chicken.',
      'arroser d\'huile d\'olive, parsemer d\'herbes et disposer l\'ail en chemise.': 'Drizzle with olive oil, sprinkle with herbs, and add the unpeeled garlic cloves.',
      'faire rôtir au four pendant 1h15 en arrosant le poulet régulièrement.': 'Roast in the oven for 1 hour 15 minutes, basting the chicken regularly.',
      'couper tous les légumes en dés réguliers.': 'Cut all the vegetables into even cubes.',
      'faire revenir les oignons et les poivrons dans de l\'huile d\'olive.': 'Sauté the onions and bell peppers in olive oil.',
      'ajouter les aubergines, puis les courgettes dans la cocotte.': 'Add the eggplants, then the zucchini to the pot.',
      'ajouter les tomates concassées et l\'ail écrasé.': 'Add the crushed tomatoes and crushed garlic.',
      'laisser mijoter à couvert et à feu doux pendant 45 minutes.': 'Cover and simmer over low heat for 45 minutes.',
      'préchauffer le four à 160°c. frotter un plat avec de l\'ail.': 'Preheat the oven to 160°C. Rub a baking dish with garlic.',
      'éplucher et couper les pommes de terre en fines rondelles.': 'Peel and slice the potatoes into thin rounds.',
      'faire chauffer le lait, la crème, l\'ail écrasé et la muscade dans une casserole.': 'Heat the milk, cream, crushed garlic, and nutmeg in a saucepan.',
      'disposer les pommes de terre dans le plat et verser le liquide chaud dessus.': 'Arrange the potatoes in the dish and pour the hot liquid over them.',
      'enfourner pour 1h15 de cuisson lente jusqu\'à ce que le gratin soit tendre.': 'Bake for 1 hour 15 minutes until the gratin is tender.',
      'faire dorer la viande dans une cocotte avec un filet d\'huile.': 'Brown the meat in a pot with a drizzle of oil.',
      'ajouter les oignons et les carottes en rondelles, saupoudrer de farine.': 'Add the sliced onions and carrots, then sprinkle with flour.',
      'verser le vin rouge et ajouter le bouquet garni. mijoter 2h30 à feu très doux.': 'Pour in the red wine and add the bouquet garni. Simmer for 2 hours 30 minutes over very low heat.',
      'faire revenir les lardons et les champignons dans une poêle.': 'Sauté the bacon and mushrooms in a pan.',
      'les ajouter à la cocotte 30 minutes avant la fin de la cuisson.': 'Add them to the pot 30 minutes before the end of cooking.',
      'mélanger le beurre mou avec le sucre roux dans un grand saladier.': 'Mix the softened butter with the brown sugar in a large bowl.',
      'ajouter l\'œuf et l\'extrait de vanille, puis bien mélanger.': 'Add the egg and vanilla extract, then mix well.',
      'incorporer la farine, la levure et les pépites de chocolat.': 'Fold in the flour, baking powder, and chocolate chips.',
      'former de petites boules de pâte, les aplatir sur une plaque et cuire 10 min.': 'Form small balls of dough, flatten them on a baking sheet, and bake for 10 minutes.',
      'faire fondre le chocolat avec le beurre à feu très doux.': 'Melt the chocolate with the butter over very low heat.',
      'séparer les blancs des jaunes d\'œufs. ajouter les jaunes au chocolat fondu.': 'Separate the egg whites and yolks. Add the yolks to the melted chocolate.',
      'monter les blancs en neige ferme avec le sucre dans un saladier.': 'Whip the egg whites to stiff peaks with the sugar in a bowl.',
      'incorporer délicatement les blancs en neige au mélange chocolaté.': 'Gently fold the whipped egg whites into the chocolate mixture.',
      'réserver au réfrigérateur au moins 4 heures avant de servir.': 'Refrigerate for at least 4 hours before serving.',
      'faire un caramel à sec avec le sucre directement dans le moule.': 'Make a dry caramel with the sugar directly in the pan.',
      'ajouter le beurre en morceaux, puis les pommes épluchées et coupées en quarts.': 'Add the butter pieces, then the peeled and quartered apples.',
      'laisser cuire 15 minutes sur le feu pour bien caraméliser les pommes.': 'Cook on the stove for 15 minutes to caramelize the apples well.',
      'recouvrir le moule avec la pâte feuilletée en rentrant les bords.': 'Cover the pan with the puff pastry, tucking in the edges.',
      'cuire au four à 180°c pendant 30 minutes, puis démouler immédiatement.': 'Bake at 180°C for 30 minutes, then invert and unmold immediately.',
      'beurrer les tranches de pain de mie sur une face.': 'Butter one side of the sandwich bread slices.',
      'poser une tranche de jambon et du fromage râpé sur le pain.': 'Place a slice of ham and grated cheese on the bread.',
      'refermer avec une seconde tranche de pain beurrée.': 'Close with a second buttered slice of bread.',
      'étaler de la crème fraîche sur le dessus et parsemer de fromage râpé.': 'Spread heavy cream on top and sprinkle with grated cheese.',
      'faire dorer sous le gril du four pendant 10 minutes.': 'Brown under the oven broiler for 10 minutes.',
      'faire revenir les oignons émincés dans le beurre jusqu\'à coloration.': 'Sauté the sliced onions in the butter until browned.',
      'saupoudrer de farine, mélanger puis mouiller avec le bouillon de bœuf.': 'Sprinkle with flour, mix, and pour in the beef broth.',
      'laisser mijoter à couvert pendant 30 minutes à feu doux.': 'Cover and simmer for 30 minutes over low heat.',
      'faire griller les tranches de pain de mie.': 'Toast the sandwich bread slices.',
      'verser la soupe dans des bols, poser le pain, couvrir de fromage et gratiner au four.': 'Pour the soup into bowls, place the bread on top, cover with cheese, and brown in the oven.',
      'faire cuire les œufs durs (9 min) et les haricots verts à l\'eau bouillante.': 'Boil the eggs (9 minutes) and green beans in boiling water.',
      'couper les tomates en quartiers et les œufs durs en deux.': 'Cut the tomatoes into wedges and the hard-boiled eggs in half.',
      'dans un grand plat, disposer les haricots, les tomates et le thon émietté.': 'In a large dish, arrange the green beans, tomatoes, and flaked tuna.',
      'ajouter les œufs durs, les anchois et les olives noires.': 'Add the hard-boiled eggs, anchovies, and black olives.',
      'arroser le tout de vinaigrette bien relevée avant de déguster.': 'Drizzle with well-seasoned vinaigrette dressing before serving.',
      'faire revenir l\'oignon et le poivron émincés dans une cocotte.': 'Sauté the chopped onion and bell pepper in a pot.',
      'ajouter les tomates concassées, les haricots égouttés et les épices.': 'Add the crushed tomatoes, drained kidney beans, and spices.',
      'laisser mijoter à feu doux pendant 40 minutes en remuant de temps en temps.': 'Simmer over low heat for 40 minutes, stirring occasionally.',
      'servir bien chaud, éventuellement accompagné de riz blanc.': 'Serve hot, optionally accompanied by white rice.',
      'couper le poulet et le poivron en dés. émincer l\'oignon.': 'Cut the chicken and bell pepper into cubes. Slice the onion.',
      'faire revenir l\'oignon, l\'ail et le gingembre dans une poêle.': 'Sauté the onion, garlic, and ginger in a pan.',
      'ajouter le poulet et le poivron, puis saupoudrer de curry.': 'Add the chicken and bell pepper, then sprinkle with curry.',
      'verser le lait de coco, mélanger et laisser mijoter 20 minutes à feu moyen.': 'Pour in the coconut milk, mix, and simmer for 20 minutes over medium heat.',
      'servir bien chaud avec du riz basmati.': 'Serve hot with basmati rice.',
      'faire cuire les pâtes dans une grande casserole d\'eau bouillante salée.': 'Cook the pasta in a large pot of boiling salted water.',
      'laver et couper les tomates cerises en deux.': 'Wash and cut the cherry tomatoes in half.',
      'dans un saladier, mélanger les pâtes chaudes égouttées avec la sauce pesto.': 'In a bowl, mix the drained hot pasta with the pesto sauce.',
      'ajouter les tomates cerises et parsemer de parmesan râpé.': 'Add the chocolate cherry tomatoes and sprinkle with grated parmesan.',
      'décorer avec quelques pignons de pin torréfiés.': 'Garnish with a few toasted pine nuts.',
      'faire gonfler le boulghour dans de l\'eau tiède pendant 15 minutes.': 'Let the bulgur soak in warm water for 15 minutes.',
      'laver et hacher très finement le persil plat et la menthe.': 'Wash and finely chop the flat-leaf parsley and mint.',
      'couper les tomates et les oignons nouveaux en très petits dés.': 'Cut the tomatoes and scallions into very small cubes.',
      'mélanger tous les ingrédients dans un saladier.': 'Mix all ingredients in a bowl.',
      'arroser avec le jus de citron et l\'huile d\'olive, puis laisser reposer au frais 2 heures.': 'Drizzle with lemon juice and olive oil, then let rest in the refrigerator for 2 hours.',
      'faire cuire les nouilles et les réserver.': 'Cook the noodles and set them aside.',
      'émincer finement le chou chinois, la carotte et l\'oignon.': 'Thinly slice the napa cabbage, carrot, and onion.',
      'faire sauter les légumes à feu vif dans un wok avec l\'ail haché.': 'Sauté the vegetables over high heat in a wok with the minced garlic.',
      'ajouter les nouilles, la sauce soja et l\'huile de sésame.': 'Add the noodles, soy sauce, and sesame oil.',
      'mélanger énergiquement et faire sauter pendant 3 à 5 minutes.': 'Toss vigorously and stir-fry for 3 to 5 minutes.',
    };

    manualInstructions.forEach((fr, en) {
      _instFrToEn[fr] = en;
      _instEnToFr[en.toLowerCase()] = fr;
    });
  }

  String _translateText(
      String text,
      String from,
      String to,
      Map<String, String> frToEn,
      Map<String, String> enToFr) {
    final clean = text.trim();
    if (clean.isEmpty) return text;
    final lower = clean.toLowerCase();

    String? translated;
    if (from == 'fr') {
      translated = frToEn[lower];
    } else {
      translated = enToFr[lower];
    }

    if (translated != null) {
      if (clean[0] == clean[0].toUpperCase()) {
        return translated[0].toUpperCase() + translated.substring(1);
      }
      return translated;
    }

    return text;
  }

  String _translateIngredient(String name, String from, String to) {
    _initTranslationDictionaries();
    return _translateText(name, from, to, _ingFrToEn, _ingEnToFr);
  }

  String _translateRecipeOrList(String name, String from, String to) {
    _initTranslationDictionaries();
    return _translateText(name, from, to, _recipeFrToEn, _recipeEnToFr);
  }

  String _translateInstruction(String text, String from, String to) {
    _initTranslationDictionaries();
    return _translateText(text, from, to, _instFrToEn, _instEnToFr);
  }

  String _translateLooseBlockName(String name, String from, String to) {
    _initTranslationDictionaries();
    final lower = name.toLowerCase().trim();
    if (lower == 'en vrac' || lower == 'loose' || lower == 'loose items') {
      return to == 'fr' ? 'En vrac' : 'Loose items';
    }
    return name;
  }

  void _translateAllData(String oldLocale, String newLocale) {
    _initTranslationDictionaries();

    // 1. Translate inventory
    for (final it in inventory) {
      it.name = _translateIngredient(it.name, oldLocale, newLocale);
    }

    // 2. Translate staples
    staples = staples.map((st) => _translateIngredient(st, oldLocale, newLocale)).toList();

    // 3. Translate lists
    for (final list in lists) {
      list.name = _translateRecipeOrList(list.name, oldLocale, newLocale);
      for (final block in list.blocks) {
        if (block.type == BlockType.loose) {
          block.name = _translateLooseBlockName(block.name, oldLocale, newLocale);
        } else {
          block.name = _translateRecipeOrList(block.name, oldLocale, newLocale);
        }
        for (final item in block.items) {
          item.name = _translateIngredient(item.name, oldLocale, newLocale);
        }
      }
    }

    // 4. Translate recipes
    for (final recipe in recipes) {
      _translateRecipe(recipe, oldLocale, newLocale);
    }
  }

  void _translateRecipe(Recipe recipe, String oldLocale, String newLocale) {
    recipe.name = _translateRecipeOrList(recipe.name, oldLocale, newLocale);
    for (final item in recipe.items) {
      item.name = _translateIngredient(item.name, oldLocale, newLocale);
    }
    recipe.instructions = recipe.instructions
        .map((inst) => _translateInstruction(inst, oldLocale, newLocale))
        .toList();
  }
}

class FridgeMatch {
  final CatalogRecipe recipe;
  final int matchCount;
  final int totalCount;
  final double matchRatio;
  final List<CatalogIngredient> missingIngredients;

  const FridgeMatch({
    required this.recipe,
    required this.matchCount,
    required this.totalCount,
    required this.matchRatio,
    required this.missingIngredients,
  });
}

class InventoryDeduction {
  final double displayQty;
  final bool inStock;
  final String subtractionLabel;

  const InventoryDeduction({
    required this.displayQty,
    required this.inStock,
    required this.subtractionLabel,
  });
}
