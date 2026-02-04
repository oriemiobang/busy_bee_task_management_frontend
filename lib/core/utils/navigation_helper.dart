import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = 
      GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;

  static void goToDashboard() {
    final ctx = context;
    if (ctx != null) {
      GoRouter.of(ctx).goNamed('dashboard');
    }
  }

  static void goToLogin() {
    final ctx = context;
    if (ctx != null) {
      GoRouter.of(ctx).goNamed('login');
    }
  }

  static void goToRegister() {
    final ctx = context;
    if (ctx != null) {
      GoRouter.of(ctx).goNamed('register');
    }
  }

  static void goBack() {
    final ctx = context;
    if (ctx != null) {
      GoRouter.of(ctx).pop();
    }
  }
}