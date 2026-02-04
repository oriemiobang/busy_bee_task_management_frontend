import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

CustomTransitionPage buildPageWithDefaultTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

// Usage in GoRouter:
/*
GoRoute(
  path: '/dashboard',
  pageBuilder: (context, state) => buildPageWithDefaultTransition(
    context: context,
    state: state,
    child: const DashboardScreen(),
  ),
),
*/