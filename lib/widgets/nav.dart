import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/list_detail_screen.dart';

/// The list-detail route with a slide + fade transition.
PageRouteBuilder listRoute(String listId) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 360),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => ListDetailScreen(listId: listId),
    transitionsBuilder: (_, anim, __, child) {
      final curved = CurvedAnimation(parent: anim, curve: LoTheme.ease);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Push list detail from a mounted context (e.g. tapping a list card).
void pushList(BuildContext context, String listId) {
  Navigator.of(context).push(listRoute(listId));
}
