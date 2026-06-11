import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/store.dart';
import '../data/catalog.dart';
import '../theme/app_theme.dart';
import '../theme/icons.dart';
import '../widgets/primitives.dart';
import '../widgets/sheets.dart';
import '../widgets/toast.dart';
import '../screens/cooking_screen.dart';

void openFridgeRouletteSheet(BuildContext context) {
  showLoSheet(
    context,
    builder: (ctx) => const FridgeRouletteBody(),
  );
}

class FridgeRouletteBody extends StatefulWidget {
  const FridgeRouletteBody({super.key});

  @override
  State<FridgeRouletteBody> createState() => _FridgeRouletteBodyState();
}

class _FridgeRouletteBodyState extends State<FridgeRouletteBody> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _rotationAnim;

  List<FridgeMatch> _topMatches = [];
  int _selectedIndex = -1;
  bool _isSpinning = false;
  bool _hasSpun = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _rotationAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOutCubic,
    );

    _animCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
          _hasSpun = true;
        });
      }
    });

    _loadMatches();
  }

  void _loadMatches() {
    final store = context.read<AppStore>();
    final allMatches = store.getFridgeMatches();
    final hundredPercentMatches = allMatches.where((m) => m.matchRatio == 1.0).toList();
    // Use the top 6 matches (or fewer if catalog is small)
    setState(() {
      _topMatches = hundredPercentMatches.take(math.min(6, hundredPercentMatches.length)).toList();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning || _topMatches.isEmpty) return;

    setState(() {
      _isSpinning = true;
      _hasSpun = false;
      _selectedIndex = math.Random().nextInt(_topMatches.length);
    });

    final double arcAngle = 2 * math.pi / _topMatches.length;
    // target stops exactly at the top (-pi/2)
    final double targetOffset = -(_selectedIndex * arcAngle) - (arcAngle / 2) - (math.pi / 2);
    // Add 4 full rotations for visual spinning effect
    final double targetRotation = (4 * 2 * math.pi) + targetOffset;

    _rotationAnim = Tween<double>(
      begin: 0.0,
      end: targetRotation,
    ).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOutCubic,
    ));

    _animCtrl.reset();
    _animCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final isFr = store.locale == 'fr';

    if (_topMatches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            isFr ? 'Aucune recette trouvée.' : 'No recipes found.',
            style: LoTheme.font(size: 16, weight: FontWeight.w700),
          ),
        ),
      );
    }

    // Segments colors mapping
    final colors = [
      Tone.of('green').soft,
      Tone.of('yellow').soft,
      Tone.of('curry').soft,
      Tone.of('tomate').soft,
      Tone.of('salade').soft,
      Tone.of('sucre').soft,
    ].sublist(0, _topMatches.length);

    final selectedMatch = _selectedIndex >= 0 ? _topMatches[_selectedIndex] : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          isFr ? 'Roulette du Frigo' : 'Fridge Roulette',
          style: LoTheme.font(size: 22, weight: FontWeight.w700, letterSpacing: -0.4),
        ),
        const SizedBox(height: 4),
        Text(
          isFr
              ? 'Laisse la roulette choisir ton prochain repas !'
              : 'Let the roulette pick your next meal!',
          style: LoTheme.font(size: 14, color: LoTheme.ink3, weight: FontWeight.w500),
        ),
        const SizedBox(height: 24),

        // Animated Roulette Wheel Stack
        Stack(
          alignment: Alignment.center,
          children: [
            // Rotated custom paint wheel
            AnimatedBuilder(
              animation: _rotationAnim,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnim.value,
                  child: CustomPaint(
                    size: const Size(200, 200),
                    painter: _RoulettePainter(colors),
                  ),
                );
              },
            ),
            // Top pointer indicator arrow
            Positioned(
              top: 0,
              child: CustomPaint(
                size: const Size(24, 20),
                painter: _PointerPainter(),
              ),
            ),
            // Spin again central tap zone
            GestureDetector(
              onTap: _spin,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: LoTheme.cardShadow,
                  border: Border.all(color: LoTheme.lineStrong, width: 2),
                ),
                child: const Icon(
                  Icons.casino_outlined,
                  color: LoTheme.primary,
                  size: 26,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Actions
        if (!_isSpinning && !_hasSpun)
          LoButton(
            label: isFr ? 'Lancer la roulette' : 'Spin the wheel',
            icon: Icons.play_arrow_rounded,
            onTap: _spin,
          ),

        // Reveal matched recipe result
        if (!_isSpinning && _hasSpun && selectedMatch != null) ...[
          _RecipeResultCard(match: selectedMatch, store: store),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: LoButton(
                  label: isFr ? 'Lancer encore' : 'Spin again',
                  variant: BtnVariant.soft,
                  icon: Icons.refresh_rounded,
                  onTap: _spin,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LoButton(
                  label: isFr ? 'Cuisiner' : 'Cook',
                  variant: BtnVariant.primary,
                  icon: AppIcons.utensils,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CookingScreen(
                          recipeName: isFr ? selectedMatch.recipe.nameFr : selectedMatch.recipe.nameEn,
                          tone: selectedMatch.recipe.tone,
                          instructions: isFr ? selectedMatch.recipe.instructionsFr : selectedMatch.recipe.instructionsEn,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 30),
      ],
    );
  }
}

