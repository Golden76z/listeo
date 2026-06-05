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
import '../widgets/confetti.dart';

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
  bool _showConfetti = false;
  bool? _wasComplete;
  bool _showSearch = false;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text;
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggle(Set<String> s, String id) => setState(() => s.contains(id) ? s.remove(id) : s.add(id));

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final list = store.listById(widget.listId);
    final isFr = store.locale == 'fr';

    // list deleted out from under us → close.
    if (list == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      });
      return const Scaffold(backgroundColor: LoTheme.bg, body: SizedBox.shrink());
    }

    final prog = listProgress(list);
    final tn = Tone.of(list.tone);

    final isComplete = prog.complete;
    if (_wasComplete == null) {
      _wasComplete = isComplete;
    } else if (isComplete && !_wasComplete! && prog.total > 0) {
      _wasComplete = true;
      _showConfetti = true;
    } else if (!isComplete) {
      _wasComplete = false;
    }

    final List<Widget> bodyWidgets;
    if (_groupByAisle) {
      final consolidatedList = consolidateItems(list.blocks, searchQuery: _searchQuery);
      final Map<String, List<ConsolidatedItem>> groups = {};
      for (final ci in consolidatedList) {
        groups.putIfAbsent(ci.category, () => []).add(ci);
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
                for (final ci in groups[cat]!)
                  _ConsolidatedItemRow(
                    key: ValueKey('${ci.name}|${ci.unit}'),
                    list: list,
                    ci: ci,
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
              searchQuery: _searchQuery,
            )
          else
            _LooseBlock(
              key: ValueKey(b.id),
              list: list,
              block: b,
              searchQuery: _searchQuery,
            ),
      ];
    }

    return Scaffold(
      backgroundColor: LoTheme.bg,
      body: Stack(
        children: [
          Column(children: [
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
                    if (_showSearch)
                      Row(children: [
                        Pressable(
                          scale: 0.85,
                          onTap: () => setState(() {
                            _showSearch = false;
                            _searchCtrl.clear();
                            _searchQuery = '';
                          }),
                          child: const SizedBox(width: 38, height: 38, child: Icon(AppIcons.chevronLeft, size: 24, color: LoTheme.ink)),
                        ),
                        Expanded(
                          child: Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: LoTheme.surface2,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(children: [
                              const Icon(AppIcons.search, size: 16, color: LoTheme.ink3),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchCtrl,
                                  autofocus: true,
                                  cursorColor: LoTheme.primary,
                                  style: LoTheme.font(size: 15, weight: FontWeight.w600),
                                  decoration: InputDecoration(
                                    isCollapsed: true,
                                    border: InputBorder.none,
                                    hintText: isFr ? 'Rechercher...' : 'Search...',
                                    hintStyle: LoTheme.font(size: 15, weight: FontWeight.w600, color: LoTheme.ink3),
                                  ),
                                ),
                              ),
                              if (_searchQuery.isNotEmpty)
                                GestureDetector(
                                  onTap: () => _searchCtrl.clear(),
                                  child: const Icon(AppIcons.x, size: 16, color: LoTheme.ink2),
                                ),
                            ]),
                          ),
                        ),
                      ])
                    else
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
                          onTap: () => setState(() => _showSearch = true),
                          child: const SizedBox(
                            width: 38,
                            height: 38,
                            child: Icon(AppIcons.search, size: 20, color: LoTheme.ink),
                          ),
                        ),
                        const SizedBox(width: 4),
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
                  ? ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        const SizedBox(height: 60),
                        _EmptyState(tone: tn),
                        const SizedBox(height: 60),
                        _StaplesPanel(list: list),
                      ],
                    )
                  : (_searchQuery.isNotEmpty && bodyWidgets.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(AppIcons.search, size: 34, color: LoTheme.lineStrong),
                              const SizedBox(height: 12),
                              Text(
                                isFr 
                                    ? 'Aucun article trouvé pour « $_searchQuery »' 
                                    : 'No items found for "$_searchQuery"',
                                style: LoTheme.font(size: 15, weight: FontWeight.w600, color: LoTheme.ink3),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                          physics: const BouncingScrollPhysics(),
                          children: [
                            ...bodyWidgets,
                            const SizedBox(height: 24),
                            _StaplesPanel(list: list),
                          ],
                        )),
            ),
          ]),
          if (_showConfetti)
            Positioned.fill(
              child: IgnorePointer(
                child: LoConfetti(
                  onFinished: () => setState(() => _showConfetti = false),
                ),
              ),
            ),
        ],
      ),
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
    final store = context.watch<AppStore>();
    final isFr = store.locale == 'fr';
    
    final deduction = store.computeDeduction(
      itemName: item.name,
      neededQty: item.qty,
      neededUnit: item.unit,
      useInventory: list.useInventory,
    );
    final inStock = deduction.inStock;
    final displayQty = deduction.displayQty;
    final subtractionLabel = deduction.subtractionLabel;

    final dim = item.checked || inStock;

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
                  Row(
                    children: [
                      Flexible(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 180),
                          style: LoTheme.font(
                            size: 16,
                            weight: FontWeight.w600,
                            color: dim ? LoTheme.ink3 : LoTheme.ink,
                            decoration: item.checked ? TextDecoration.lineThrough : TextDecoration.none,
                            decorationColor: LoTheme.primary,
                          ),
                          child: Text(item.name),
                        ),
                      ),
                      if (inStock) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: LoTheme.primarySoft,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.inventory_2_rounded, size: 10, color: LoTheme.primaryPress),
                              const SizedBox(width: 3),
                              Text(
                                isFr ? 'En stock' : 'In stock',
                                style: LoTheme.font(size: 10, weight: FontWeight.w700, color: LoTheme.primaryPress),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtractionLabel.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtractionLabel,
                      style: LoTheme.font(
                        size: 12,
                        weight: FontWeight.w600,
                        color: LoTheme.ink3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Pressable(
            scale: 0.9,
            onTap: () => openEditItem(context, list.id, block.id, item),
            child: QtyChip(qty: inStock ? item.qty : displayQty, unit: item.unit, dim: dim),
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
  final String searchQuery;
  const _RecipeBlock({
    super.key,
    required this.list,
    required this.block,
    required this.collapsed,
    required this.servingsOpen,
    required this.onToggleCollapse,
    required this.onToggleServings,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final filteredItems = searchQuery.isEmpty 
        ? block.items 
        : block.items.where((it) => it.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    if (filteredItems.isEmpty && searchQuery.isNotEmpty) return const SizedBox.shrink();

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
                    for (final it in filteredItems) _ItemRow(list: list, block: block, item: it),
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
  final String searchQuery;
  const _LooseBlock({super.key, required this.list, required this.block, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final filteredItems = searchQuery.isEmpty 
        ? block.items 
        : block.items.where((it) => it.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    if (filteredItems.isEmpty) return const SizedBox.shrink();

    // Group items by category
    final Map<String, List<Item>> groups = {};
    for (final it in filteredItems) {
      final cat = it.customCategory ?? getCategoryForProduct(it.name);
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

class _ConsolidatedItemRow extends StatelessWidget {
  final ShoppingList list;
  final ConsolidatedItem ci;
  const _ConsolidatedItemRow({super.key, required this.list, required this.ci});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final isFr = store.locale == 'fr';

    final deduction = store.computeDeduction(
      itemName: ci.name,
      neededQty: ci.totalQty,
      neededUnit: ci.unit,
      useInventory: list.useInventory,
    );
    final inStock = deduction.inStock;
    final displayQty = deduction.displayQty;
    final subtractionLabel = deduction.subtractionLabel;

    final dim = ci.checked || inStock;

    final labels = <String>[];
    for (final b in ci.blocks) {
      if (b.isRecipe) {
        labels.add(isFr ? 'pour ${b.name}' : 'for ${b.name}');
      } else {
        labels.add(isFr ? 'en vrac' : 'loose');
      }
    }
    var subtitleLabel = labels.join(', ');
    if (subtractionLabel.isNotEmpty) {
      subtitleLabel += ' • $subtractionLabel';
    }

    final itemIds = ci.items.map((it) => it.id).toList();
    final blockIds = ci.blocks.map((b) => b.id).toList();

    return Dismissible(
      key: ValueKey('${ci.name}|${ci.unit}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        store.deleteConsolidatedItem(list.id, blockIds, itemIds);
        LoToast.show(context, isFr ? '${ci.name} supprimé' : '${ci.name} deleted');
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
          LoCheckbox(
            checked: ci.checked,
            onToggle: () => store.toggleConsolidatedItem(list.id, itemIds, !ci.checked),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => store.toggleConsolidatedItem(list.id, itemIds, !ci.checked),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 180),
                          style: LoTheme.font(
                            size: 16.0,
                            weight: FontWeight.w600,
                            color: dim ? LoTheme.ink3 : LoTheme.ink,
                            decoration: ci.checked ? TextDecoration.lineThrough : TextDecoration.none,
                            decorationColor: LoTheme.primary,
                          ),
                          child: Text(ci.name),
                        ),
                      ),
                      if (inStock) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: LoTheme.primarySoft,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.inventory_2_rounded, size: 10, color: LoTheme.primaryPress),
                              const SizedBox(width: 3),
                              Text(
                                isFr ? 'En stock' : 'In stock',
                                style: LoTheme.font(size: 10, weight: FontWeight.w700, color: LoTheme.primaryPress),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitleLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
            onTap: () => openEditConsolidatedItem(context, list.id, ci),
            child: QtyChip(qty: inStock ? ci.totalQty : displayQty, unit: ci.unit, dim: dim),
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
  return context.categoryName(cat);
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

// ── staples panel ───────────────────────────────────────────
class _StaplesPanel extends StatefulWidget {
  final ShoppingList list;
  const _StaplesPanel({required this.list});

  @override
  State<_StaplesPanel> createState() => _StaplesPanelState();
}

class _StaplesPanelState extends State<_StaplesPanel> {
  bool _expanded = false;
  bool _adding = false;
  final _newStapleCtrl = TextEditingController();

  @override
  void dispose() {
    _newStapleCtrl.dispose();
    super.dispose();
  }

  bool _listContainsItem(ShoppingList list, String name) {
    final cleanName = name.toLowerCase().trim();
    for (final b in list.blocks) {
      for (final it in b.items) {
        if (it.name.toLowerCase().trim() == cleanName) {
          return true;
        }
      }
    }
    return false;
  }

  void _addCustomStaple(AppStore store) {
    final text = _newStapleCtrl.text.trim();
    if (text.isNotEmpty) {
      store.addStaple(text);
      _newStapleCtrl.clear();
      setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final isFr = store.locale == 'fr';
    final list = widget.list;

    // Count how many staples are currently in the list
    int inListCount = 0;
    for (final s in store.staples) {
      if (_listContainsItem(list, s)) {
        inListCount++;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: LoTheme.surface,
        borderRadius: BorderRadius.circular(LoTheme.radius),
        border: Border.all(color: LoTheme.line),
        boxShadow: LoTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Click to toggle expand)
          Pressable(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: inListCount > 0 ? LoTheme.primarySoft : LoTheme.surface2,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      AppIcons.store,
                      size: 16,
                      color: inListCount > 0 ? LoTheme.primaryPress : LoTheme.ink2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isFr ? 'Produits de base' : 'Pantry Staples',
                          style: LoTheme.font(size: 15, weight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isFr
                              ? '$inListCount / ${store.staples.length} sur la liste'
                              : '$inListCount / ${store.staples.length} in list',
                          style: LoTheme.font(size: 12, color: LoTheme.ink3, weight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? AppIcons.chevronDown : AppIcons.chevronRight,
                    size: 18,
                    color: LoTheme.ink3,
                  ),
                ],
              ),
            ),
          ),
          
          // Expandable Body
          if (_expanded) ...[
            const Divider(color: LoTheme.line, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isFr
                        ? 'Touche un ingrédient pour l\'ajouter ou le retirer. Appuie long pour supprimer.'
                        : 'Tap to add/remove from list. Long press to delete.',
                    style: LoTheme.font(size: 12, color: LoTheme.ink3, weight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Staples Chips
                      ...store.staples.map((staple) {
                        final inList = _listContainsItem(list, staple);
                        return GestureDetector(
                          onLongPress: () {
                            store.removeStaple(staple);
                            LoToast.show(
                              context,
                              isFr ? '$staple retiré des favoris' : '$staple removed from staples',
                            );
                          },
                          child: Pressable(
                            onTap: () {
                              if (inList) {
                                store.removeLooseItemByName(list.id, staple);
                                LoToast.show(
                                  context,
                                  isFr ? '$staple retiré de la liste' : '$staple removed from list',
                                );
                              } else {
                                store.addLooseItem(
                                  list.id,
                                  name: staple,
                                  qty: 1,
                                  unit: 'pc',
                                );
                                LoToast.show(
                                  context,
                                  isFr ? '$staple ajouté en vrac' : '$staple added as loose item',
                                );
                              }
                            },
                            child: AnimatedContainer(
                              duration: LoTheme.fast,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: inList ? LoTheme.primarySoft : LoTheme.surface2,
                                borderRadius: BorderRadius.circular(LoTheme.r(0.8)),
                                border: Border.all(
                                  color: inList ? LoTheme.primaryPress : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (inList) ...[
                                    const Icon(AppIcons.check, size: 12, color: LoTheme.primaryPress),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    staple,
                                    style: LoTheme.font(
                                      size: 13,
                                      weight: inList ? FontWeight.w700 : FontWeight.w600,
                                      color: inList ? LoTheme.primaryPress : LoTheme.ink2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      
                      // Add Staple Form or Button
                      if (_adding)
                        Container(
                          width: 160,
                          height: 32,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: LoTheme.surface2,
                            borderRadius: BorderRadius.circular(LoTheme.r(0.8)),
                            border: Border.all(color: LoTheme.lineStrong, width: 1),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _newStapleCtrl,
                                  autofocus: true,
                                  style: LoTheme.font(size: 12, weight: FontWeight.w600),
                                  decoration: InputDecoration(
                                    isCollapsed: true,
                                    border: InputBorder.none,
                                    hintText: isFr ? 'Nouveau...' : 'New...',
                                    hintStyle: LoTheme.font(size: 12, color: LoTheme.ink3, weight: FontWeight.w500),
                                  ),
                                  onSubmitted: (_) => _addCustomStaple(store),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _addCustomStaple(store),
                                child: const Icon(AppIcons.check, size: 14, color: LoTheme.primary),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => setState(() => _adding = false),
                                child: const Icon(AppIcons.x, size: 14, color: LoTheme.danger),
                              ),
                            ],
                          ),
                        )
                      else
                        Pressable(
                          onTap: () => setState(() => _adding = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: LoTheme.surface2,
                              borderRadius: BorderRadius.circular(LoTheme.r(0.8)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(AppIcons.plus, size: 12, color: LoTheme.ink3),
                                const SizedBox(width: 4),
                                Text(
                                  isFr ? 'Ajouter' : 'Add',
                                  style: LoTheme.font(
                                    size: 13,
                                    weight: FontWeight.w600,
                                    color: LoTheme.ink3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
