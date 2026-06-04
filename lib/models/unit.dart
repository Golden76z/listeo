// Units of measure + quantity scaling / formatting helpers.
// Ported from the prototype's data.jsx.

enum UnitKind { count, mass }

class LoUnit {
  final String id;
  final String label;
  final UnitKind kind;
  final String short;
  const LoUnit(this.id, this.label, this.kind, this.short);
}

const List<LoUnit> kUnits = [
  LoUnit('pc', 'pièce', UnitKind.count, ''),
  LoUnit('g', 'g', UnitKind.mass, 'g'),
  LoUnit('kg', 'kg', UnitKind.mass, 'kg'),
  LoUnit('ml', 'ml', UnitKind.mass, 'ml'),
  LoUnit('L', 'L', UnitKind.mass, 'L'),
  LoUnit('cas', 'c. à s', UnitKind.count, 'c.à.s'),
  LoUnit('cac', 'c. à c', UnitKind.count, 'c.à.c'),
  LoUnit('pincee', 'pincée', UnitKind.count, 'pincée'),
];

LoUnit unitById(String id) =>
    kUnits.firstWhere((u) => u.id == id, orElse: () => kUnits.first);

/// Round a scaled quantity sensibly per unit.
double roundQty(double q, String unitId) {
  final u = unitById(unitId);
  if (u.kind == UnitKind.count) {
    if (unitId == 'cas' || unitId == 'cac' || unitId == 'pincee') {
      // allow halves for spoons / pinches
      final v = (q * 2).round() / 2;
      return v < 0.5 ? 0.5 : v;
    }
    final v = q.round();
    return v < 1 ? 1 : v.toDouble();
  }
  // mass / volume
  if (q >= 100) return (q / 10).round() * 10;
  if (q >= 20) return (q / 5).round() * 5;
  return q.round().toDouble();
}

/// French-style pretty number: 1.5 → "1,5", 2 → "2".
String numFr(double n) {
  final r = (n * 100).round() / 100;
  var s = r == r.roundToDouble() ? r.toInt().toString() : r.toString();
  return s.replaceAll('.', ',');
}

class FormattedQty {
  final String value;
  final String suffix;
  const FormattedQty(this.value, this.suffix);
}

/// Format a quantity + unit for display.
FormattedQty fmtQty(double qty, String unitId) {
  final u = unitById(unitId);
  if (u.id == 'pc') return FormattedQty('×${numFr(qty)}', '');
  return FormattedQty(numFr(qty), ' ${u.short}');
}

class ParsedItem {
  final String name;
  final double qty;
  final String unit;
  const ParsedItem({required this.name, required this.qty, required this.unit});
}

ParsedItem parseItemFr(String line) {
  final input = line.trim();
  if (input.isEmpty) {
    return const ParsedItem(name: '', qty: 1, unit: 'pc');
  }

  final regex = RegExp(
    r'^([0-9]+(?:[.,][0-9]+)?)\s*(kg|g|ml|l|L|cas|cac|c\.à\.s|c\.à\.c|cs|cc|pincées?|pincée)?\s*(?:de\s+|d\x27\s+|d’\s+)?(.+)$',
    caseSensitive: false,
  );

  final match = regex.firstMatch(input);
  if (match != null) {
    final qtyStr = match.group(1)!;
    final unitStr = match.group(2)?.toLowerCase();
    final nameStr = match.group(3)!.trim();

    final qty = double.tryParse(qtyStr.replaceAll(',', '.')) ?? 1.0;
    var unit = 'pc';
    if (unitStr != null) {
      if (unitStr == 'g') {
        unit = 'g';
      } else if (unitStr == 'kg') {
        unit = 'kg';
      } else if (unitStr == 'ml') {
        unit = 'ml';
      } else if (unitStr == 'l') {
        unit = 'L';
      } else if (unitStr == 'cas' || unitStr == 'c.à.s' || unitStr == 'cs') {
        unit = 'cas';
      } else if (unitStr == 'cac' || unitStr == 'c.à.c' || unitStr == 'cc') {
        unit = 'cac';
      } else if (unitStr.startsWith('pinc')) {
        unit = 'pincee';
      }
    }
    return ParsedItem(name: nameStr, qty: qty, unit: unit);
  }

  return ParsedItem(name: input, qty: 1.0, unit: 'pc');
}

