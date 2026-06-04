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

// ── Sheet shell ─────────────────────────────────────────────
Future<T?> showLoSheet<T>(BuildContext context, {String? title, required WidgetBuilder builder}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x52191D14),
    builder: (ctx) {
      return _SheetShell(title: title, child: Builder(builder: builder));
    },
  );
}

class _SheetShell extends StatelessWidget {
  final String? title;
  final Widget child;
  const _SheetShell({this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: LoTheme.ease,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
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
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
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
  showLoSheet(context, title: 'nouvelle liste', builder: (ctx) => _CreateListBody(store: store));
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
      ...store.recipes.map((r) {
        final on = _sel.contains(r.id);
        final tn = Tone.of(r.tone);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Pressable(
            onTap: () => setState(() => on ? _sel.remove(r.id) : _sel.add(r.id)),
            child: AnimatedContainer(
              duration: LoTheme.fast,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: on ? LoTheme.primarySoft : LoTheme.surface2,
                borderRadius: BorderRadius.circular(LoTheme.r(0.85)),
                border: Border.all(color: on ? LoTheme.primary : Colors.transparent, width: 2),
              ),
              child: Row(children: [
                _toneIcon(tn, 34, 17),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.name, style: LoTheme.font(size: 15, weight: FontWeight.w700)),
                    Text('${r.servings} ${context.t('recipe.servings')}', style: LoTheme.font(size: 12.5, weight: FontWeight.w600, color: LoTheme.ink3)),
                  ]),
                ),
                AnimatedContainer(
                  duration: LoTheme.fast,
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: on ? LoTheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: on ? null : Border.all(color: LoTheme.lineStrong, width: 2),
                  ),
                  child: on ? const Icon(AppIcons.check, size: 14, color: Colors.white) : null,
                ),
              ]),
            ),
          ),
        );
      }),
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

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: InlineInput(controller: _name, focusNode: _focus, autofocus: true, placeholder: 'ex. Tomates', onSubmit: _add)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 6, right: 6),
          child: Text('COULEUR DE LA LISTE', style: LoTheme.font(size: 11, weight: FontWeight.w700, color: LoTheme.ink3, letterSpacing: 0.5)),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16, left: 6, right: 6),
          child: StatefulBuilder(
            builder: (context, setState) {
              return TonePicker(
                value: list.tone,
                onChange: (newTone) {
                  setState(() {});
                  store.changeListTone(list.id, newTone);
                },
              );
            },
          ),
        ),
        const Divider(color: LoTheme.line, height: 1),
        _MenuRow(icon: AppIcons.pencil, label: 'renommer la liste', onTap: () {
          Navigator.pop(context);
          openRename(context, title: 'renommer la liste', value: list.name, onSave: (v) => store.renameList(list.id, v));
        }),
        _MenuRow(icon: AppIcons.copy, label: 'dupliquer', onTap: () {
          store.duplicateList(list.id);
          LoToast.show(context, 'Liste dupliquée');
          Navigator.pop(context);
        }),
        _MenuRow(icon: AppIcons.share, label: 'partager la liste', onTap: () {
          shareList(context, list);
          Navigator.pop(context);
        }),
        _MenuRow(icon: AppIcons.uncheck, label: 'tout décocher', onTap: () {
          store.uncheckAllItems(list.id);
          LoToast.show(context, 'Articles décochés');
          Navigator.pop(context);
        }),
        _MenuRow(icon: AppIcons.deleteChecked, label: 'nettoyer les articles cochés', onTap: () {
          store.clearCheckedItems(list.id);
          LoToast.show(context, 'Articles cochés supprimés');
          Navigator.pop(context);
        }),
        _MenuRow(icon: AppIcons.trash2, label: 'supprimer la liste', danger: true, last: true, onTap: () {
          final nav = Navigator.of(context);
          nav.pop();
          openConfirm(nav.context,
              title: 'Supprimer la liste ?',
              message: '« ${list.name} » et tout son contenu seront supprimés.',
              confirmLabel: 'supprimer',
              onConfirm: (ctx) {
                store.deleteList(list.id);
                LoToast.show(ctx, 'Liste supprimée');
              });
        }),
      ],
    );
  });
}

// ── Block menu ──────────────────────────────────────────────
void openBlockMenu(BuildContext context, String listId, Block block) {
  final store = context.read<AppStore>();
  showLoSheet(context, title: block.name, builder: (ctx) {
    return Column(children: [
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

String formatListAsText(ShoppingList list) {
  final sb = StringBuffer();
  sb.writeln('🛒 ${list.name}');
  sb.writeln('--------------------');
  for (final b in list.blocks) {
    if (b.items.isEmpty) continue;
    if (b.isRecipe) {
      sb.writeln('\n🍳 ${b.name} (${b.servings} pers.) :');
    } else {
      sb.writeln('\n📦 ${b.name} :');
    }
    for (final it in b.items) {
      final checkSymbol = it.checked ? '[x]' : '[ ]';
      final qtyStr = it.qty == 1 && it.unit == 'pc' ? '' : ' (${fmtQty(it.qty, it.unit).value}${fmtQty(it.qty, it.unit).suffix})';
      sb.writeln('  $checkSymbol ${it.name}$qtyStr');
    }
  }
  return sb.toString();
}

void shareList(BuildContext context, ShoppingList list) {
  final text = formatListAsText(list);
  Clipboard.setData(ClipboardData(text: text));
  LoToast.show(context, 'Liste copiée dans le presse-papiers');
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