class _RoulettePainter extends CustomPainter {
  final List<Color> colors;

  _RoulettePainter(this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()..style = PaintingStyle.fill;

    final double arcAngle = 2 * math.pi / colors.length;

    for (int i = 0; i < colors.length; i++) {
      paint.color = colors[i];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * arcAngle,
        arcAngle,
        true,
        paint,
      );
    }

    // Dividers
    final linePaint = Paint()
      ..color = LoTheme.lineStrong
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < colors.length; i++) {
      final double angle = i * arcAngle;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), linePaint);
    }

    // Outer circle
    final outerPaint = Paint()
      ..color = LoTheme.lineStrong
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, outerPaint);

    // Center pin circle background
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.25, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = LoTheme.danger
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0.0, 0.0)
      ..lineTo(size.width, 0.0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RecipeResultCard extends StatelessWidget {
  final FridgeMatch match;
  final AppStore store;

  const _RecipeResultCard({required this.match, required this.store});

  void _addMissingIngredient(BuildContext context, CatalogIngredient ing) {
    final isFr = store.locale == 'fr';
    final name = isFr ? ing.nameFr : ing.nameEn;

    // Retrieve or auto-create active shopping list
    String listId;
    String listName;
    if (store.lists.isNotEmpty) {
      listId = store.lists.first.id;
      listName = store.lists.first.name;
    } else {
      listId = store.createList(
        isFr ? 'Courses de la semaine' : 'Weekly Groceries',
        [],
        'green',
      );
      listName = isFr ? 'Courses de la semaine' : 'Weekly Groceries';
    }

    store.addLooseItem(
      listId,
      name: name,
      qty: ing.qty,
      unit: ing.unit,
    );

    LoToast.show(
      context,
      isFr ? '$name ajouté à $listName' : '$name added to $listName',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFr = store.locale == 'fr';
    final r = match.recipe;
    final tn = Tone.of(r.tone);
    final name = isFr ? r.nameFr : r.nameEn;

    final ratioPct = (match.matchRatio * 100).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LoTheme.surface,
        borderRadius: BorderRadius.circular(LoTheme.radius),
        border: Border.all(color: LoTheme.line),
        boxShadow: LoTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tn.soft,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(AppIcons.utensils, size: 21, color: tn.dot),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: LoTheme.font(size: 17, weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isFr
                          ? '$ratioPct% en stock (${match.matchCount}/${match.totalCount})'
                          : '$ratioPct% in stock (${match.matchCount}/${match.totalCount})',
                      style: LoTheme.font(
                        size: 13,
                        weight: FontWeight.w600,
                        color: match.matchRatio == 1.0
                            ? LoTheme.primaryPress
                            : (match.matchRatio >= 0.5 ? LoTheme.accentInk : LoTheme.danger),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 1,
            color: LoTheme.line,
          ),
          const SizedBox(height: 10),
          Text(
            isFr ? 'Ingrédients :' : 'Ingredients:',
            style: LoTheme.font(size: 14, weight: FontWeight.w700),
          ),
          const SizedBox(height: 8),

          // List ingredients with in stock checkmarks vs add buttons
          Column(
            children: r.ingredients.map((ing) {
              final ingName = isFr ? ing.nameFr : ing.nameEn;
              final inStock = store.isItemInStock(ing.nameFr) || store.isItemInStock(ing.nameEn);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          inStock ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          size: 16,
                          color: inStock ? LoTheme.primary : LoTheme.ink3,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$ingName (${ing.qty == ing.qty.toInt() ? ing.qty.toInt() : ing.qty} ${ing.unit})',
                          style: LoTheme.font(
                            size: 13.5,
                            weight: FontWeight.w600,
                            color: inStock ? LoTheme.ink : LoTheme.ink3,
                          ),
                        ),
                      ],
                    ),
                    if (!inStock)
                      Pressable(
                        scale: 0.88,
                        onTap: () => _addMissingIngredient(context, ing),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: LoTheme.primarySoft,
                          ),
                          child: const Icon(
                            AppIcons.plus,
                            size: 16,
                            color: LoTheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
