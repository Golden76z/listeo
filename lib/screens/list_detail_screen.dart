import 'package:flutter/material.dart';
import '../theme/icons.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import '../widgets/primitives.dart';
import '../widgets/sheets.dart';

class ListDetailScreen extends StatefulWidget {
  final String listId;
  const ListDetailScreen({super.key, required this.listId});
  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  final _collapsed = <String>{};
  final _servingsOpen = <String>{};

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
                      prog.total == 0 ? 'vide' : (prog.complete ? 'terminé !' : '${prog.done} / ${prog.total}'),
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
                  children: [
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
                  ],
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
    return Padding(
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
                color: item.checked ? LoTheme.ink : LoTheme.ink2,
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
                  borderRadius: BorderRadius.circular(99),
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
                    Flexible(child: Text('pour combien de personnes ?', style: LoTheme.font(size: 14, weight: FontWeight.w600, color: LoTheme.ink2))),
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
                          Text('ingrédient', style: LoTheme.font(size: 14.5, weight: FontWeight.w700, color: LoTheme.primaryPress)),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
          child: Row(children: [
            const Icon(AppIcons.shoppingCart, size: 16, color: LoTheme.ink3),
            const SizedBox(width: 8),
            Text(block.name.toUpperCase(), style: LoTheme.font(size: 12.5, weight: FontWeight.w700, color: LoTheme.ink3, letterSpacing: 0.6)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: LoTheme.surface,
            borderRadius: BorderRadius.circular(LoTheme.radius),
            border: Border.all(color: LoTheme.line),
            boxShadow: LoTheme.cardShadow,
          ),
          child: Column(children: [for (final it in block.items) _ItemRow(list: list, block: block, item: it)]),
        ),
      ]),
    );
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
        Expanded(flex: 5, child: LoButton(label: 'article', variant: BtnVariant.ghost, icon: AppIcons.plus, full: true, onTap: () => openAddItem(context, listId))),
        const SizedBox(width: 10),
        Expanded(flex: 6, child: LoButton(label: 'un plat', icon: AppIcons.utensils, full: true, onTap: () => openAddDish(context, listId))),
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
        Text("Liste vide pour l'instant", style: LoTheme.font(size: 17, weight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Ajoute un article ou un plat ci-dessous.', style: LoTheme.font(size: 14, weight: FontWeight.w500, color: LoTheme.ink3)),
      ]),
    );
  }
}