const Map<String, String> kProductDefaultUnits = {
  'banane': 'pc',
  'bananes': 'pc',
  'pomme': 'pc',
  'pommes': 'pc',
  'orange': 'pc',
  'oranges': 'pc',
  'citron': 'pc',
  'citrons': 'pc',
  'fraise': 'g',
  'fraises': 'g',
  'tomate': 'pc',
  'tomates': 'pc',
  'carotte': 'pc',
  'carottes': 'pc',
  'oignon': 'pc',
  'oignons': 'pc',
  'ail': 'pc',
  'courgette': 'pc',
  'courgettes': 'pc',
  'pomme de terre': 'kg',
  'pommes de terre': 'kg',
  'patates': 'kg',
  'salade': 'pc',
  'avocat': 'pc',
  'avocats': 'pc',
  'pain': 'pc',
  'baguette': 'pc',
  'lait': 'L',
  'beurre': 'g',
  'fromage': 'g',
  'fromage râpé': 'g',
  'crème': 'ml',
  'crème fraîche': 'ml',
  'yaourt': 'pc',
  'yaourts': 'pc',
  'oeuf': 'pc',
  'oeufs': 'pc',
  'œufs': 'pc',
  'œuf': 'pc',
  'viande': 'g',
  'viande hachée': 'g',
  'poulet': 'g',
  'filet de poulet': 'g',
  'jambon': 'pc',
  'saumon': 'g',
  'poisson': 'g',
  'pâtes': 'g',
  'spaghetti': 'g',
  'riz': 'g',
  'farine': 'g',
  'sucre': 'g',
  'sel': 'pincee',
  'poivre': 'pincee',
  'huile': 'L',
  'huile d\'olive': 'L',
  'eau': 'L',
  'bière': 'pc',
  'bières': 'pc',
  'vin': 'pc',
  'café': 'g',
  'chocolat': 'g',
  'chips': 'pc',
  'houmous': 'pc',
  'olives': 'g',
  'asperges': 'g',
  'brocoli': 'g',
  'champignons': 'g',
  'poivron': 'pc',
  'aubergine': 'pc',
  'portobellos': 'pc',
  'pignons de pin': 'g',
  'sauce soja': 'ml',
  'miel': 'cas',
  'gingembre': 'g',
  'herbes de provence': 'cas',
  'ananas': 'g',
  'sauce aigre-douce': 'ml',
  'garam masala': 'cas',
  'double de tomate': 'cas',
  'vinaigre balsamique': 'ml',
  'cassonade': 'g',
  'sauce barbecue': 'ml',
  'oignon rouge': 'pc',
  'beurre de cacahuète': 'cas',
  'pavé de saumon': 'g',
  'steak de bœuf': 'g',
  'tofu ferme': 'g',
  'crevettes': 'g',
  'côtes de porc': 'g',
  'filet de cabillaud': 'g',
  'escalope de dinde': 'g',
  'magret de canard': 'g',
  'saucisses': 'pc',
  'tempeh': 'g',
  'lentilles vertes': 'g',
  'pâtes penne': 'g',
  'quinoa': 'g',
  'semoule': 'g',
  'patates douces': 'g',
  'vinaigrette': 'cas',
  'persil': 'pc',
  'basilic': 'pc',
  'crème liquide': 'ml',
  'beurre d\'ail': 'g',
  'polenta': 'g',
  'pâte brisée': 'pc',
  'pommes gala': 'pc',
  'mascarpone': 'g',
  'biscuits cuillères': 'pc',
  'amaretto': 'ml',
  'citron vert': 'pc',
  'sucre glace': 'g',
  'framboises': 'g',
  'pâte à gaufres': 'g',
};

