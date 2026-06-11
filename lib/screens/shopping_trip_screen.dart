import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/store.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/icons.dart';
import '../l10n/l10n.dart';
import '../widgets/animations.dart';
import '../widgets/primitives.dart';
import '../widgets/toast.dart';
import '../widgets/confetti.dart';

class ShoppingTripScreen extends StatefulWidget {
  final String listId;
  const ShoppingTripScreen({super.key, required this.listId});

  @override
  State<ShoppingTripScreen> createState() => _ShoppingTripScreenState();
}

class _ShoppingTripScreenState extends State<ShoppingTripScreen> {
  Timer? _ticker;
  int _secondsElapsed = 0;
  bool _screenActiveMock = true;
  final Set<String> _collapsedCats = {};
  bool _showConfetti = false;
  bool _tripCompleted = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !_tripCompleted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  String _formatTime(int totalSecs) {
    final mins = totalSecs ~/ 60;
    final secs = totalSecs % 60;
    final sM = mins.toString().padLeft(2, '0');
    final sS = secs.toString().padLeft(2, '0');
    return '$sM:$sS';
  }

  void _toggleCategory(String cat) {
    setState(() {
      if (_collapsedCats.contains(cat)) {
        _collapsedCats.remove(cat);
      } else {
        _collapsedCats.add(cat);
      }
    });
  }

