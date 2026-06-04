import 'package:flutter/material.dart';
import '../theme/icons.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n.dart';
import '../widgets/animations.dart';
import '../widgets/nav.dart';
import '../widgets/primitives.dart';
import '../widgets/sheets.dart';

/// "mes listes" — the lists tab.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final lists = store.lists;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // brand + header
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.t('title.lists'), style: LoTheme.font(size: 32, weight: FontWeight.w700, letterSpacing: -0.6)),
              const LanguageToggle(),
            ],
          ),
          const SizedBox(height: 4),
          Text("${lists.length} ${context.t('subtitle.lists')}",
              style: LoTheme.font(size: 14, weight: FontWeight.w500, color: LoTheme.ink3)),
        ]),
      ),
      Expanded(
        child: ListView.separated(
          // bottom room so the last card clears the floating "nouvelle liste" button
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
          physics: const BouncingScrollPhysics(),
          itemCount: lists.length,
          separatorBuilder: (_, __) => const SizedBox(height: 13),
          itemBuilder: (c, i) => FadeSlideIn(index: i, child: _ListCard(list: lists[i])),
        ),
      ),
    ]);
  }
}

class _ListCard extends StatelessWidget {
  final ShoppingList list;
  const _ListCard({required this.list});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final prog = listProgress(list);
    final tn = Tone.of(list.tone);
    final done = prog.complete;
    final isFr = store.locale == 'fr';

    return Pressable(
      scale: 0.98,
      onTap: () => pushList(context, list.id),
      child: Container(
        decoration: BoxDecoration(
          color: tn.soft,
          borderRadius: BorderRadius.circular(LoTheme.radius),
          border: Border.all(color: tn.dot.withValues(alpha: 0.18)),
          boxShadow: LoTheme.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(children: [
          Container(width: 5, color: tn.dot),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(list.name, style: LoTheme.font(size: 18, weight: FontWeight.w700, letterSpacing: -0.2)),
                      const SizedBox(height: 3),
                      Row(children: [
                        const Icon(AppIcons.clock, size: 13, color: LoTheme.ink3),
                        const SizedBox(width: 6),
                        Text(relTime(list.createdAt), style: LoTheme.font(size: 13, weight: FontWeight.w500, color: LoTheme.ink3)),
                        Text('  ·  ${prog.total} ${context.t('btn.add_item')}${prog.total > 1 ? 's' : ''}', style: LoTheme.font(size: 13, weight: FontWeight.w500, color: LoTheme.ink3)),
                      ]),
                    ]),
                  ),
                  Pressable(
                    scale: 0.85,
                    onTap: () => openListMenu(context, list),
                    child: const SizedBox(width: 32, height: 32, child: Icon(AppIcons.moreVertical, size: 18, color: LoTheme.ink3)),
                  ),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: ProgressBar(value: prog.pct, color: done ? LoTheme.primary : tn.dot, height: 6)),
                  const SizedBox(width: 10),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    if (done) ...[
                      const Icon(AppIcons.check, size: 13, color: LoTheme.primaryPress),
                      const SizedBox(width: 4),
                    ],
                    Text(done ? (isFr ? 'terminé' : 'completed') : '${prog.done}/${prog.total}',
                        style: LoTheme.font(size: 12.5, weight: FontWeight.w700, color: done ? LoTheme.primaryPress : LoTheme.ink3)),
                  ]),
                ]),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
