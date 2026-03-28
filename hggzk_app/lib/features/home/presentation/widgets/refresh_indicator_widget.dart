// lib/features/home/presentation/widgets/common/refresh_indicator_widget.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// يغلّف محتوى الصفحة الرئيسية بسحب للتحديث متسق مع هوية التطبيق حتى تبقى
/// تجربة إعادة التحميل جزءًا من نفس اللغة البصرية.
/// Wraps home content in a pull-to-refresh interaction that matches the app's
/// visual identity so reload behavior feels native to the screen.
class FuturisticRefreshIndicator extends StatefulWidget {
  /// المحتوى الداخلي الذي سيستجيب لحركة السحب للتحديث.
  /// Child content that should respond to the pull-to-refresh gesture.
  final Widget child;

  /// الاستدعاء الذي ينفذ منطق التحديث عند سحب الصفحة إلى الأسفل.
  /// Callback that performs the refresh logic when the page is pulled down.
  final Future<void> Function() onRefresh;

  /// ينشئ الغلاف البصري لميزة السحب للتحديث في الصفحة الرئيسية.
  /// Creates the visual wrapper that provides pull-to-refresh on the home
  /// screen.
  const FuturisticRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  /// ينشئ كائن الحالة الذي يدير حركة المؤشر أثناء التحديث.
  /// Creates the state object that drives indicator animation during refresh.
  @override
  State<FuturisticRefreshIndicator> createState() =>
      _FuturisticRefreshIndicatorState();
}

/// يدير حركة المؤشر الدوّار أثناء تنفيذ التحديث الفعلي.
/// Manages the rotating indicator animation while the refresh is in progress.
class _FuturisticRefreshIndicatorState extends State<FuturisticRefreshIndicator>
    with SingleTickerProviderStateMixin {
  /// متحكم الحركة المستخدم لتدوير المؤشر أثناء التحديث.
  /// Animation controller used to rotate the indicator during refresh.
  late AnimationController _rotationController;

  /// يجهز متحكم الحركة قبل أن يبدأ المستخدم استخدام السحب للتحديث.
  /// Prepares the animation controller before pull-to-refresh is used.
  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  /// يحرر متحكم الحركة عندما تُزال الأداة من الشجرة.
  /// Releases the animation controller when the widget leaves the tree.
  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  /// يبني عنصر السحب للتحديث مع ربطه بحالة الحركة الحالية.
  /// Builds the refresh widget and binds it to the current animation state.
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _rotationController.repeat();
        await widget.onRefresh();
        _rotationController.stop();
        _rotationController.reset();
      },
      color: AppTheme.primaryBlue,
      backgroundColor: AppTheme.darkCard,
      strokeWidth: 3,
      displacement: 80,
      child: widget.child,
    );
  }
}