  void _confirmExit(BuildContext context, Progress prog) {
    if (prog.complete) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: LoTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LoTheme.radius)),
        title: Text(
          context.t('trip.exit_confirm_title'),
          style: LoTheme.font(size: 18, weight: FontWeight.w700),
        ),
        content: Text(
          context.t('trip.exit_confirm_desc'),
          style: LoTheme.font(size: 14, weight: FontWeight.w500, color: LoTheme.ink2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.t('trip.btn.continue'),
              style: LoTheme.font(size: 14, weight: FontWeight.w700, color: LoTheme.primary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Exit trip screen
            },
            child: Text(
              context.t('trip.btn.exit'),
              style: LoTheme.font(size: 14, weight: FontWeight.w700, color: LoTheme.danger),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'Fruits & Légumes':
        return Icons.local_florist_rounded;
      case 'Produits Laitiers & Œufs':
        return Icons.egg_alt_rounded;
      case 'Boulangerie':
        return Icons.bakery_dining_rounded;
      case 'Boucherie & Poissonnerie':
        return Icons.kebab_dining_rounded;
      case 'Épicerie':
        return Icons.dinner_dining_rounded;
      case 'Boissons':
        return Icons.local_cafe_rounded;
      case 'Hygiène & Entretien':
        return Icons.clean_hands_rounded;
      default:
        return AppIcons.shoppingCart;
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final list = store.listById(widget.listId);
    final isFr = store.locale == 'fr';

    if (list == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
      return const Scaffold(backgroundColor: LoTheme.bg, body: SizedBox.shrink());
    }

    final prog = listProgress(list);
    final isComplete = prog.complete;

    if (isComplete && !_tripCompleted && prog.total > 0) {
      _tripCompleted = true;
      _showConfetti = true;
      _ticker?.cancel();
    }

    // Aisle grouped items using consolidateItems
    final consolidatedList = consolidateItems(list.blocks);
    final Map<String, List<ConsolidatedItem>> groups = {};
    for (final ci in consolidatedList) {
      groups.putIfAbsent(ci.category, () => []).add(ci);
    }

    final order = [
      'Fruits & Légumes',
      'Produits Laitiers & Œufs',
      'Boulangerie',
      'Boucherie & Poissonnerie',
      'Épicerie',
      'Boissons',
      'Hygiène & Entretien',
      'En vrac',
    ];

    final sortedCats = groups.keys.toList()
      ..sort((a, b) {
        final idxA = order.indexOf(a);
        final idxB = order.indexOf(b);
        if (idxA != -1 && idxB != -1) return idxA.compareTo(idxB);
        if (idxA != -1) return -1;
        if (idxB != -1) return 1;
        return a.compareTo(b);
      });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: LoTheme.bg,
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Premium Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.t('trip.title'),
                                style: LoTheme.font(size: 13, weight: FontWeight.w700, color: LoTheme.ink3, letterSpacing: 0.5),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                list.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: LoTheme.font(size: 20, weight: FontWeight.w800, color: LoTheme.ink),
                              ),
                            ],
                          ),
                        ),
                        // Wake Lock Toggle Button
                        Pressable(
                          scale: 0.88,
                          onTap: () {
                            setState(() => _screenActiveMock = !_screenActiveMock);
                            LoToast.show(
                              context,
                              _screenActiveMock ? context.t('trip.wake_lock_on') : context.t('trip.wake_lock_off'),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _screenActiveMock ? LoTheme.primarySoft : LoTheme.surface2,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _screenActiveMock ? LoTheme.primary.withValues(alpha: 0.3) : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _screenActiveMock ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                                  size: 14,
                                  color: _screenActiveMock ? LoTheme.primary : LoTheme.ink3,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  context.t('trip.wake_lock_label'),
                                  style: LoTheme.font(
                                    size: 11,
                                    weight: FontWeight.w700,
                                    color: _screenActiveMock ? LoTheme.primaryPress : LoTheme.ink2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Close Screen Button
                        Pressable(
                          scale: 0.88,
                          onTap: () => _confirmExit(context, prog),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: LoTheme.surface2,
                            ),
                            child: const Icon(AppIcons.x, size: 18, color: LoTheme.ink),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Timer & Progress Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: LoTheme.surface,
                        borderRadius: BorderRadius.circular(LoTheme.radius),
                        border: Border.all(color: LoTheme.line),
                        boxShadow: LoTheme.cardShadow,
                      ),
                      child: Row(
                        children: [
                          // Timer display
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.t('trip.timer').toUpperCase(),
                                style: LoTheme.font(size: 10, weight: FontWeight.w700, color: LoTheme.ink3, letterSpacing: 0.4),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(AppIcons.clock, size: 16, color: LoTheme.ink),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatTime(_secondsElapsed),
                                    style: LoTheme.font(size: 18, weight: FontWeight.w800, color: LoTheme.ink),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Container(width: 1, height: 32, color: LoTheme.line),
                          const SizedBox(width: 20),
                          // Progress display
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      context.t('trip.progress').toUpperCase(),
                                      style: LoTheme.font(size: 10, weight: FontWeight.w700, color: LoTheme.ink3, letterSpacing: 0.4),
                                    ),
                                    Text(
                                      '${prog.done} / ${prog.total}',
                                      style: LoTheme.font(size: 12, weight: FontWeight.w700, color: LoTheme.ink2),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                ProgressBar(
                                  value: prog.pct,
                                  color: LoTheme.primary,
                                  height: 6,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Shopping Trip List (Aisle accordions)
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      physics: const BouncingScrollPhysics(),
                      itemCount: sortedCats.length,
                      itemBuilder: (context, idx) {
                        final cat = sortedCats[idx];
                        final catItems = groups[cat]!;
                        final isCollapsed = _collapsedCats.contains(cat);
                        final displayName = context.categoryName(cat);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: LoTheme.surface,
                            borderRadius: BorderRadius.circular(LoTheme.radius),
                            border: Border.all(color: LoTheme.line),
                            boxShadow: LoTheme.cardShadow,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              // Accordion Header
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _toggleCategory(cat),
                                child: Container(
                                  color: LoTheme.surface2.withValues(alpha: 0.6),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  child: Row(
                                    children: [
                                      Icon(_getCategoryIcon(cat), size: 18, color: LoTheme.ink2),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          displayName.toUpperCase(),
                                          style: LoTheme.font(size: 13, weight: FontWeight.w700, color: LoTheme.ink, letterSpacing: 0.5),
                                        ),
                                      ),
                                      AnimatedRotation(
                                        turns: isCollapsed ? -0.25 : 0,
                                        duration: LoTheme.fast,
                                        child: const Icon(AppIcons.chevronDown, size: 18, color: LoTheme.ink3),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Accordion Items
                              AnimatedSize(
                                duration: LoTheme.med,
                                curve: LoTheme.ease,
                                alignment: Alignment.topCenter,
                                child: isCollapsed
                                    ? const SizedBox(width: double.infinity)
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                        child: Column(
                                          children: [
                                            for (final ci in catItems)
                                              _ShoppingRowItem(
                                                listId: list.id,
                                                ci: ci,
                                                store: store,
                                              ),
                                          ],
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Celebratory Completion Overlay
            if (_tripCompleted)
              Positioned.fill(
                child: Container(
                  color: LoTheme.bg.withValues(alpha: 0.98),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          // Celebratory Icon Badge
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: LoTheme.primarySoft,
                            ),
                            child: const Icon(
                              Icons.local_mall_rounded,
                              size: 40,
                              color: LoTheme.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            context.t('trip.completed_title'),
                            textAlign: TextAlign.center,
                            style: LoTheme.font(size: 26, weight: FontWeight.w800, color: LoTheme.ink),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.t('trip.completed_desc').replaceAll('{}', _formatTime(_secondsElapsed)),
                            textAlign: TextAlign.center,
                            style: LoTheme.font(size: 16, weight: FontWeight.w600, color: LoTheme.ink2),
                          ),
                          const SizedBox(height: 32),
                          // Stat Card
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: LoTheme.surface,
                              borderRadius: BorderRadius.circular(LoTheme.radius),
                              border: Border.all(color: LoTheme.line),
                              boxShadow: LoTheme.cardShadow,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      isFr ? 'DURÉE' : 'DURATION',
                                      style: LoTheme.font(size: 11, weight: FontWeight.w700, color: LoTheme.ink3, letterSpacing: 0.3),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTime(_secondsElapsed),
                                      style: LoTheme.font(size: 20, weight: FontWeight.w800, color: LoTheme.ink),
                                    ),
                                  ],
                                ),
                                Container(width: 1, height: 28, color: LoTheme.line),
                                Column(
                                  children: [
                                    Text(
                                      isFr ? 'ARTICLES' : 'ITEMS',
                                      style: LoTheme.font(size: 11, weight: FontWeight.w700, color: LoTheme.ink3, letterSpacing: 0.3),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${prog.total}',
                                      style: LoTheme.font(size: 20, weight: FontWeight.w800, color: LoTheme.ink),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          LoButton(
                            label: context.t('trip.completed_btn'),
                            variant: BtnVariant.primary,
                            full: true,
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Confetti Overlay Layer
            if (_showConfetti)
              Positioned.fill(
                child: IgnorePointer(
                  child: LoConfetti(
                    onFinished: () {
                      setState(() => _showConfetti = false);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Large Finger-friendly Shopping Row Item ───────────────────
class _ShoppingRowItem extends StatelessWidget {
  final String listId;
  final ConsolidatedItem ci;
  final AppStore store;

  const _ShoppingRowItem({
    required this.listId,
    required this.ci,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final isFr = store.locale == 'fr';
    final list = store.listById(listId);
    final useInventory = list?.useInventory ?? false;

    final deduction = store.computeDeduction(
      itemName: ci.name,
      neededQty: ci.totalQty,
      neededUnit: ci.unit,
      useInventory: useInventory,
    );
    final inStock = deduction.inStock;
    final displayQty = deduction.displayQty;
    final subtractionLabel = deduction.subtractionLabel;

    final dim = ci.checked || inStock;
    final itemIds = ci.items.map((it) => it.id).toList();

    return Dismissible(
      key: ValueKey('${ci.name}|${ci.unit}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        final blockIds = ci.blocks.map((b) => b.id).toList();
        store.deleteConsolidatedItem(listId, blockIds, itemIds);
        LoToast.show(context, isFr ? '${ci.name} supprimé' : '${ci.name} deleted');
      },
      background: Container(color: Colors.transparent),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: LoTheme.dangerSoft,
          borderRadius: BorderRadius.circular(LoTheme.radius),
        ),
        child: const Icon(AppIcons.trash2, color: LoTheme.danger, size: 20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => store.toggleConsolidatedItem(listId, itemIds, !ci.checked),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Row(
              children: [
                // Extra-large Checkbox Container (28x28 pixels)
                Pressable(
                  scale: 0.85,
                  onTap: () => store.toggleConsolidatedItem(listId, itemIds, !ci.checked),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: LoTheme.ease,
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: ci.checked ? LoTheme.primary : Colors.transparent,
                      shape: BoxShape.circle,
                      border: ci.checked ? null : Border.all(color: LoTheme.lineStrong, width: 2),
                    ),
                    child: AnimatedScale(
                      scale: ci.checked ? 1 : 0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutBack,
                      child: const Icon(AppIcons.check, size: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Item details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 180),
                              style: LoTheme.font(
                                size: 17,
                                weight: FontWeight.w600,
                                color: dim ? LoTheme.ink3 : LoTheme.ink,
                                decoration: ci.checked ? TextDecoration.lineThrough : TextDecoration.none,
                                decorationColor: LoTheme.primary,
                              ),
                              child: Text(ci.name),
                            ),
                          ),
                          if (inStock) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: LoTheme.primarySoft,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.inventory_2_rounded, size: 10, color: LoTheme.primaryPress),
                                  const SizedBox(width: 3),
                                  Text(
                                    isFr ? 'En stock' : 'In stock',
                                    style: LoTheme.font(size: 10, weight: FontWeight.w700, color: LoTheme.primaryPress),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (subtractionLabel.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtractionLabel,
                          style: LoTheme.font(
                            size: 12,
                            weight: FontWeight.w600,
                            color: LoTheme.ink3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Quantity chip
                QtyChip(
                  qty: inStock ? ci.totalQty : displayQty,
                  unit: ci.unit,
                  dim: dim,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
