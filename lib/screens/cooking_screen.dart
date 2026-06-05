import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../theme/icons.dart';
import '../widgets/primitives.dart';
import '../widgets/animations.dart';
import '../widgets/toast.dart';
import '../widgets/confetti.dart';

class CookingScreen extends StatefulWidget {
  final String recipeName;
  final String tone;
  final List<String> instructions;

  const CookingScreen({
    super.key,
    required this.recipeName,
    required this.tone,
    required this.instructions,
  });

  @override
  State<CookingScreen> createState() => _CookingScreenState();
}

class _CookingScreenState extends State<CookingScreen> {
  final _pageController = PageController();
  int _currentIndex = 0;
  bool _showConfetti = false;
  bool _screenActiveMock = true; // Simulated screen wake lock active by default

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentIndex < widget.instructions.length - 1) {
      _pageController.nextPage(duration: LoTheme.med, curve: LoTheme.ease);
    } else {
      // Finished!
      setState(() {
        _showConfetti = true;
      });
    }
  }

  void _prev() {
    if (_currentIndex > 0) {
      _pageController.previousPage(duration: LoTheme.med, curve: LoTheme.ease);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tn = Tone.of(widget.tone);
    final totalSteps = widget.instructions.length;
    final progress = totalSteps == 0 ? 0.0 : (_currentIndex + 1) / totalSteps;
    final isLastStep = _currentIndex == totalSteps - 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: LoTheme.surface,
        systemNavigationBarDividerColor: Colors.transparent,
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
                  // Header Block
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.recipeName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: LoTheme.font(size: 14, weight: FontWeight.w700, color: LoTheme.ink3),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                totalSteps == 0
                                    ? 'Aucune étape'
                                    : 'Étape ${_currentIndex + 1} sur $totalSteps',
                                style: LoTheme.font(size: 20, weight: FontWeight.w800, color: LoTheme.ink),
                              ),
                            ],
                          ),
                        ),
                        // Simulated Wake lock toggle button
                        Pressable(
                          scale: 0.88,
                          onTap: () {
                            setState(() => _screenActiveMock = !_screenActiveMock);
                            LoToast.show(
                              context,
                              _screenActiveMock
                                  ? 'Écran actif : la mise en veille est empêchée'
                                  : 'Écran normal : veille automatique autorisée',
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
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
                                  size: 15,
                                  color: _screenActiveMock ? LoTheme.primary : LoTheme.ink3,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Écran actif',
                                  style: LoTheme.font(
                                    size: 11.5,
                                    weight: FontWeight.w700,
                                    color: _screenActiveMock ? LoTheme.primaryPress : LoTheme.ink2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Close / Exit button
                        Pressable(
                          scale: 0.88,
                          onTap: () => Navigator.pop(context),
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

                  // Progress Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ProgressBar(
                      value: progress,
                      color: tn.dot,
                      height: 6,
                    ),
                  ),

                  // Carousel
                  Expanded(
                    child: totalSteps == 0
                        ? Center(
                            child: Text(
                              'Aucune instruction disponible.',
                              style: LoTheme.font(size: 16, weight: FontWeight.w600, color: LoTheme.ink3),
                            ),
                          )
                        : PageView.builder(
                            controller: _pageController,
                            onPageChanged: (idx) => setState(() => _currentIndex = idx),
                            itemCount: totalSteps,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, idx) {
                              final text = widget.instructions[idx];
                              return _StepCard(
                                stepIndex: idx,
                                text: text,
                                tone: widget.tone,
                              );
                            },
                          ),
                  ),

                  // Bottom Controls
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 26),
                    decoration: const BoxDecoration(
                      color: LoTheme.surface,
                      border: Border(top: BorderSide(color: LoTheme.line)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: LoButton(
                            label: 'précédent',
                            variant: BtnVariant.soft,
                            disabled: _currentIndex == 0,
                            full: true,
                            onTap: _prev,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: LoButton(
                            label: isLastStep ? 'terminer' : 'suivant',
                            variant: BtnVariant.primary,
                            icon: isLastStep ? AppIcons.check : AppIcons.chevronRight,
                            full: true,
                            onTap: _next,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Confetti Layer
            if (_showConfetti)
              Positioned.fill(
                child: IgnorePointer(
                  child: LoConfetti(
                    onFinished: () {
                      setState(() => _showConfetti = false);
                      Navigator.pop(context);
                      LoToast.show(context, 'Bon appétit ! 🍽️');
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

class _StepCard extends StatelessWidget {
  final int stepIndex;
  final String text;
  final String tone;

  const _StepCard({
    required this.stepIndex,
    required this.text,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final tn = Tone.of(tone);
    final parsedTimer = detectTimer(text);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: LoTheme.surface,
        borderRadius: BorderRadius.circular(LoTheme.r(1.5)),
        border: Border.all(color: LoTheme.line),
        boxShadow: LoTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tn.soft,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${stepIndex + 1}',
                  style: LoTheme.font(size: 15, weight: FontWeight.w800, color: tn.dot),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Text(
                text,
                style: LoTheme.font(
                  size: 23,
                  weight: FontWeight.w700,
                  height: 1.45,
                  color: LoTheme.ink,
                ),
              ),
            ),
          ),
          if (parsedTimer != null) ...[
            const SizedBox(height: 16),
            _StepTimerView(timer: parsedTimer, tone: tone),
          ],
        ],
      ),
    );
  }
}

// ── Step Timer parsing helpers ─────────────────────────────────

class ParsedTimer {
  final int seconds;
  final String label;
  ParsedTimer({required this.seconds, required this.label});
}

ParsedTimer? detectTimer(String text) {
  final regex = RegExp(
    r'(\d+(?:[.,]\d+)?)\s*(minutes?|min|heures?|hours?|h|hr|hrs)\b',
    caseSensitive: false,
  );
  final match = regex.firstMatch(text);
  if (match != null) {
    final valStr = match.group(1)!;
    final unitStr = match.group(2)!.toLowerCase();
    
    final val = double.tryParse(valStr.replaceAll(',', '.')) ?? 0.0;
    if (val <= 0) return null;
    
    int secs = 0;
    if (unitStr.startsWith('h')) {
      secs = (val * 3600).round();
    } else {
      secs = (val * 60).round();
    }
    
    return ParsedTimer(seconds: secs, label: match.group(0)!);
  }
  return null;
}

// ── Circular countdown step timer card ─────────────────────────

class _StepTimerView extends StatefulWidget {
  final ParsedTimer timer;
  final String tone;

  const _StepTimerView({
    required this.timer,
    required this.tone,
  });

  @override
  State<_StepTimerView> createState() => _StepTimerViewState();
}

class _StepTimerViewState extends State<_StepTimerView> {
  Timer? _ticker;
  late int _remaining;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.timer.seconds;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _toggle() {
    if (_running) {
      _ticker?.cancel();
      setState(() => _running = false);
    } else {
      setState(() => _running = true);
      _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_remaining > 1) {
          setState(() => _remaining--);
        } else {
          _ticker?.cancel();
          setState(() {
            _remaining = 0;
            _running = false;
          });
          HapticFeedback.vibrate();
          LoToast.show(context, 'Minuteur terminé ! 🔔');
        }
      });
    }
  }

  void _reset() {
    _ticker?.cancel();
    setState(() {
      _remaining = widget.timer.seconds;
      _running = false;
    });
  }

  String _format(int totalSecs) {
    if (totalSecs < 0) return '00:00';
    final hrs = totalSecs ~/ 3600;
    final mins = (totalSecs % 3600) ~/ 60;
    final secs = totalSecs % 60;
    
    final sM = mins.toString().padLeft(2, '0');
    final sS = secs.toString().padLeft(2, '0');
    
    if (hrs > 0) {
      return '$hrs:$sM:$sS';
    }
    return '$sM:$sS';
  }

  @override
  Widget build(BuildContext context) {
    final tn = Tone.of(widget.tone);
    final pct = widget.timer.seconds == 0 ? 0.0 : _remaining / widget.timer.seconds;
    final completed = _remaining == 0;

    return AnimatedContainer(
      duration: LoTheme.fast,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: completed ? LoTheme.dangerSoft : LoTheme.primarySoft,
        borderRadius: BorderRadius.circular(LoTheme.radius),
        border: Border.all(
          color: completed 
              ? LoTheme.danger.withValues(alpha: 0.3) 
              : LoTheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Circular progress ring
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: pct,
                  strokeWidth: 3.5,
                  color: completed ? LoTheme.danger : tn.dot,
                  backgroundColor: completed 
                      ? LoTheme.danger.withValues(alpha: 0.1) 
                      : tn.dot.withValues(alpha: 0.1),
                ),
                Icon(
                  completed 
                      ? Icons.notifications_active_rounded 
                      : (_running ? Icons.hourglass_bottom_rounded : Icons.hourglass_top_rounded),
                  size: 18,
                  color: completed ? LoTheme.danger : tn.dot,
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.timer.label,
                  style: LoTheme.font(
                    size: 13,
                    weight: FontWeight.w700,
                    color: completed ? LoTheme.danger : LoTheme.ink2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _format(_remaining),
                  style: LoTheme.font(
                    size: 20,
                    weight: FontWeight.w800,
                    color: completed ? LoTheme.danger : LoTheme.ink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Action Buttons
          if (!completed) ...[
            Pressable(
              scale: 0.88,
              onTap: _toggle,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tn.dot,
                ),
                child: Icon(
                  _running ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Pressable(
            scale: 0.88,
            onTap: _reset,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: LoTheme.surface,
              ),
              child: Icon(
                Icons.refresh_rounded,
                size: 18,
                color: completed ? LoTheme.danger : LoTheme.ink2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
