import 'package:flutter/material.dart';
import '../theme/icons.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
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

  void _create() {
    final nav = Navigator.of(context);
    final nm = _name.text.trim().isEmpty ? 'Nouvelle liste' : _name.text.trim();
    final id = widget.store.createList(nm, _sel.toList());
    nav.pop();
    nav.push(listRoute(id));
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      LoTextField(controller: _name, placeholder: 'ex. Courses de la semaine', autoFocus: true, onSubmit: _create),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final s in ['Courses de la semaine', 'Apéro', 'Week-end', 'Batch cooking'])
          Pressable(
            onTap: () => setState(() => _name.text = s),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              decoration: BoxDecoration(color: LoTheme.surface2, borderRadius: BorderRadius.circular(99)),
              child: Text(s, style: LoTheme.font(size: 13, weight: FontWeight.w600, color: LoTheme.ink2)),
            ),
          ),
      ]),
      Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 10),
        child: Text.rich(TextSpan(children: [
          TextSpan(text: 'DÉMARRER AVEC UNE RECETTE ', style: LoTheme.font(size: 12.5, weight: FontWeight.w700, color: LoTheme.ink3, letterSpacing: 0.5)),
          TextSpan(text: '· optionnel', style: LoTheme.font(size: 12.5, weight: FontWeight.w500, color: LoTheme.ink3)),
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
                    Text('${r.servings} pers.', style: LoTheme.font(size: 12.5, weight: FontWeight.w600, color: LoTheme.ink3)),
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
        label: 'créer la liste${_sel.isNotEmpty ? ' · ${_sel.length} plat${_sel.length > 1 ? 's' : ''}' : ''}',
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

  void _save() {
    widget.store.updateItem(widget.listId, widget.blockId ?? _findBlockId(), widget.item.id,
        name: _name.text.trim().isEmpty ? widget.item.name : _name.text.trim(),
        qty: double.tryParse(_qty.text.replaceAll(',', '.')) ?? widget.item.qty,
        unit: _unit);
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
      const SizedBox(height: 12),
      UnitChips(value: _unit, onChange: (v) => setState(() => _unit = v)),
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
  final _draft = RecipeDraft(servings: 2);
  bool _saveLib = true;

  Widget _backLink(VoidCallback onTap) => Pressable(
        onTap: onTap,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(AppIcons.chevronLeft, size: 16, color: LoTheme.ink2),
          const SizedBox(width: 5),
          Text('retour', style: LoTheme.font(size: 14, weight: FontWeight.w700, color: LoTheme.ink2)),
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
                Text('nouveau plat', style: LoTheme.font(size: 15.5, weight: FontWeight.w700, color: LoTheme.primaryPress)),
                Text('composer librement les ingrédients', style: LoTheme.font(size: 12.5, weight: FontWeight.w600, color: LoTheme.ink2)),
              ]),
            ),
            const Icon(AppIcons.chevronRight, size: 18, color: LoTheme.primaryPress),
          ]),
        ),
      ),
      sheetLabel('mes recettes'),
      ...store.recipes.map((r) {
        final tn = Tone.of(r.tone);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _recipeRow(
            tone: tn,
            title: r.name,
            subtitle: '${r.items.length} ingrédients · ${r.servings} pers.',
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
            Text('pour', style: LoTheme.font(size: 15, weight: FontWeight.w700)),
          ]),
          LoStepper(value: _servings, min: 1, max: 50, suffix: ' pers.', onChange: (v) => setState(() => _servings = v)),
        ]),
      ),
      sheetLabel('quantités ajustées'),
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
        label: 'ajouter à la liste',
        icon: AppIcons.plus,
        full: true,
        onTap: () {
          widget.store.addRecipeBlock(widget.listId, r, _servings);
          LoToast.show(context, '${r.name} ajouté');
          Navigator.pop(context);
        },
      ),
    ]);
  }

  Widget _adhoc() {
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
            Text('enregistrer aussi dans mes recettes', style: LoTheme.font(size: 14.5, weight: FontWeight.w600)),
            const SizedBox(width: 6),
            const Icon(AppIcons.bookmark, size: 16, color: LoTheme.accentInk),
          ]),
        ),
      ),
      const SizedBox(height: 16),
      LoButton(
        label: 'ajouter à la liste',
        icon: AppIcons.plus,
        full: true,
        disabled: _draft.name.trim().isEmpty || _draft.items.isEmpty,
        onTap: () {
          widget.store.addAdhocDish(widget.listId, name: _draft.name, servings: _draft.servings, items: _draft.items, saveLib: _saveLib);
          LoToast.show(context, '${_draft.name.trim()} ajouté');
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
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(r.name, style: LoTheme.font(size: 20, weight: FontWeight.w700)),
          Text('${r.items.length} ingrédients · ${r.servings} pers.', style: LoTheme.font(size: 13, weight: FontWeight.w600, color: LoTheme.ink3)),
        ]),
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
              onConfirm: () {
                store.deleteRecipe(r.id);
                LoToast.show(nav.context, 'Recette supprimée');
              });
        }),
      ]),
    ]);
  }
}

