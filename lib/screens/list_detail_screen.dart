import 'package:flutter/material.dart';
import '../theme/icons.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../models/models.dart';
import '../models/unit.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n.dart';
import '../widgets/animations.dart';
import '../widgets/primitives.dart';
import '../widgets/sheets.dart';
import '../widgets/toast.dart';

class ListDetailScreen extends StatefulWidget {
  final String listId;
  const ListDetailScreen({super.key, required this.listId});
  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  final _collapsed = <String>{};
  final _servingsOpen = <String>{};
  bool _groupByAisle = false;

  void _toggle(Set<String> s, String id) => setState(() => s.contains(id) ? s.remove(id) : s.add(id));

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final list = store.listById(widget.listId);

    // list deleted out from under us → close.
    if (list == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      });
      return const Scaffold(backgroundColor: LoTheme.bg, body: SizedBox.shrink());
    }

    final prog = listProgress(list);
    final tn = Tone.of(list.tone);

    final List<Widget> bodyWidgets;
    if (_groupByAisle) {
      final Map<String, List<_GroupedItem>> groups = {};
      for (final b in list.blocks) {
        for (final it in b.items) {
          final cat = getCategoryForProduct(it.name);
          groups.putIfAbsent(cat, () => []).add(_GroupedItem(b, it));
        }
      }

      final order = [
        'Fruits & Légumes',
        'Produits Laitiers & Œufs',
        'Boulangerie',
        'Boucherie & Poissonnerie',
        'Épicerie',
        'Boissons',
        'En vrac',
      ];

      final sortedCats = groups.keys.toList()
        ..sort((a, b) {
          final idxA = order.indexOf(a);
          final idxB = order.indexOf(b);
          if (idxA != -1 && idxB != -1) return idxA.compareTo(idxB);
          if (idxA != -1) return -1;
          if (idxB != -1) return 1;
          return a.compareTo(b);
        });

      bodyWidgets = [
        for (final cat in sortedCats) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
            child: Row(children: [
              Icon(_getCategoryIcon(cat), size: 16, color: LoTheme.ink3),
              const SizedBox(width: 8),
              Text(
                _getCategoryDisplayName(context, cat).toUpperCase(),
                style: LoTheme.font(size: 12.5, weight: FontWeight.w700, color: LoTheme.ink3, letterSpacing: 0.6),
              ),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: LoTheme.surface,
              borderRadius: BorderRadius.circular(LoTheme.radius),
              border: Border.all(color: LoTheme.line),
              boxShadow: LoTheme.cardShadow,
            ),
            child: Column(
              children: [
                for (final gItem in groups[cat]!)
                  _AisleItemRow(
                    key: ValueKey(gItem.item.id),
                    list: list,
                    block: gItem.block,
                    item: gItem.item,
                  ),
              ],
            ),
          ),
        ],
      ];
    } else {
      bodyWidgets = [
        for (final b in list.blocks)
          if (b.isRecipe)
            _RecipeBlock(
              key: ValueKey(b.id),
              list: list,
              block: b,
              collapsed: _collapsed.contains(b.id),
              servingsOpen: _servingsOpen.contains(b.id),
              onToggleCollapse: () => _toggle(_collapsed, b.id),
              onToggleServings: () => _toggle(_servingsOpen, b.id),
            )
          else
            _LooseBlock(key: ValueKey(b.id), list: list, block: b),
      ];
    }

    return Scaffold(
      backgroundColor: LoTheme.bg,
      body: Column(children: [
        // header
        Container(
          decoration: const BoxDecoration(
            color: LoTheme.bg,
            border: Border(bottom: BorderSide(color: LoTheme.line)),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 16, 12),
              child: Column(children: [
                Row(children: [
                  Pressable(
                    scale: 0.85,
                    onTap: () => Navigator.pop(context),
                    child: const SizedBox(width: 38, height: 38, child: Icon(AppIcons.chevronLeft, size: 24, color: LoTheme.ink)),
                  ),
                  Expanded(
                    child: Text(list.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LoTheme.font(size: 22, weight: FontWeight.w700, letterSpacing: -0.2)),
                  ),
                  Pressable(
                    scale: 0.85,
                    onTap: () => setState(() => _groupByAisle = !_groupByAisle),
                    child: AnimatedContainer(
                      duration: LoTheme.fast,
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _groupByAisle ? LoTheme.primarySoft : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        AppIcons.store,
                        size: 20,
                        color: _groupByAisle ? LoTheme.primaryPress : LoTheme.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Pressable(
                    scale: 0.85,
                    onTap: () => openListMenu(context, list),
                    child: const SizedBox(width: 38, height: 38, child: Icon(AppIcons.moreVertical, size: 20, color: LoTheme.ink)),
                  ),
                ]),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Row(children: [
                    Expanded(child: ProgressBar(value: prog.pct, color: LoTheme.primary, height: 7)),
                    const SizedBox(width: 10),
                    Text(
                      prog.total == 0 ? context.t('list.status.empty') : (prog.complete ? context.t('list.status.complete') : '${prog.done} / ${prog.total}'),
                      style: LoTheme.font(size: 13, weight: FontWeight.w700, color: prog.complete ? LoTheme.primaryPress : LoTheme.ink3),
                    ),
                  ]),
                ),
              ]),
            ),
          ),
        ),
        // body
        Expanded(
          child: prog.total == 0
              ? _EmptyState(tone: tn)
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  physics: const BouncingScrollPhysics(),
                  children: bodyWidgets,
                ),
        ),
      ]),
      bottomNavigationBar: _Footer(listId: list.id),
    );
  }
}

