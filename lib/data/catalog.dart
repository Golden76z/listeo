class CatalogRecipe {
  final String id;
  final String nameFr;
  final String nameEn;
  final String tone;
  final int servings;
  final List<CatalogIngredient> ingredients;
  final List<String> instructionsFr;
  final List<String> instructionsEn;
  final List<String> tags;

  const CatalogRecipe({
    required this.id,
    required this.nameFr,
    required this.nameEn,
    required this.tone,
    required this.servings,
    required this.ingredients,
    required this.instructionsFr,
    required this.instructionsEn,
    required this.tags,
  });
}

class CatalogIngredient {
  final String nameFr;
  final String nameEn;
  final double qty;
  final String unit;

  const CatalogIngredient({
    required this.nameFr,
    required this.nameEn,
    required this.qty,
    required this.unit,
  });
}

// Base hand-written recipes, including original 8 + 8 new dessert classics.
const List<CatalogRecipe> _kBaseCatalogRecipes = [
  CatalogRecipe(
    id: 'cat_carbonara',
    nameFr: 'Pâtes Carbonara',
    nameEn: 'Pasta Carbonara',
    tone: 'yellow',
    servings: 4,
    tags: ['pates'],
    ingredients: [
      CatalogIngredient(nameFr: 'Spaghetti', nameEn: 'Spaghetti', qty: 400, unit: 'g'),
      CatalogIngredient(nameFr: 'Lardons', nameEn: 'Bacon', qty: 200, unit: 'g'),
      CatalogIngredient(nameFr: 'Oeufs', nameEn: 'Eggs', qty: 4, unit: 'pc'),
      CatalogIngredient(nameFr: 'Parmesan', nameEn: 'Parmesan cheese', qty: 75, unit: 'g'),
      CatalogIngredient(nameFr: 'Sel', nameEn: 'Salt', qty: 1, unit: 'pincee'),
      CatalogIngredient(nameFr: 'Poivre', nameEn: 'Black pepper', qty: 2, unit: 'pincee'),
    ],
    instructionsFr: [
      'Faire cuire les spaghetti dans de l\'eau bouillante salée.',
      'Faire dorer les lardons dans une poêle chaude sans matière grasse.',
      'Dans un saladier, fouetter les œufs avec le parmesan râpé et le poivre.',
      'Égoutter les pâtes, y ajouter les lardons chauds puis le mélange d\'œufs hors du feu. Mélanger énergiquement pour obtenir une sauce crémeuse.',
    ],
    instructionsEn: [
      'Cook spaghetti in a large pot of boiling salted water.',
      'Fry bacon in a pan over medium heat until crispy.',
      'In a bowl, whisk eggs with grated parmesan cheese and black pepper.',
      'Drain the pasta, add the hot bacon, and pour in the egg mixture off the heat. Toss quickly to form a creamy sauce.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_curry',
    nameFr: 'Curry de Poulet',
    nameEn: 'Chicken Curry',
    tone: 'curry',
    servings: 4,
    tags: ['poulet', 'legumes', 'gluten_free', 'lactose_free'],
    ingredients: [
      CatalogIngredient(nameFr: 'Filet de poulet', nameEn: 'Chicken breast', qty: 600, unit: 'g'),
      CatalogIngredient(nameFr: 'Oignon', nameEn: 'Onion', qty: 2, unit: 'pc'),
      CatalogIngredient(nameFr: 'Lait de coco', nameEn: 'Coconut milk', qty: 400, unit: 'ml'),
      CatalogIngredient(nameFr: 'Pâte de curry', nameEn: 'Curry paste', qty: 2, unit: 'cas'),
      CatalogIngredient(nameFr: 'Huile d\'olive', nameEn: 'Olive oil', qty: 2, unit: 'cas'),
      CatalogIngredient(nameFr: 'Riz', nameEn: 'Rice', qty: 300, unit: 'g'),
    ],
    instructionsFr: [
      'Faire cuire le riz selon les instructions du paquet.',
      'Émincer finement les oignons et couper le poulet en cubes.',
      'Faire revenir les oignons dans l\'huile, puis ajouter la pâte de curry et le poulet.',
      'Verser le lait de coco et laisser mijoter 15 minutes à feu doux. Servir chaud avec le riz.',
    ],
    instructionsEn: [
      'Cook rice according to the package instructions.',
      'Finely slice onions and chop chicken breasts into cubes.',
      'Saute onions in olive oil, then stir in curry paste and add chicken.',
      'Pour in coconut milk and let it simmer for 15 minutes over low heat. Serve hot with rice.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_salad',
    nameFr: 'Salade Végétarienne',
    nameEn: 'Vegetarian Salad',
    tone: 'salade',
    servings: 2,
    tags: ['legumes', 'veggie', 'gluten_free', 'lactose_free'],
    ingredients: [
      CatalogIngredient(nameFr: 'Salade', nameEn: 'Salad', qty: 1, unit: 'pc'),
      CatalogIngredient(nameFr: 'Tomates', nameEn: 'Tomatoes', qty: 2, unit: 'pc'),
      CatalogIngredient(nameFr: 'Concombre', nameEn: 'Cucumber', qty: 0.5, unit: 'pc'),
      CatalogIngredient(nameFr: 'Avocat', nameEn: 'Avocado', qty: 1, unit: 'pc'),
      CatalogIngredient(nameFr: 'Huile d\'olive', nameEn: 'Olive oil', qty: 2, unit: 'cas'),
      CatalogIngredient(nameFr: 'Citron', nameEn: 'Lemon', qty: 0.5, unit: 'pc'),
      CatalogIngredient(nameFr: 'Pois chiches', nameEn: 'Chickpeas', qty: 200, unit: 'g'),
    ],
    instructionsFr: [
      'Laver la salade. Découper les tomates et le concombre en rondelles.',
      'Couper l\'avocat en deux, retirer le noyau et le couper en tranches.',
      'Rincer et égoutter les pois chiches.',
      'Mélanger tous les ingrédients dans un grand bol avec l\'huile d\'olive et le jus de citron.',
    ],
    instructionsEn: [
      'Wash salad greens. Slice tomatoes and cucumber.',
      'Cut avocado in half, remove pit, and slice the flesh.',
      'Rinse and drain the chickpeas.',
      'Combine all ingredients in a large bowl and toss with olive oil and lemon juice.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_soup',
    nameFr: 'Soupe de Tomates',
    nameEn: 'Tomato Soup',
    tone: 'tomate',
    servings: 4,
    tags: ['legumes', 'veggie', 'gluten_free', 'lactose_free'],
    ingredients: [
      CatalogIngredient(nameFr: 'Tomates', nameEn: 'Tomatoes', qty: 1, unit: 'kg'),
      CatalogIngredient(nameFr: 'Oignon', nameEn: 'Onion', qty: 1, unit: 'pc'),
      CatalogIngredient(nameFr: 'Ail', nameEn: 'Garlic', qty: 2, unit: 'pc'),
      CatalogIngredient(nameFr: 'Eau', nameEn: 'Water', qty: 500, unit: 'ml'),
      CatalogIngredient(nameFr: 'Huile d\'olive', nameEn: 'Olive oil', qty: 1, unit: 'cas'),
      CatalogIngredient(nameFr: 'Sel', nameEn: 'Salt', qty: 1, unit: 'pincee'),
    ],
    instructionsFr: [
      'Éplucher et hacher l\'oignon et l\'ail.',
      'Couper les tomates en gros morceaux.',
      'Faire dorer l\'oignon et l\'ail dans la poêle, ajouter les tomates, le sel et l\'eau.',
      'Couvrir et laisser mijoter 20 minutes. Mixer ensuite le tout pour obtenir un velouté.',
    ],
    instructionsEn: [
      'Peel and chop onion and garlic.',
      'Cut tomatoes into large chunks.',
      'Saute onion and garlic in olive oil, then add tomatoes, salt, and water.',
      'Cover and simmer for 20 minutes. Blend everything until creamy and smooth.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_cake',
    nameFr: 'Gâteau au Chocolat',
    nameEn: 'Chocolate Cake',
    tone: 'sucre',
    servings: 6,
    tags: ['dessert', 'veggie'],
    ingredients: [
      CatalogIngredient(nameFr: 'Chocolat', nameEn: 'Chocolate', qty: 200, unit: 'g'),
      CatalogIngredient(nameFr: 'Beurre', nameEn: 'Butter', qty: 125, unit: 'g'),
      CatalogIngredient(nameFr: 'Sucre', nameEn: 'Sugar', qty: 150, unit: 'g'),
      CatalogIngredient(nameFr: 'Oeufs', nameEn: 'Eggs', qty: 4, unit: 'pc'),
      CatalogIngredient(nameFr: 'Farine', nameEn: 'Flour', qty: 50, unit: 'g'),
    ],
    instructionsFr: [
      'Préchauffer le four à 180°C.',
      'Faire fondre le chocolat et le beurre ensemble à feu doux.',
      'Mélanger les œufs et le sucre dans un saladier, puis incorporer la farine.',
      'Ajouter le chocolat fondu. Verser dans un moule et faire cuire 22 minutes.',
    ],
    instructionsEn: [
      'Preheat oven to 180°C (350°F).',
      'Melt chocolate and butter together over low heat.',
      'Whisk eggs and sugar in a bowl, then stir in the flour.',
      'Fold in the melted chocolate mixture. Pour into a pan and bake for 22 minutes.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_avotoast',
    nameFr: 'Avocado Toast',
    nameEn: 'Avocado Toast',
    tone: 'green',
    servings: 2,
    tags: ['legumes', 'veggie', 'lactose_free'],
    ingredients: [
      CatalogIngredient(nameFr: 'Pain', nameEn: 'Bread', qty: 4, unit: 'pc'),
      CatalogIngredient(nameFr: 'Avocat', nameEn: 'Avocado', qty: 2, unit: 'pc'),
      CatalogIngredient(nameFr: 'Citron', nameEn: 'Lemon', qty: 0.5, unit: 'pc'),
      CatalogIngredient(nameFr: 'Huile d\'olive', nameEn: 'Olive oil', qty: 1, unit: 'cas'),
      CatalogIngredient(nameFr: 'Oeufs', nameEn: 'Eggs', qty: 2, unit: 'pc'),
      CatalogIngredient(nameFr: 'Sel', nameEn: 'Salt', qty: 1, unit: 'pincee'),
    ],
    instructionsFr: [
      'Faire griller les tranches de pain.',
      'Écraser la chair d\'avocat dans un bol avec le jus de citron, le sel et l\'huile d\'olive.',
      'Faire pocher ou frire les deux œufs.',
      'Étaler la préparation à l\'avocat sur le pain et déposer un œuf sur le dessus.',
    ],
    instructionsEn: [
      'Toast the bread slices.',
      'Mash avocado flesh in a bowl with lemon juice, salt, and olive oil.',
      'Poach or fry the eggs.',
      'Spread avocado mash on the toasted bread and place an egg on top.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_pancakes',
    nameFr: 'Pancakes Maison',
    nameEn: 'Fluffy Pancakes',
    tone: 'yellow',
    servings: 4,
    tags: ['dessert', 'veggie'],
    ingredients: [
      CatalogIngredient(nameFr: 'Farine', nameEn: 'Flour', qty: 250, unit: 'g'),
      CatalogIngredient(nameFr: 'Lait', nameEn: 'Milk', qty: 300, unit: 'ml'),
      CatalogIngredient(nameFr: 'Oeufs', nameEn: 'Eggs', qty: 2, unit: 'pc'),
      CatalogIngredient(nameFr: 'Beurre', nameEn: 'Butter', qty: 50, unit: 'g'),
      CatalogIngredient(nameFr: 'Sucre', nameEn: 'Sugar', qty: 30, unit: 'g'),
      CatalogIngredient(nameFr: 'Sel', nameEn: 'Salt', qty: 1, unit: 'pincee'),
    ],
    instructionsFr: [
      'Mélanger la farine, le sucre et le sel dans un saladier.',
      'Battre les œufs avec le lait, puis les incorporer délicatement au mélange de farine.',
      'Ajouter le beurre fondu et bien mélanger.',
      'Faire cuire de petites louches de pâte dans une poêle chaude et beurrée.',
    ],
    instructionsEn: [
      'Mix flour, sugar, and salt in a large bowl.',
      'Whisk eggs with milk, then stir gently into the dry ingredients.',
      'Add melted butter and mix well to get a smooth batter.',
      'Cook small ladles of batter in a hot buttered skillet until bubbly, then flip.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_tacos',
    nameFr: 'Tacos au Bœuf',
    nameEn: 'Beef Tacos',
    tone: 'curry',
    servings: 4,
    tags: ['beef', 'legumes'],
    ingredients: [
      CatalogIngredient(nameFr: 'Viande hachée', nameEn: 'Ground beef', qty: 500, unit: 'g'),
      CatalogIngredient(nameFr: 'Tortillas', nameEn: 'Taco shells', qty: 8, unit: 'pc'),
      CatalogIngredient(nameFr: 'Tomates', nameEn: 'Tomatoes', qty: 2, unit: 'pc'),
      CatalogIngredient(nameFr: 'Oignon', nameEn: 'Onion', qty: 1, unit: 'pc'),
      CatalogIngredient(nameFr: 'Salade', nameEn: 'Lettuce', qty: 1, unit: 'pc'),
      CatalogIngredient(nameFr: 'Fromage râpé', nameEn: 'Grated cheese', qty: 100, unit: 'g'),
      CatalogIngredient(nameFr: 'Crème fraîche', nameEn: 'Sour cream', qty: 100, unit: 'g'),
    ],
    instructionsFr: [
      'Faire dorer la viande hachée dans une poêle à feu moyen.',
      'Couper les tomates et l\'oignon en petits dés, et ciseler la salade.',
      'Faire tiédir les tortillas/tacos au four ou à la poêle.',
      'Garnir les tacos avec la viande chaude, les légumes coupés, le fromage et une touche de crème.',
    ],
    instructionsEn: [
      'Cook ground beef in a skillet over medium heat until browned.',
      'Dice tomatoes and onion, and shred the lettuce.',
      'Warm the taco shells in the oven or in a skillet.',
      'Assemble tacos with warm beef, veggies, grated cheese, and a dollop of sour cream.',
    ],
  ),
  // Additional classic desserts to enrich the dessert category
  CatalogRecipe(
    id: 'cat_applepie',
    nameFr: 'Tarte aux Pommes',
    nameEn: 'Classic Apple Pie',
    tone: 'sucre',
    servings: 6,
    tags: ['dessert', 'veggie'],
    ingredients: [
      CatalogIngredient(nameFr: 'Pâte brisée', nameEn: 'Pie crust', qty: 1, unit: 'pc'),
      CatalogIngredient(nameFr: 'Pommes gala', nameEn: 'Apples', qty: 6, unit: 'pc'),
      CatalogIngredient(nameFr: 'Sucre', nameEn: 'Sugar', qty: 50, unit: 'g'),
      CatalogIngredient(nameFr: 'Beurre', nameEn: 'Butter', qty: 30, unit: 'g'),
      CatalogIngredient(nameFr: 'Sel', nameEn: 'Salt', qty: 1, unit: 'pincee'),
    ],
    instructionsFr: [
      'Préchauffer le four à 200°C.',
      'Étaler la pâte brisée dans un moule à tarte.',
      'Éplucher et couper les pommes en fines tranches.',
      'Disposer les pommes sur la pâte en cercles serrés.',
      'Saupoudrer de sucre, parsemer de noisettes de beurre et cuire 35 minutes.',
    ],
    instructionsEn: [
      'Preheat oven to 200°C (400°F).',
      'Roll out the pie crust into a pie dish.',
      'Peel, core, and thinly slice the apples.',
      'Arrange the apple slices on the crust in tight concentric circles.',
      'Sprinkle with sugar, dot with butter pieces, and bake for 35 minutes.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_cremebrulee',
    nameFr: 'Crème Brûlée',
    nameEn: 'Vanilla Crème Brûlée',
    tone: 'sucre',
    servings: 4,
    tags: ['dessert', 'veggie', 'gluten_free'],
    ingredients: [
      CatalogIngredient(nameFr: 'Crème liquide', nameEn: 'Heavy cream', qty: 400, unit: 'ml'),
      CatalogIngredient(nameFr: 'Oeufs', nameEn: 'Eggs', qty: 5, unit: 'pc'),
      CatalogIngredient(nameFr: 'Sucre', nameEn: 'Sugar', qty: 70, unit: 'g'),
      CatalogIngredient(nameFr: 'Cassonade', nameEn: 'Brown sugar', qty: 40, unit: 'g'),
    ],
    instructionsFr: [
      'Préchauffer le four à 100°C.',
      'Fouetter les jaunes d\'œufs (5 jaunes) avec le sucre.',
      'Ajouter la crème liquide et mélanger doucement.',
      'Répartir dans 4 ramequins et cuire au bain-marie pendant 1 heure.',
      'Laisser refroidir, puis saupoudrer de cassonade et caraméliser.',
    ],
    instructionsEn: [
      'Preheat oven to 100°C (212°F).',
      'Whisk egg yolks (from 5 eggs) and sugar in a bowl.',
      'Stir in heavy cream until smooth.',
      'Divide the mixture among 4 ramekins and bake in a water bath for 1 hour.',
      'Let cool, then sprinkle with brown sugar and caramelize.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_lemontart',
    nameFr: 'Tarte au Citron Meringuée',
    nameEn: 'Lemon Meringue Tart',
    tone: 'sucre',
    servings: 6,
    tags: ['dessert', 'veggie'],
    ingredients: [
      CatalogIngredient(nameFr: 'Pâte brisée', nameEn: 'Pie crust', qty: 1, unit: 'pc'),
      CatalogIngredient(nameFr: 'Citron', nameEn: 'Lemon', qty: 3, unit: 'pc'),
      CatalogIngredient(nameFr: 'Sucre', nameEn: 'Sugar', qty: 150, unit: 'g'),
      CatalogIngredient(nameFr: 'Beurre', nameEn: 'Butter', qty: 100, unit: 'g'),
      CatalogIngredient(nameFr: 'Oeufs', nameEn: 'Eggs', qty: 4, unit: 'pc'),
    ],
    instructionsFr: [
      'Préchauffer le four à 180°C et cuire la pâte à blanc 15 minutes.',
      'Mélanger le jus des citrons, le sucre, le beurre fondu et 3 œufs battus.',
      'Faire épaissir à feu doux en remuant, puis verser sur la pâte.',
      'Monter 2 blancs d\'œufs en neige avec 50g de sucre, étaler sur la tarte et dorer sous le gril.',
    ],
    instructionsEn: [
      'Preheat oven to 180°C (350°F) and bake pie crust blank for 15 minutes.',
      'Mix lemon juice, sugar, melted butter, and 3 beaten eggs.',
      'Thicken over low heat while stirring, then pour onto the crust.',
      'Beat 2 egg whites to soft peaks with 50g sugar, spread on top, and brown under the broiler.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_lavacake',
    nameFr: 'Fondant au Chocolat',
    nameEn: 'Lava Chocolate Cake',
    tone: 'sucre',
    servings: 4,
    tags: ['dessert', 'veggie'],
    ingredients: [
      CatalogIngredient(nameFr: 'Chocolat', nameEn: 'Chocolate', qty: 100, unit: 'g'),
      CatalogIngredient(nameFr: 'Beurre', nameEn: 'Butter', qty: 80, unit: 'g'),
      CatalogIngredient(nameFr: 'Sucre', nameEn: 'Sugar', qty: 50, unit: 'g'),
      CatalogIngredient(nameFr: 'Oeufs', nameEn: 'Eggs', qty: 3, unit: 'pc'),
      CatalogIngredient(nameFr: 'Farine', nameEn: 'Flour', qty: 40, unit: 'g'),
    ],
    instructionsFr: [
      'Préchauffer le four à 200°C.',
      'Faire fondre le chocolat et le beurre ensemble.',
      'Ajouter le sucre, les œufs battus, puis la farine.',
      'Répartir dans 4 moules beurrés et cuire 8 à 10 minutes pour garder le cœur coulant.',
    ],
    instructionsEn: [
      'Preheat oven to 200°C (400°F).',
      'Melt chocolate and butter together.',
      'Stir in sugar, beaten eggs, and flour.',
      'Divide into 4 buttered ramekins and bake for 8 to 10 minutes for a runny center.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_tiramisu',
    nameFr: 'Tiramisu Classique',
    nameEn: 'Classic Tiramisu',
    tone: 'sucre',
    servings: 6,
    tags: ['dessert', 'veggie'],
    ingredients: [
      CatalogIngredient(nameFr: 'Mascarpone', nameEn: 'Mascarpone cheese', qty: 250, unit: 'g'),
      CatalogIngredient(nameFr: 'Biscuits cuillères', nameEn: 'Ladyfingers', qty: 24, unit: 'pc'),
      CatalogIngredient(nameFr: 'Oeufs', nameEn: 'Eggs', qty: 3, unit: 'pc'),
      CatalogIngredient(nameFr: 'Sucre', nameEn: 'Sugar', qty: 80, unit: 'g'),
      CatalogIngredient(nameFr: 'Café', nameEn: 'Brewed coffee', qty: 250, unit: 'ml'),
      CatalogIngredient(nameFr: 'Amaretto', nameEn: 'Amaretto', qty: 2, unit: 'cas'),
      CatalogIngredient(nameFr: 'Chocolat', nameEn: 'Cocoa powder', qty: 20, unit: 'g'),
    ],
    instructionsFr: [
      'Séparer les blancs des jaunes d\'œufs. Battre les jaunes avec le sucre et le mascarpone.',
      'Monter les blancs en neige et les incorporer délicatement au mélange.',
      'Mélanger le café et l\'amaretto. Y tremper rapidement les biscuits.',
      'Tapisser un plat de biscuits, recouvrir de crème, répéter et saupoudrer de cacao. Réfrigérer 4 heures.',
    ],
    instructionsEn: [
      'Separate egg whites and yolks. Whisk yolks with sugar and mascarpone.',
      'Whip whites to stiff peaks and gently fold into the mascarpone cream.',
      'Mix coffee and amaretto. Dip ladyfingers quickly into the mixture.',
      'Layer dipped biscuits in a dish, spread cream on top, repeat layers, and dust with cocoa. Chill for 4 hours.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_fruitsalad',
    nameFr: 'Salade de Fruits Frais',
    nameEn: 'Fresh Fruit Salad',
    tone: 'sucre',
    servings: 4,
    tags: ['dessert', 'legumes', 'veggie', 'gluten_free', 'lactose_free'],
    ingredients: [
      CatalogIngredient(nameFr: 'Fraises', nameEn: 'Strawberries', qty: 250, unit: 'g'),
      CatalogIngredient(nameFr: 'Bananes', nameEn: 'Bananas', qty: 2, unit: 'pc'),
      CatalogIngredient(nameFr: 'Pommes', nameEn: 'Apples', qty: 2, unit: 'pc'),
      CatalogIngredient(nameFr: 'Oranges', nameEn: 'Oranges', qty: 2, unit: 'pc'),
      CatalogIngredient(nameFr: 'Citron vert', nameEn: 'Lime', qty: 1, unit: 'pc'),
      CatalogIngredient(nameFr: 'Miel', nameEn: 'Honey', qty: 2, unit: 'cas'),
    ],
    instructionsFr: [
      'Laver, éplucher et couper tous les fruits en morceaux de taille égale.',
      'Mélanger le jus du citron vert et le miel dans un grand bol.',
      'Ajouter les fruits, mélanger délicatement et réserver au frais avant de servir.',
    ],
    instructionsEn: [
      'Wash, peel, and chop all fruits into bite-sized pieces.',
      'In a large bowl, whisk lime juice and honey together.',
      'Add the fruits, toss gently to combine, and chill before serving.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_waffles',
    nameFr: 'Gaufres Maison',
    nameEn: 'Crispy Homemade Waffles',
    tone: 'sucre',
    servings: 4,
    tags: ['dessert', 'veggie'],
    ingredients: [
      CatalogIngredient(nameFr: 'Farine', nameEn: 'Flour', qty: 250, unit: 'g'),
      CatalogIngredient(nameFr: 'Lait', nameEn: 'Milk', qty: 350, unit: 'ml'),
      CatalogIngredient(nameFr: 'Oeufs', nameEn: 'Eggs', qty: 2, unit: 'pc'),
      CatalogIngredient(nameFr: 'Beurre', nameEn: 'Butter', qty: 75, unit: 'g'),
      CatalogIngredient(nameFr: 'Sucre', nameEn: 'Sugar', qty: 50, unit: 'g'),
      CatalogIngredient(nameFr: 'Levure', nameEn: 'Baking powder', qty: 1, unit: 'pc'),
    ],
    instructionsFr: [
      'Mélanger la farine, la levure et le sucre dans un récipient.',
      'Ajouter les œufs battus, puis incorporer le lait en fouettant doucement.',
      'Ajouter le beurre fondu et laisser reposer la pâte 30 minutes.',
      'Faire cuire les gaufres dans un gaufrier chaud et huilé jusqu\'à ce qu\'elles soient dorées.',
    ],
    instructionsEn: [
      'Whisk flour, baking powder, and sugar in a large bowl.',
      'Whisk in the eggs, then gradually pour in milk while whisking.',
      'Stir in the melted butter and let the batter rest for 30 minutes.',
      'Bake in a preheated, oiled waffle maker until crisp and golden brown.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_chocmousse',
    nameFr: 'Mousse au Chocolat',
    nameEn: 'Chocolate Mousse',
    tone: 'sucre',
    servings: 4,
    tags: ['dessert'],
    ingredients: [
      CatalogIngredient(nameFr: 'Chocolat', nameEn: 'Chocolate', qty: 200, unit: 'g'),
      CatalogIngredient(nameFr: 'Oeufs', nameEn: 'Eggs', qty: 6, unit: 'pc'),
      CatalogIngredient(nameFr: 'Beurre', nameEn: 'Butter', qty: 30, unit: 'g'),
      CatalogIngredient(nameFr: 'Sucre', nameEn: 'Sugar', qty: 20, unit: 'g'),
    ],
    instructionsFr: [
      'Faire fondre le chocolat avec le beurre à feu très doux.',
      'Séparer les blancs des jaunes d\'œufs. Ajouter les jaunes au chocolat fondu.',
      'Monter les blancs en neige ferme avec le sucre.',
      'Incorporer délicatement les blancs en neige au mélange chocolaté. Réfrigérer 4 heures.',
    ],
    instructionsEn: [
      'Melt chocolate and butter together over very low heat.',
      'Separate egg whites and yolks. Whisk yolks into the melted chocolate.',
      'Whip egg whites to stiff peaks with the sugar.',
      'Gently fold the whipped whites into the chocolate mixture. Refrigerate for 4 hours.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_quiche',
    nameFr: 'Quiche Lorraine',
    nameEn: 'Quiche Lorraine',
    tone: 'yellow',
    servings: 6,
    tags: ['beef'],
    ingredients: [
      CatalogIngredient(nameFr: 'Pâte brisée', nameEn: 'Pie crust', qty: 1, unit: 'pc'),
      CatalogIngredient(nameFr: 'Lardons', nameEn: 'Bacon lardons', qty: 200, unit: 'g'),
      CatalogIngredient(nameFr: 'Crème fraîche', nameEn: 'Sour cream / Heavy cream', qty: 20, unit: 'cl'),
      CatalogIngredient(nameFr: 'Oeufs', nameEn: 'Eggs', qty: 3, unit: 'pc'),
      CatalogIngredient(nameFr: 'Lait', nameEn: 'Milk', qty: 10, unit: 'cl'),
      CatalogIngredient(nameFr: 'Fromage râpé', nameEn: 'Grated cheese', qty: 100, unit: 'g'),
      CatalogIngredient(nameFr: 'Noix de muscade', nameEn: 'Nutmeg', qty: 1, unit: 'pincee'),
    ],
    instructionsFr: [
      'Préchauffer le four à 180°C. Étaler la pâte dans un moule.',
      'Faire rissoler les lardons dans une poêle sans matière grasse.',
      'Fouetter les œufs, la crème, le lait et la muscade dans un bol.',
      'Disposer les lardons et le fromage sur la pâte, puis verser le mélange.',
      'Cuire au four pendant 35 minutes.',
    ],
    instructionsEn: [
      'Preheat oven to 180°C (350°F). Roll out the crust in a pie dish.',
      'Pan-fry lardons until slightly crispy; drain excess fat.',
      'Whisk eggs, cream, milk, and a pinch of nutmeg in a bowl.',
      'Scatter lardons and grated cheese over the crust, then pour the mixture.',
      'Bake for 35 minutes until golden brown and set.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_lasagne',
    nameFr: 'Lasagnes Bolognaise',
    nameEn: 'Beef Lasagna',
    tone: 'tomate',
    servings: 6,
    tags: ['pates', 'beef'],
    ingredients: [
      CatalogIngredient(nameFr: 'Plaques de lasagne', nameEn: 'Lasagna sheets', qty: 12, unit: 'pc'),
      CatalogIngredient(nameFr: 'Viande hachée', nameEn: 'Ground beef', qty: 500, unit: 'g'),
      CatalogIngredient(nameFr: 'Sauce tomate', nameEn: 'Tomato sauce', qty: 600, unit: 'g'),
      CatalogIngredient(nameFr: 'Oignon', nameEn: 'Onion', qty: 1, unit: 'pc'),
      CatalogIngredient(nameFr: 'Beurre', nameEn: 'Butter', qty: 50, unit: 'g'),
      CatalogIngredient(nameFr: 'Farine', nameEn: 'Flour', qty: 50, unit: 'g'),
      CatalogIngredient(nameFr: 'Lait', nameEn: 'Milk', qty: 50, unit: 'cl'),
      CatalogIngredient(nameFr: 'Fromage râpé', nameEn: 'Grated cheese', qty: 150, unit: 'g'),
    ],
    instructionsFr: [
      'Préparer la béchamel en faisant fondre le beurre, ajouter la farine puis incorporer le lait.',
      'Faire revenir l\'oignon et la viande hachée dans une poêle.',
      'Ajouter la sauce tomate à la viande et laisser mijoter 10 minutes.',
      'Dans un plat, alterner les couches de lasagnes, bolognaise et béchamel.',
      'Parsemer de fromage râpé et cuire au four pendant 35 minutes à 180°C.',
    ],
    instructionsEn: [
      'Make béchamel sauce by melting butter, stirring in flour, then whisking in milk.',
      'Saute diced onion and ground beef in a skillet until browned.',
      'Stir tomato sauce into the beef and let it simmer for 10 minutes.',
      'Layer lasagna sheets, meat sauce, and béchamel in a baking dish.',
      'Top with grated cheese and bake at 180°C (350°F) for 35 minutes.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_risotto',
    nameFr: 'Risotto aux Champignons',
    nameEn: 'Mushroom Risotto',
    tone: 'green',
    servings: 3,
    tags: ['legumes', 'veggie', 'gluten_free'],
    ingredients: [
      CatalogIngredient(nameFr: 'Riz Arborio', nameEn: 'Arborio rice', qty: 250, unit: 'g'),
      CatalogIngredient(nameFr: 'Champignons', nameEn: 'Mushrooms', qty: 300, unit: 'g'),
      CatalogIngredient(nameFr: 'Oignon', nameEn: 'Onion', qty: 1, unit: 'pc'),
      CatalogIngredient(nameFr: 'Bouillon de légumes', nameEn: 'Vegetable broth', qty: 1, unit: 'L'),
      CatalogIngredient(nameFr: 'Parmesan', nameEn: 'Parmesan cheese', qty: 50, unit: 'g'),
      CatalogIngredient(nameFr: 'Vin blanc', nameEn: 'White wine', qty: 10, unit: 'cl'),
      CatalogIngredient(nameFr: 'Beurre', nameEn: 'Butter', qty: 30, unit: 'g'),
    ],
    instructionsFr: [
      'Faire revenir l\'oignon ciselé dans du beurre.',
      'Ajouter les champignons émincés et les faire dorer.',
      'Ajouter le riz Arborio et le faire nacrer pendant 2 minutes.',
      'Verser le vin blanc, puis ajouter le bouillon chaud louche par louche en remuant.',
      'Incorporer le parmesan et le reste du beurre hors du feu.',
    ],
    instructionsEn: [
      'Saute diced onion in melted butter in a pot.',
      'Add sliced mushrooms and cook until browned.',
      'Add Arborio rice and toast for 2 minutes.',
      'Pour in white wine, then add hot vegetable broth one ladle at a time, stirring constantly.',
      'Stir in parmesan cheese and remaining butter off the heat.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_poulet_roti',
    nameFr: 'Poulet Rôti aux Pommes de Terre',
    nameEn: 'Roast Chicken & Potatoes',
    tone: 'yellow',
    servings: 4,
    tags: ['poulet'],
    ingredients: [
      CatalogIngredient(nameFr: 'Poulet entier', nameEn: 'Whole chicken', qty: 1, unit: 'pc'),
      CatalogIngredient(nameFr: 'Pommes de terre', nameEn: 'Potatoes', qty: 1, unit: 'kg'),
      CatalogIngredient(nameFr: 'Gousses d\'ail', nameEn: 'Garlic cloves', qty: 4, unit: 'pc'),
      CatalogIngredient(nameFr: 'Herbes de Provence', nameEn: 'Herbs de Provence', qty: 2, unit: 'cas'),
      CatalogIngredient(nameFr: 'Huile d\'olive', nameEn: 'Olive oil', qty: 3, unit: 'cas'),
      CatalogIngredient(nameFr: 'Beurre', nameEn: 'Butter', qty: 30, unit: 'g'),
    ],
    instructionsFr: [
      'Préchauffer le four à 200°C.',
      'Placer le poulet dans un grand plat et répartir des noisettes de beurre dessus.',
      'Couper les pommes de terre en morceaux et les disposer tout autour.',
      'Arroser d\'huile d\'olive, parsemer d\'herbes et disposer l\'ail.',
      'Faire rôtir au four pendant 1h15 en arrosant régulièrement.',
    ],
    instructionsEn: [
      'Preheat oven to 200°C (400°F).',
      'Place whole chicken in a large baking dish and dot with butter.',
      'Cut potatoes into chunks and arrange them around the chicken.',
      'Drizzle with olive oil, sprinkle with herbs, and add garlic cloves.',
      'Roast for 1 hour and 15 minutes, basting the chicken regularly.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_ratatouille',
    nameFr: 'Ratatouille Niçoise',
    nameEn: 'Classic Ratatouille',
    tone: 'tomate',
    servings: 4,
    tags: ['legumes', 'veggie', 'gluten_free', 'lactose_free'],
    ingredients: [
      CatalogIngredient(nameFr: 'Courgettes', nameEn: 'Zucchinis', qty: 3, unit: 'pc'),
      CatalogIngredient(nameFr: 'Aubergines', nameEn: 'Eggplants', qty: 2, unit: 'pc'),
      CatalogIngredient(nameFr: 'Poivrons', nameEn: 'Bell peppers', qty: 2, unit: 'pc'),
      CatalogIngredient(nameFr: 'Tomates', nameEn: 'Tomatoes', qty: 4, unit: 'pc'),
      CatalogIngredient(nameFr: 'Oignon', nameEn: 'Onion', qty: 1, unit: 'pc'),
      CatalogIngredient(nameFr: 'Ail', nameEn: 'Garlic', qty: 2, unit: 'pc'),
      CatalogIngredient(nameFr: 'Huile d\'olive', nameEn: 'Olive oil', qty: 4, unit: 'cas'),
    ],
    instructionsFr: [
      'Couper tous les légumes en dés réguliers.',
      'Faire revenir les oignons et les poivrons dans de l\'huile d\'olive.',
      'Ajouter les aubergines, puis les courgettes dans la cocotte.',
      'Ajouter les tomates concassées et l\'ail écrasé.',
      'Laisser mijoter à couvert et à feu doux pendant 45 minutes.',
    ],
    instructionsEn: [
      'Dice all vegetables into even pieces.',
      'Saute onions and peppers in olive oil in a large pot.',
      'Add eggplants, then zucchinis to the pot.',
      'Add crushed tomatoes and minced garlic.',
      'Simmer covered over low heat for 45 minutes.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_gratin',
    nameFr: 'Gratin Dauphinois',
    nameEn: 'Gratin Dauphinois',
    tone: 'yellow',
    servings: 6,
    tags: ['legumes', 'veggie', 'gluten_free'],
    ingredients: [
      CatalogIngredient(nameFr: 'Pommes de terre', nameEn: 'Potatoes', qty: 1.5, unit: 'kg'),
      CatalogIngredient(nameFr: 'Crème fraîche liquide', nameEn: 'Heavy cream', qty: 50, unit: 'cl'),
      CatalogIngredient(nameFr: 'Lait', nameEn: 'Milk', qty: 50, unit: 'cl'),
      CatalogIngredient(nameFr: 'Gousse d\'ail', nameEn: 'Garlic clove', qty: 2, unit: 'pc'),
      CatalogIngredient(nameFr: 'Noix de muscade', nameEn: 'Nutmeg', qty: 1, unit: 'pincee'),
      CatalogIngredient(nameFr: 'Beurre', nameEn: 'Butter', qty: 20, unit: 'g'),
    ],
    instructionsFr: [
      'Préchauffer le four à 160°C. Frotter un plat avec de l\'ail.',
      'Éplucher et couper les pommes de terre en fines rondelles.',
      'Faire chauffer le lait, la crème, l\'ail écrasé et la muscade.',
      'Disposer les pommes de terre dans le plat et verser le liquide chaud.',
      'Enfourner pour 1h15 de cuisson lente jusqu\'à ce qu\'il soit tendre.',
    ],
    instructionsEn: [
      'Preheat oven to 160°C (320°F). Rub a baking dish with garlic.',
      'Peel and slice potatoes into thin rounds.',
      'Heat milk, cream, minced garlic, and nutmeg in a saucepan.',
      'Layer potatoes in the baking dish and pour the hot mixture over.',
      'Bake for 1 hour 15 minutes until tender and golden.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_bourguignon',
    nameFr: 'Boeuf Bourguignon',
    nameEn: 'Beef Bourguignon',
    tone: 'tomate',
    servings: 6,
    tags: ['beef', 'lactose_free'],
    ingredients: [
      CatalogIngredient(nameFr: 'Viande de bœuf', nameEn: 'Beef stew meat', qty: 1, unit: 'kg'),
      CatalogIngredient(nameFr: 'Vin rouge', nameEn: 'Red wine', qty: 75, unit: 'cl'),
      CatalogIngredient(nameFr: 'Carottes', nameEn: 'Carrots', qty: 4, unit: 'pc'),
      CatalogIngredient(nameFr: 'Oignons', nameEn: 'Onions', qty: 2, unit: 'pc'),
      CatalogIngredient(nameFr: 'Champignons', nameEn: 'Mushrooms', qty: 250, unit: 'g'),
      CatalogIngredient(nameFr: 'Lardons', nameEn: 'Bacon lardons', qty: 150, unit: 'g'),
      CatalogIngredient(nameFr: 'Farine', nameEn: 'Flour', qty: 30, unit: 'g'),
      CatalogIngredient(nameFr: 'Bouquet garni', nameEn: 'Herb bouquet', qty: 1, unit: 'pc'),
    ],
    instructionsFr: [
      'Faire dorer la viande dans une cocotte avec un filet d\'huile.',
      'Ajouter les oignons et les carottes en rondelles, saupoudrer de farine.',
      'Verser le vin rouge et ajouter le bouquet garni. Mijoter 2h30.',
      'Faire revenir les lardons et les champignons dans une poêle.',
      'Les ajouter à la cocotte 30 minutes avant de servir.',
    ],
    instructionsEn: [
      'Brown beef cubes in a large pot or Dutch oven with oil.',
      'Add sliced onions and carrots, then sprinkle with flour.',
      'Pour in red wine and add the herb bouquet. Simmer for 2.5 hours.',
      'Saute bacon lardons and sliced mushrooms in a pan.',
      'Add them to the pot 30 minutes before serving.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_cookies',
    nameFr: 'Cookies aux Pépites de Chocolat',
    nameEn: 'Chocolate Chip Cookies',
    tone: 'sucre',
    servings: 4,
    tags: ['dessert', 'veggie'],
    ingredients: [
      CatalogIngredient(nameFr: 'Farine', nameEn: 'Flour', qty: 220, unit: 'g'),
      CatalogIngredient(nameFr: 'Pépites de chocolat', nameEn: 'Chocolate chips', qty: 150, unit: 'g'),
      CatalogIngredient(nameFr: 'Beurre', nameEn: 'Butter (softened)', qty: 120, unit: 'g'),
      CatalogIngredient(nameFr: 'Sucre roux', nameEn: 'Brown sugar', qty: 100, unit: 'g'),
      CatalogIngredient(nameFr: 'Oeufs', nameEn: 'Egg', qty: 1, unit: 'pc'),
      CatalogIngredient(nameFr: 'Levure', nameEn: 'Baking powder', qty: 1, unit: 'pc'),
      CatalogIngredient(nameFr: 'Vanille', nameEn: 'Vanilla extract', qty: 1, unit: 'cac'),
    ],
    instructionsFr: [
      'Préchauffer le four à 180°C.',
      'Mélanger le beurre mou avec le sucre roux dans un grand bol.',
      'Ajouter l\'œuf et l\'extrait de vanille, puis bien mélanger.',
      'Incorporer la farine, la levure et les pépites de chocolat.',
      'Formes des boules de pâte, les aplatir sur une plaque et cuire 10 min.',
    ],
    instructionsEn: [
      'Preheat oven to 180°C (350°F).',
      'Mix softened butter and brown sugar in a large bowl.',
      'Add egg and vanilla extract; mix well.',
      'Stir in flour, baking powder, and chocolate chips.',
      'Form dough balls, place on a baking sheet, and bake for 10 minutes.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_tatin',
    nameFr: 'Tarte Tatin',
    nameEn: 'Tarte Tatin',
    tone: 'sucre',
    servings: 6,
    tags: ['dessert', 'veggie'],
    ingredients: [
      CatalogIngredient(nameFr: 'Pommes', nameEn: 'Apples', qty: 6, unit: 'pc'),
      CatalogIngredient(nameFr: 'Pâte feuilletée', nameEn: 'Puff pastry', qty: 1, unit: 'pc'),
      CatalogIngredient(nameFr: 'Sucre', nameEn: 'Sugar', qty: 150, unit: 'g'),
      CatalogIngredient(nameFr: 'Beurre', nameEn: 'Butter', qty: 80, unit: 'g'),
    ],
    instructionsFr: [
      'Faire un caramel avec le sucre directement dans le moule.',
      'Ajouter le beurre en morceaux, puis les pommes épluchées et coupées en quarts.',
      'Laisser cuire 15 minutes sur le feu pour caraméliser les pommes.',
      'Recouvrir le moule avec la pâte feuilletée en rentrant les bords.',
      'Cuire au four à 180°C pendant 30 minutes, puis démouler chaud.',
    ],
    instructionsEn: [
      'Make caramel with sugar directly in the baking pan.',
      'Add butter chunks, then peeled and quartered apples.',
      'Cook over medium heat for 15 minutes to caramelize apples.',
      'Cover with puff pastry, tucking in the edges.',
      'Bake at 180°C (350°F) for 30 minutes, then unmold hot.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_croque',
    nameFr: 'Croque-Monsieur',
    nameEn: 'Croque-Monsieur',
    tone: 'yellow',
    servings: 2,
    tags: ['beef'],
    ingredients: [
      CatalogIngredient(nameFr: 'Pain de mie', nameEn: 'Sliced bread', qty: 8, unit: 'tranche'),
      CatalogIngredient(nameFr: 'Jambon blanc', nameEn: 'Ham', qty: 4, unit: 'tranche'),
      CatalogIngredient(nameFr: 'Fromage râpé', nameEn: 'Grated cheese', qty: 150, unit: 'g'),
      CatalogIngredient(nameFr: 'Beurre', nameEn: 'Butter', qty: 50, unit: 'g'),
      CatalogIngredient(nameFr: 'Crème fraîche', nameEn: 'Sour cream', qty: 4, unit: 'cas'),
    ],
    instructionsFr: [
      'Beurrer les tranches de pain de mie sur une face.',
      'Poser une tranche de jambon et du fromage râpé sur le pain.',
      'Refermer avec une seconde tranche de pain beurrée.',
      'Étaler de la crème fraîche sur le dessus et parsemer de fromage râpé.',
      'Faire dorer au four sous le gril pendant 10 minutes.',
    ],
    instructionsEn: [
      'Butter one side of each bread slice.',
      'Place a ham slice and grated cheese on half of the bread slices.',
      'Close with the remaining bread slices (buttered side out).',
      'Spread sour cream on top and sprinkle with more cheese.',
      'Toast under the broiler for 10 minutes until golden and bubbly.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_soupe_oignon',
    nameFr: 'Soupe à l\'Oignon',
    nameEn: 'French Onion Soup',
    tone: 'yellow',
    servings: 4,
    tags: ['legumes', 'veggie'],
    ingredients: [
      CatalogIngredient(nameFr: 'Oignons', nameEn: 'Onions', qty: 1, unit: 'kg'),
      CatalogIngredient(nameFr: 'Beurre', nameEn: 'Butter', qty: 50, unit: 'g'),
      CatalogIngredient(nameFr: 'Farine', nameEn: 'Flour', qty: 2, unit: 'cas'),
      CatalogIngredient(nameFr: 'Bouillon de bœuf', nameEn: 'Beef broth', qty: 1.5, unit: 'L'),
      CatalogIngredient(nameFr: 'Pain de mie', nameEn: 'Bread slices', qty: 8, unit: 'tranche'),
      CatalogIngredient(nameFr: 'Fromage râpé', nameEn: 'Grated cheese', qty: 100, unit: 'g'),
    ],
    instructionsFr: [
      'Faire revenir les oignons émincés dans le beurre jusqu\'à coloration.',
      'Saupoudrer de farine, mélanger puis mouiller avec le bouillon.',
      'Laisser mijoter à couvert pendant 30 minutes.',
      'Faire griller les tranches de pain.',
      'Verser la soupe dans des bols, poser le pain, couvrir de fromage et gratiner.',
    ],
    instructionsEn: [
      'Saute sliced onions in butter until deeply caramelized.',
      'Sprinkle with flour, stir, and add beef broth.',
      'Simmer covered for 30 minutes over low heat.',
      'Toast the bread slices.',
      'Ladle soup into bowls, place bread on top, cover with cheese, and broil.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_salade_nicoise',
    nameFr: 'Salade Niçoise',
    nameEn: 'Nicoise Salad',
    tone: 'green',
    servings: 4,
    tags: ['legumes', 'gluten_free', 'lactose_free'],
    ingredients: [
      CatalogIngredient(nameFr: 'Tomates', nameEn: 'Tomatoes', qty: 4, unit: 'pc'),
      CatalogIngredient(nameFr: 'Thon en boîte', nameEn: 'Canned tuna', qty: 200, unit: 'g'),
      CatalogIngredient(nameFr: 'Oeufs', nameEn: 'Eggs', qty: 4, unit: 'pc'),
      CatalogIngredient(nameFr: 'Haricots verts', nameEn: 'Green beans', qty: 200, unit: 'g'),
      CatalogIngredient(nameFr: 'Anchois', nameEn: 'Anchovies', qty: 8, unit: 'pc'),
      CatalogIngredient(nameFr: 'Olives noires', nameEn: 'Black olives', qty: 50, unit: 'g'),
      CatalogIngredient(nameFr: 'Vinaigrette', nameEn: 'Vinaigrette', qty: 4, unit: 'cas'),
    ],
    instructionsFr: [
      'Faire cuire les œufs durs (9 min) et les haricots verts à l\'eau.',
      'Couper les tomates en quartiers et les œufs durs en deux.',
      'Dans un grand plat, disposer les haricots, les tomates et le thon.',
      'Ajouter les œufs, les anchois et les olives.',
      'Arroser de vinaigrette bien relevée avant de servir.',
    ],
    instructionsEn: [
      'Boil eggs (9 mins) and green beans until tender.',
      'Cut tomatoes into quarters and hard-boiled eggs in half.',
      'Arrange beans, tomatoes, and flaked tuna in a large dish.',
      'Add eggs, anchovies, and olives.',
      'Drizzle with vinaigrette before serving.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_chili',
    nameFr: 'Chili con Carne',
    nameEn: 'Chili con Carne',
    tone: 'tomate',
    servings: 4,
    tags: ['beef', 'lactose_free', 'gluten_free'],
    ingredients: [
      CatalogIngredient(nameFr: 'Viande hachée', nameEn: 'Ground beef', qty: 500, unit: 'g'),
      CatalogIngredient(nameFr: 'Haricots rouges', nameEn: 'Kidney beans', qty: 400, unit: 'g'),
      CatalogIngredient(nameFr: 'Tomates concassées', nameEn: 'Crushed tomatoes', qty: 400, unit: 'g'),
      CatalogIngredient(nameFr: 'Oignon', nameEn: 'Onion', qty: 1, unit: 'pc'),
      CatalogIngredient(nameFr: 'Poivron', nameEn: 'Bell pepper', qty: 1, unit: 'pc'),
      CatalogIngredient(nameFr: 'Epices', nameEn: 'Chili powder', qty: 2, unit: 'cas'),
      CatalogIngredient(nameFr: 'Huile d\'olive', nameEn: 'Olive oil', qty: 2, unit: 'cas'),
    ],
    instructionsFr: [
      'Faire revenir l\'oignon et le poivron émincés dans une cocotte.',
      'Ajouter la viande hachée and la faire dorer.',
      'Ajouter les tomates, les haricots égouttés et les épices.',
      'Laisser mijoter à feu doux pendant 40 minutes.',
      'Servir chaud, éventuellement avec du riz.',
    ],
    instructionsEn: [
      'Saute diced onion and pepper in oil in a pot.',
      'Add ground beef and cook until browned.',
      'Stir in crushed tomatoes, drained beans, and chili powder.',
      'Simmer over low heat for 40 minutes.',
      'Serve hot, optionally with rice.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_curry_poulet',
    nameFr: 'Curry de Poulet au Coco',
    nameEn: 'Coconut Chicken Curry',
    tone: 'curry',
    servings: 4,
    tags: ['poulet', 'gluten_free', 'lactose_free'],
    ingredients: [
      CatalogIngredient(nameFr: 'Filet de poulet', nameEn: 'Chicken breast', qty: 600, unit: 'g'),
      CatalogIngredient(nameFr: 'Lait de coco', nameEn: 'Coconut milk', qty: 400, unit: 'ml'),
      CatalogIngredient(nameFr: 'Oignon', nameEn: 'Onion', qty: 1, unit: 'pc'),
      CatalogIngredient(nameFr: 'Poivron', nameEn: 'Bell pepper', qty: 1, unit: 'pc'),
      CatalogIngredient(nameFr: 'Pâte de curry', nameEn: 'Curry powder / paste', qty: 2, unit: 'cas'),
      CatalogIngredient(nameFr: 'Ail', nameEn: 'Garlic', qty: 1, unit: 'gousse'),
      CatalogIngredient(nameFr: 'Gingembre', nameEn: 'Ginger', qty: 1, unit: 'cm'),
    ],
    instructionsFr: [
      'Couper le poulet et le poivron en dés. Émincer l\'oignon.',
      'Faire revenir l\'oignon, l\'ail et le gingembre.',
      'Ajouter le poulet et le poivron, puis le curry.',
      'Verser le lait de coco et laisser mijoter 20 minutes.',
      'Servir chaud avec du riz.',
    ],
    instructionsEn: [
      'Cut chicken and pepper into cubes. Slice onion.',
      'Saute onion, minced garlic, and ginger in a pan.',
      'Add chicken, bell pepper, and curry powder.',
      'Pour in coconut milk and simmer for 20 minutes.',
      'Serve hot with rice.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_pesto',
    nameFr: 'Pâtes au Pesto',
    nameEn: 'Pesto Pasta',
    tone: 'green',
    servings: 3,
    tags: ['pates', 'legumes', 'veggie'],
    ingredients: [
      CatalogIngredient(nameFr: 'Pâtes', nameEn: 'Pasta', qty: 300, unit: 'g'),
      CatalogIngredient(nameFr: 'Basilic', nameEn: 'Pesto sauce', qty: 150, unit: 'g'),
      CatalogIngredient(nameFr: 'Tomates cerises', nameEn: 'Cherry tomatoes', qty: 200, unit: 'g'),
      CatalogIngredient(nameFr: 'Parmesan', nameEn: 'Parmesan cheese', qty: 30, unit: 'g'),
      CatalogIngredient(nameFr: 'Pignons de pin', nameEn: 'Pine nuts', qty: 20, unit: 'g'),
    ],
    instructionsFr: [
      'Faire cuire les pâtes dans une grande casserole d\'eau bouillante salée.',
      'Laver et couper les tomates cerises en deux.',
      'Mélanger les pâtes chaudes égouttées avec le pesto.',
      'Ajouter les tomates cerises et le parmesan.',
      'Décorer avec les pignons de pin.',
    ],
    instructionsEn: [
      'Cook pasta in boiling salted water.',
      'Wash and cut cherry tomatoes in halves.',
      'Toss hot pasta with pesto sauce in a bowl.',
      'Add cherry tomatoes and grated parmesan.',
      'Garnish with pine nuts.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_taboule',
    nameFr: 'Taboulé Libanais',
    nameEn: 'Lebanese Tabbouleh',
    tone: 'green',
    servings: 4,
    tags: ['legumes', 'veggie', 'lactose_free'],
    ingredients: [
      CatalogIngredient(nameFr: 'Boulghour', nameEn: 'Bulgur', qty: 100, unit: 'g'),
      CatalogIngredient(nameFr: 'Persil plat', nameEn: 'Flat-leaf parsley', qty: 3, unit: 'bouquet'),
      CatalogIngredient(nameFr: 'Menthe', nameEn: 'Fresh mint', qty: 1, unit: 'bouquet'),
      CatalogIngredient(nameFr: 'Tomates', nameEn: 'Tomatoes', qty: 3, unit: 'pc'),
      CatalogIngredient(nameFr: 'Oignons', nameEn: 'Green onions', qty: 3, unit: 'pc'),
      CatalogIngredient(nameFr: 'Citron', nameEn: 'Lemons', qty: 2, unit: 'pc'),
      CatalogIngredient(nameFr: 'Huile d\'olive', nameEn: 'Olive oil', qty: 6, unit: 'cas'),
    ],
    instructionsFr: [
      'Faire gonfler le boulghour dans de l\'eau tiède pendant 15 minutes.',
      'Hacher finement le persil et la menthe.',
      'Couper les tomates et les oignons en très petits dés.',
      'Mélanger le tout avec le jus de citron et l\'huile d\'olive.',
      'Laisser reposer au frais 2 heures avant de servir.',
    ],
    instructionsEn: [
      'Soak bulgur in warm water for 15 minutes.',
      'Finely chop parsley leaves and mint.',
      'Finely dice tomatoes and green onions.',
      'Mix all ingredients together with lemon juice and olive oil.',
      'Chill in the refrigerator for 2 hours before serving.',
    ],
  ),
  CatalogRecipe(
    id: 'cat_chow_mein',
    nameFr: 'Chow Mein aux Légumes',
    nameEn: 'Veggie Chow Mein',
    tone: 'curry',
    servings: 2,
    tags: ['pates', 'legumes', 'veggie', 'lactose_free'],
    ingredients: [
      CatalogIngredient(nameFr: 'Nouilles', nameEn: 'Chow mein noodles', qty: 200, unit: 'g'),
      CatalogIngredient(nameFr: 'Chou chinois', nameEn: 'Napa cabbage', qty: 0.5, unit: 'pc'),
      CatalogIngredient(nameFr: 'Carottes', nameEn: 'Carrot', qty: 1, unit: 'pc'),
      CatalogIngredient(nameFr: 'Oignon', nameEn: 'Onion', qty: 1, unit: 'pc'),
      CatalogIngredient(nameFr: 'Sauce soja', nameEn: 'Soy sauce', qty: 3, unit: 'cas'),
      CatalogIngredient(nameFr: 'Huile de sésame', nameEn: 'Sesame oil', qty: 1, unit: 'cas'),
      CatalogIngredient(nameFr: 'Ail', nameEn: 'Garlic', qty: 1, unit: 'gousse'),
    ],
    instructionsFr: [
      'Faire cuire les nouilles et les réserver.',
      'Émincer le chou, la carotte et l\'oignon.',
      'Faire sauter les légumes dans un wok avec l\'ail.',
      'Ajouter les nouilles, la sauce soja et l\'huile de sésame.',
      'Mélanger et faire sauter 3 à 5 minutes de plus.',
    ],
    instructionsEn: [
      'Cook noodles and set aside.',
      'Shred cabbage, carrot, and onion.',
      'Stir-fry vegetables in a wok with minced garlic.',
      'Add noodles, soy sauce, and sesame oil.',
      'Toss and stir-fry for an additional 3-5 minutes.',
    ],
  ),
];

// Generator definitions for bases, styles, and sides
class _BaseGen {
  final String id;
  final String nameFr;
  final String nameEn;
  final String displayNameFr;
  final String displayNameEn;
  final double qty;
  final String unit;
  final List<String> tags;

  const _BaseGen({
    required this.id,
    required this.nameFr,
    required this.nameEn,
    required this.displayNameFr,
    required this.displayNameEn,
    required this.qty,
    required this.unit,
    required this.tags,
  });
}

class _StyleGen {
  final String nameFr;
  final String nameEn;
  final String tone;
  final List<CatalogIngredient> ingredients;
  final List<String> tags;

  const _StyleGen({
    required this.nameFr,
    required this.nameEn,
    required this.tone,
    required this.ingredients,
    required this.tags,
  });
}

class _SideGen {
  final String nameFr;
  final String nameEn;
  final List<CatalogIngredient> ingredients;
  final List<String> tags;

  const _SideGen({
    required this.nameFr,
    required this.nameEn,
    required this.ingredients,
    required this.tags,
  });
}

const List<_BaseGen> _bases = [
  _BaseGen(id: 'poulet', nameFr: 'Filet de poulet', nameEn: 'Chicken breast', displayNameFr: 'Poulet', displayNameEn: 'Chicken', qty: 500, unit: 'g', tags: ['poulet']),
  _BaseGen(id: 'saumon', nameFr: 'Pavé de saumon', nameEn: 'Salmon fillet', displayNameFr: 'Saumon', displayNameEn: 'Salmon', qty: 500, unit: 'g', tags: ['legumes']),
  _BaseGen(id: 'boeuf', nameFr: 'Steak de bœuf', nameEn: 'Beef steak', displayNameFr: 'Bœuf', displayNameEn: 'Beef', qty: 500, unit: 'g', tags: ['beef']),
  _BaseGen(id: 'tofu', nameFr: 'Tofu ferme', nameEn: 'Firm tofu', displayNameFr: 'Tofu', displayNameEn: 'Tofu', qty: 400, unit: 'g', tags: ['legumes']),
  _BaseGen(id: 'crevettes', nameFr: 'Crevettes', nameEn: 'Shrimp', displayNameFr: 'Crevettes', displayNameEn: 'Shrimp', qty: 400, unit: 'g', tags: ['legumes']),
  _BaseGen(id: 'poischiches', nameFr: 'Pois chiches', nameEn: 'Chickpeas', displayNameFr: 'Pois chiches', displayNameEn: 'Chickpeas', qty: 400, unit: 'g', tags: ['legumes']),
  _BaseGen(id: 'porc', nameFr: 'Côtes de porc', nameEn: 'Pork chops', displayNameFr: 'Porc', displayNameEn: 'Pork', qty: 500, unit: 'g', tags: ['beef']),
  _BaseGen(id: 'aubergine', nameFr: 'Aubergine', nameEn: 'Eggplant', displayNameFr: 'Aubergines', displayNameEn: 'Eggplant', qty: 2, unit: 'pc', tags: ['legumes']),
  _BaseGen(id: 'cabillaud', nameFr: 'Filet de cabillaud', nameEn: 'Cod fillet', displayNameFr: 'Cabillaud', displayNameEn: 'Cod', qty: 500, unit: 'g', tags: ['legumes']),
  _BaseGen(id: 'dinde', nameFr: 'Escalope de dinde', nameEn: 'Turkey escalope', displayNameFr: 'Dinde', displayNameEn: 'Turkey', qty: 500, unit: 'g', tags: ['poulet']),
  _BaseGen(id: 'canard', nameFr: 'Magret de canard', nameEn: 'Duck breast', displayNameFr: 'Canard', displayNameEn: 'Duck', qty: 400, unit: 'g', tags: ['beef']),
  _BaseGen(id: 'saucisse', nameFr: 'Saucisses', nameEn: 'Sausages', displayNameFr: 'Saucisses', displayNameEn: 'Sausages', qty: 4, unit: 'pc', tags: ['beef']),
  _BaseGen(id: 'tempeh', nameFr: 'Tempeh', nameEn: 'Tempeh', displayNameFr: 'Tempeh', displayNameEn: 'Tempeh', qty: 300, unit: 'g', tags: ['legumes']),
  _BaseGen(id: 'portobello', nameFr: 'Portobellos', nameEn: 'Portobello mushrooms', displayNameFr: 'Portobellos', displayNameEn: 'Portobellos', qty: 4, unit: 'pc', tags: ['legumes']),
  _BaseGen(id: 'lentilles', nameFr: 'Lentilles vertes', nameEn: 'Green lentils', displayNameFr: 'Lentilles', displayNameEn: 'Lentils', qty: 300, unit: 'g', tags: ['legumes']),
];

const List<_StyleGen> _styles = [
  _StyleGen(
    nameFr: 'sauce tomate-basilic',
    nameEn: 'tomato-basil sauce',
    tone: 'tomato',
    tags: ['legumes'],
    ingredients: [
      CatalogIngredient(nameFr: 'Tomates concassées', nameEn: 'Crushed tomatoes', qty: 400, unit: 'g'),
      CatalogIngredient(nameFr: 'Ail', nameEn: 'Garlic', qty: 2, unit: 'pc'),
      CatalogIngredient(nameFr: 'Basilic', nameEn: 'Basil', qty: 1, unit: 'pc'),
    ],
  ),
  _StyleGen(
    nameFr: 'au pesto',
    nameEn: 'pesto',
    tone: 'green',
    tags: ['legumes'],
    ingredients: [
      CatalogIngredient(nameFr: 'Basilic', nameEn: 'Basil', qty: 1, unit: 'pc'),
      CatalogIngredient(nameFr: 'Pignons de pin', nameEn: 'Pine nuts', qty: 30, unit: 'g'),
      CatalogIngredient(nameFr: 'Ail', nameEn: 'Garlic', qty: 1, unit: 'pc'),
    ],
  ),
  _StyleGen(
    nameFr: 'au curry de coco',
    nameEn: 'coconut curry',
    tone: 'curry',
    tags: ['legumes'],
    ingredients: [
      CatalogIngredient(nameFr: 'Lait de coco', nameEn: 'Coconut milk', qty: 400, unit: 'ml'),
      CatalogIngredient(nameFr: 'Pâte de curry', nameEn: 'Curry paste', qty: 2, unit: 'cas'),
      CatalogIngredient(nameFr: 'Oignon', nameEn: 'Onion', qty: 1, unit: 'pc'),
    ],
  ),
  _StyleGen(
    nameFr: 'sauce teriyaki',
    nameEn: 'teriyaki sauce',
    tone: 'curry',
    tags: ['legumes'],
    ingredients: [
      CatalogIngredient(nameFr: 'Sauce soja', nameEn: 'Soy sauce', qty: 50, unit: 'ml'),
      CatalogIngredient(nameFr: 'Miel', nameEn: 'Honey', qty: 2, unit: 'cas'),
      CatalogIngredient(nameFr: 'Gingembre', nameEn: 'Ginger', qty: 10, unit: 'g'),
    ],
  ),
  _StyleGen(
    nameFr: 'sauce crémeuse aux champignons',
    nameEn: 'creamy mushroom sauce',
    tone: 'yellow',
    tags: ['legumes'],
    ingredients: [
      CatalogIngredient(nameFr: 'Champignons', nameEn: 'Mushrooms', qty: 200, unit: 'g'),
      CatalogIngredient(nameFr: 'Crème fraîche', nameEn: 'Sour cream', qty: 200, unit: 'ml'),
      CatalogIngredient(nameFr: 'Ail', nameEn: 'Garlic', qty: 1, unit: 'pc'),
    ],
  ),
  _StyleGen(
    nameFr: 'au citron et herbes',
    nameEn: 'lemon herb',
    tone: 'yellow',
    tags: ['legumes'],
    ingredients: [
      CatalogIngredient(nameFr: 'Citron', nameEn: 'Lemon', qty: 1, unit: 'pc'),
      CatalogIngredient(nameFr: 'Herbes de Provence', nameEn: 'Mixed herbs', qty: 1, unit: 'cas'),
      CatalogIngredient(nameFr: 'Beurre', nameEn: 'Butter', qty: 30, unit: 'g'),
    ],
  ),
  _StyleGen(
    nameFr: 'au beurre d\'ail',
    nameEn: 'garlic butter',
    tone: 'yellow',
    tags: ['legumes'],
    ingredients: [
      CatalogIngredient(nameFr: 'Ail', nameEn: 'Garlic', qty: 3, unit: 'pc'),
      CatalogIngredient(nameFr: 'Beurre', nameEn: 'Butter', qty: 50, unit: 'g'),
      CatalogIngredient(nameFr: 'Persil', nameEn: 'Parsley', qty: 1, unit: 'pc'),
    ],
  ),
  _StyleGen(
    nameFr: 'sauce aigre-douce',
    nameEn: 'sweet and sour sauce',
    tone: 'tomato',
    tags: ['legumes'],
    ingredients: [
      CatalogIngredient(nameFr: 'Poivron', nameEn: 'Bell pepper', qty: 1, unit: 'pc'),
      CatalogIngredient(nameFr: 'Ananas', nameEn: 'Pineapple', qty: 150, unit: 'g'),
      CatalogIngredient(nameFr: 'Sauce aigre-douce', nameEn: 'Sweet and sour sauce', qty: 200, unit: 'ml'),
    ],
  ),
  _StyleGen(
    nameFr: 'façon tikka masala',
    nameEn: 'tikka masala style',
    tone: 'curry',
    tags: ['legumes'],
    ingredients: [
      CatalogIngredient(nameFr: 'Garam masala', nameEn: 'Garam masala', qty: 1, unit: 'cas'),
      CatalogIngredient(nameFr: 'Double de tomate', nameEn: 'Tomato paste', qty: 2, unit: 'cas'),
      CatalogIngredient(nameFr: 'Crème liquide', nameEn: 'Heavy cream', qty: 200, unit: 'ml'),
    ],
  ),
  _StyleGen(
    nameFr: 'sauce chimichurri',
    nameEn: 'chimichurri sauce',
    tone: 'green',
    tags: ['legumes'],
    ingredients: [
      CatalogIngredient(nameFr: 'Persil', nameEn: 'Parsley', qty: 1, unit: 'pc'),
      CatalogIngredient(nameFr: 'Ail', nameEn: 'Garlic', qty: 2, unit: 'pc'),
      CatalogIngredient(nameFr: 'Huile d\'olive', nameEn: 'Olive oil', qty: 50, unit: 'ml'),
    ],
  ),
  _StyleGen(
    nameFr: 'aux épices cajun',
    nameEn: 'cajun spiced',
    tone: 'curry',
    tags: ['legumes'],
    ingredients: [
      CatalogIngredient(nameFr: 'Épices cajun', nameEn: 'Cajun spices', qty: 1, unit: 'cas'),
      CatalogIngredient(nameFr: 'Poivron', nameEn: 'Bell pepper', qty: 1, unit: 'pc'),
      CatalogIngredient(nameFr: 'Oignon', nameEn: 'Onion', qty: 1, unit: 'pc'),
    ],
  ),
  _StyleGen(
    nameFr: 'sauce moutarde et miel',
    nameEn: 'honey mustard sauce',
    tone: 'yellow',
    tags: ['legumes'],
    ingredients: [
      CatalogIngredient(nameFr: 'Moutarde', nameEn: 'Mustard', qty: 2, unit: 'cas'),
      CatalogIngredient(nameFr: 'Miel', nameEn: 'Honey', qty: 2, unit: 'cas'),
      CatalogIngredient(nameFr: 'Crème liquide', nameEn: 'Heavy cream', qty: 100, unit: 'ml'),
    ],
  ),
  _StyleGen(
    nameFr: 'sauce satay aux cacahuètes',
    nameEn: 'peanut satay sauce',
    tone: 'curry',
    tags: ['legumes'],
    ingredients: [
      CatalogIngredient(nameFr: 'Beurre de cacahuète', nameEn: 'Peanut butter', qty: 3, unit: 'cas'),
      CatalogIngredient(nameFr: 'Lait de coco', nameEn: 'Coconut milk', qty: 200, unit: 'ml'),
      CatalogIngredient(nameFr: 'Sauce soja', nameEn: 'Soy sauce', qty: 1, unit: 'cas'),
    ],
  ),
  _StyleGen(
    nameFr: 'au glaçage balsamique',
    nameEn: 'balsamic glazed',
    tone: 'tomato',
    tags: ['legumes'],
    ingredients: [
      CatalogIngredient(nameFr: 'Vinaigre balsamique', nameEn: 'Balsamic vinegar', qty: 100, unit: 'ml'),
      CatalogIngredient(nameFr: 'Cassonade', nameEn: 'Brown sugar', qty: 1, unit: 'cas'),
    ],
  ),
  _StyleGen(
    nameFr: 'sauce barbecue',
    nameEn: 'barbecue sauce',
    tone: 'tomato',
    tags: ['legumes'],
    ingredients: [
      CatalogIngredient(nameFr: 'Sauce barbecue', nameEn: 'Barbecue sauce', qty: 150, unit: 'ml'),
      CatalogIngredient(nameFr: 'Oignon rouge', nameEn: 'Red onion', qty: 1, unit: 'pc'),
    ],
  ),
];

const List<_SideGen> _sides = [
  _SideGen(
    nameFr: 'Riz jasmin',
    nameEn: 'Jasmine rice',
    tags: ['legumes'],
    ingredients: [
      CatalogIngredient(nameFr: 'Riz jasmin', nameEn: 'Jasmine rice', qty: 300, unit: 'g'),
    ],
  ),
  _SideGen(
    nameFr: 'Quinoa',
    nameEn: 'Quinoa',
    tags: ['legumes'],
    ingredients: [
      CatalogIngredient(nameFr: 'Quinoa', nameEn: 'Quinoa', qty: 250, unit: 'g'),
    ],
  ),
  _SideGen(
    nameFr: 'Asperges rôties',
    nameEn: 'roasted asparagus',
    tags: ['legumes'],
    ingredients: [
      CatalogIngredient(nameFr: 'Asperges', nameEn: 'Asparagus', qty: 400, unit: 'g'),
      CatalogIngredient(nameFr: 'Huile d\'olive', nameEn: 'Olive oil', qty: 2, unit: 'cas'),
    ],
  ),
  _SideGen(
    nameFr: 'Purée de pommes de terre',
    nameEn: 'mashed potatoes',
    tags: ['legumes'],
    ingredients: [
      CatalogIngredient(nameFr: 'Pommes de terre', nameEn: 'Potatoes', qty: 800, unit: 'g'),
      CatalogIngredient(nameFr: 'Beurre', nameEn: 'Butter', qty: 30, unit: 'g'),
      CatalogIngredient(nameFr: 'Lait', nameEn: 'Milk', qty: 100, unit: 'ml'),
    ],
  ),
  _SideGen(
    nameFr: 'Pâtes Penne',
    nameEn: 'penne pasta',
    tags: ['pates'],
    ingredients: [
      CatalogIngredient(nameFr: 'Pâtes Penne', nameEn: 'Penne pasta', qty: 300, unit: 'g'),
    ],
  ),
  _SideGen(
    nameFr: 'Semoule',
    nameEn: 'couscous',
    tags: ['legumes'],
    ingredients: [
      CatalogIngredient(nameFr: 'Semoule', nameEn: 'Couscous', qty: 250, unit: 'g'),
    ],
  ),
  _SideGen(
    nameFr: 'Frites de patate douce',
    nameEn: 'sweet potato fries',
    tags: ['legumes'],
    ingredients: [
      CatalogIngredient(nameFr: 'Patates douces', nameEn: 'Sweet potatoes', qty: 600, unit: 'g'),
    ],
  ),
  _SideGen(
    nameFr: 'Salade verte',
    nameEn: 'green salad',
    tags: ['legumes'],
    ingredients: [
      CatalogIngredient(nameFr: 'Salade', nameEn: 'Salad', qty: 1, unit: 'pc'),
      CatalogIngredient(nameFr: 'Vinaigrette', nameEn: 'Vinaigrette', qty: 2, unit: 'cas'),
    ],
  ),
  _SideGen(
    nameFr: 'Brocolis vapeur',
    nameEn: 'steamed broccoli',
    tags: ['legumes'],
    ingredients: [
      CatalogIngredient(nameFr: 'Brocoli', nameEn: 'Broccoli', qty: 400, unit: 'g'),
    ],
  ),
  _SideGen(
    nameFr: 'Carottes rôties',
    nameEn: 'roasted carrots',
    tags: ['legumes'],
    ingredients: [
      CatalogIngredient(nameFr: 'Carottes', nameEn: 'Carrots', qty: 500, unit: 'g'),
      CatalogIngredient(nameFr: 'Huile d\'olive', nameEn: 'Olive oil', qty: 2, unit: 'cas'),
    ],
  ),
  _SideGen(
    nameFr: 'Épinards sautés',
    nameEn: 'sauteed spinach',
    tags: ['legumes'],
    ingredients: [
      CatalogIngredient(nameFr: 'Épinards', nameEn: 'Spinach', qty: 300, unit: 'g'),
      CatalogIngredient(nameFr: 'Beurre', nameEn: 'Butter', qty: 20, unit: 'g'),
    ],
  ),
  _SideGen(
    nameFr: 'Pain à l\'ail',
    nameEn: 'garlic bread',
    tags: ['legumes'],
    ingredients: [
      CatalogIngredient(nameFr: 'Pain complet', nameEn: 'Bread', qty: 1, unit: 'pc'),
      CatalogIngredient(nameFr: 'Beurre d\'ail', nameEn: 'Garlic butter', qty: 50, unit: 'g'),
    ],
  ),
  _SideGen(
    nameFr: 'Riz de chou-fleur',
    nameEn: 'cauliflower rice',
    tags: ['legumes'],
    ingredients: [
      CatalogIngredient(nameFr: 'Riz de chou-fleur', nameEn: 'Cauliflower rice', qty: 400, unit: 'g'),
    ],
  ),
  _SideGen(
    nameFr: 'Polenta',
    nameEn: 'polenta',
    tags: ['legumes'],
    ingredients: [
      CatalogIngredient(nameFr: 'Polenta', nameEn: 'Polenta', qty: 200, unit: 'g'),
      CatalogIngredient(nameFr: 'Parmesan', nameEn: 'Parmesan cheese', qty: 30, unit: 'g'),
    ],
  ),
];

// Generates 200 distinct recipes dynamically on startup.
List<CatalogRecipe> _generateRecipes() {
  final List<CatalogRecipe> generated = [];

  for (int i = 0; i < 200; i++) {
    final base = _bases[i % _bases.length];
    final style = _styles[(i * 7) % _styles.length];
    final side = _sides[(i * 13) % _sides.length];

    final nameFr = "${base.displayNameFr} ${style.nameFr} et ${side.nameFr}";
    final capitalizedStyleEn = style.nameEn[0].toUpperCase() + style.nameEn.substring(1);
    final nameEn = "$capitalizedStyleEn ${base.displayNameEn} with ${side.nameEn}";

    final tagsSet = <String>{}
      ..addAll(base.tags)
      ..addAll(style.tags)
      ..addAll(side.tags);
    final tags = tagsSet.toList();

    final List<CatalogIngredient> ingredients = [];
    ingredients.add(CatalogIngredient(
      nameFr: base.nameFr,
      nameEn: base.nameEn,
      qty: base.qty,
      unit: base.unit,
    ));
    ingredients.addAll(style.ingredients);
    ingredients.addAll(side.ingredients);

    final instructionsFr = [
      "Préparer ${side.nameFr.toLowerCase()} selon les instructions de préparation.",
      "Assaisonner ${base.nameFr.toLowerCase()} de sel, poivre et épices.",
      "Faire cuire ${base.nameFr.toLowerCase()} dans une poêle chaude avec un filet d'huile.",
      "Ajouter les ingrédients pour la préparation ${style.nameFr} et laisser mijoter.",
      "Dresser le tout bien chaud avec ${side.nameFr.toLowerCase()} et déguster."
    ];

    final instructionsEn = [
      "Prepare the ${side.nameEn.toLowerCase()} following the directions.",
      "Season the ${base.nameEn.toLowerCase()} with salt, pepper, and spices.",
      "Cook the ${base.nameEn.toLowerCase()} in a hot skillet with a splash of oil.",
      "Add the ingredients for the ${style.nameEn} and let simmer.",
      "Plate the dish hot with the ${side.nameEn.toLowerCase()} and enjoy."
    ];

    generated.add(CatalogRecipe(
      id: 'gen_${i}_${base.id}',
      nameFr: nameFr,
      nameEn: nameEn,
      tone: style.tone,
      servings: 4,
      ingredients: ingredients,
      instructionsFr: instructionsFr,
      instructionsEn: instructionsEn,
      tags: tags,
    ));
  }

  return generated;
}

// Single catalog list combining classic and generated recipes.
final List<CatalogRecipe> kCatalogRecipes = [
  ..._kBaseCatalogRecipes,
  ..._generateRecipes(),
];
