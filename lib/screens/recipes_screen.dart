import 'package:flutter/material.dart';
import '../theme/icons.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n.dart';
import '../widgets/animations.dart';
import '../widgets/primitives.dart';
import '../widgets/sheets.dart';

/// "mes recettes" — the recipes tab.
class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});
  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
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

  bool _matchesTag(Recipe r, String tagId) {
    if (tagId == 'all') return true;
    final nameLower = r.name.toLowerCase();
    bool hasIngredient(String kw) => r.items.any((it) => it.name.toLowerCase().contains(kw.toLowerCase()));
    bool hasName(String kw) => nameLower.contains(kw.toLowerCase());
    bool match(String kw) => hasName(kw) || hasIngredient(kw);

    switch (tagId) {
      case 'pates':
        return match('pât') || match('past') || match('spag') || match('noodle');
      case 'poulet':
        return match('poulet') || match('chicken');
      case 'beef':
        return match('bœuf') || match('boeuf') || match('beef') || match('taco');
      case 'legumes':
        final keywords = ['légume', 'veg', 'oignon', 'onion', 'tomate', 'tomato', 'salade', 'salad', 'carotte', 'carrot', 'courgette', 'zucchini', 'ail', 'garlic', 'avocat', 'avocado', 'concombre', 'cucumber', 'pomme de terre', 'potato', 'épinard', 'spinach'];
        return keywords.any((kw) => match(kw));
      case 'dessert':
        return match('sucre') || match('sugar') || match('chocolat') || match('chocolate') || match('gâteau') || match('cake') || match('pancake') || match('dessert');
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final filterTags = [
      (id: 'all', label: context.t('filter.all')),
      (id: 'pates', label: context.t('filter.pasta')),
      (id: 'poulet', label: context.t('filter.chicken')),
      (id: 'beef', label: context.t('filter.beef')),
      (id: 'legumes', label: context.t('filter.vegetables')),
      (id: 'dessert', label: context.t('filter.dessert')),
    ];

    final filtered = store.recipes.where((r) {
      final matchesQuery = r.name.toLowerCase().contains(_q.toLowerCase());
      if (!matchesQuery) return false;

      // Dietary & Allergen filters
      if (store.activeDietaryFilters.isNotEmpty) {
        final matchesDiets = store.activeDietaryFilters.every((tag) => r.tags.contains(tag));
        if (!matchesDiets) return false;
      }

      return _matchesTag(r, _activeTag);
    }).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.t('title.recipes'), style: LoTheme.font(size: 30, weight: FontWeight.w700, letterSpacing: -0.6)),
              const LanguageToggle(),
            ],
          ),
          const SizedBox(height: 4),
          Text('${store.recipes.length} ${context.t('subtitle.recipes')}',
              style: LoTheme.font(size: 14, weight: FontWeight.w500, color: LoTheme.ink3)),
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
                    hintText: context.t('search.recipes'),
                    hintStyle: LoTheme.font(size: 15, weight: FontWeight.w600, color: LoTheme.ink3),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Pressable(
                onTap: () => openDietaryFilterSheet(context),
                child: AnimatedContainer(
                  duration: LoTheme.fast,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: store.activeDietaryFilters.isNotEmpty ? LoTheme.primarySoft : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.eco_rounded,
                    size: 20,
                    color: store.activeDietaryFilters.isNotEmpty ? LoTheme.primaryPress : LoTheme.ink3,
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
        ]),
      ),
      Expanded(
        child: filtered.isEmpty
            ? Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(AppIcons.book, size: 34, color: LoTheme.lineStrong),
                  const SizedBox(height: 12),
                  Text('${context.t('search.no_recipes')} « $_q »', style: LoTheme.font(size: 15, weight: FontWeight.w600, color: LoTheme.ink3)),
                ]),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                physics: const BouncingScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (c, i) => FadeSlideIn(index: i, child: _RecipeCard(recipe: filtered[i])),
              ),
      ),
    ]);
  }
}

class _RecipeCard extends StatelessWidget {
  final Recipe recipe;
  const _RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final tn = Tone.of(recipe.tone);
    return Pressable(
      scale: 0.98,
      onTap: () => openRecipeDetail(context, recipe.id),
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
              Text(recipe.name, style: LoTheme.font(size: 16.5, weight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('${recipe.items.length} ${context.t('recipe.ingredients')} · ${recipe.servings} ${context.t('recipe.servings')}',
                  style: LoTheme.font(size: 13, weight: FontWeight.w600, color: LoTheme.ink3)),
            ]),
          ),
          LoButton(
            label: context.t('btn.add_item'),
            variant: BtnVariant.soft,
            icon: AppIcons.plus,
            small: true,
            onTap: () => openAddRecipeToList(context, recipe.id),
          ),
        ]),
      ),
    );
  }
}
