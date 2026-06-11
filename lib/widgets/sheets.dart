import 'package:flutter/material.dart';
import '../theme/icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../data/store.dart';
import '../l10n/l10n.dart';
import '../models/models.dart';
import '../models/unit.dart';
import '../theme/app_theme.dart';
import 'primitives.dart';
import 'recipe_editor.dart';
import 'toast.dart';
import 'nav.dart';
import '../screens/cooking_screen.dart';

// ── Sheet shell ─────────────────────────────────────────────
Future<T?> showLoSheet<T>(
  BuildContext context, {
  String? title,
  double? maxHeight,
  double? minHeight,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x52191D14),
    builder: (ctx) {
      return _SheetShell(title: title, maxHeight: maxHeight, minHeight: minHeight, child: Builder(builder: builder));
    },
  );
}

class _SheetShell extends StatelessWidget {
  final String? title;
  final Widget child;
  final double? maxHeight;
  final double? minHeight;
  const _SheetShell({this.title, required this.child, this.maxHeight, this.minHeight});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final maxH = maxHeight ?? (MediaQuery.of(context).size.height * 0.88);
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: LoTheme.ease,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          minHeight: minHeight ?? 0,
          maxHeight: maxH,
        ),
        decoration: const BoxDecoration(
          color: LoTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          boxShadow: [BoxShadow(color: Color(0x2E191D14), blurRadius: 40, offset: Offset(0, -12))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(width: 38, height: 4.5, decoration: BoxDecoration(color: LoTheme.lineStrong, borderRadius: BorderRadius.circular(99))),
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(title!, style: LoTheme.font(size: 21, weight: FontWeight.w700, letterSpacing: -0.2)),
                    ),
                    Pressable(
                      scale: 0.88,
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(color: LoTheme.surface2, shape: BoxShape.circle),
                        child: const Icon(AppIcons.x, size: 17, color: LoTheme.ink2),
                      ),
                    ),
                  ],
                ),
              ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  4,
                  20,
                  8 + MediaQuery.of(context).padding.bottom,
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Create list ─────────────────────────────────────────────
void openCreateList(BuildContext context) {
  final store = context.read<AppStore>();
  showLoSheet(
    context,
    title: 'nouvelle liste',
    minHeight: MediaQuery.of(context).size.height * 0.85,
    maxHeight: MediaQuery.of(context).size.height * 0.94,
    builder: (ctx) => _CreateListBody(store: store),
  );
}

class _CreateListBody extends StatefulWidget {
  final AppStore store;
  const _CreateListBody({required this.store});
  @override
  State<_CreateListBody> createState() => _CreateListBodyState();
}

class _CreateListBodyState extends State<_CreateListBody> {
  final _name = TextEditingController();
  final _sel = <String>{};
  late String _tone;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _tone = Tone.allTones[widget.store.lists.length % Tone.allTones.length];
  }

  void _create() {
    final nav = Navigator.of(context);
    final isFr = widget.store.locale == 'fr';
    final defaultTitle = isFr ? 'Nouvelle liste' : 'New list';
    final nm = _name.text.trim().isEmpty ? defaultTitle : _name.text.trim();
    final id = widget.store.createList(nm, _sel.toList(), _tone);
    nav.pop();
    nav.push(listRoute(id));
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final isFr = store.locale == 'fr';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      LoTextField(
        controller: _name,
        placeholder: isFr ? 'ex. Courses de la semaine' : 'ex. Weekly groceries',
        autoFocus: true,
        onSubmit: _create,
      ),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final s in isFr
            ? ['Courses de la semaine', 'Apéro', 'Week-end', 'Batch cooking']
            : ['Weekly groceries', 'Drinks', 'Weekend', 'Batch cooking'])
          Pressable(
            onTap: () => setState(() => _name.text = s),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              decoration: BoxDecoration(color: LoTheme.surface2, borderRadius: BorderRadius.circular(LoTheme.r(0.8))),
              child: Text(s, style: LoTheme.font(size: 13, weight: FontWeight.w600, color: LoTheme.ink2)),
            ),
          ),
      ]),
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(context.t('list.editor.color'), style: LoTheme.font(size: 11, weight: FontWeight.w700, color: LoTheme.ink3, letterSpacing: 0.5)),
      ),
      TonePicker(
        value: _tone,
        onChange: (v) => setState(() => _tone = v),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 10),
        child: Text.rich(TextSpan(children: [
          TextSpan(text: '${context.t('list.editor.rec_start')} ', style: LoTheme.font(size: 12.5, weight: FontWeight.w700, color: LoTheme.ink3, letterSpacing: 0.5)),
          TextSpan(text: '· ${context.t('list.editor.optional')}', style: LoTheme.font(size: 12.5, weight: FontWeight.w500, color: LoTheme.ink3)),
        ])),
      ),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.85,
        ),
        itemCount: store.recipes.length > 3
            ? (_expanded ? store.recipes.length + 1 : 4)
            : store.recipes.length,
        itemBuilder: (context, index) {
          final recipes = store.recipes;
          final showExpandButton = recipes.length > 3;
          final displayCount = showExpandButton && !_expanded ? 4 : recipes.length + 1;

          if (showExpandButton && index == displayCount - 1) {
            return Pressable(
              scale: 0.95,
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: LoTheme.surface2,
                  borderRadius: BorderRadius.circular(LoTheme.r(0.85)),
                  border: Border.all(color: LoTheme.line, width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: LoTheme.primary,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _expanded
                          ? (isFr ? 'Réduire' : 'Show less')
                          : (isFr ? 'Voir plus' : 'Show more'),
                      style: LoTheme.font(
                        size: 13,
                        weight: FontWeight.w700,
                        color: LoTheme.primaryPress,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final r = recipes[index];
          final on = _sel.contains(r.id);
          final tn = Tone.of(r.tone);
          return Pressable(
            scale: 0.95,
            onTap: () => setState(() => on ? _sel.remove(r.id) : _sel.add(r.id)),
            child: AnimatedContainer(
              duration: LoTheme.fast,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: on ? LoTheme.primarySoft : LoTheme.surface2,
                borderRadius: BorderRadius.circular(LoTheme.r(0.85)),
                border: Border.all(color: on ? LoTheme.primary : Colors.transparent, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _toneIcon(tn, 24, 12),
                      AnimatedContainer(
                        duration: LoTheme.fast,
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: on ? LoTheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: on ? null : Border.all(color: LoTheme.lineStrong, width: 2),
                        ),
                        child: on ? const Icon(AppIcons.check, size: 10, color: Colors.white) : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          r.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: LoTheme.font(size: 13, weight: FontWeight.w700, height: 1.15),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          '${r.servings} ${context.t('recipe.servings')}',
                          style: LoTheme.font(size: 11, weight: FontWeight.w600, color: LoTheme.ink3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 18),
      LoButton(
        label: isFr
            ? 'créer la liste${_sel.isNotEmpty ? " · ${_sel.length} plat${_sel.length > 1 ? "s" : ""}" : ""}'
            : 'create list${_sel.isNotEmpty ? " · ${_sel.length} recipe${_sel.length > 1 ? "s" : ""}" : ""}',
        icon: AppIcons.plus,
        full: true,
        onTap: _create,
      ),
    ]);
  }
}

// ── Add item ────────────────────────────────────────────────
void openAddItem(BuildContext context, String listId, {String? blockId}) {
  final store = context.read<AppStore>();
  showLoSheet(context,
      title: blockId != null ? 'ajouter un ingrédient' : 'ajouter un article',
      builder: (ctx) => _AddItemBody(store: store, listId: listId, blockId: blockId));
}

class _AddItemBody extends StatefulWidget {
  final AppStore store;
  final String listId;
  final String? blockId;
  const _AddItemBody({required this.store, required this.listId, this.blockId});
  @override
  State<_AddItemBody> createState() => _AddItemBodyState();
}

class _AddItemBodyState extends State<_AddItemBody> {
  final _name = TextEditingController();
  final _qty = TextEditingController(text: '1');
  final _focus = FocusNode();
  String _unit = 'pc';
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _name.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    final query = _name.text.trim().toLowerCase();
    if (query.length < 2) {
      if (_suggestions.isNotEmpty) setState(() => _suggestions = []);
      return;
    }
    final matches = kProductDefaultUnits.keys
        .where((k) => k.startsWith(query) && k != query)
        .take(5)
        .toList();
    setState(() => _suggestions = matches);
  }

  void _selectSuggestion(String suggestion) {
    _name.text = suggestion;
    final defUnit = kProductDefaultUnits[suggestion];
    if (defUnit != null) {
      setState(() => _unit = defUnit);
    }
    _name.selection = TextSelection.fromPosition(TextPosition(offset: suggestion.length));
    setState(() => _suggestions = []);
  }

  void _add() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final qty = double.tryParse(_qty.text.replaceAll(',', '.')) ?? 1;
    if (widget.blockId != null) {
      widget.store.addItemToBlock(widget.listId, widget.blockId!, name: name, qty: qty, unit: _unit);
    } else {
      widget.store.addLooseItem(widget.listId, name: name, qty: qty, unit: _unit);
    }
    LoToast.show(context, '$name ajouté');
    setState(() {
      _name.clear();
      _qty.text = '1';
    });
    _focus.requestFocus();
  }

  @override
  void dispose() {
    _name.dispose();
    _qty.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _showDatabaseItems() {
    _focus.unfocus();
    final isFr = widget.store.locale == 'fr';
    showLoSheet(
      context,
      title: isFr ? 'catalogue des articles' : 'product catalog',
      maxHeight: MediaQuery.of(context).size.height * 0.9,
      builder: (ctx) => _DatabaseItemsSheet(
        onSelect: (name) {
          setState(() {
            _name.text = name;
            final defUnit = kProductDefaultUnits[name];
            if (defUnit != null) {
              _unit = defUnit;
            }
          });
          Navigator.pop(ctx);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _focus.requestFocus();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
          child: InlineInput(
            controller: _name,
            focusNode: _focus,
            autofocus: true,
            placeholder: 'ex. Tomates',
            onSubmit: _add,
            suffix: Pressable(
              scale: 0.88,
              onTap: _showDatabaseItems,
              child: const Icon(Icons.storage_rounded, color: LoTheme.ink3, size: 20),
            ),
          ),
        ),
        const SizedBox(width: 10),
        InlineInput(controller: _qty, width: 64, align: TextAlign.center, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
      ]),
      if (_suggestions.isNotEmpty) ...[
        const SizedBox(height: 8),
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _suggestions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (c, i) {
              final sug = _suggestions[i];
              return Pressable(
                onTap: () => _selectSuggestion(sug),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: LoTheme.primarySoft,
                    borderRadius: BorderRadius.circular(LoTheme.r(0.8)),
                    border: Border.all(color: LoTheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(sug, style: LoTheme.font(size: 13, weight: FontWeight.w700, color: LoTheme.primaryPress)),
                ),
              );
            },
          ),
        ),
      ],
      const SizedBox(height: 12),
      UnitChips(value: _unit, onChange: (v) => setState(() => _unit = v)),
      const SizedBox(height: 18),
      Row(children: [
        Expanded(flex: 10, child: LoButton(label: 'terminé', variant: BtnVariant.soft, full: true, onTap: () => Navigator.pop(context))),
        const SizedBox(width: 10),
        Expanded(flex: 14, child: ValueListenableBuilder(
          valueListenable: _name,
          builder: (c, v, _) => LoButton(label: 'ajouter', icon: AppIcons.plus, full: true, disabled: v.text.trim().isEmpty, onTap: _add),
        )),
      ]),
      const SizedBox(height: 12),
      Center(
        child: Text('Astuce : appuie sur Entrée pour enchaîner les articles.',
            style: LoTheme.font(size: 12.5, weight: FontWeight.w500, color: LoTheme.ink3)),
      ),
    ]);
  }
}

