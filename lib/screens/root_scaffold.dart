import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/icons.dart';

import '../theme/app_theme.dart';
import '../widgets/primitives.dart';
import 'home_screen.dart';
import 'recipes_screen.dart';

/// Root shell: two tabs (Listes / Recettes) swipeable left↔right via PageView,
/// with a frosted bottom nav whose indicator + icon colors track the swipe.
class RootScaffold extends StatefulWidget {
  const RootScaffold({super.key});
  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  final _controller = PageController();
  double _page = 0; // continuous page offset (0..1) for indicator interpolation

  static const _tabs = [
    (icon: AppIcons.list, label: 'listes'),
    (icon: AppIcons.book, label: 'recettes'),
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _page = _controller.page ?? 0.0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int i) {
    _controller.animateToPage(i, duration: LoTheme.med, curve: LoTheme.ease);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoTheme.bg,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: PageView(
          controller: _controller,
          physics: const BouncingScrollPhysics(),
          children: const [HomeScreen(), RecipesScreen()],
        ),
      ),
      bottomNavigationBar: _BottomNav(page: _page, tabs: _tabs, onTap: _goTo),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final double page;
  final List<({IconData icon, String label})> tabs;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.page, required this.tabs, required this.onTap});

  Color _lerp(int index) {
    final dist = (page - index).abs().clamp(0.0, 1.0);
    return Color.lerp(LoTheme.primary, LoTheme.ink3, dist)!;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: LoTheme.surface.withOpacity(0.88),
            border: const Border(top: BorderSide(color: LoTheme.line)),
          ),
          padding: EdgeInsets.only(top: 10, bottom: bottomPad > 0 ? bottomPad : 14),
          child: Stack(children: [
            // sliding indicator
            LayoutBuilder(builder: (c, cons) {
              final tabW = cons.maxWidth / tabs.length;
              const indW = 28.0;
              final left = tabW * page + (tabW - indW) / 2;
              return Positioned(
                top: 0,
                left: left,
                child: Container(
                  width: indW,
                  height: 3,
                  decoration: BoxDecoration(color: LoTheme.primary, borderRadius: BorderRadius.circular(99)),
                ),
              );
            }),
            Row(
              children: [
                for (var i = 0; i < tabs.length; i++)
                  Expanded(
                    child: Pressable(
                      scale: 0.92,
                      onTap: () => onTap(i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(tabs[i].icon, size: 23, color: _lerp(i)),
                          const SizedBox(height: 4),
                          Text(tabs[i].label, style: LoTheme.font(size: 11, weight: FontWeight.w700, color: _lerp(i), letterSpacing: 0.2)),
                        ]),
                      ),
                    ),
                  ),
              ],
            ),
          ]),
        ),
      ),
    );
  }

}
