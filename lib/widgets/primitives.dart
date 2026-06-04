import 'package:flutter/material.dart';
import '../theme/icons.dart';

import 'package:provider/provider.dart';
import '../data/store.dart';
import '../models/unit.dart';
import '../theme/app_theme.dart';

// ── Pressable: scale-on-tap wrapper used across the app ──────
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  const Pressable({super.key, required this.child, this.onTap, this.scale = 0.96});

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _down = true),
      onTapUp: widget.onTap == null ? null : (_) => setState(() => _down = false),
      onTapCancel: widget.onTap == null ? null : () => setState(() => _down = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: const Duration(milliseconds: 110),
        curve: LoTheme.ease,
        child: widget.child,
      ),
    );
  }
}

// ── Animated checkbox ───────────────────────────────────────
class LoCheckbox extends StatelessWidget {
  final bool checked;
  final VoidCallback onToggle;
  final String shape; // 'round-square' | 'circle'
  const LoCheckbox({super.key, required this.checked, required this.onToggle, this.shape = 'round-square'});

  @override
  Widget build(BuildContext context) {
    final radius = shape == 'circle' ? 12.0 : LoTheme.r(0.5);
    return Pressable(
      scale: 0.85,
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: LoTheme.ease,
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: checked ? LoTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          border: checked ? null : Border.all(color: LoTheme.lineStrong, width: 2),
        ),
        child: AnimatedScale(
          scale: checked ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          child: const Icon(AppIcons.check, size: 15, color: Colors.white),
        ),
      ),
    );
  }
}

// ── Quantity chip ───────────────────────────────────────────
class QtyChip extends StatelessWidget {
  final double qty;
  final String unit;
  final bool dim;
  const QtyChip({super.key, required this.qty, required this.unit, this.dim = false});

  @override
  Widget build(BuildContext context) {
    final f = fmtQty(qty, unit);
    return AnimatedContainer(
      duration: LoTheme.fast,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: dim ? Colors.transparent : LoTheme.surface2,
        borderRadius: BorderRadius.circular(LoTheme.r(0.6)),
      ),
      child: Text('${f.value}${f.suffix}',
          style: LoTheme.font(
            size: 13.5,
            weight: FontWeight.w600,
            color: dim ? LoTheme.ink3 : LoTheme.ink2,
            letterSpacing: 0.1,
          )),
    );
  }
}

// ── Stepper (− N +) ─────────────────────────────────────────
class LoStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChange;
  final int min;
  final int max;
  final String? suffix;
  const LoStepper({super.key, required this.value, required this.onChange, this.min = 1, this.max = 99, this.suffix});

  Widget _btn(IconData icon, int dir, bool disabled) {
    return Pressable(
      scale: 0.88,
      onTap: disabled ? null : () => onChange(value + dir),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: disabled ? LoTheme.surface2 : LoTheme.primarySoft,
        ),
        child: Icon(icon, size: 18, color: disabled ? LoTheme.ink3 : LoTheme.primary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _btn(AppIcons.minus, -1, value <= min),
        const SizedBox(width: 12),
        SizedBox(
          width: 56,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (c, a) => ScaleTransition(
                scale: Tween(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: a, curve: LoTheme.ease)),
                child: FadeTransition(opacity: a, child: c)),
            child: Text.rich(
              key: ValueKey(value),
              TextSpan(children: [
                TextSpan(text: '$value', style: LoTheme.font(size: 17, weight: FontWeight.w700)),
                if (suffix != null)
                  TextSpan(text: suffix, style: LoTheme.font(size: 12, weight: FontWeight.w600, color: LoTheme.ink2)),
              ]),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(width: 12),
        _btn(AppIcons.plus, 1, value >= max),
      ],
    );
  }
}

// ── Buttons ─────────────────────────────────────────────────
enum BtnVariant { primary, soft, ghost, danger }

class LoButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final BtnVariant variant;
  final IconData? icon;
  final bool full;
  final bool small;
  final bool disabled;
  const LoButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = BtnVariant.primary,
    this.icon,
    this.full = false,
    this.small = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    late Color bg, fg;
    Border? border;
    switch (variant) {
      case BtnVariant.primary:
        bg = LoTheme.primary;
        fg = Colors.white;
        break;
      case BtnVariant.soft:
        bg = LoTheme.primarySoft;
        fg = LoTheme.primaryPress;
        break;
      case BtnVariant.ghost:
        bg = LoTheme.surface;
        fg = LoTheme.ink2;
        border = Border.all(color: LoTheme.lineStrong, width: 1.5);
        break;
      case BtnVariant.danger:
        bg = LoTheme.dangerSoft;
        fg = LoTheme.danger;
        break;
    }
    final h = small ? 40.0 : 52.0;
    final fs = small ? 14.0 : 16.0;
    final child = Container(
      height: h,
      width: full ? double.infinity : null,
      padding: EdgeInsets.symmetric(horizontal: small ? 14 : 20),
      decoration: BoxDecoration(
        color: bg,
        border: border,
        borderRadius: BorderRadius.circular(LoTheme.r(0.95)),
      ),
      child: Row(
        mainAxisSize: full ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon, size: fs + 3, color: fg), const SizedBox(width: 8)],
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: LoTheme.font(size: fs, weight: FontWeight.w700, color: fg, letterSpacing: 0.1))),
        ],
      ),
    );
    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: Pressable(scale: 0.97, onTap: disabled ? null : onTap, child: child),
    );
  }
}

