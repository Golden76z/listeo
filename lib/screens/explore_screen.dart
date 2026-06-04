import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/store.dart';
import '../data/catalog.dart';
import '../models/models.dart';
import '../models/unit.dart';
import '../theme/app_theme.dart';
import '../theme/icons.dart';
import '../l10n/l10n.dart';
import '../widgets/primitives.dart';
import '../widgets/sheets.dart';
import '../widgets/animations.dart';
import '../widgets/toast.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _search = TextEditingController();
  String _q = '';
  String _activeTag = 'all';

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() => _q = _search.text));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final isFr = store.locale == 'fr';

    // Categories filter chips
    final filterTags = [
      (id: 'all', label: context.t('filter.all')),
      (id: 'pates', label: context.t('filter.pasta')),
      (id: 'poulet', label: context.t('filter.chicken')),
      (id: 'beef', label: context.t('filter.beef')),
      (id: 'legumes', label: context.t('filter.vegetables')),
      (id: 'dessert', label: context.t('filter.dessert')),
    ];

    // Filter recipes by search query + selected tag chip
    final filtered = kCatalogRecipes.where((r) {
      final name = isFr ? r.nameFr : r.nameEn;
      final matchesQuery = name.toLowerCase().contains(_q.toLowerCase());
      if (!matchesQuery) return false;

      if (_activeTag != 'all') {
        return r.tags.contains(_activeTag);
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.t('title.discover'), style: LoTheme.font(size: 30, weight: FontWeight.w700, letterSpacing: -0.6)),
                  const LanguageToggle(),
                ],
              ),
              const SizedBox(height: 4),
              Text(context.t('subtitle.discover'), style: LoTheme.font(size: 14, weight: FontWeight.w500, color: LoTheme.ink3)),
              const SizedBox(height: 14),
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(color: LoTheme.surface2, borderRadius: BorderRadius.circular(LoTheme.r(0.9))),
                child: Row(children: [
                  const Icon(AppIcons.search, size: 18, color: LoTheme.ink3),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _search,
                      cursorColor: LoTheme.primary,
                      style: LoTheme.font(size: 15, weight: FontWeight.w600),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: context.t('search.explore'),
                        hintStyle: LoTheme.font(size: 15, weight: FontWeight.w600, color: LoTheme.ink3),
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: filterTags.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (c, idx) {
                    final tag = filterTags[idx];
                    final active = _activeTag == tag.id;
                    return Pressable(
                      scale: 0.94,
                      onTap: () => setState(() => _activeTag = tag.id),
                      child: AnimatedContainer(
                        duration: LoTheme.fast,
                        curve: LoTheme.ease,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: active ? LoTheme.primary : LoTheme.surface2,
                          borderRadius: BorderRadius.circular(LoTheme.r(0.8)),
                        ),
                        child: Text(
                          tag.label,
                          style: LoTheme.font(size: 13, weight: FontWeight.w700, color: active ? Colors.white : LoTheme.ink2),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(AppIcons.book, size: 34, color: LoTheme.lineStrong),
                    const SizedBox(height: 12),
                    Text(context.t('search.no_explore'), style: LoTheme.font(size: 15, weight: FontWeight.w600, color: LoTheme.ink3)),
                  ]),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (c, i) => FadeSlideIn(index: i, child: _CatalogRecipeCard(recipe: filtered[i])),
                ),
        ),
      ],
    );
  }
}

class _CatalogRecipeCard extends StatelessWidget {
  final CatalogRecipe recipe;
  const _CatalogRecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final isFr = store.locale == 'fr';
    final tn = Tone.of(recipe.tone);
    final name = isFr ? recipe.nameFr : recipe.nameEn;

