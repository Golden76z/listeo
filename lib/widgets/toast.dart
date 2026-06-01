import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Lightweight overlay toast that slides up from the bottom, matching the
/// prototype's `lo-toast` animation.
class LoToast {
  static OverlayEntry? _entry;

  static void show(BuildContext context, String msg) {
    _entry?.remove();
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => _ToastWidget(message: msg, onDone: () {
        _entry?.remove();
        _entry = null;
      }),
    );
    _entry = entry;
    overlay.insert(entry);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final VoidCallback onDone;
  const _ToastWidget({required this.message, required this.onDone});

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

  @override
  void initState() {
    super.initState();
    _c.forward();
    Future.delayed(const Duration(milliseconds: 1700), () async {
      if (mounted) {
        await _c.reverse();
        widget.onDone();
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Positioned(
      left: 0,
      right: 0,
      bottom: media.padding.bottom + 96,
      child: IgnorePointer(
        child: Center(
          child: FadeTransition(
            opacity: _c,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, 0.5), end: Offset.zero)
                  .animate(CurvedAnimation(parent: _c, curve: LoTheme.ease)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                decoration: BoxDecoration(
                  color: LoTheme.ink,
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: const [BoxShadow(color: Color(0x47282E20), blurRadius: 24, offset: Offset(0, 8))],
                ),
                child: Text(widget.message,
                    style: LoTheme.font(size: 14, weight: FontWeight.w600, color: LoTheme.bg)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