// ── Text field ──────────────────────────────────────────────
class LoTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? placeholder;
  final bool autoFocus;
  final VoidCallback? onSubmit;
  final TextAlign align;
  final TextInputType? keyboardType;
  final double? width;
  const LoTextField({
    super.key,
    required this.controller,
    this.placeholder,
    this.autoFocus = false,
    this.onSubmit,
    this.align = TextAlign.left,
    this.keyboardType,
    this.width,
  });

  @override
  State<LoTextField> createState() => _LoTextFieldState();
}

class _LoTextFieldState extends State<LoTextField> {
  final _focus = FocusNode();
  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: LoTheme.fast,
      width: widget.width,
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: LoTheme.surface2,
        borderRadius: BorderRadius.circular(LoTheme.r(0.9)),
        border: Border.all(color: _focus.hasFocus ? LoTheme.primary : Colors.transparent, width: 2),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        autofocus: widget.autoFocus,
        textAlign: widget.align,
        keyboardType: widget.keyboardType,
        onSubmitted: (_) => widget.onSubmit?.call(),
        textInputAction: widget.onSubmit != null ? TextInputAction.done : TextInputAction.none,
        cursorColor: LoTheme.primary,
        style: LoTheme.font(size: 16, weight: FontWeight.w600),
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          hintText: widget.placeholder,
          hintStyle: LoTheme.font(size: 16, weight: FontWeight.w600, color: LoTheme.ink3),
        ),
      ),
    );
  }
}

// ── Bare inline input (small qty / inline edit fields) ──────
class InlineInput extends StatelessWidget {
  final TextEditingController controller;
  final String? placeholder;
  final double width;
  final TextAlign align;
  final Color background;
  final TextInputType? keyboardType;
  final VoidCallback? onSubmit;
  final FocusNode? focusNode;
  final bool autofocus;
  const InlineInput({
    super.key,
    required this.controller,
    this.placeholder,
    this.width = double.infinity,
    this.align = TextAlign.left,
    this.background = LoTheme.surface2,
    this.keyboardType,
    this.onSubmit,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width == double.infinity ? null : width,
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(LoTheme.r(0.9))),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        textAlign: align,
        keyboardType: keyboardType,
        onSubmitted: (_) => onSubmit?.call(),
        textInputAction: onSubmit != null ? TextInputAction.done : TextInputAction.none,
        cursorColor: LoTheme.primary,
        style: LoTheme.font(size: 16, weight: FontWeight.w700),
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          hintText: placeholder,
          hintStyle: LoTheme.font(size: 16, weight: FontWeight.w600, color: LoTheme.ink3),
        ),
      ),
    );
  }
}

// ── Horizontal unit selector ────────────────────────────────
class UnitChips extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChange;
  const UnitChips({super.key, required this.value, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: kUnits.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (c, i) {
          final u = kUnits[i];
          final active = u.id == value;
          return Pressable(
            onTap: () => onChange(u.id),
            child: AnimatedContainer(
              duration: LoTheme.fast,
              curve: LoTheme.ease,
              padding: const EdgeInsets.symmetric(horizontal: 13),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? LoTheme.primary : LoTheme.surface2,
                borderRadius: BorderRadius.circular(LoTheme.r(0.8)),
              ),
              child: Text(u.label,
                  style: LoTheme.font(size: 13, weight: FontWeight.w700, color: active ? Colors.white : LoTheme.ink2)),
            ),
          );
        },
      ),
    );
  }
}

// ── small labelled section header used in sheets ───────────
Widget sheetLabel(String text, {Widget? trailing}) {
  return Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 10),
    child: Row(children: [
      Text(text.toUpperCase(),
          style: LoTheme.font(size: 12.5, weight: FontWeight.w700, color: LoTheme.ink3, letterSpacing: 0.5)),
      if (trailing != null) trailing,
    ]),
  );
}

/// A premium capsule language switcher (FR / EN).
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final isFr = store.locale == 'fr';
    return Pressable(
      scale: 0.9,
      onTap: store.toggleLocale,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: LoTheme.surface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: LoTheme.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('FR', style: LoTheme.font(size: 11.5, weight: isFr ? FontWeight.w800 : FontWeight.w600, color: isFr ? LoTheme.primary : LoTheme.ink3)),
            const SizedBox(width: 4),
            Text('·', style: LoTheme.font(size: 11.5, color: LoTheme.ink3)),
            const SizedBox(width: 4),
            Text('EN', style: LoTheme.font(size: 11.5, weight: !isFr ? FontWeight.w800 : FontWeight.w600, color: !isFr ? LoTheme.primary : LoTheme.ink3)),
          ],
        ),
      ),
    );
  }
}