// ── Quick Add (Batch) ───────────────────────────────────────
void openQuickAdd(BuildContext context, String listId, {String? blockId}) {
  final store = context.read<AppStore>();
  showLoSheet(context,
      title: 'ajout rapide de plusieurs articles',
      builder: (ctx) => _QuickAddBody(store: store, listId: listId, blockId: blockId));
}

class _QuickAddBody extends StatefulWidget {
  final AppStore store;
  final String listId;
  final String? blockId;
  const _QuickAddBody({required this.store, required this.listId, this.blockId});
  @override
  State<_QuickAddBody> createState() => _QuickAddBodyState();
}

class _QuickAddBodyState extends State<_QuickAddBody> {
  final _textCtrl = TextEditingController();

  void _submit() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;

    final lines = text.split('\n');
    var addedCount = 0;
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final parsed = parseItemFr(line);
      if (parsed.name.isEmpty) continue;

      if (widget.blockId != null) {
        widget.store.addItemToBlock(
          widget.listId,
          widget.blockId!,
          name: parsed.name,
          qty: parsed.qty,
          unit: parsed.unit,
        );
      } else {
        widget.store.addLooseItem(
          widget.listId,
          name: parsed.name,
          qty: parsed.qty,
          unit: parsed.unit,
        );
      }
      addedCount++;
    }

    if (addedCount > 0) {
      LoToast.show(context, '$addedCount articles ajoutés');
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saisis tes articles (un par ligne).\nExemples :\n3 bananes\n500g farine\n1.5L lait\nchocolat',
          style: LoTheme.font(size: 14, weight: FontWeight.w500, color: LoTheme.ink2, height: 1.45),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: LoTheme.surface2,
            borderRadius: BorderRadius.circular(LoTheme.r(0.9)),
          ),
          child: TextField(
            controller: _textCtrl,
            autofocus: true,
            maxLines: 8,
            cursorColor: LoTheme.primary,
            style: LoTheme.font(size: 15.5, weight: FontWeight.w600),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Colle ou écris ta liste ici...',
              hintStyle: LoTheme.font(size: 15.5, weight: FontWeight.w600, color: LoTheme.ink3),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: LoButton(
                label: 'annuler',
                variant: BtnVariant.soft,
                full: true,
                onTap: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _textCtrl,
                builder: (c, v, _) {
                  final empty = v.text.trim().isEmpty;
                  return LoButton(
                    label: 'ajouter',
                    icon: AppIcons.plus,
                    full: true,
                    disabled: empty,
                    onTap: _submit,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Edit item ───────────────────────────────────────────────
void openEditItem(BuildContext context, String listId, String? blockId, Item item) {
  final store = context.read<AppStore>();
  showLoSheet(context, title: "modifier l'article", builder: (ctx) => _EditItemBody(store: store, listId: listId, blockId: blockId, item: item));
}

class _EditItemBody extends StatefulWidget {
  final AppStore store;
  final String listId;
  final String? blockId;
  final Item item;
  const _EditItemBody({required this.store, required this.listId, this.blockId, required this.item});
  @override
  State<_EditItemBody> createState() => _EditItemBodyState();
}

class _EditItemBodyState extends State<_EditItemBody> {
  late final _name = TextEditingController(text: widget.item.name);
  late final _qty = TextEditingController(text: numFr(widget.item.qty));
  late String _unit = widget.item.unit;
  late String _customCategory = widget.item.customCategory ?? getCategoryForProduct(widget.item.name);
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _name.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    final query = _name.text.trim().toLowerCase();
    if (query.length < 2) {
      if (_suggestions.isNotEmpty) setState(() => _suggestions = []);
      return;
    }
    final matches = kProductDefaultUnits.keys
        .where((k) => k.startsWith(query) && k != query)
        .take(5)
        .toList();
    setState(() => _suggestions = matches);
  }

  void _selectSuggestion(String suggestion) {
    _name.text = suggestion;
    final defUnit = kProductDefaultUnits[suggestion];
    if (defUnit != null) {
      setState(() => _unit = defUnit);
    }
    _name.selection = TextSelection.fromPosition(TextPosition(offset: suggestion.length));
    setState(() => _suggestions = []);
  }

  void _save() {
    widget.store.updateItem(widget.listId, widget.blockId ?? _findBlockId(), widget.item.id,
        name: _name.text.trim().isEmpty ? widget.item.name : _name.text.trim(),
        qty: double.tryParse(_qty.text.replaceAll(',', '.')) ?? widget.item.qty,
        unit: _unit,
        customCategory: _customCategory);
    Navigator.pop(context);
  }

  // edit-item can be opened without a blockId for loose items in some flows;
  // resolve the owning block from the store as a fallback.
  String _findBlockId() {
    final l = widget.store.listById(widget.listId);
    if (l == null) return '';
    for (final b in l.blocks) {
      if (b.items.any((i) => i.id == widget.item.id)) return b.id;
    }
    return '';
  }

  @override
  void dispose() {
    _name.dispose();
    _qty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      sheetLabel('article'),
      Row(children: [
        Expanded(child: LoTextField(controller: _name)),
        const SizedBox(width: 10),
        InlineInput(controller: _qty, width: 64, align: TextAlign.center, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
      ]),
      if (_suggestions.isNotEmpty) ...[
        const SizedBox(height: 8),
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _suggestions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (c, i) {
              final sug = _suggestions[i];
              return Pressable(
                onTap: () => _selectSuggestion(sug),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: LoTheme.primarySoft,
                    borderRadius: BorderRadius.circular(LoTheme.r(0.8)),
                    border: Border.all(color: LoTheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(sug, style: LoTheme.font(size: 13, weight: FontWeight.w700, color: LoTheme.primaryPress)),
                ),
              );
            },
          ),
        ),
      ],
      const SizedBox(height: 12),
      UnitChips(value: _unit, onChange: (v) => setState(() => _unit = v)),
      const SizedBox(height: 14),
      sheetLabel(context.t('item.editor.aisle')),
      CategoryChips(value: _customCategory, onChange: (v) => setState(() => _customCategory = v)),
      const SizedBox(height: 18),
      Row(children: [
        LoButton(
          label: 'retirer',
          variant: BtnVariant.danger,
          icon: AppIcons.trash2,
          onTap: () {
            widget.store.deleteItem(widget.listId, widget.blockId ?? _findBlockId(), widget.item.id);
            Navigator.pop(context);
          },
        ),
        const SizedBox(width: 10),
        Expanded(child: LoButton(label: 'enregistrer', icon: AppIcons.check, full: true, onTap: _save)),
      ]),
    ]);
  }
}

