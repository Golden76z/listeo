import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/icons.dart';

import '../theme/app_theme.dart';
import '../l10n/l10n.dart';
import '../widgets/primitives.dart';
import '../widgets/sheets.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'recipes_screen.dart';
import 'planner_screen.dart';

/// Root shell: three tabs (Listes / Découvrir / Recettes) swipeable left↔right via PageView,
/// with a frosted bottom nav whose indicator + icon colors track the swipe.
class RootScaffold extends StatefulWidget {
  const RootScaffold({super.key});
  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  final _controller = PageController();
  double _page = 0; // continuous page offset (0..2) for indicator interpolation

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
    final tabs = [
      (icon: AppIcons.list, label: context.t('tab.lists')),
      (icon: AppIcons.utensils, label: context.t('tab.discover')),
      (icon: AppIcons.book, label: context.t('tab.recipes')),
      (icon: AppIcons.calendar, label: context.t('tab.planner')),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFFFFFFF),
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: LoTheme.bg,
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: PageView(
            controller: _controller,
            physics: const BouncingScrollPhysics(),
            children: const [HomeScreen(), ExploreScreen(), RecipesScreen(), PlannerScreen()],
          ),
        ),
        // Lives in the Scaffold slot so it's always positioned above the bottom
        // nav bar; shows on lists/recipes tabs and hides on the discover tab.
        floatingActionButton: _buildFab(),
        bottomNavigationBar: _BottomNav(page: _page, tabs: tabs, onTap: _goTo),
      ),
    );
  }

  Widget? _buildFab() {
    if (_page > 0.5 && _page < 1.5) {
      return null; // hide on discover tab
    }
    if (_page >= 2.5) {
      return null; // hide on planner tab
    }
    final isRecipes = _page >= 1.5 && _page < 2.5;
    final label = isRecipes ? context.t('fab.new_recipe') : context.t('fab.new_list');
    final onTap = isRecipes ? () => openRecipeEditor(context) : () => openCreateList(context);

    return Pressable(
      scale: 0.94,
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.only(left: 18, right: 22),
        decoration: BoxDecoration(
          color: LoTheme.primary,
          borderRadius: BorderRadius.circular(LoTheme.radius),
          boxShadow: [BoxShadow(color: LoTheme.primaryShadow, blurRadius: 22, offset: const Offset(0, 8))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(AppIcons.plus, size: 22, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: LoTheme.font(size: 16, weight: FontWeight.w700, color: Colors.white),
            ),
          ],
        ),
      ),
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
            color: LoTheme.surface.withValues(alpha: 0.88),
            border: const Border(top: BorderSide(color: LoTheme.line)),
          ),
          padding: EdgeInsets.only(top: 10, bottom: bottomPad > 0 ? bottomPad : 14),
          child: Stack(children: [
            // sliding indicator
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LayoutBuilder(builder: (c, cons) {
                final tabW = cons.maxWidth / tabs.length;
                const indW = 28.0;
                final left = (tabW * page + (tabW - indW) / 2).clamp(0.0, double.infinity);
                return Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: EdgeInsets.only(left: left),
                    width: indW,
                    height: 3,
                    decoration: BoxDecoration(color: LoTheme.primary, borderRadius: BorderRadius.circular(99)),
                  ),
                );
              }),
            ),
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
