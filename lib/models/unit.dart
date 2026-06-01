/// Units of measure + quantity scaling / formatting helpers.
/// Ported from the prototype's data.jsx.

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