// ── Edit inventory item ──────────────────────────────────────
void openEditInventoryItem(BuildContext context, InventoryItem item) {
  final store = context.read<AppStore>();
  showLoSheet(
    context,
    title: store.locale == 'fr' ? "modifier l'inventaire" : "edit inventory",
    builder: (ctx) => _EditInventoryItemBody(store: store, item: item),
  );
}

class _EditInventoryItemBody extends StatefulWidget {
  final AppStore store;
  final InventoryItem item;
  const _EditInventoryItemBody({required this.store, required this.item});
  @override
  State<_EditInventoryItemBody> createState() => _EditInventoryItemBodyState();
}

class _EditInventoryItemBodyState extends State<_EditInventoryItemBody> {
  late final _name = TextEditingController(text: widget.item.name);
  late final _qty = TextEditingController(text: numFr(widget.item.qty));
  late String _unit = widget.item.unit;

  @override
  void dispose() {
    _name.dispose();
    _qty.dispose();
    super.dispose();
  }

  void _save() {
    final nameVal = _name.text.trim().isEmpty ? widget.item.name : _name.text.trim();
    final qtyVal = double.tryParse(_qty.text.replaceAll(',', '.')) ?? widget.item.qty;
    widget.store.updateInventoryItem(widget.item.id, name: nameVal, qty: qtyVal, unit: _unit);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isFr = widget.store.locale == 'fr';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sheetLabel(isFr ? 'produit' : 'product'),
        Row(
          children: [
            Expanded(child: LoTextField(controller: _name)),
            const SizedBox(width: 10),
            InlineInput(
              controller: _qty,
              width: 64,
              align: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        const SizedBox(height: 12),
        UnitChips(value: _unit, onChange: (v) => setState(() => _unit = v)),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: LoButton(
                label: isFr ? 'supprimer' : 'delete',
                variant: BtnVariant.danger,
                icon: AppIcons.trash2,
                full: true,
                onTap: () {
                  widget.store.deleteInventoryItem(widget.item.id);
                  LoToast.show(context, isFr ? '${widget.item.name} supprimé' : '${widget.item.name} deleted');
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: LoButton(
                label: isFr ? 'enregistrer' : 'save',
                icon: AppIcons.check,
                full: true,
                onTap: _save,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Add dish (menu / configure / adhoc) ─────────────────────
void openAddDish(BuildContext context, String listId) {
  final store = context.read<AppStore>();
  showLoSheet(context, title: 'ajouter un plat', builder: (ctx) => _AddDishBody(store: store, listId: listId));
}

class _AddDishBody extends StatefulWidget {
  final AppStore store;
  final String listId;
  const _AddDishBody({required this.store, required this.listId});
  @override
  State<_AddDishBody> createState() => _AddDishBodyState();
}

class _AddDishBodyState extends State<_AddDishBody> {
  String _step = 'menu'; // menu | configure | adhoc
  Recipe? _chosen;
  int _servings = 2;
  late final _draft = RecipeDraft(servings: 2, tone: Tone.allTones[widget.store.recipes.length % Tone.allTones.length]);
  bool _saveLib = true;

  Widget _backLink(VoidCallback onTap) => Pressable(
        onTap: onTap,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(AppIcons.chevronLeft, size: 16, color: LoTheme.ink2),
          const SizedBox(width: 5),
          Text(context.t('btn.back'), style: LoTheme.font(size: 14, weight: FontWeight.w700, color: LoTheme.ink2)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    if (_step == 'menu') return _menu();
    if (_step == 'configure' && _chosen != null) return _configure();
    return _adhoc();
  }

  Widget _menu() {
    final store = widget.store;
    final isFr = store.locale == 'fr';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Pressable(
        onTap: () => setState(() => _step = 'adhoc'),
        child: Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(color: LoTheme.primarySoft, borderRadius: BorderRadius.circular(LoTheme.r(0.9))),
          child: Row(children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: LoTheme.primary, borderRadius: BorderRadius.circular(11)),
              child: const Icon(AppIcons.sparkles, size: 19, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(isFr ? 'nouveau plat' : 'new dish', style: LoTheme.font(size: 15.5, weight: FontWeight.w700, color: LoTheme.primaryPress)),
                Text(isFr ? 'composer librement les ingrédients' : 'freely compose the ingredients', style: LoTheme.font(size: 12.5, weight: FontWeight.w600, color: LoTheme.ink2)),
              ]),
            ),
            const Icon(AppIcons.chevronRight, size: 18, color: LoTheme.primaryPress),
          ]),
        ),
      ),
      sheetLabel(context.t('title.recipes')),
      ...store.recipes.map((r) {
        final tn = Tone.of(r.tone);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _recipeRow(
            tone: tn,
            title: r.name,
            subtitle: '${r.items.length} ${context.t('recipe.ingredients')} · ${r.servings} ${context.t('recipe.servings')}',
            trailing: const Icon(AppIcons.chevronRight, size: 18, color: LoTheme.ink3),
            onTap: () => setState(() {
              _chosen = r;
              _servings = r.servings;
              _step = 'configure';
            }),
          ),
        );
      }),
    ]);
  }

  Widget _configure() {
    final r = _chosen!;
    final isFr = widget.store.locale == 'fr';
    final preview = recipeToBlock(r, _servings).items;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _backLink(() => setState(() => _step = 'menu')),
      const SizedBox(height: 6),
      Text(r.name, style: LoTheme.font(size: 19, weight: FontWeight.w700)),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: LoTheme.surface2, borderRadius: BorderRadius.circular(LoTheme.r(0.9))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            const Icon(AppIcons.users, size: 18, color: LoTheme.ink2),
            const SizedBox(width: 8),
            Text(context.t('recipe.editor.servings').toLowerCase(), style: LoTheme.font(size: 15, weight: FontWeight.w700)),
          ]),
          LoStepper(value: _servings, min: 1, max: 50, suffix: ' ${context.t('recipe.servings')}', onChange: (v) => setState(() => _servings = v)),
        ]),
      ),
      sheetLabel(context.t('list.adjust_qty')),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: LoTheme.surface,
          border: Border.all(color: LoTheme.line),
          borderRadius: BorderRadius.circular(LoTheme.r(0.9)),
        ),
        child: Column(
          children: [
            for (var i = 0; i < preview.length; i++)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(border: i == preview.length - 1 ? null : const Border(bottom: BorderSide(color: LoTheme.line))),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(preview[i].name, style: LoTheme.font(size: 15, weight: FontWeight.w600, color: LoTheme.ink2)),
                  QtyChip(qty: preview[i].qty, unit: preview[i].unit),
                ]),
              ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      LoButton(
        label: context.t('btn.add_to_list_act'),
        icon: AppIcons.plus,
        full: true,
        onTap: () {
          widget.store.addRecipeBlock(widget.listId, r, _servings);
          LoToast.show(context, isFr ? '${r.name} ajouté' : '${r.name} added');
          Navigator.pop(context);
        },
      ),
    ]);
  }

  Widget _adhoc() {
    final isFr = widget.store.locale == 'fr';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _backLink(() => setState(() => _step = 'menu')),
      const SizedBox(height: 6),
      RecipeEditorView(draft: _draft, onChanged: () => setState(() {})),
      Pressable(
        onTap: () => setState(() => _saveLib = !_saveLib),
        child: Padding(
          padding: const EdgeInsets.only(top: 18),
          child: Row(children: [
            AnimatedContainer(
              duration: LoTheme.fast,
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: _saveLib ? LoTheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: _saveLib ? null : Border.all(color: LoTheme.lineStrong, width: 2),
              ),
              child: _saveLib ? const Icon(AppIcons.check, size: 14, color: Colors.white) : null,
            ),
            const SizedBox(width: 10),
            Text(context.t('list.editor.save_lib'), style: LoTheme.font(size: 14.5, weight: FontWeight.w600)),
            const SizedBox(width: 6),
            const Icon(AppIcons.bookmark, size: 16, color: LoTheme.accentInk),
          ]),
        ),
      ),
      const SizedBox(height: 16),
      LoButton(
        label: context.t('btn.add_to_list_act'),
        icon: AppIcons.plus,
        full: true,
        disabled: _draft.name.trim().isEmpty || _draft.items.isEmpty,
        onTap: () {
          widget.store.addAdhocDish(widget.listId, name: _draft.name, servings: _draft.servings, tone: _draft.tone, items: _draft.items, saveLib: _saveLib);
          LoToast.show(context, isFr ? '${_draft.name.trim()} ajouté' : '${_draft.name.trim()} added');
          Navigator.pop(context);
        },
      ),
    ]);
  }
}