// ── item row ────────────────────────────────────────────────
class _ItemRow extends StatelessWidget {
  final ShoppingList list;
  final Block block;
  final Item item;
  const _ItemRow({required this.list, required this.block, required this.item});

  @override
  Widget build(BuildContext context) {
    final store = context.read<AppStore>();
    final isFr = store.locale == 'fr';
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        store.deleteItem(list.id, block.id, item.id);
        LoToast.show(context, isFr ? '${item.name} supprimé' : '${item.name} deleted');
      },
      background: Container(color: Colors.transparent),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: LoTheme.dangerSoft,
          borderRadius: BorderRadius.circular(LoTheme.radius),
        ),
        child: const Icon(AppIcons.trash2, color: LoTheme.danger, size: 20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(children: [
          LoCheckbox(checked: item.checked, onToggle: () => store.toggleItem(list.id, block.id, item.id)),
          const SizedBox(width: 13),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => store.toggleItem(list.id, block.id, item.id),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: LoTheme.font(
                  size: 16,
                  weight: FontWeight.w600,
                  color: item.checked ? LoTheme.ink3 : LoTheme.ink,
                  decoration: item.checked ? TextDecoration.lineThrough : TextDecoration.none,
                  decorationColor: LoTheme.primary,
                ),
                child: Text(item.name),
              ),
            ),
          ),
          Pressable(
            scale: 0.9,
            onTap: () => openEditItem(context, list.id, block.id, item),
            child: QtyChip(qty: item.qty, unit: item.unit, dim: item.checked),
          ),
        ]),
      ),
    );
  }
}

// ── recipe folder block ─────────────────────────────────────
class _RecipeBlock extends StatelessWidget {
  final ShoppingList list;
  final Block block;
  final bool collapsed;
  final bool servingsOpen;
  final VoidCallback onToggleCollapse;
  final VoidCallback onToggleServings;
  const _RecipeBlock({
    super.key,
    required this.list,
    required this.block,
    required this.collapsed,
    required this.servingsOpen,
    required this.onToggleCollapse,
    required this.onToggleServings,
  });