    return Pressable(
      scale: 0.98,
      onTap: () => _openCatalogDetail(context, recipe),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LoTheme.surface,
          borderRadius: BorderRadius.circular(LoTheme.radius),
          border: Border.all(color: LoTheme.line),
          boxShadow: LoTheme.cardShadow,
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: tn.soft, borderRadius: BorderRadius.circular(13)),
            child: Icon(AppIcons.utensils, size: 21, color: tn.dot),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: LoTheme.font(size: 16.5, weight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(
                '${recipe.ingredients.length} ${context.t('recipe.ingredients')} · ${recipe.servings} ${context.t('recipe.servings')}',
                style: LoTheme.font(size: 13, weight: FontWeight.w600, color: LoTheme.ink3),
              ),
            ]),
          ),
          const Icon(AppIcons.chevronRight, size: 18, color: LoTheme.ink3),
        ]),
      ),
    );
  }

  void _openCatalogDetail(BuildContext context, CatalogRecipe r) {
    showLoSheet(
      context,
      builder: (ctx) => _CatalogDetailBody(recipe: r),
    );
  }
}

class _CatalogDetailBody extends StatefulWidget {
  final CatalogRecipe recipe;
  const _CatalogDetailBody({required this.recipe});

  @override
  State<_CatalogDetailBody> createState() => _CatalogDetailBodyState();
}

class _CatalogDetailBodyState extends State<_CatalogDetailBody> {
  late int _servings;

  @override
  void initState() {
    super.initState();
    _servings = widget.recipe.servings;
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final isFr = store.locale == 'fr';
    final r = widget.recipe;
    final tn = Tone.of(r.tone);
    final name = isFr ? r.nameFr : r.nameEn;
    final instructions = isFr ? r.instructionsFr : r.instructionsEn;

    // Scale factor
    final factor = _servings / r.servings;

    // Group scaled ingredients by category ID
    final Map<String, List<({String name, double qty, String unit})>> groupedIngs = {};
    for (final ing in r.ingredients) {
      final ingName = isFr ? ing.nameFr : ing.nameEn;
      final cat = getCategoryForProduct(ing.nameFr); // Categories mapped by French product name
      groupedIngs.putIfAbsent(cat, () => []).add((
        name: ingName,
        qty: roundQty(ing.qty * factor, ing.unit),
        unit: ing.unit,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: tn.soft, borderRadius: BorderRadius.circular(15)),
            child: Icon(AppIcons.utensils, size: 23, color: tn.dot),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: LoTheme.font(size: 20, weight: FontWeight.w700)),
              Text(
                '${r.ingredients.length} ${context.t('recipe.ingredients')} · $_servings ${context.t('recipe.servings')}',
                style: LoTheme.font(size: 13, weight: FontWeight.w600, color: LoTheme.ink3),
              ),
            ]),
          ),
        ]),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: LoTheme.surface2, borderRadius: BorderRadius.circular(LoTheme.r(0.9))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              const Icon(AppIcons.users, size: 18, color: LoTheme.ink2),
              const SizedBox(width: 8),
              Text(context.t('recipe.editor.servings').toLowerCase(), style: LoTheme.font(size: 15, weight: FontWeight.w700)),
            ]),
            LoStepper(
              value: _servings,
              min: 1,
              max: 50,
              suffix: ' ${context.t('recipe.servings')}',
              onChange: (v) => setState(() => _servings = v),
            ),
          ]),
        ),
        sheetLabel(context.t('recipe.ingredients')),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: LoTheme.surface,
            border: Border.all(color: LoTheme.line),
            borderRadius: BorderRadius.circular(LoTheme.r(0.9)),
            boxShadow: LoTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final cat in groupedIngs.keys) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 6),
                  child: Row(children: [
                    Icon(_getCategoryIcon(cat), size: 14, color: LoTheme.ink3),
                    const SizedBox(width: 6),
                    Text(
                      _getCategoryDisplayName(context, cat).toUpperCase(),
                      style: LoTheme.font(size: 11.5, weight: FontWeight.w700, color: LoTheme.ink3, letterSpacing: 0.5),
                    ),
                  ]),
                ),
                for (final ing in groupedIngs[cat]!)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: LoTheme.line))),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(ing.name, style: LoTheme.font(size: 14.5, weight: FontWeight.w600, color: LoTheme.ink2)),
                      QtyChip(qty: ing.qty, unit: ing.unit),
                    ]),
                  ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
        sheetLabel(context.t('recipe.steps')),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: LoTheme.surface2,
            borderRadius: BorderRadius.circular(LoTheme.r(0.9)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < instructions.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 18,
                        height: 18,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: tn.dot, shape: BoxShape.circle),
                        child: Text('${i + 1}', style: LoTheme.font(size: 11, weight: FontWeight.w800, color: Colors.white)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          instructions[i],
                          style: LoTheme.font(size: 14.5, weight: FontWeight.w600, color: LoTheme.ink, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        LoButton(
          label: context.t('btn.add_to_list'),
          icon: AppIcons.shoppingCart,
          full: true,
          onTap: () {
            // Convert CatalogRecipe to a dynamic library Recipe
            final converted = _toRecipe(r, isFr);
            final nav = Navigator.of(context);
            nav.pop();
            // Open the list selector dialog
            openAddRecipeToList(nav.context, converted.id, tempRecipe: converted, servingsOverride: _servings);
          },
        ),
        const SizedBox(height: 10),
        _SaveRecipeButton(recipe: r, isFr: isFr),
      ],
    );
  }

  Recipe _toRecipe(CatalogRecipe cr, bool isFr) {
    return Recipe(
      id: cr.id,
      name: isFr ? cr.nameFr : cr.nameEn,
      servings: cr.servings,
      tone: cr.tone,
      items: cr.ingredients
          .map((i) => Item(
                id: uid('it'),
                name: isFr ? i.nameFr : i.nameEn,
                qty: i.qty,
                unit: i.unit,
              ))
          .toList(),
    );
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'Fruits & Légumes':
        return Icons.local_florist_rounded;
      case 'Produits Laitiers & Œufs':
        return Icons.egg_alt_rounded;
      case 'Boulangerie':
        return Icons.bakery_dining_rounded;
      case 'Boucherie & Poissonnerie':
        return Icons.kebab_dining_rounded;
      case 'Épicerie':
        return Icons.dinner_dining_rounded;
      case 'Boissons':
        return Icons.local_cafe_rounded;
      default:
        return AppIcons.shoppingCart;
    }
  }

  String _getCategoryDisplayName(BuildContext context, String cat) {
    switch (cat) {
      case 'Fruits & Légumes':
        return context.t('cat.fruits');
      case 'Produits Laitiers & Œufs':
        return context.t('cat.dairy');
      case 'Boulangerie':
        return context.t('cat.bakery');
      case 'Boucherie & Poissonnerie':
        return context.t('cat.meat');
      case 'Épicerie':
        return context.t('cat.grocery');
      case 'Boissons':
        return context.t('cat.drinks');
      default:
        return context.t('cat.bulk');
    }
  }
}

