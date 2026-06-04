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

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final constDays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();

    // Check if the planner has any scheduled items
    bool hasAnyMeals = false;
    for (final day in constDays) {
      if (store.mealPlan[day]?.isNotEmpty ?? false) {
        hasAnyMeals = true;
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.t('title.planner'),
                    style: LoTheme.font(size: 30, weight: FontWeight.w700, letterSpacing: -0.6),
                  ),
                  const LanguageToggle(),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                context.t('subtitle.planner'),
                style: LoTheme.font(size: 14, weight: FontWeight.w500, color: LoTheme.ink3),
              ),
            ],
          ),
        ),

        // Weekly Grid
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(16, 12, 16, hasAnyMeals ? 100 : 30),
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

        // Floating/Sticky Footer Actions
        if (hasAnyMeals)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 26),
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
                    onTap: () => _confirmClear(context, store),
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

  void _confirmClear(BuildContext context, AppStore store) {
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
}

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
          // Day Header
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

          // Planned Meals
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
                    // Tone color circle icon
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

                    // Recipe details
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

                    // Servings stepper
                    LoStepper(
                      value: meal.servings,
                      suffix: store.locale == 'fr' ? ' pers.' : ' serv.',
                      onChange: (newVal) {
                        store.updateMealServings(day, i, newVal);
                      },
                    ),

                    const SizedBox(width: 6),

                    // Delete button
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
