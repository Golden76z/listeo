import 'package:flutter/material.dart';
import '../theme/icons.dart';

import '../models/models.dart';
import '../models/unit.dart';
import '../theme/app_theme.dart';
import 'primitives.dart';

/// Editable recipe draft held by the editor.
class RecipeDraft {
  String name;
  int servings;
  List<Item> items;
  RecipeDraft({this.name = '', this.servings = 4, List<Item>? items}) : items = items ?? [];
}

/// Controlled recipe editor — name, servings, ingredient rows + an add row.
class RecipeEditorView extends StatefulWidget {
  final RecipeDraft draft;
  final VoidCallback onChanged;
  const RecipeEditorView({super.key, required this.draft, required this.onChanged});

  @override
  State<RecipeEditorView> createState() => _RecipeEditorViewState();
}

class _RecipeEditorViewState extends State<RecipeEditorView> {
  final _nameCtrl = TextEditingController();
  final _draftName = TextEditingController();
  final _draftQty = TextEditingController(text: '1');
  String _draftUnit = 'pc';

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.draft.name;
    _nameCtrl.addListener(() {
      widget.draft.name = _nameCtrl.text;
      widget.onChanged();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _draftName.dispose();
    _draftQty.dispose();
    super.dispose();
  }

  void _addItem() {
    final name = _draftName.text.trim();
    if (name.isEmpty) return;
    setState(() {
      widget.draft.items.add(Item(
        id: uid('it'),
        name: name,
        qty: double.tryParse(_draftQty.text.replaceAll(',', '.')) ?? 1,
        unit: _draftUnit,
      ));
      _draftName.clear();
      _draftQty.text = '1';
      _draftUnit = 'pc';
    });
    widget.onChanged();
  }

  Widget _label(String t, {EdgeInsets? padding}) => Padding(
        padding: padding ?? const EdgeInsets.only(bottom: 8),
        child: Text(t.toUpperCase(),
            style: LoTheme.font(size: 12.5, weight: FontWeight.w700, color: LoTheme.ink3, letterSpacing: 0.5)),
      );

  @override
  Widget build(BuildContext context) {
    final d = widget.draft;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('nom du plat'),
        LoTextField(controller: _nameCtrl, placeholder: 'ex. Curry de légumes', autoFocus: d.name.isEmpty),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              const Icon(AppIcons.users, size: 16, color: LoTheme.ink2),
              const SizedBox(width: 7),
              Text('POUR', style: LoTheme.font(size: 12.5, weight: FontWeight.w700, color: LoTheme.ink3, letterSpacing: 0.5)),
            ]),
            LoStepper(
              value: d.servings,
              min: 1,
              max: 50,
              suffix: ' pers.',
              onChange: (v) => setState(() {
                d.servings = v;
                widget.onChanged();
              }),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _label('ingrédients · ${d.items.length}'),
        ...d.items.map((it) => _EditIngredientRow(
              key: ValueKey(it.id),
              item: it,
              onChanged: () => setState(widget.onChanged),
              onDelete: () => setState(() {
                d.items.remove(it);
                widget.onChanged();
              }),
            )),
        if (d.items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text('Ajoute ton premier ingrédient ci-dessous.',
                style: LoTheme.font(size: 14, color: LoTheme.ink3)),
          ),
        const SizedBox(height: 14),
        // add ingredient card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: LoTheme.surface2, borderRadius: BorderRadius.circular(LoTheme.r(0.9))),
          child: Column(
            children: [
              Row(children: [
                Expanded(
                  child: InlineInput(
                    controller: _draftName,
                    placeholder: 'nouvel ingrédient',
                    background: LoTheme.surface,
                    onSubmit: _addItem,
                  ),
                ),
                const SizedBox(width: 8),
                InlineInput(
                  controller: _draftQty,
                  width: 56,
                  align: TextAlign.center,
                  background: LoTheme.surface,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ]),
              const SizedBox(height: 10),
              UnitChips(value: _draftUnit, onChange: (v) => setState(() => _draftUnit = v)),
              const SizedBox(height: 10),
              ValueListenableBuilder(
                valueListenable: _draftName,
                builder: (c, v, _) {
                  final enabled = v.text.trim().isNotEmpty;
                  return Pressable(
                    onTap: enabled ? _addItem : null,
                    child: Container(
                      height: 42,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: enabled ? LoTheme.primarySoft : LoTheme.line,
                        borderRadius: BorderRadius.circular(LoTheme.r(1)),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(AppIcons.plus, size: 17, color: enabled ? LoTheme.primaryPress : LoTheme.ink3),
                        const SizedBox(width: 6),
                        Text("ajouter l'ingrédient",
                            style: LoTheme.font(size: 14.5, weight: FontWeight.w700, color: enabled ? LoTheme.primaryPress : LoTheme.ink3)),
                      ]),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EditIngredientRow extends StatefulWidget {
  final Item item;
  final VoidCallback onChanged;
  final VoidCallback onDelete;
  const _EditIngredientRow({super.key, required this.item, required this.onChanged, required this.onDelete});

  @override
  State<_EditIngredientRow> createState() => _EditIngredientRowState();
}

class _EditIngredientRowState extends State<_EditIngredientRow> {
  late final TextEditingController _name = TextEditingController(text: widget.item.name);
  late final TextEditingController _qty = TextEditingController(text: numFr(widget.item.qty));

  @override
  void initState() {
    super.initState();
    _name.addListener(() {
      widget.item.name = _name.text;
      widget.onChanged();
    });
    _qty.addListener(() {
      widget.item.qty = double.tryParse(_qty.text.replaceAll(',', '.')) ?? 0;
      widget.onChanged();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _qty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: LoTheme.line))),
      child: Row(children: [
        Container(width: 6, height: 6, decoration: const BoxDecoration(color: LoTheme.lineStrong, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _name,
            cursorColor: LoTheme.primary,
            style: LoTheme.font(size: 15.5, weight: FontWeight.w600),
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              hintText: 'ingrédient',
              hintStyle: LoTheme.font(size: 15.5, weight: FontWeight.w600, color: LoTheme.ink3),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 46,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(color: LoTheme.surface2, borderRadius: BorderRadius.circular(8)),
          child: TextField(
            controller: _qty,
            textAlign: TextAlign.right,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            cursorColor: LoTheme.primary,
            style: LoTheme.font(size: 14, weight: FontWeight.w700),
            decoration: const InputDecoration(isCollapsed: true, border: InputBorder.none),
          ),
        ),
        SizedBox(
          width: 44,
          child: Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(unitById(widget.item.unit).label,
                style: LoTheme.font(size: 12.5, weight: FontWeight.w600, color: LoTheme.ink2)),
          ),
        ),
        Pressable(
          scale: 0.8,
          onTap: widget.onDelete,
          child: const SizedBox(width: 28, height: 28, child: Icon(AppIcons.x, size: 16, color: LoTheme.ink3)),
        ),
      ]),
    );
  }
}
