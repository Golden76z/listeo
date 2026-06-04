import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import 'seed.dart';

const _storeKey = 'listeo.v1';

/// Single source of truth for app data + all mutating actions.
/// Mirrors the actions object from the prototype's app.jsx.
class AppStore extends ChangeNotifier {
  List<ShoppingList> lists = [];
  List<Recipe> recipes = [];
  SharedPreferences? _prefs;
  String locale = 'en';

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
        notifyListeners();
        return;
      } catch (_) {/* fall through to seed */}
    }
    lists = seedLists();
    recipes = seedRecipes();
    notifyListeners();
  }

  void _persist() {
    _prefs?.setString('listeo.locale', locale);
    _prefs?.setString(
      _storeKey,
      jsonEncode({
        'lists': lists.map((l) => l.toJson()).toList(),
        'recipes': recipes.map((r) => r.toJson()).toList(),
      }),
    );
  }

  void toggleLocale() {
    locale = locale == 'fr' ? 'en' : 'fr';
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
      {String? name, double? qty, String? unit}) {
    final b = _block(listId, blockId);
    final it = b?.items.cast<Item?>().firstWhere((i) => i?.id == itemId, orElse: () => null);
    if (b == null || it == null) return;
    if (name != null) it.name = name;
    if (unit != null) it.unit = unit;
    if (qty != null) {
      it.qty = qty;
      if (b.isRecipe) it.baseQty = qty * b.baseServings / b.servings;
    }
    _changed();
  }

  void deleteItem(String listId, String blockId, String itemId) {
    final b = _block(listId, blockId);
    if (b == null) return;
    b.items.removeWhere((i) => i.id == itemId);
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
  void saveRecipe({String? id, String? existingId, required String name, required int servings, required String tone, required List<Item> items, List<String>? instructions}) {
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
      }
    } else {
      recipes.insert(0, Recipe(
        id: id ?? uid('r'),
        name: name.trim(),
        servings: servings,
        tone: tone,
        items: items.map((it) => Item(id: uid(), name: it.name, qty: it.qty, unit: it.unit)).toList(),
        instructions: instructions ?? const [],
      ));
    }
    _changed();
  }

  void deleteRecipe(String id) {
    recipes.removeWhere((r) => r.id == id);
    _changed();
  }
}
