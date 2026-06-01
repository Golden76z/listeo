import '../models/models.dart';

/// Seed recipe library — matches the prototype's defaults.
List<Recipe> seedRecipes() => [
      Recipe(id: 'r_bolo', name: 'Spaghetti bolognaise', servings: 4, tone: 'tomate', items: [
        Item(id: uid(), name: 'Spaghetti', qty: 500, unit: 'g'),
        Item(id: uid(), name: 'Viande hachée', qty: 400, unit: 'g'),
        Item(id: uid(), name: 'Oignon', qty: 1, unit: 'pc'),
        Item(id: uid(), name: 'Tomates concassées', qty: 400, unit: 'g'),
        Item(id: uid(), name: 'Ail', qty: 2, unit: 'pc'),
        Item(id: uid(), name: 'Parmesan', qty: 50, unit: 'g'),
      ]),
      Recipe(id: 'r_cesar', name: 'Salade César', servings: 2, tone: 'salade', items: [
        Item(id: uid(), name: 'Salade romaine', qty: 1, unit: 'pc'),
        Item(id: uid(), name: 'Filet de poulet', qty: 250, unit: 'g'),
        Item(id: uid(), name: 'Croûtons', qty: 80, unit: 'g'),
        Item(id: uid(), name: 'Parmesan', qty: 40, unit: 'g'),
        Item(id: uid(), name: 'Œuf', qty: 2, unit: 'pc'),
      ]),
      Recipe(id: 'r_pancake', name: 'Pancakes', servings: 4, tone: 'sucre', items: [
        Item(id: uid(), name: 'Farine', qty: 250, unit: 'g'),
        Item(id: uid(), name: 'Lait', qty: 300, unit: 'ml'),
        Item(id: uid(), name: 'Œuf', qty: 2, unit: 'pc'),
        Item(id: uid(), name: 'Sucre', qty: 50, unit: 'g'),
        Item(id: uid(), name: 'Levure', qty: 1, unit: 'pc'),
      ]),
      Recipe(id: 'r_curry', name: 'Curry de pois chiches', servings: 3, tone: 'curry', items: [
        Item(id: uid(), name: 'Pois chiches', qty: 400, unit: 'g'),
        Item(id: uid(), name: 'Lait de coco', qty: 400, unit: 'ml'),
        Item(id: uid(), name: 'Oignon', qty: 1, unit: 'pc'),
        Item(id: uid(), name: 'Pâte de curry', qty: 2, unit: 'cas'),
        Item(id: uid(), name: 'Épinards', qty: 150, unit: 'g'),
      ]),
    ];

/// Seed lists — a stocked weekly list with a recipe folder + loose items,
/// and a lighter apéro list.
List<ShoppingList> seedLists() {
  final recipes = seedRecipes();
  final bolo = recipeToBlock(recipes[0], 4);
  bolo.items[0].checked = true;
  bolo.items[2].checked = true;

  final now = DateTime.now().millisecondsSinceEpoch;

  return [
    ShoppingList(
      id: 'l_semaine',
      name: 'Courses de la semaine',
      tone: 'green',
      createdAt: now - 1000 * 60 * 60 * 5,
      blocks: [
        bolo,
        Block(id: uid('blk'), type: BlockType.loose, name: 'En vrac', items: [
          Item(id: uid('it'), name: 'Bananes', qty: 6, unit: 'pc'),
          Item(id: uid('it'), name: 'Café moulu', qty: 250, unit: 'g', checked: true),
          Item(id: uid('it'), name: 'Pain complet', qty: 1, unit: 'pc'),
          Item(id: uid('it'), name: 'Lait', qty: 1, unit: 'L'),
          Item(id: uid('it'), name: 'Yaourts nature', qty: 8, unit: 'pc'),
        ]),
      ],
    ),
    ShoppingList(
      id: 'l_apero',
      name: 'Apéro samedi',
      tone: 'yellow',
      createdAt: now - 1000 * 60 * 60 * 30,
      blocks: [
        Block(id: uid('blk'), type: BlockType.loose, name: 'En vrac', items: [
          Item(id: uid('it'), name: 'Chips', qty: 2, unit: 'pc'),
          Item(id: uid('it'), name: 'Olives', qty: 200, unit: 'g'),
          Item(id: uid('it'), name: 'Houmous', qty: 1, unit: 'pc'),
          Item(id: uid('it'), name: 'Citrons', qty: 3, unit: 'pc'),
        ]),
      ],
    ),
  ];
}
