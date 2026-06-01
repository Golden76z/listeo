import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Fades + slides a child up on first build, staggered by [index].
/// Used for list/recipe card entrances.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration base;
  const FadeSlideIn({super.key, required this.child, this.index = 0, this.base = const Duration(milliseconds: 380)});

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.base);

  @override
  void initState() {
    super.initState();
    final delay = Duration(milliseconds: (widget.index * 55).clamp(0, 600));
    Future.delayed(delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _c, curve: LoTheme.ease);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.10), end: Offset.zero).animate(curved),
        child: widget.child,
      ),
    );
  }
}

/// Animated horizontal progress bar that tweens to [value] (0..1).
class ProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;
  const ProgressBar({super.key, required this.value, required this.color, this.height = 7});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: Container(
        height: height,
        color: LoTheme.line,
        child: Align(
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.clamp(0, 1)),
            duration: const Duration(milliseconds: 450),
            curve: LoTheme.ease,
            builder: (c, v, _) => FractionallySizedBox(
              widthFactor: v == 0 ? 0.0001 : v,
              child: Container(
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(99)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
