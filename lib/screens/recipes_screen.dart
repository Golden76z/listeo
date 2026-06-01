import 'package:flutter/material.dart';
import '../theme/icons.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
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
    final filtered = store.recipes.where((r) => r.name.toLowerCase().contains(_q.toLowerCase())).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('mes recettes', style: LoTheme.font(size: 30, weight: FontWeight.w700, letterSpacing: -0.6)),
            Pressable(
              scale: 0.9,
              onTap: () => openRecipeEditor(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: LoTheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: LoTheme.primaryShadow, blurRadius: 14, offset: const Offset(0, 4))],
                ),
                child: const Icon(AppIcons.plus, size: 22, color: Colors.white),
              ),
            ),
          ]),
          const SizedBox(height: 4),
          Text('${store.recipes.length} recettes enregistrées · réutilise-les en un geste',
              style: LoTheme.font(size: 14, weight: FontWeight.w500, color: LoTheme.ink3)),
          const SizedBox(height: 14),
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(color: LoTheme.surface2, borderRadius: BorderRadius.circular(99)),
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
                    hintText: 'rechercher une recette',
                    hintStyle: LoTheme.font(size: 15, weight: FontWeight.w600, color: LoTheme.ink3),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
      Expanded(
        child: filtered.isEmpty
            ? Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(AppIcons.book, size: 34, color: LoTheme.lineStrong),
                  const SizedBox(height: 12),
                  Text('Aucune recette pour « $_q »', style: LoTheme.font(size: 15, weight: FontWeight.w600, color: LoTheme.ink3)),
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
              Text('${recipe.items.length} ingrédients · ${recipe.servings} pers.',
                  style: LoTheme.font(size: 13, weight: FontWeight.w600, color: LoTheme.ink3)),
            ]),
          ),
          LoButton(
            label: 'liste',
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