class _SaveRecipeButton extends StatelessWidget {
  final CatalogRecipe recipe;
  final bool isFr;
  const _SaveRecipeButton({required this.recipe, required this.isFr});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final alreadySaved = store.recipes.any((r) => r.id == recipe.id || r.name.toLowerCase() == (isFr ? recipe.nameFr : recipe.nameEn).toLowerCase());

    return LoButton(
      label: context.t('btn.save_to_recipes'),
      variant: BtnVariant.ghost,
      icon: AppIcons.bookmark,
      full: true,
      disabled: alreadySaved,
      onTap: () {
        if (alreadySaved) {
          LoToast.show(context, context.t('toast.already_saved'));
          return;
        }
        final items = recipe.ingredients
            .map((i) => Item(
                  id: uid('it'),
                  name: isFr ? i.nameFr : i.nameEn,
                  qty: i.qty,
                  unit: i.unit,
                ))
            .toList();
        store.saveRecipe(
          id: recipe.id,
          existingId: null,
          name: isFr ? recipe.nameFr : recipe.nameEn,
          servings: recipe.servings,
          tone: recipe.tone,
          items: items,
          instructions: isFr ? recipe.instructionsFr : recipe.instructionsEn,
        );

        LoToast.show(context, context.t('toast.saved_to_recipes'));
        Navigator.pop(context);
      },
    );
  }
}