// ── Add a library recipe to a chosen list ───────────────────
void openAddRecipeToList(BuildContext context, String recipeId) {
  final store = context.read<AppStore>();
  showLoSheet(context, title: 'ajouter à une liste', builder: (ctx) => _AddRecipeToListBody(store: store, recipeId: recipeId));
}

class _AddRecipeToListBody extends StatefulWidget {
  final AppStore store;
  final String recipeId;
  const _AddRecipeToListBody({required this.store, required this.recipeId});
  @override
  State<_AddRecipeToListBody> createState() => _AddRecipeToListBodyState();
}

class _AddRecipeToListBodyState extends State<_AddRecipeToListBody> {
  late int _servings;
  Recipe? _r;

  @override
  void initState() {
    super.initState();
    _r = widget.store.recipeById(widget.recipeId);
    _servings = _r?.servings ?? 2;
  }

  @override
  Widget build(BuildContext context) {
    final r = _r;
    if (r == null) return const SizedBox.shrink();
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
            Text('pour', style: LoTheme.font(size: 15, weight: FontWeight.w700)),
          ]),
          LoStepper(value: _servings, min: 1, max: 50, suffix: ' pers.', onChange: (v) => setState(() => _servings = v)),
        ]),
      ),
      sheetLabel('ajouter à'),
      ...widget.store.lists.map((l) {
        final tn = Tone.of(l.tone);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Pressable(
            onTap: () {
              final nav = Navigator.of(context);
              widget.store.addRecipeBlock(l.id, r, _servings);
              nav.pop();
              LoToast.show(nav.context, 'Ajouté à ${l.name}');
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
          final nav = Navigator.of(context);
          final id = widget.store.createList('Nouvelle liste', []);
          widget.store.addRecipeBlock(id, r, _servings);
          nav.pop();
          LoToast.show(nav.context, 'Nouvelle liste créée');
          nav.push(listRoute(id));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: LoTheme.primarySoft, borderRadius: BorderRadius.circular(LoTheme.r(0.85))),
          child: Row(children: [
            const Icon(AppIcons.plus, size: 20, color: LoTheme.primaryPress),
            const SizedBox(width: 12),
            Expanded(child: Text('une nouvelle liste', style: LoTheme.font(size: 15, weight: FontWeight.w700, color: LoTheme.primaryPress))),
          ]),
        ),
      ),
    ]);
  }
}

// ── Recipe create / edit ────────────────────────────────────
void openRecipeEditor(BuildContext context, {String? recipeId}) {
  final store = context.read<AppStore>();
  showLoSheet(context,
      title: recipeId != null ? 'modifier la recette' : 'nouvelle recette',
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
        ? RecipeDraft(name: r.name, servings: r.servings, items: r.items.map((it) => Item(id: uid('it'), name: it.name, qty: it.qty, unit: it.unit)).toList())
        : RecipeDraft(servings: 4);
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
          widget.store.saveRecipe(existingId: widget.recipeId, name: _draft.name, servings: _draft.servings, items: _draft.items);
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
void openConfirm(BuildContext context, {required String title, required String message, String confirmLabel = 'supprimer', required VoidCallback onConfirm}) {
  showLoSheet(context, title: title, builder: (ctx) => _ConfirmBody(message: message, confirmLabel: confirmLabel, onConfirm: onConfirm));
}

class _ConfirmBody extends StatelessWidget {
  final String message;
  final String confirmLabel;
  final VoidCallback onConfirm;
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
          onConfirm();
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
    return Column(children: [
      _MenuRow(icon: AppIcons.pencil, label: 'renommer la liste', onTap: () {
        Navigator.pop(context);
        openRename(context, title: 'renommer la liste', value: list.name, onSave: (v) => store.renameList(list.id, v));
      }),
      _MenuRow(icon: AppIcons.copy, label: 'dupliquer', onTap: () {
        store.duplicateList(list.id);
        LoToast.show(context, 'Liste dupliquée');
        Navigator.pop(context);
      }),
      _MenuRow(icon: AppIcons.trash2, label: 'supprimer la liste', danger: true, last: true, onTap: () {
        Navigator.pop(context);
        openConfirm(context,
            title: 'Supprimer la liste ?',
            message: '« ${list.name} » et tout son contenu seront supprimés.',
            confirmLabel: 'supprimer',
            onConfirm: () {
              store.deleteList(list.id);
              LoToast.show(context, 'Liste supprimée');
            });
      }),
    ]);
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
