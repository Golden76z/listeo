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
    locale = locale == 'fr' ? 'en' : 'fr';
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
      inventory[idx].inStock = !inventory[idx].inStock;
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
      if (qty != null) inventory[idx].qty = qty;
      if (unit != null) inventory[idx].unit = unit;
      if (inStock != null) inventory[idx].inStock = inStock;
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
          return InventoryDeduction(
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