const Map<String, String> kProductCategories = {
  'banane': 'Fruits & Légumes',
  'bananes': 'Fruits & Légumes',
  'pomme': 'Fruits & Légumes',
  'pommes': 'Fruits & Légumes',
  'orange': 'Fruits & Légumes',
  'oranges': 'Fruits & Légumes',
  'citron': 'Fruits & Légumes',
  'citrons': 'Fruits & Légumes',
  'fraise': 'Fruits & Légumes',
  'fraises': 'Fruits & Légumes',
  'tomate': 'Fruits & Légumes',
  'tomates': 'Fruits & Légumes',
  'carotte': 'Fruits & Légumes',
  'carottes': 'Fruits & Légumes',
  'oignon': 'Fruits & Légumes',
  'oignons': 'Fruits & Légumes',
  'ail': 'Fruits & Légumes',
  'courgette': 'Fruits & Légumes',
  'courgettes': 'Fruits & Légumes',
  'pomme de terre': 'Fruits & Légumes',
  'pommes de terre': 'Fruits & Légumes',
  'patates': 'Fruits & Légumes',
  'salade': 'Fruits & Légumes',
  'avocat': 'Fruits & Légumes',
  'avocats': 'Fruits & Légumes',
  'épinards': 'Fruits & Légumes',
  'olives': 'Fruits & Légumes',
  'asperges': 'Fruits & Légumes',
  'brocoli': 'Fruits & Légumes',
  'champignons': 'Fruits & Légumes',
  'poivron': 'Fruits & Légumes',
  'aubergine': 'Fruits & Légumes',
  'aubergines': 'Fruits & Légumes',
  'portobellos': 'Fruits & Légumes',
  'portobello': 'Fruits & Légumes',
  'oignon rouge': 'Fruits & Légumes',
  'gingembre': 'Fruits & Légumes',
  'persil': 'Fruits & Légumes',
  'basilic': 'Fruits & Légumes',
  'citron vert': 'Fruits & Légumes',
  'pommes gala': 'Fruits & Légumes',
  'framboises': 'Fruits & Légumes',

  'lait': 'Produits Laitiers & Œufs',
  'beurre': 'Produits Laitiers & Œufs',
  'fromage': 'Produits Laitiers & Œufs',
  'fromage râpé': 'Produits Laitiers & Œufs',
  'parmesan': 'Produits Laitiers & Œufs',
  'crème': 'Produits Laitiers & Œufs',
  'crème fraîche': 'Produits Laitiers & Œufs',
  'yaourt': 'Produits Laitiers & Œufs',
  'yaourts': 'Produits Laitiers & Œufs',
  'oeuf': 'Produits Laitiers & Œufs',
  'oeufs': 'Produits Laitiers & Œufs',
  'œufs': 'Produits Laitiers & Œufs',
  'œuf': 'Produits Laitiers & Œufs',
  'mascarpone': 'Produits Laitiers & Œufs',
  'crème liquide': 'Produits Laitiers & Œufs',
  'beurre d\'ail': 'Produits Laitiers & Œufs',

  'pain': 'Boulangerie',
  'pain complet': 'Boulangerie',
  'baguette': 'Boulangerie',
  'croissant': 'Boulangerie',
  'croûtons': 'Boulangerie',
  'pâte brisée': 'Boulangerie',
  'biscuits cuillères': 'Boulangerie',

  'viande': 'Boucherie & Poissonnerie',
  'viande hachée': 'Boucherie & Poissonnerie',
  'poulet': 'Boucherie & Poissonnerie',
  'filet de poulet': 'Boucherie & Poissonnerie',
  'jambon': 'Boucherie & Poissonnerie',
  'saumon': 'Boucherie & Poissonnerie',
  'poisson': 'Boucherie & Poissonnerie',
  'pavé de saumon': 'Boucherie & Poissonnerie',
  'steak de bœuf': 'Boucherie & Poissonnerie',
  'crevettes': 'Boucherie & Poissonnerie',
  'côtes de porc': 'Boucherie & Poissonnerie',
  'filet de cabillaud': 'Boucherie & Poissonnerie',
  'escalope de dinde': 'Boucherie & Poissonnerie',
  'magret de canard': 'Boucherie & Poissonnerie',
  'saucisses': 'Boucherie & Poissonnerie',

  'pâtes': 'Épicerie',
  'spaghetti': 'Épicerie',
  'riz': 'Épicerie',
  'farine': 'Épicerie',
  'sucre': 'Épicerie',
  'sel': 'Épicerie',
  'poivre': 'Épicerie',
  'huile': 'Épicerie',
  'huile d\'olive': 'Épicerie',
  'café': 'Épicerie',
  'café moulu': 'Épicerie',
  'chocolat': 'Épicerie',
  'pignons de pin': 'Épicerie',
  'sauce soja': 'Épicerie',
  'miel': 'Épicerie',
  'herbes de provence': 'Épicerie',
  'ananas': 'Épicerie',
  'sauce aigre-douce': 'Épicerie',
  'garam masala': 'Épicerie',
  'double de tomate': 'Épicerie',
  'vinaigre balsamique': 'Épicerie',
  'cassonade': 'Épicerie',
  'sauce barbecue': 'Épicerie',
  'beurre de cacahuète': 'Épicerie',
  'tofu ferme': 'Épicerie',
  'tempeh': 'Épicerie',
  'lentilles vertes': 'Épicerie',
  'pâtes penne': 'Épicerie',
  'quinoa': 'Épicerie',
  'semoule': 'Épicerie',
  'patates douces': 'Épicerie',
  'vinaigrette': 'Épicerie',
  'polenta': 'Épicerie',
  'sucre glace': 'Épicerie',
  'amaretto': 'Épicerie',
  'chips': 'Épicerie',
  'houmous': 'Épicerie',
  'pois chiches': 'Épicerie',
  'lait de coco': 'Épicerie',
  'pâte de curry': 'Épicerie',
  'levure': 'Épicerie',
  'tomates concassées': 'Épicerie',

  'eau': 'Boissons',
  'jus': 'Boissons',
  'soda': 'Boissons',
  'bière': 'Boissons',
  'bières': 'Boissons',
  'vin': 'Boissons',
};

String getCategoryForProduct(String name) {
  final cleanName = name.trim().toLowerCase();
  if (kProductCategories.containsKey(cleanName)) {
    return kProductCategories[cleanName]!;
  }
  for (final entry in kProductCategories.entries) {
    if (cleanName.contains(entry.key)) {
      return entry.value;
    }
  }
  return 'En vrac';
}