// ── Recipe detail ───────────────────────────────────────────
void openRecipeDetail(BuildContext context, String recipeId) {
  final store = context.read<AppStore>();
  showLoSheet(context, builder: (ctx) => _RecipeDetailBody(store: store, recipeId: recipeId));
}

class _RecipeDetailBody extends StatelessWidget {
  final AppStore store;
  final String recipeId;
  const _RecipeDetailBody({required this.store, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    final r = store.recipeById(recipeId);
    if (r == null) return const SizedBox.shrink();
    final tn = Tone.of(r.tone);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        _toneIcon(tn, 48, 23),
        const SizedBox(width: 13),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              r.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: LoTheme.font(size: 20, weight: FontWeight.w700),
            ),
            Text('${r.items.length} ingrédients · ${r.servings} pers.', style: LoTheme.font(size: 13, weight: FontWeight.w600, color: LoTheme.ink3)),
          ]),
        ),
      ]),
      sheetLabel('ingrédients'),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(color: LoTheme.surface2, borderRadius: BorderRadius.circular(LoTheme.r(0.9))),
        child: Column(children: [
          for (var i = 0; i < r.items.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(border: i == r.items.length - 1 ? null : const Border(bottom: BorderSide(color: LoTheme.line))),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(r.items[i].name, style: LoTheme.font(size: 15, weight: FontWeight.w600)),
                QtyChip(qty: r.items[i].qty, unit: r.items[i].unit),
              ]),
            ),
        ]),
      ),
      if (r.instructions.isNotEmpty) ...[
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
              for (var i = 0; i < r.instructions.length; i++)
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
                          r.instructions[i],
                          style: LoTheme.font(size: 14.5, weight: FontWeight.w600, color: LoTheme.ink, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
      const SizedBox(height: 18),
      if (store.getRecipeInstructions(r.id).isNotEmpty) ...[
        LoButton(
          label: store.locale == 'fr' ? 'commencer à cuisiner' : 'start cooking',
          icon: Icons.restaurant_menu_rounded,
          full: true,
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CookingScreen(
                  recipeName: r.name,
                  tone: r.tone,
                  instructions: store.getRecipeInstructions(r.id),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
      ],
      LoButton(label: 'ajouter à une liste', icon: AppIcons.shoppingCart, full: true, onTap: () {
        final nav = Navigator.of(context);
        nav.pop();
        openAddRecipeToList(nav.context, r.id);
      }),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: LoButton(label: 'modifier', variant: BtnVariant.ghost, icon: AppIcons.pencil, full: true, onTap: () {
          final nav = Navigator.of(context);
          nav.pop();
          openRecipeEditor(nav.context, recipeId: r.id);
        })),
        const SizedBox(width: 10),
        LoButton(label: 'supprimer', variant: BtnVariant.danger, icon: AppIcons.trash2, onTap: () {
          final nav = Navigator.of(context);
          nav.pop();
          openConfirm(nav.context,
              title: 'Supprimer la recette ?',
              message: '« ${r.name} » sera retirée de tes recettes.',
              confirmLabel: 'supprimer',
              onConfirm: (ctx) {
                store.deleteRecipe(r.id);
                LoToast.show(ctx, 'Recette supprimée');
              });
        }),
      ]),
    ]);
  }
}

// ── Add a library recipe to a chosen list ───────────────────
void openAddRecipeToList(BuildContext context, String recipeId, {Recipe? tempRecipe, int? servingsOverride}) {
  final store = context.read<AppStore>();
  final title = store.locale == 'fr' ? 'ajouter à une liste' : 'add to a list';
  showLoSheet(context, title: title, builder: (ctx) => _AddRecipeToListBody(store: store, recipeId: recipeId, tempRecipe: tempRecipe, servingsOverride: servingsOverride));
}

class _AddRecipeToListBody extends StatefulWidget {
  final AppStore store;
  final String recipeId;
  final Recipe? tempRecipe;
  final int? servingsOverride;
  const _AddRecipeToListBody({required this.store, required this.recipeId, this.tempRecipe, this.servingsOverride});
  @override
  State<_AddRecipeToListBody> createState() => _AddRecipeToListBodyState();
}

class _AddRecipeToListBodyState extends State<_AddRecipeToListBody> {
  late int _servings;
  Recipe? _r;

  @override
  void initState() {
    super.initState();
    _r = widget.tempRecipe ?? widget.store.recipeById(widget.recipeId);
    _servings = widget.servingsOverride ?? _r?.servings ?? 2;
  }

