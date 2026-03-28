import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// ينشئ صفحة انتقال بتأثير التلاشي للمسارات التي تريد دخولًا هادئًا وغير
/// متكلف عند الانتقال بينها.
/// Creates a fade-only transition page for routes that should enter with a
/// calm and minimal motion.
CustomTransitionPage<T> fadeTransitionPage<T>({
  required Widget child,
  Duration duration = const Duration(milliseconds: 250),
}) {
  return CustomTransitionPage<T>(
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

/// ينشئ انتقالًا يجمع بين التلاشي والتكبير الخفيف عندما تحتاج الصفحة إلى
/// حضور بصري أوضح من مجرد fade.
/// Creates a transition that combines fade and a subtle scale-up when a page
/// needs a slightly stronger visual entrance.
CustomTransitionPage<T> scaleFadeTransitionPage<T>({
  required Widget child,
  Duration duration = const Duration(milliseconds: 300),
}) {
  return CustomTransitionPage<T>(
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// ينشئ انتقالًا يصعد فيه المحتوى قليلًا مع التلاشي حتى تبدو حركة التنقل
/// سلسة ومقروءة في الصفحات الثقيلة.
/// Creates a subtle upward slide paired with fade so navigation feels smooth
/// and readable on denser pages.
CustomTransitionPage<T> slideUpTransitionPage<T>({
  required Widget child,
  Duration duration = const Duration(milliseconds: 300),
}) {
  return CustomTransitionPage<T>(
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuart,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(opacity: curved, child: child),
      );
    },
  );
}
