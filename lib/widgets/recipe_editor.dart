import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/icons.dart';

import '../data/store.dart';
import '../models/models.dart';
import '../models/unit.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n.dart';
import 'primitives.dart';

/// Editable recipe draft held by the editor.
class RecipeDraft {
  String name;
  int servings;
  String tone;
  List<Item> items;
  List<String> instructions;
  List<String> tags;
  RecipeDraft({this.name = '', this.servings = 4, this.tone = 'green', List<Item>? items, List<String>? instructions, List<String>? tags})
      : items = items ?? [],
        instructions = instructions ?? [],
        tags = tags ?? [];
}

/// A premium color selection row for list and recipe accent tones.
class TonePicker extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChange;
  const TonePicker({super.key, required this.value, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: Tone.allTones.map((key) {
        final tn = Tone.of(key);
        final selected = value == key;
        return Pressable(
          scale: 0.88,
          onTap: () => onChange(key),
          child: AnimatedContainer(
            duration: LoTheme.fast,
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: tn.soft,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? tn.dot : Colors.transparent,
                width: 2.5,
              ),
            ),
            child: Center(
              child: selected
                  ? Icon(AppIcons.check, size: 16, color: tn.dot)
                  : Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: tn.dot.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Controlled recipe editor — name, servings, color, ingredient rows + an add row.
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
  final _draftStep = TextEditingController();
  List<_InstructionDraft> _instructions = [];

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.draft.name;
    _nameCtrl.addListener(() {
      widget.draft.name = _nameCtrl.text;
      widget.onChanged();
    });
    _instructions = widget.draft.instructions.map((s) => _InstructionDraft(uid('ins'), s)).toList();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _draftName.dispose();
    _draftQty.dispose();
    _draftStep.dispose();
    super.dispose();
  }

  void _addStep() {
    final text = _draftStep.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _instructions.add(_InstructionDraft(uid('ins'), text));
      _draftStep.clear();
      _syncInstructions();
    });
  }

  void _syncInstructions() {
    widget.draft.instructions = _instructions.map((ins) => ins.text.trim()).toList();
    widget.onChanged();
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
    final store = context.watch<AppStore>();
    final isFr = store.locale == 'fr';
    final d = widget.draft;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(context.t('recipe.editor.name')),
        LoTextField(controller: _nameCtrl, placeholder: 'ex. Curry de légumes', autoFocus: d.name.isEmpty),
        const SizedBox(height: 18),
        _label(context.t('recipe.editor.color')),
        TonePicker(
          value: d.tone,
          onChange: (v) => setState(() {
            d.tone = v;
            widget.onChanged();
          }),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              const Icon(AppIcons.users, size: 16, color: LoTheme.ink2),
              const SizedBox(width: 7),
              Text(context.t('recipe.editor.servings'), style: LoTheme.font(size: 12.5, weight: FontWeight.w700, color: LoTheme.ink3, letterSpacing: 0.5)),
            ]),
            LoStepper(
              value: d.servings,
              min: 1,
              max: 50,
              suffix: ' ${context.t('recipe.servings')}',
              onChange: (v) => setState(() {
                d.servings = v;
                widget.onChanged();
              }),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _label(isFr ? 'Régime alimentaire' : 'Dietary tags'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _TagChip(
              label: isFr ? 'Végétarien' : 'Vegetarian',
              active: d.tags.contains('veggie'),
              onTap: () => setState(() {
                if (d.tags.contains('veggie')) {
                  d.tags.remove('veggie');
                } else {
                  d.tags.add('veggie');
                }
                widget.onChanged();
              }),
            ),
            _TagChip(
              label: isFr ? 'Sans Gluten' : 'Gluten-Free',
              active: d.tags.contains('gluten_free'),
              onTap: () => setState(() {
                if (d.tags.contains('gluten_free')) {
                  d.tags.remove('gluten_free');
                } else {
                  d.tags.add('gluten_free');
                }
                widget.onChanged();
              }),
            ),
            _TagChip(
              label: isFr ? 'Sans Lactose' : 'Dairy-Free',
              active: d.tags.contains('lactose_free'),
              onTap: () => setState(() {
                if (d.tags.contains('lactose_free')) {
                  d.tags.remove('lactose_free');
                } else {
                  d.tags.add('lactose_free');
                }
                widget.onChanged();
              }),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _label('${context.t('recipe.editor.ingredients')} · ${d.items.length}'),
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
            child: Text(isFr ? 'Ajoute ton premier ingrédient ci-dessous.' : 'Add your first ingredient below.',
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
                    placeholder: context.t('recipe.editor.new_ingredient'),
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
                        Text(context.t('recipe.editor.add_ingredient'),
                            style: LoTheme.font(size: 14.5, weight: FontWeight.w700, color: enabled ? LoTheme.primaryPress : LoTheme.ink3)),
                      ]),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _label('${isFr ? 'préparation' : 'instructions'} · ${_instructions.length}'),
        ..._instructions.asMap().entries.map((entry) {
          final idx = entry.key;
          final ins = entry.value;
          return _EditInstructionRow(
            key: ValueKey(ins.id),
            index: idx,
            item: ins,
            onChanged: _syncInstructions,
            onDelete: () => setState(() {
              _instructions.remove(ins);
              _syncInstructions();
            }),
          );
        }),
        if (_instructions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(isFr ? 'Ajoute ta première étape ci-dessous.' : 'Add your first step below.',
                style: LoTheme.font(size: 14, color: LoTheme.ink3)),
          ),
        const SizedBox(height: 14),
        // add step card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: LoTheme.surface2, borderRadius: BorderRadius.circular(LoTheme.r(0.9))),
          child: Column(
            children: [
              InlineInput(
                controller: _draftStep,
                placeholder: isFr ? 'Ajouter une étape...' : 'Add a step...',
                background: LoTheme.surface,
                onSubmit: _addStep,
              ),
              const SizedBox(height: 10),
              ValueListenableBuilder(
                valueListenable: _draftStep,
                builder: (c, v, _) {
                  final enabled = v.text.trim().isNotEmpty;
                  return Pressable(
                    onTap: enabled ? _addStep : null,
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
                        Text(isFr ? 'Ajouter l\'étape' : 'Add Step',
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
    final isFr = context.watch<AppStore>().locale == 'fr';
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
              hintText: isFr ? 'ingrédient' : 'ingredient',
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

class _InstructionDraft {
  final String id;
  String text;
  _InstructionDraft(this.id, this.text);
}

class _EditInstructionRow extends StatefulWidget {
  final int index;
  final _InstructionDraft item;
  final VoidCallback onChanged;
  final VoidCallback onDelete;
  const _EditInstructionRow({
    super.key,
    required this.index,
    required this.item,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<_EditInstructionRow> createState() => _EditInstructionRowState();
}

class _EditInstructionRowState extends State<_EditInstructionRow> {
  late final TextEditingController _ctrl = TextEditingController(text: widget.item.text);

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      widget.item.text = _ctrl.text;
      widget.onChanged();
    });
  }

  @override
  void didUpdateWidget(covariant _EditInstructionRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.text != widget.item.text && _ctrl.text != widget.item.text) {
      _ctrl.text = widget.item.text;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFr = context.watch<AppStore>().locale == 'fr';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: LoTheme.line))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: LoTheme.surface2,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${widget.index + 1}',
              style: LoTheme.font(size: 12, weight: FontWeight.w700, color: LoTheme.ink2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _ctrl,
              cursorColor: LoTheme.primary,
              maxLines: null,
              style: LoTheme.font(size: 15, weight: FontWeight.w600),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: isFr ? 'étape de préparation' : 'preparation step',
                hintStyle: LoTheme.font(size: 15, weight: FontWeight.w600, color: LoTheme.ink3),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Pressable(
            scale: 0.8,
            onTap: widget.onDelete,
            child: const SizedBox(width: 28, height: 28, child: Icon(AppIcons.x, size: 16, color: LoTheme.ink3)),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TagChip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: LoTheme.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? LoTheme.primarySoft : LoTheme.surface2,
          borderRadius: BorderRadius.circular(LoTheme.r(0.8)),
          border: Border.all(
            color: active ? LoTheme.primaryPress : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: LoTheme.font(
            size: 13.5,
            weight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? LoTheme.primaryPress : LoTheme.ink2,
          ),
        ),
      ),
    );
  }
}