  @override
  Widget build(BuildContext context) {
    final r = _r;
    if (r == null) return const SizedBox.shrink();
    final isFr = widget.store.locale == 'fr';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(r.name, style: LoTheme.font(size: 18, weight: FontWeight.w700)),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: LoTheme.surface2, borderRadius: BorderRadius.circular(LoTheme.r(0.9))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            const Icon(AppIcons.users, size: 18, color: LoTheme.ink2),
            const SizedBox(width: 8),
            Text(context.t('recipe.editor.servings').toLowerCase(), style: LoTheme.font(size: 15, weight: FontWeight.w700)),
          ]),
          LoStepper(value: _servings, min: 1, max: 50, suffix: ' ${context.t('recipe.servings')}', onChange: (v) => setState(() => _servings = v)),
        ]),
      ),
      sheetLabel(isFr ? 'ajouter à' : 'add to'),
      ...widget.store.lists.map((l) {
        final tn = Tone.of(l.tone);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Pressable(
            onTap: () {
              widget.store.addRecipeBlock(l.id, r, _servings);
              LoToast.show(context, isFr ? 'Ajouté à ${l.name}' : 'Added to ${l.name}');
              final nav = Navigator.of(context);
              nav.pop();
              nav.push(listRoute(l.id));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: LoTheme.surface2, borderRadius: BorderRadius.circular(LoTheme.r(0.85))),
              child: Row(children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: tn.dot, shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Expanded(child: Text(l.name, style: LoTheme.font(size: 15, weight: FontWeight.w700))),
                const Icon(AppIcons.plus, size: 18, color: LoTheme.primary),
              ]),
            ),
          ),
        );
      }),
      Pressable(
        onTap: () {
          final defaultListTitle = isFr ? 'Nouvelle liste' : 'New list';
          final id = widget.store.createList(defaultListTitle, [], Tone.allTones[widget.store.lists.length % Tone.allTones.length]);
          widget.store.addRecipeBlock(id, r, _servings);
          LoToast.show(context, isFr ? 'Nouvelle liste créée' : 'New list created');
          final nav = Navigator.of(context);
          nav.pop();
          nav.push(listRoute(id));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: LoTheme.primarySoft, borderRadius: BorderRadius.circular(LoTheme.r(0.85))),
          child: Row(children: [
            const Icon(AppIcons.plus, size: 20, color: LoTheme.primaryPress),
            const SizedBox(width: 12),
            Expanded(child: Text(isFr ? 'une nouvelle liste' : 'a new list', style: LoTheme.font(size: 15, weight: FontWeight.w700, color: LoTheme.primaryPress))),
          ]),
        ),
      ),
    ]);
  }
}

// ── Recipe create / edit ────────────────────────────────────
void openRecipeEditor(BuildContext context, {String? recipeId}) {
  final store = context.read<AppStore>();
  final isFr = store.locale == 'fr';
  final title = recipeId != null
      ? isFr ? 'modifier la recette' : 'edit recipe'
      : isFr ? 'nouvelle recette' : 'new recipe';
  showLoSheet(context,
      title: title,
      builder: (ctx) => _RecipeEditorBody(store: store, recipeId: recipeId));
}

class _RecipeEditorBody extends StatefulWidget {
  final AppStore store;
  final String? recipeId;
  const _RecipeEditorBody({required this.store, this.recipeId});
  @override
  State<_RecipeEditorBody> createState() => _RecipeEditorBodyState();
}

class _RecipeEditorBodyState extends State<_RecipeEditorBody> {
  late final RecipeDraft _draft;
  late final bool _existing;

  @override
  void initState() {
    super.initState();
    final r = widget.recipeId != null ? widget.store.recipeById(widget.recipeId!) : null;
    _existing = r != null;
    _draft = r != null
        ? RecipeDraft(
            name: r.name,
            servings: r.servings,
            tone: r.tone,
            items: r.items.map((it) => Item(id: uid('it'), name: it.name, qty: it.qty, unit: it.unit)).toList(),
            instructions: List.from(r.instructions),
            tags: List.from(r.tags),
          )
        : RecipeDraft(servings: 4, tone: Tone.allTones[widget.store.recipes.length % Tone.allTones.length]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      RecipeEditorView(draft: _draft, onChanged: () => setState(() {})),
      const SizedBox(height: 18),
      LoButton(
        label: _existing ? 'enregistrer les modifications' : 'enregistrer la recette',
        icon: AppIcons.bookmark,
        full: true,
        disabled: _draft.name.trim().isEmpty || _draft.items.isEmpty,
        onTap: () {
          widget.store.saveRecipe(
            existingId: widget.recipeId,
            name: _draft.name,
            servings: _draft.servings,
            tone: _draft.tone,
            items: _draft.items,
            instructions: _draft.instructions,
            tags: _draft.tags,
          );
          LoToast.show(context, _existing ? 'Recette modifiée' : 'Recette enregistrée');
          Navigator.pop(context);
        },
      ),
    ]);
  }
}

// ── Rename ──────────────────────────────────────────────────
void openRename(BuildContext context, {required String title, required String value, required ValueChanged<String> onSave}) {
  showLoSheet(context, title: title, builder: (ctx) => _RenameBody(value: value, onSave: onSave));
}

class _RenameBody extends StatefulWidget {
  final String value;
  final ValueChanged<String> onSave;
  const _RenameBody({required this.value, required this.onSave});
  @override
  State<_RenameBody> createState() => _RenameBodyState();
}

class _RenameBodyState extends State<_RenameBody> {
  late final _ctrl = TextEditingController(text: widget.value);
  void _save() {
    widget.onSave(_ctrl.text.trim().isEmpty ? widget.value : _ctrl.text.trim());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      LoTextField(controller: _ctrl, autoFocus: true, onSubmit: _save),
      const SizedBox(height: 16),
      LoButton(label: 'renommer', icon: AppIcons.check, full: true, onTap: _save),
    ]);
  }
}

// ── Confirm ─────────────────────────────────────────────────
void openConfirm(BuildContext context, {required String title, required String message, String confirmLabel = 'supprimer', required void Function(BuildContext context) onConfirm}) {
  showLoSheet(context, title: title, builder: (ctx) => _ConfirmBody(message: message, confirmLabel: confirmLabel, onConfirm: onConfirm));
}

class _ConfirmBody extends StatelessWidget {
  final String message;
  final String confirmLabel;
  final void Function(BuildContext context) onConfirm;
  const _ConfirmBody({required this.message, required this.confirmLabel, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Text(message, style: LoTheme.font(size: 15.5, weight: FontWeight.w500, color: LoTheme.ink2, height: 1.5)),
      ),
      Row(children: [
        Expanded(child: LoButton(label: 'annuler', variant: BtnVariant.ghost, full: true, onTap: () => Navigator.pop(context))),
        const SizedBox(width: 10),
        Expanded(child: LoButton(label: confirmLabel, variant: BtnVariant.danger, icon: AppIcons.trash2, full: true, onTap: () {
          onConfirm(context);
          Navigator.pop(context);
        })),
      ]),
    ]);
  }
}

// ── List menu ───────────────────────────────────────────────
void openListMenu(BuildContext context, ShoppingList list) {
  final store = context.read<AppStore>();
  showLoSheet(context, title: list.name, builder: (ctx) {
    return StatefulBuilder(
      builder: (context, setState) {
        final isFr = store.locale == 'fr';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 6, right: 6),
              child: Text(
                isFr ? 'COULEUR DE LA LISTE' : 'LIST COLOR',
                style: LoTheme.font(size: 11, weight: FontWeight.w700, color: LoTheme.ink3, letterSpacing: 0.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 6, right: 6),
              child: TonePicker(
                value: list.tone,
                onChange: (newTone) {
                  setState(() {});
                  store.changeListTone(list.id, newTone);
                },
              ),
            ),
            const Divider(color: LoTheme.line, height: 1),
            // Inventory setting toggle
            Pressable(
              scale: 0.99,
              onTap: () {
                store.toggleListUseInventory(list.id);
                setState(() {});
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: LoTheme.line)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 20, color: LoTheme.ink2),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.t('list.setting.use_inventory'),
                            style: LoTheme.font(size: 16, weight: FontWeight.w600, color: LoTheme.ink),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.t('list.setting.use_inventory_desc'),
                            style: LoTheme.font(size: 12.5, weight: FontWeight.w500, color: LoTheme.ink3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 44,
                      height: 24,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        color: list.useInventory ? LoTheme.primary : LoTheme.lineStrong,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        alignment: list.useInventory ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _MenuRow(icon: AppIcons.pencil, label: isFr ? 'renommer la liste' : 'rename list', onTap: () {
              Navigator.pop(context);
              openRename(context, title: isFr ? 'renommer la liste' : 'rename list', value: list.name, onSave: (v) => store.renameList(list.id, v));
            }),
            _MenuRow(icon: AppIcons.copy, label: isFr ? 'dupliquer' : 'duplicate', onTap: () {
              store.duplicateList(list.id);
              LoToast.show(context, isFr ? 'Liste dupliquée' : 'List duplicated');
              Navigator.pop(context);
            }),
            _MenuRow(icon: AppIcons.share, label: isFr ? 'partager la liste' : 'share list', onTap: () {
              shareList(context, list);
              Navigator.pop(context);
            }),
            _MenuRow(icon: AppIcons.uncheck, label: isFr ? 'tout décocher' : 'uncheck all', onTap: () {
              store.uncheckAllItems(list.id);
              LoToast.show(context, isFr ? 'Articles décochés' : 'Items unchecked');
              Navigator.pop(context);
            }),
            _MenuRow(icon: AppIcons.deleteChecked, label: isFr ? 'nettoyer les articles cochés' : 'clear checked items', onTap: () {
              store.clearCheckedItems(list.id);
              LoToast.show(context, isFr ? 'Articles cochés supprimés' : 'Checked items removed');
              Navigator.pop(context);
            }),
            _MenuRow(icon: AppIcons.trash2, label: isFr ? 'supprimer la liste' : 'delete list', danger: true, last: true, onTap: () {
              final nav = Navigator.of(context);
              nav.pop();
              openConfirm(nav.context,
                  title: isFr ? 'Supprimer la liste ?' : 'Delete list?',
                  message: isFr 
                      ? '« ${list.name} » et tout son contenu seront supprimés.' 
                      : '“${list.name}” and all its contents will be deleted.',
                  confirmLabel: isFr ? 'supprimer' : 'delete',
                  onConfirm: (ctx) {
                    store.deleteList(list.id);
                    LoToast.show(ctx, isFr ? 'Liste supprimée' : 'List deleted');
                  });
            }),
          ],
        );
      },
    );
  });
}