  @override
  Widget build(BuildContext context) {
    final store = context.read<AppStore>();
    final tn = Tone.of(block.tone);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: LoTheme.surface,
        borderRadius: BorderRadius.circular(LoTheme.radius),
        border: Border.all(color: LoTheme.line),
        boxShadow: LoTheme.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        // header
        Container(
          color: tn.soft,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: LoTheme.surface, borderRadius: BorderRadius.circular(10)),
              child: Icon(AppIcons.utensils, size: 18, color: tn.dot),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onToggleCollapse,
                child: Row(children: [
                  Flexible(child: Text(block.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: LoTheme.font(size: 16.5, weight: FontWeight.w700))),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: collapsed ? -0.25 : 0,
                    duration: LoTheme.fast,
                    child: const Icon(AppIcons.chevronDown, size: 16, color: LoTheme.ink3),
                  ),
                ]),
              ),
            ),
            Pressable(
              scale: 0.9,
              onTap: onToggleServings,
              child: AnimatedContainer(
                duration: LoTheme.fast,
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  color: servingsOpen ? LoTheme.primary : LoTheme.surface,
                  borderRadius: BorderRadius.circular(LoTheme.r(0.8)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(AppIcons.users, size: 15, color: servingsOpen ? Colors.white : LoTheme.ink2),
                  const SizedBox(width: 5),
                  Text('${block.servings}', style: LoTheme.font(size: 13.5, weight: FontWeight.w700, color: servingsOpen ? Colors.white : LoTheme.ink2)),
                ]),
              ),
            ),
            Pressable(
              scale: 0.85,
              onTap: () => openBlockMenu(context, list.id, block),
              child: const SizedBox(width: 32, height: 32, child: Icon(AppIcons.moreVertical, size: 18, color: LoTheme.ink2)),
            ),
          ]),
        ),
        // live servings control
        AnimatedSize(
          duration: LoTheme.med,
          curve: LoTheme.ease,
          child: servingsOpen
              ? Container(
                  width: double.infinity,
                  color: LoTheme.surface2,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Flexible(child: Text(context.t('list.servings_question'), style: LoTheme.font(size: 14, weight: FontWeight.w600, color: LoTheme.ink2))),
                    LoStepper(value: block.servings, min: 1, max: 50, onChange: (v) => store.setBlockServings(list.id, block.id, v)),
                  ]),
                )
              : const SizedBox(width: double.infinity),
        ),
        // ingredients
        AnimatedSize(
          duration: LoTheme.med,
          curve: LoTheme.ease,
          alignment: Alignment.topCenter,
          child: collapsed
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                  child: Column(children: [
                    for (final it in block.items) _ItemRow(list: list, block: block, item: it),
                    Pressable(
                      scale: 0.98,
                      onTap: () => openAddItem(context, list.id, blockId: block.id),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 4),
                        child: Row(children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(color: LoTheme.primarySoft, borderRadius: BorderRadius.circular(LoTheme.r(0.5))),
                            child: const Icon(AppIcons.plus, size: 15, color: LoTheme.primaryPress),
                          ),
                          const SizedBox(width: 9),
                          Text(context.t('recipe.editor.new_ingredient'), style: LoTheme.font(size: 14.5, weight: FontWeight.w700, color: LoTheme.primaryPress)),
                        ]),
                      ),
                    ),
                  ]),
                ),
        ),
      ]),
    );
  }
}

// ── loose section block ─────────────────────────────────────
class _LooseBlock extends StatelessWidget {
  final ShoppingList list;
  final Block block;
  const _LooseBlock({super.key, required this.list, required this.block});

