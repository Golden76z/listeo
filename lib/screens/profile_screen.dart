import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/store.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/icons.dart';
import '../l10n/l10n.dart';
import '../widgets/animations.dart';
import '../widgets/primitives.dart';
import '../widgets/sheets.dart';
import '../widgets/toast.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();
  final _addCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    _addCtrl.dispose();
    super.dispose();
  }

  void _addInventoryItem(AppStore store) {
    final text = _addCtrl.text.trim();
    if (text.isNotEmpty) {
      store.addInventoryItem(text);
      _addCtrl.clear();
      LoToast.show(context, store.locale == 'fr' ? '$text ajouté !' : '$text added!');
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final isFr = store.locale == 'fr';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 650;

        if (isWide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, store),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Meal Planner
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: Text(
                              isFr ? 'Planning repas' : 'Meal Planner',
                              style: LoTheme.font(size: 18, weight: FontWeight.w700),
                            ),
                          ),
                          Expanded(child: _buildPlannerView(context, store)),
                        ],
                      ),
                    ),
                    // Vertical Divider
                    Container(width: 1, color: LoTheme.line),
                    // Right: Pantry Inventory
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: Text(
                              isFr ? 'Inventaire du placard' : 'Pantry Inventory',
                              style: LoTheme.font(size: 18, weight: FontWeight.w700),
                            ),
                          ),
                          Expanded(child: _buildInventoryView(context, store)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        } else {
          // Mobile responsive: Tabbed selector
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, store),
              // Segmented Sliding Tab Selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: LoTheme.surface2,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    dividerColor: Colors.transparent,
                    dividerHeight: 0.0,
                    indicator: BoxDecoration(
                      color: LoTheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: LoTheme.line),
                      boxShadow: LoTheme.cardShadow,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: LoTheme.primaryPress,
                    unselectedLabelColor: LoTheme.ink3,
                    labelStyle: LoTheme.font(size: 14, weight: FontWeight.w700),
                    unselectedLabelStyle: LoTheme.font(size: 14, weight: FontWeight.w600),
                    tabs: [
                      Tab(text: isFr ? 'Planning' : 'Planner'),
                      Tab(text: isFr ? 'Inventaire' : 'Inventory'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPlannerView(context, store),
                    _buildInventoryView(context, store),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildHeader(BuildContext context, AppStore store) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.t('title.profile'),
                style: LoTheme.font(size: 30, weight: FontWeight.w700, letterSpacing: -0.6),
              ),
              const LanguageToggle(),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            context.t('subtitle.profile'),
            style: LoTheme.font(size: 14, weight: FontWeight.w500, color: LoTheme.ink3),
          ),
        ],
      ),
    );
  }

  // ── Meal Planner View ───────────────────────────────────────
  Widget _buildPlannerView(BuildContext context, AppStore store) {
    final constDays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

    bool hasAnyMeals = false;
    for (final day in constDays) {
      if (store.mealPlan[day]?.isNotEmpty ?? false) {
        hasAnyMeals = true;
        break;
      }
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(16, 12, 16, hasAnyMeals ? 16 : 60 + MediaQuery.of(context).padding.bottom),
            physics: const BouncingScrollPhysics(),
            itemCount: constDays.length,
            itemBuilder: (c, i) {
              final day = constDays[i];
              final meals = store.mealPlan[day] ?? [];

              return FadeSlideIn(
                index: i,
                child: _DayCard(
                  day: day,
                  meals: meals,
                  store: store,
                ),
              );
            },
          ),
        ),
        if (hasAnyMeals)
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              12 + 32 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: LoTheme.bg.withValues(alpha: 0.95),
              border: const Border(top: BorderSide(color: LoTheme.line)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: LoButton(
                    label: context.t('planner.btn.clear'),
                    variant: BtnVariant.danger,
                    full: true,
                    onTap: () => _confirmClearPlanner(context, store),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: LoButton(
                    label: context.t('planner.btn.generate'),
                    variant: BtnVariant.primary,
                    icon: AppIcons.plus,
                    full: true,
                    onTap: () => openGenerateListFromPlanner(context),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _confirmClearPlanner(BuildContext context, AppStore store) {
    showLoSheet(
      context,
      title: context.t('planner.dialog.clear_title'),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t('planner.dialog.clear_desc'),
            style: LoTheme.font(size: 15, weight: FontWeight.w500, color: LoTheme.ink2),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: LoButton(
                  label: context.t('btn.cancel'),
                  variant: BtnVariant.soft,
                  full: true,
                  onTap: () => Navigator.pop(ctx),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LoButton(
                  label: context.t('btn.confirm_delete'),
                  variant: BtnVariant.danger,
                  full: true,
                  onTap: () {
                    store.clearMealPlan();
                    Navigator.pop(ctx);
                    LoToast.show(context, context.t('planner.toast.cleared'));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Pantry Inventory View ───────────────────────────────────
  Widget _buildInventoryView(BuildContext context, AppStore store) {
    final isFr = store.locale == 'fr';
    final filtered = store.inventory.where((it) {
      if (_searchQuery.isEmpty) return true;
      return it.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        // Add new item & search box
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // Search input
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: LoTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: LoTheme.line),
                  boxShadow: LoTheme.cardShadow,
                ),
                child: Row(
                  children: [
                    const Icon(AppIcons.search, size: 18, color: LoTheme.ink3),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        style: LoTheme.font(size: 14, weight: FontWeight.w600),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: isFr ? 'Rechercher un produit...' : 'Search product...',
                          hintStyle: LoTheme.font(size: 14, color: LoTheme.ink3, weight: FontWeight.w500),
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () => _searchCtrl.clear(),
                        child: const Icon(AppIcons.x, size: 18, color: LoTheme.ink3),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Add input
              Container(
                height: 42,
                padding: const EdgeInsets.only(left: 12, right: 4),
                decoration: BoxDecoration(
                  color: LoTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: LoTheme.line),
                  boxShadow: LoTheme.cardShadow,
                ),
                child: Row(
                  children: [
                    const Icon(AppIcons.plus, size: 18, color: LoTheme.primaryPress),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _addCtrl,
                        style: LoTheme.font(size: 14, weight: FontWeight.w600),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: isFr ? 'Ajouter à l\'inventaire...' : 'Add to inventory...',
                          hintStyle: LoTheme.font(size: 14, color: LoTheme.ink3, weight: FontWeight.w500),
                        ),
                        onSubmitted: (_) => _addInventoryItem(store),
                      ),
                    ),
                    LoButton(
                      label: isFr ? 'Ajouter' : 'Add',
                      variant: BtnVariant.primary,
                      small: true,
                      onTap: () => _addInventoryItem(store),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Inventory Items list
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 40, color: LoTheme.lineStrong),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isNotEmpty
                            ? (isFr ? 'Aucun produit trouvé' : 'No products found')
                            : context.t('inventory.empty'),
                        style: LoTheme.font(size: 16, weight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _searchQuery.isNotEmpty
                            ? (isFr ? 'Essaie un autre nom' : 'Try another name')
                            : context.t('inventory.empty_desc'),
                        style: LoTheme.font(size: 13, color: LoTheme.ink3, weight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    60 + MediaQuery.of(context).padding.bottom,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final item = filtered[i];
                    return FadeSlideIn(
                      index: i,
                      child: _InventoryItemRow(item: item, store: store),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ── Weekly Planner Card (Existing UI kept untouched) ─────────
class _DayCard extends StatelessWidget {
  final String day;
  final List<MealPlanItem> meals;
  final AppStore store;

  const _DayCard({
    required this.day,
    required this.meals,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final dayLabel = context.t('day.$day');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LoTheme.surface,
        borderRadius: BorderRadius.circular(LoTheme.radius),
        border: Border.all(color: LoTheme.line),
        boxShadow: LoTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dayLabel,
                style: LoTheme.font(size: 16.5, weight: FontWeight.w700, color: LoTheme.ink),
              ),
              Pressable(
                scale: 0.88,
                onTap: () => openSelectRecipeForDay(context, day),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: LoTheme.primarySoft,
                  ),
                  child: const Icon(
                    AppIcons.plus,
                    size: 18,
                    color: LoTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          if (meals.isEmpty) ...[
            const SizedBox(height: 10),
            Center(
              child: Text(
                context.t('planner.empty'),
                style: LoTheme.font(size: 13.5, weight: FontWeight.w600, color: LoTheme.ink3),
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: meals.length,
              separatorBuilder: (c, i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(height: 1, color: LoTheme.line),
              ),
              itemBuilder: (c, i) {
                final meal = meals[i];
                final r = store.recipeById(meal.recipeId);
                if (r == null) return const SizedBox.shrink();

                final tn = Tone.of(r.tone);
                return Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: tn.soft,
                        borderRadius: BorderRadius.circular(36 * 0.3),
                      ),
                      child: Icon(AppIcons.utensils, size: 18, color: tn.dot),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: LoTheme.font(size: 15, weight: FontWeight.w700, color: LoTheme.ink),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            store.locale == 'fr'
                                ? '${r.items.length} ingrédients'
                                : '${r.items.length} ingredients',
                            style: LoTheme.font(size: 12, weight: FontWeight.w600, color: LoTheme.ink3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    LoStepper(
                      value: meal.servings,
                      suffix: store.locale == 'fr' ? ' pers.' : ' serv.',
                      onChange: (newVal) {
                        store.updateMealServings(day, i, newVal);
                      },
                    ),
                    const SizedBox(width: 6),
                    Pressable(
                      scale: 0.88,
                      onTap: () {
                        store.removeMeal(day, i);
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: LoTheme.dangerSoft,
                        ),
                        child: const Icon(
                          AppIcons.trash2,
                          size: 17,
                          color: LoTheme.danger,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

// ── Inventory Item Row widget ────────────────────────────────
class _InventoryItemRow extends StatelessWidget {
  final InventoryItem item;
  final AppStore store;

  const _InventoryItemRow({required this.item, required this.store});

  @override
  Widget build(BuildContext context) {
    final isFr = store.locale == 'fr';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: LoTheme.surface,
        borderRadius: BorderRadius.circular(LoTheme.radius),
        border: Border.all(color: LoTheme.line),
        boxShadow: LoTheme.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Pressable(
        scale: 0.98,
        onTap: () => store.toggleInventoryItemStock(item.id),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Checkbox/In stock toggle circle
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.inStock ? LoTheme.primarySoft : Colors.transparent,
                  border: Border.all(
                    color: item.inStock ? LoTheme.primaryPress : LoTheme.lineStrong,
                    width: 2,
                  ),
                ),
                child: item.inStock
                    ? const Icon(AppIcons.check, size: 14, color: LoTheme.primaryPress)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.name,
                            style: LoTheme.font(
                              size: 15.5,
                              weight: FontWeight.w700,
                              color: item.inStock ? LoTheme.ink : LoTheme.ink3,
                            ),
                          ),
                        ),
                        if (item.qty > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '(${_formatNum(item.qty)} ${item.unit})',
                            style: LoTheme.font(
                              size: 13,
                              weight: FontWeight.w600,
                              color: LoTheme.ink3,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.inStock
                          ? (isFr ? 'En stock' : 'In stock')
                          : (isFr ? 'Rupture de stock / À acheter' : 'Out of stock / To buy'),
                      style: LoTheme.font(
                        size: 12,
                        weight: FontWeight.w600,
                        color: item.inStock ? LoTheme.primaryPress : LoTheme.danger,
                      ),
                    ),
                  ],
                ),
              ),
              // Rename button
              Pressable(
                scale: 0.88,
                onTap: () {
                  openEditInventoryItem(context, item);
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: LoTheme.surface2,
                  ),
                  child: const Icon(
                    AppIcons.pencil,
                    size: 16,
                    color: LoTheme.ink2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Delete button
              Pressable(
                scale: 0.88,
                onTap: () {
                  store.deleteInventoryItem(item.id);
                  LoToast.show(context, isFr ? '${item.name} supprimé' : '${item.name} deleted');
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: LoTheme.dangerSoft,
                  ),
                  child: const Icon(
                    AppIcons.trash2,
                    size: 16,
                    color: LoTheme.danger,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNum(double n) {
    if (n == n.toInt()) return n.toInt().toString();
    return n.toStringAsFixed(1);
  }
}