// ── Block menu ──────────────────────────────────────────────
void openBlockMenu(BuildContext context, String listId, Block block) {
  final store = context.read<AppStore>();
  final instructions = block.recipeId != null ? store.getRecipeInstructions(block.recipeId!) : const <String>[];
  final hasInstructions = instructions.isNotEmpty;
  
  showLoSheet(context, title: block.name, builder: (ctx) {
    return Column(children: [
      if (hasInstructions)
        _MenuRow(icon: Icons.restaurant_menu_rounded, label: store.locale == 'fr' ? 'commencer à cuisiner' : 'start cooking', onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CookingScreen(
                recipeName: block.name,
                tone: block.tone ?? 'green',
                instructions: instructions,
              ),
            ),
          );
        }),
      _MenuRow(icon: AppIcons.pencil, label: 'renommer le plat', onTap: () {
        Navigator.pop(context);
        openRename(context, title: 'renommer le plat', value: block.name, onSave: (v) => store.renameBlock(listId, block.id, v));
      }),
      _MenuRow(icon: AppIcons.bookmark, label: 'enregistrer comme recette', onTap: () {
        store.saveBlockAsRecipe(listId, block);
        LoToast.show(context, 'Ajouté à mes recettes');
        Navigator.pop(context);
      }),
      _MenuRow(icon: AppIcons.trash2, label: 'retirer le plat', danger: true, last: true, onTap: () {
        store.deleteBlock(listId, block.id);
        LoToast.show(context, 'Plat retiré');
        Navigator.pop(context);
      }),
    ]);
  });
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool danger;
  final bool last;
  final VoidCallback onTap;
  const _MenuRow({required this.icon, required this.label, this.danger = false, this.last = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = danger ? LoTheme.danger : LoTheme.ink;
    return Pressable(
      scale: 0.99,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 6),
        decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: LoTheme.line))),
        child: Row(children: [
          Icon(icon, size: 20, color: danger ? LoTheme.danger : LoTheme.ink2),
          const SizedBox(width: 14),
          Text(label, style: LoTheme.font(size: 16, weight: FontWeight.w600, color: color)),
        ]),
      ),
    );
  }
}

// ── shared bits ─────────────────────────────────────────────
Widget _toneIcon(Tone tn, double box, double icon) => Container(
      width: box,
      height: box,
      decoration: BoxDecoration(color: tn.soft, borderRadius: BorderRadius.circular(box * 0.3)),
      child: Icon(AppIcons.utensils, size: icon, color: tn.dot),
    );

Widget _recipeRow({required Tone tone, required String title, required String subtitle, Widget? trailing, required VoidCallback onTap}) {
  return Pressable(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: LoTheme.surface2, borderRadius: BorderRadius.circular(LoTheme.r(0.85))),
      child: Row(children: [
        _toneIcon(tone, 36, 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: LoTheme.font(size: 15, weight: FontWeight.w700)),
            Text(subtitle, style: LoTheme.font(size: 12.5, weight: FontWeight.w600, color: LoTheme.ink3)),
          ]),
        ),
        if (trailing != null) trailing,
      ]),
    ),
  );
}