  @override
  Widget build(BuildContext context) {
    if (block.items.isEmpty) return const SizedBox.shrink();

    // Group items by category
    final Map<String, List<Item>> groups = {};
    for (final it in block.items) {
      final cat = getCategoryForProduct(it.name);
      groups.putIfAbsent(cat, () => []).add(it);
    }

    // Define standard category order
    final order = [
      'Fruits & Légumes',
      'Produits Laitiers & Œufs',
      'Boulangerie',
      'Boucherie & Poissonnerie',
      'Épicerie',
      'Boissons',
      'En vrac',
    ];

    final sortedCats = groups.keys.toList()
      ..sort((a, b) {
        final idxA = order.indexOf(a);
        final idxB = order.indexOf(b);
        if (idxA != -1 && idxB != -1) return idxA.compareTo(idxB);
        if (idxA != -1) return -1;
        if (idxB != -1) return 1;
        return a.compareTo(b);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final cat in sortedCats) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
            child: Row(children: [
              Icon(_getCategoryIcon(cat), size: 16, color: LoTheme.ink3),
              const SizedBox(width: 8),
              Text(
                _getCategoryDisplayName(context, cat).toUpperCase(),
                style: LoTheme.font(size: 12.5, weight: FontWeight.w700, color: LoTheme.ink3, letterSpacing: 0.6),
              ),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: LoTheme.surface,
              borderRadius: BorderRadius.circular(LoTheme.radius),
              border: Border.all(color: LoTheme.line),
              boxShadow: LoTheme.cardShadow,
            ),
            child: Column(
              children: [
                for (final it in groups[cat]!)
                  _ItemRow(list: list, block: block, item: it),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _GroupedItem {
  final Block block;
  final Item item;
  const _GroupedItem(this.block, this.item);
}

// ── aisle sorted item row ───────────────────────────────────
class _AisleItemRow extends StatelessWidget {
  final ShoppingList list;
  final Block block;
  final Item item;
  const _AisleItemRow({super.key, required this.list, required this.block, required this.item});

  @override
  Widget build(BuildContext context) {
    final store = context.read<AppStore>();
    final hasRecipe = block.isRecipe;
    final isFr = store.locale == 'fr';
    final originLabel = hasRecipe 
        ? (isFr ? 'pour ${block.name}' : 'for ${block.name}')
        : (isFr ? 'en vrac' : 'loose');

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        store.deleteItem(list.id, block.id, item.id);
        LoToast.show(context, isFr ? '${item.name} supprimé' : '${item.name} deleted');
      },
      background: Container(color: Colors.transparent),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: LoTheme.dangerSoft,
          borderRadius: BorderRadius.circular(LoTheme.radius),
        ),
        child: const Icon(AppIcons.trash2, color: LoTheme.danger, size: 20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(children: [
          LoCheckbox(checked: item.checked, onToggle: () => store.toggleItem(list.id, block.id, item.id)),
          const SizedBox(width: 13),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => store.toggleItem(list.id, block.id, item.id),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    style: LoTheme.font(
                      size: 16.0,
                      weight: FontWeight.w600,
                      color: item.checked ? LoTheme.ink3 : LoTheme.ink,
                      decoration: item.checked ? TextDecoration.lineThrough : TextDecoration.none,
                      decorationColor: LoTheme.primary,
                    ),
                    child: Text(item.name),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    originLabel,
                    style: LoTheme.font(
                      size: 12,
                      weight: FontWeight.w600,
                      color: LoTheme.ink3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Pressable(
            scale: 0.9,
            onTap: () => openEditItem(context, list.id, block.id, item),
            child: QtyChip(qty: item.qty, unit: item.unit, dim: item.checked),
          ),
        ]),
      ),
    );
  }
}

// ── category display helper functions ─────────────────────────
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

// ── footer actions ──────────────────────────────────────────
class _Footer extends StatelessWidget {
  final String listId;
  const _Footer({required this.listId});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [LoTheme.bg, LoTheme.bg, Color(0x00F3FAF4)],
          stops: [0, 0.62, 1],
        ),
      ),
      padding: EdgeInsets.fromLTRB(16, 14, 16, 20 + MediaQuery.of(context).padding.bottom),
      child: Row(children: [
        Expanded(child: LoButton(label: context.t('btn.add_item'), variant: BtnVariant.ghost, icon: AppIcons.plus, full: true, small: true, onTap: () => openAddItem(context, listId))),
        const SizedBox(width: 8),
        Expanded(child: LoButton(label: context.t('btn.quick_add'), variant: BtnVariant.ghost, icon: AppIcons.list, full: true, small: true, onTap: () => openQuickAdd(context, listId))),
        const SizedBox(width: 8),
        Expanded(child: LoButton(label: context.t('btn.add_dish'), icon: AppIcons.utensils, full: true, small: true, onTap: () => openAddDish(context, listId))),
      ]),
    );
  }
}

// ── empty state ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final Tone tone;
  const _EmptyState({required this.tone});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(color: tone.soft, borderRadius: BorderRadius.circular(20)),
          child: Icon(AppIcons.shoppingCart, size: 30, color: tone.dot),
        ),
        const SizedBox(height: 16),
        Text(context.t('list.empty'), style: LoTheme.font(size: 17, weight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(context.t('list.empty_desc'), style: LoTheme.font(size: 14, weight: FontWeight.w500, color: LoTheme.ink3)),
      ]),
    );
  }
}
