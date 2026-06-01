/// Core data models for Listeo: Item, Block (recipe folder / loose section),
/// ShoppingList, Recipe. All are mutable plain objects with JSON (de)serialization
/// to mirror the prototype's localStorage shape.

import 'dart:math';
import 'unit.dart';

final _rng = Random();

/// Short unique id, e.g. "it_x9f2a3k4z".
String uid([String prefix = 'id']) {
  final a = _rng.nextDouble().toString().substring(2);
  final b = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
  final tail = (a + b);
  return '${prefix}_${tail.substring(0, min(9, tail.length))}';
}

class Item {
  String id;
  String name;
  double qty;
  String unit;
  bool checked;

  /// Only present on items inside a recipe block — the quantity at baseServings.
  double? baseQty;

  Item({
    required this.id,
    required this.name,
    required this.qty,
    required this.unit,
    this.checked = false,
    this.baseQty,
  });

  Item copyWith({
    String? name,
    double? qty,
    String? unit,
    bool? checked,
    double? baseQty,
  }) =>
      Item(
        id: id,
        name: name ?? this.name,
        qty: qty ?? this.qty,
        unit: unit ?? this.unit,
        checked: checked ?? this.checked,
        baseQty: baseQty ?? this.baseQty,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'qty': qty,
        'unit': unit,
        'checked': checked,
        if (baseQty != null) 'baseQty': baseQty,
      };

  factory Item.fromJson(Map<String, dynamic> j) => Item(
        id: j['id'] as String,
        name: j['name'] as String,
        qty: (j['qty'] as num).toDouble(),
        unit: j['unit'] as String,
        checked: j['checked'] as bool? ?? false,
        baseQty: (j['baseQty'] as num?)?.toDouble(),
      );
}

enum BlockType { recipe, loose }

class Block {
  String id;
  BlockType type;
  String name;
  List<Item> items;

  // recipe-only fields
  String? tone;
  String? recipeId;
  int baseServings;
  int servings;

  Block({
    required this.id,
    required this.type,
    required this.name,
    required this.items,
    this.tone,
    this.recipeId,
    this.baseServings = 1,
    this.servings = 1,
  });

  bool get isRecipe => type == BlockType.recipe;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type == BlockType.recipe ? 'recipe' : 'loose',
        'name': name,
        'items': items.map((i) => i.toJson()).toList(),
        if (type == BlockType.recipe) ...{
          'tone': tone,
          'recipeId': recipeId,
          'baseServings': baseServings,
          'servings': servings,
        },
      };

  factory Block.fromJson(Map<String, dynamic> j) => Block(
        id: j['id'] as String,
        type: j['type'] == 'recipe' ? BlockType.recipe : BlockType.loose,
        name: j['name'] as String,
        items: (j['items'] as List)
            .map((e) => Item.fromJson(e as Map<String, dynamic>))
            .toList(),
        tone: j['tone'] as String?,
        recipeId: j['recipeId'] as String?,
        baseServings: (j['baseServings'] as num?)?.toInt() ?? 1,
        servings: (j['servings'] as num?)?.toInt() ?? 1,
      );
}

class ShoppingList {
  String id;
  String name;
  String tone;
  int createdAt;
  List<Block> blocks;

  ShoppingList({
    required this.id,
    required this.name,
    required this.tone,
    required this.createdAt,
    required this.blocks,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tone': tone,
        'createdAt': createdAt,
        'blocks': blocks.map((b) => b.toJson()).toList(),
      };

  factory ShoppingList.fromJson(Map<String, dynamic> j) => ShoppingList(
        id: j['id'] as String,
        name: j['name'] as String,
        tone: j['tone'] as String? ?? 'green',
        createdAt: (j['createdAt'] as num).toInt(),
        blocks: (j['blocks'] as List)
            .map((e) => Block.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class Recipe {
  String id;
  String name;
  int servings;
  String tone;
  List<Item> items;

  Recipe({
    required this.id,
    required this.name,
    required this.servings,
    required this.tone,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'servings': servings,
        'tone': tone,
        'items': items.map((i) => i.toJson()).toList(),
      };

  factory Recipe.fromJson(Map<String, dynamic> j) => Recipe(
        id: j['id'] as String,
        name: j['name'] as String,
        servings: (j['servings'] as num).toInt(),
        tone: j['tone'] as String? ?? 'green',
        items: (j['items'] as List)
            .map((e) => Item.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ── transforms ───────────────────────────────────────────────

/// Build a recipe block placed inside a list. Keeps baseQty + a derived qty.
Block recipeToBlock(Recipe recipe, int servings) {
  final s = servings;
  final f = s / recipe.servings;
  return Block(
    id: uid('blk'),
    type: BlockType.recipe,
    name: recipe.name,
    tone: recipe.tone,
    recipeId: recipe.id,
    baseServings: recipe.servings,
    servings: s,
    items: recipe.items
        .map((it) => Item(
              id: uid('it'),
              name: it.name,
              unit: it.unit,
              baseQty: it.qty,
              qty: roundQty(it.qty * f, it.unit),
              checked: false,
            ))
        .toList(),
  );
}

/// Recompute a recipe block's item quantities for a new serving count.
Block rescaleBlock(Block block, int servings) {
  final f = servings / block.baseServings;
  return Block(
    id: block.id,
    type: block.type,
    name: block.name,
    tone: block.tone,
    recipeId: block.recipeId,
    baseServings: block.baseServings,
    servings: servings,
    items: block.items
        .map((it) => it.copyWith(qty: roundQty((it.baseQty ?? it.qty) * f, it.unit)))
        .toList(),
  );
}

/// Turn a list recipe-block back into a saveable library recipe.
Recipe blockToRecipe(Block block) => Recipe(
      id: uid('r'),
      name: block.name,
      servings: block.servings,
      tone: block.tone ?? 'green',
      items: block.items
          .map((it) => Item(id: uid(), name: it.name, qty: it.qty, unit: it.unit))
          .toList(),
    );

// ── progress + time ──────────────────────────────────────────

class Progress {
  final int done;
  final int total;
  const Progress(this.done, this.total);
  double get pct => total == 0 ? 0 : done / total;
  bool get complete => total > 0 && done == total;
}

Progress listProgress(ShoppingList list) {
  var done = 0, total = 0;
  for (final b in list.blocks) {
    for (final it in b.items) {
      total++;
      if (it.checked) done++;
    }
  }
  return Progress(done, total);
}

String relTime(int ts) {
  final diff = DateTime.now().millisecondsSinceEpoch - ts;
  final h = diff ~/ 3600000;
  if (h < 1) return "à l'instant";
  if (h < 24) return 'il y a $h h';
  final d = h ~/ 24;
  if (d == 1) return 'hier';
  if (d < 7) return 'il y a $d j';
  return 'il y a ${d ~/ 7} sem';
}