String formatListForSharing({
  required BuildContext context,
  required ShoppingList list,
  required bool groupByAisle,
  required bool excludeChecked,
  required String locale,
}) {
  final sb = StringBuffer();
  final isFr = locale == 'fr';
  
  sb.writeln('🛒 ${list.name}');
  sb.writeln('====================');

  if (groupByAisle) {
    final consolidated = consolidateItems(list.blocks);
    
    final Map<String, List<ConsolidatedItem>> groups = {};
    for (final ci in consolidated) {
      if (excludeChecked && ci.checked) continue;
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

    for (final cat in sortedCats) {
      final displayName = context.categoryName(cat);
      sb.writeln('\n📦 ${displayName.toUpperCase()} :');
      for (final ci in groups[cat]!) {
        final checkSymbol = ci.checked ? '✓' : '☐';
        final f = fmtQty(ci.totalQty, ci.unit);
        final qtyStr = ci.totalQty == 1 && ci.unit == 'pc' ? '' : ' (${f.value}${f.suffix})';
        
        final sourceLabels = ci.blocks.map((b) => b.isRecipe ? b.name : (isFr ? 'vrac' : 'loose')).join(', ');
        
        sb.writeln('  $checkSymbol ${ci.name}$qtyStr [$sourceLabels]');
      }
    }
  } else {
    for (final b in list.blocks) {
      final items = excludeChecked ? b.items.where((it) => !it.checked).toList() : b.items;
      if (items.isEmpty) continue;
      
      if (b.isRecipe) {
        sb.writeln('\n🍳 ${b.name} (${b.servings} ${isFr ? "pers." : "serv."}) :');
      } else {
        sb.writeln(isFr ? '\n📦 EN VRAC :' : '\n📦 BULK :');
      }
      for (final it in items) {
        final checkSymbol = it.checked ? '✓' : '☐';
        final f = fmtQty(it.qty, it.unit);
        final qtyStr = it.qty == 1 && it.unit == 'pc' ? '' : ' (${f.value}${f.suffix})';
        sb.writeln('  $checkSymbol ${it.name}$qtyStr');
      }
    }
  }
  
  return sb.toString();
}

void shareList(BuildContext context, ShoppingList list) {
  final store = context.read<AppStore>();
  showLoSheet(
    context,
    title: store.locale == 'fr' ? 'partager la liste' : 'share list',
    builder: (ctx) => _ShareListBody(store: store, list: list),
  );
}

class _ShareListBody extends StatefulWidget {
  final AppStore store;
  final ShoppingList list;
  const _ShareListBody({super.key, required this.store, required this.list});

  @override
  State<_ShareListBody> createState() => _ShareListBodyState();
}

class _ShareListBodyState extends State<_ShareListBody> {
  bool _groupByAisle = false;
  bool _excludeChecked = false;

  Widget _toggleButton({required String label, required bool active, required VoidCallback onTap}) {
    return Expanded(
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: LoTheme.fast,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? LoTheme.primary : LoTheme.surface2,
            borderRadius: BorderRadius.circular(LoTheme.r(0.85)),
          ),
          child: Text(
            label,
            style: LoTheme.font(
              size: 13,
              weight: FontWeight.w700,
              color: active ? Colors.white : LoTheme.ink2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFr = widget.store.locale == 'fr';
    
    final previewText = formatListForSharing(
      context: context,
      list: widget.list,
      groupByAisle: _groupByAisle,
      excludeChecked: _excludeChecked,
      locale: widget.store.locale,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isFr ? 'GROUPER PAR' : 'GROUP BY', style: LoTheme.font(size: 11, weight: FontWeight.w700, color: LoTheme.ink3, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Row(
          children: [
            _toggleButton(
              label: isFr ? 'Recettes' : 'Recipes',
              active: !_groupByAisle,
              onTap: () => setState(() => _groupByAisle = false),
            ),
            const SizedBox(width: 8),
            _toggleButton(
              label: isFr ? 'Rayons' : 'Aisles',
              active: _groupByAisle,
              onTap: () => setState(() => _groupByAisle = true),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Text(isFr ? 'FILTRER LES ARTICLES' : 'FILTER ITEMS', style: LoTheme.font(size: 11, weight: FontWeight.w700, color: LoTheme.ink3, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Row(
          children: [
            _toggleButton(
              label: isFr ? 'Tout' : 'All',
              active: !_excludeChecked,
              onTap: () => setState(() => _excludeChecked = false),
            ),
            const SizedBox(width: 8),
            _toggleButton(
              label: isFr ? 'À acheter' : 'To buy',
              active: _excludeChecked,
              onTap: () => setState(() => _excludeChecked = true),
            ),
          ],
        ),
        
        sheetLabel(isFr ? 'aperçu' : 'preview'),
        Container(
          height: 180,
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: LoTheme.bg,
            borderRadius: BorderRadius.circular(LoTheme.radius),
            border: Border.all(color: LoTheme.line),
          ),
          child: Scrollbar(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: SelectableText(
                previewText,
                style: LoTheme.font(
                  size: 13.5,
                  weight: FontWeight.w600,
                  height: 1.45,
                  color: LoTheme.ink2,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        LoButton(
          label: isFr ? 'copier la liste' : 'copy list',
          icon: AppIcons.check,
          full: true,
          onTap: () {
            Clipboard.setData(ClipboardData(text: previewText));
            Navigator.pop(context);
            LoToast.show(context, isFr ? 'Liste copiée dans le presse-papiers' : 'List copied to clipboard');
          },
        ),
      ],
    );
  }
}

class CategoryChips extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChange;
  const CategoryChips({super.key, required this.value, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final order = [
      'Fruits & Légumes',
      'Produits Laitiers & Œufs',
      'Boulangerie',
      'Boucherie & Poissonnerie',
      'Épicerie',
      'Boissons',
      'En vrac',
    ];

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: order.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (c, i) {
          final cat = order[i];
          final active = cat == value;
          return Pressable(
            onTap: () => onChange(cat),
            child: AnimatedContainer(
              duration: LoTheme.fast,
              curve: LoTheme.ease,
              padding: const EdgeInsets.symmetric(horizontal: 13),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? LoTheme.primary : LoTheme.surface2,
                borderRadius: BorderRadius.circular(LoTheme.r(0.8)),
              ),
              child: Text(
                context.categoryName(cat),
                style: LoTheme.font(size: 13, weight: FontWeight.w700, color: active ? Colors.white : LoTheme.ink2),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Select Recipe For Day ────────────────────────────────────
void openSelectRecipeForDay(BuildContext context, String day) {
  final store = context.read<AppStore>();
  showLoSheet(
    context,
    title: context.t('planner.sheet.select_title'),
    builder: (ctx) => _SelectRecipeForDayBody(store: store, day: day),
  );
}

class _SelectRecipeForDayBody extends StatelessWidget {
  final AppStore store;
  final String day;
  const _SelectRecipeForDayBody({required this.store, required this.day});

  @override
  Widget build(BuildContext context) {
    final recipes = store.recipes;
    if (recipes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            store.locale == 'fr'
                ? 'Aucune recette dans votre bibliothèque.'
                : 'No recipes in your library.',
            style: LoTheme.font(size: 15, weight: FontWeight.w600, color: LoTheme.ink3),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final r in recipes) ...[
          _recipeRow(
            tone: Tone.of(r.tone),
            title: r.name,
            subtitle: store.locale == 'fr'
                ? '${r.items.length} ingrédients · ${r.servings} pers.'
                : '${r.items.length} ingredients · ${r.servings} serv.',
            onTap: () {
              store.planMeal(day, r.id, r.servings);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

// ── Generate List From Planner ────────────────────────────────
void openGenerateListFromPlanner(BuildContext context) {
  final store = context.read<AppStore>();
  showLoSheet(
    context,
    title: context.t('planner.sheet.generate_title'),
    builder: (ctx) => _GenerateListFromPlannerBody(store: store),
  );
}

class _GenerateListFromPlannerBody extends StatefulWidget {
  final AppStore store;
  const _GenerateListFromPlannerBody({required this.store});

  @override
  State<_GenerateListFromPlannerBody> createState() => _GenerateListFromPlannerBodyState();
}

class _GenerateListFromPlannerBodyState extends State<_GenerateListFromPlannerBody> {
  final _name = TextEditingController();
  late String _tone;

  @override
  void initState() {
    super.initState();
    _tone = Tone.allTones[widget.store.lists.length % Tone.allTones.length];
    final isFr = widget.store.locale == 'fr';
    _name.text = isFr ? 'Repas de la semaine' : 'Weekly Meals';
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _generate() {
    final nav = Navigator.of(context);
    final nm = _name.text.trim().isEmpty 
        ? (widget.store.locale == 'fr' ? 'Repas de la semaine' : 'Weekly Meals') 
        : _name.text.trim();
    final id = widget.store.generateListFromPlanner(nm, _tone);
    nav.pop();
    nav.push(listRoute(id));
    LoToast.show(context, context.t('planner.toast.generated'));
  }

  @override
  Widget build(BuildContext context) {
    final isFr = widget.store.locale == 'fr';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LoTextField(
          controller: _name,
          placeholder: isFr ? 'ex. Repas de la semaine' : 'ex. Weekly Meals',
          autoFocus: true,
          onSubmit: _generate,
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final s in isFr
              ? ['Repas de la semaine', 'Menu hebdo', 'Semaine complète']
              : ['Weekly Meals', 'Weekly Menu', 'Full Week'])
            Pressable(
              onTap: () => setState(() => _name.text = s),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                decoration: BoxDecoration(color: LoTheme.surface2, borderRadius: BorderRadius.circular(LoTheme.r(0.8))),
                child: Text(s, style: LoTheme.font(size: 13, weight: FontWeight.w600, color: LoTheme.ink2)),
              ),
            ),
        ]),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(context.t('planner.sheet.generate_color'), style: LoTheme.font(size: 11, weight: FontWeight.w700, color: LoTheme.ink3, letterSpacing: 0.5)),
        ),
        TonePicker(
          value: _tone,
          onChange: (v) => setState(() => _tone = v),
        ),
        const SizedBox(height: 20),
        LoButton(
          label: context.t('planner.sheet.generate_title'),
          icon: AppIcons.plus,
          full: true,
          onTap: _generate,
        ),
      ],
    );
  }
}

// ── Edit consolidated item ──────────────────────────────────
void openEditConsolidatedItem(BuildContext context, String listId, ConsolidatedItem ci) {
  final store = context.read<AppStore>();
  showLoSheet(
    context,
    title: store.locale == 'fr' ? "modifier l'article groupé" : "edit grouped item",
    builder: (ctx) => _EditConsolidatedItemBody(store: store, listId: listId, ci: ci),
  );
}

class _EditConsolidatedItemBody extends StatefulWidget {
  final AppStore store;
  final String listId;
  final ConsolidatedItem ci;
  const _EditConsolidatedItemBody({required this.store, required this.listId, required this.ci});

  @override
  State<_EditConsolidatedItemBody> createState() => _EditConsolidatedItemBodyState();
}

class _EditConsolidatedItemBodyState extends State<_EditConsolidatedItemBody> {
  late final _name = TextEditingController(text: widget.ci.name);
  late final List<TextEditingController> _qtyControllers;
  late String _unit = widget.ci.unit;
  late String _customCategory = widget.ci.category;

  @override
  void initState() {
    super.initState();
    _qtyControllers = widget.ci.items.map((it) => TextEditingController(text: numFr(it.qty))).toList();
  }

  @override
  void dispose() {
    _name.dispose();
    for (final ctrl in _qtyControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _save() {
    final nameVal = _name.text.trim();
    final newName = nameVal.isEmpty ? widget.ci.name : nameVal;
    
    final List<double> newQtys = [];
    for (var i = 0; i < widget.ci.items.length; i++) {
      final double val = double.tryParse(_qtyControllers[i].text.replaceAll(',', '.')) ?? widget.ci.items[i].qty;
      newQtys.add(val);
    }

    final itemIds = widget.ci.items.map((it) => it.id).toList();
    final blockIds = widget.ci.blocks.map((b) => b.id).toList();

    widget.store.updateConsolidatedItem(
      widget.listId,
      blockIds,
      itemIds,
      newName,
      newQtys,
      _unit,
      _customCategory,
    );
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isFr = widget.store.locale == 'fr';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sheetLabel(isFr ? 'article' : 'item'),
        LoTextField(controller: _name),
        const SizedBox(height: 12),
        UnitChips(value: _unit, onChange: (v) => setState(() => _unit = v)),
        const SizedBox(height: 14),
        sheetLabel(context.t('item.editor.aisle')),
        CategoryChips(value: _customCategory, onChange: (v) => setState(() => _customCategory = v)),
        const SizedBox(height: 14),
        sheetLabel(isFr ? 'détails par recette' : 'details by recipe'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: LoTheme.surface2,
            borderRadius: BorderRadius.circular(LoTheme.r(0.9)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < widget.ci.items.length; i++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.ci.blocks[i].isRecipe
                              ? widget.ci.blocks[i].name
                              : (isFr ? 'En vrac' : 'Loose'),
                          style: LoTheme.font(size: 14.5, weight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 12),
                      InlineInput(
                        controller: _qtyControllers[i],
                        width: 80,
                        align: TextAlign.center,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _unit,
                        style: LoTheme.font(size: 14.5, weight: FontWeight.w700, color: LoTheme.ink3),
                      ),
                    ],
                  ),
                ),
                if (i < widget.ci.items.length - 1)
                  const Divider(color: LoTheme.line, height: 1),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            LoButton(
              label: isFr ? 'retirer' : 'remove',
              variant: BtnVariant.danger,
              icon: AppIcons.trash2,
              onTap: () {
                final itemIds = widget.ci.items.map((it) => it.id).toList();
                final blockIds = widget.ci.blocks.map((b) => b.id).toList();
                widget.store.deleteConsolidatedItem(widget.listId, blockIds, itemIds);
                Navigator.pop(context);
              },
            ),
            const SizedBox(width: 10),
            Expanded(
              child: LoButton(
                label: isFr ? 'enregistrer' : 'save',
                icon: AppIcons.check,
                full: true,
                onTap: _save,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

void openDietaryFilterSheet(BuildContext context) {
  final store = context.read<AppStore>();
  showLoSheet(
    context,
    title: store.locale == 'fr' ? 'Régimes & Allergènes' : 'Diets & Allergens',
    builder: (ctx) => _DietaryFilterSheetBody(store: store),
  );
}

class _DietaryFilterSheetBody extends StatefulWidget {
  final AppStore store;
  const _DietaryFilterSheetBody({required this.store});

  @override
  State<_DietaryFilterSheetBody> createState() => _DietaryFilterSheetBodyState();
}

class _DietaryFilterSheetBodyState extends State<_DietaryFilterSheetBody> {
  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final isFr = store.locale == 'fr';

    Widget filterRow({
      required String label,
      required String tag,
      required IconData icon,
    }) {
      final active = store.activeDietaryFilters.contains(tag);
      return Pressable(
        onTap: () {
          setState(() {
            store.toggleDietaryFilter(tag);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: active ? LoTheme.primarySoft : LoTheme.surface2,
            borderRadius: BorderRadius.circular(LoTheme.r(0.9)),
            border: Border.all(
              color: active ? LoTheme.primaryPress : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: active ? LoTheme.primaryPress : LoTheme.ink2),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: LoTheme.font(
                    size: 15,
                    weight: active ? FontWeight.w700 : FontWeight.w600,
                    color: active ? LoTheme.primaryPress : LoTheme.ink,
                  ),
                ),
              ),
              if (active)
                const Icon(AppIcons.check, size: 18, color: LoTheme.primaryPress)
              else
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    border: Border.all(color: LoTheme.lineStrong, width: 2),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        filterRow(
          label: isFr ? 'Végétarien' : 'Vegetarian',
          tag: 'veggie',
          icon: Icons.grass_rounded,
        ),
        filterRow(
          label: isFr ? 'Sans Gluten' : 'Gluten-Free',
          tag: 'gluten_free',
          icon: Icons.grain_rounded,
        ),
        filterRow(
          label: isFr ? 'Sans Lactose' : 'Dairy-Free',
          tag: 'lactose_free',
          icon: Icons.water_drop_rounded,
        ),
        const SizedBox(height: 16),
        if (store.activeDietaryFilters.isNotEmpty)
          LoButton(
            label: isFr ? 'réinitialiser les filtres' : 'reset filters',
            variant: BtnVariant.soft,
            full: true,
            onTap: () {
              setState(() {
                store.clearDietaryFilters();
              });
            },
          ),
      ],
    );
  }
}

// ── Database / Catalog Items Bottom Sheet ────────────────────
void openDatabaseItemsSheet(BuildContext context, ValueChanged<String> onSelect) {
  final store = context.read<AppStore>();
  showLoSheet(
    context,
    title: store.locale == 'fr' ? "catalogue produits" : "product catalog",
    minHeight: MediaQuery.of(context).size.height * 0.85,
    maxHeight: MediaQuery.of(context).size.height * 0.94,
    builder: (ctx) => _DatabaseItemsSheet(onSelect: (val) {
      onSelect(val);
      Navigator.pop(ctx);
    }),
  );
}

class _DatabaseItemsSheet extends StatefulWidget {
  final ValueChanged<String> onSelect;
  const _DatabaseItemsSheet({required this.onSelect});

  @override
  State<_DatabaseItemsSheet> createState() => _DatabaseItemsSheetState();
}

class _DatabaseItemsSheetState extends State<_DatabaseItemsSheet> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final isFr = store.locale == 'fr';

    // Unique products from the database
    final allProducts = kProductCategories.keys.toList()..sort();

    // Filter by search query
    final filtered = _searchQuery.isEmpty
        ? allProducts
        : allProducts.where((p) => p.toLowerCase().contains(_searchQuery)).toList();

    // Group by category
    final Map<String, List<String>> groups = {};
    for (final p in filtered) {
      final cat = getCategoryForProduct(p);
      groups.putIfAbsent(cat, () => []).add(p);
    }

    // Sort categories using standard order
    final order = [
      'Fruits & Légumes',
      'Produits Laitiers & Œufs',
      'Boulangerie',
      'Boucherie & Poissonnerie',
      'Épicerie',
      'Boissons',
      'Hygiène & Entretien',
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
        LoTextField(
          controller: _searchCtrl,
          placeholder: isFr ? 'Rechercher un article...' : 'Search an item...',
          autoFocus: false,
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                isFr ? 'Aucun article trouvé' : 'No items found',
                style: LoTheme.font(size: 15, color: LoTheme.ink3, weight: FontWeight.w600),
              ),
            ),
          )
        else
          ...sortedCats.map((cat) {
            final displayName = context.categoryName(cat);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 16, 4, 10),
                  child: Row(
                    children: [
                      Icon(_getCategoryIcon(cat), size: 16, color: LoTheme.ink3),
                      const SizedBox(width: 8),
                      Text(
                        displayName.toUpperCase(),
                        style: LoTheme.font(
                          size: 12,
                          weight: FontWeight.w700,
                          color: LoTheme.ink3,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: groups[cat]!.map((p) {
                    return Pressable(
                      onTap: () => widget.onSelect(p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: LoTheme.surface2,
                          borderRadius: BorderRadius.circular(LoTheme.r(0.8)),
                        ),
                        child: Text(
                          p,
                          style: LoTheme.font(size: 13.5, weight: FontWeight.w600, color: LoTheme.ink2),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          }),
      ],
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
      case 'Hygiène & Entretien':
        return Icons.clean_hands_rounded;
      default:
        return AppIcons.shoppingCart;
    }
  }
}



