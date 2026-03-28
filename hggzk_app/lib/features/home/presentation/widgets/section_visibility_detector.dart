// lib/features/home/presentation/widgets/analyticsection_visibility_detectors/.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:hggzk/features/home/presentation/bloc/home_bloc.dart';
import 'package:hggzk/features/home/presentation/bloc/home_event.dart';

/// يراقب نسبة ظهور القسم داخل نافذة العرض حتى لا تُسجل الانطباعات
/// والتحليلات إلا عندما يكون القسم قد ظهر فعلًا للمستخدم بشكل معتبر.
/// Monitors how much of a section is inside the viewport so impressions and
/// analytics are recorded only once the user has genuinely seen that section.
class SectionVisibilityDetector extends StatefulWidget {
  /// معرّف القسم الذي تُربط به الانطباعات وقياسات التفاعل.
  /// Section identifier used to attribute impressions and engagement metrics.
  final String sectionId;

  /// المحتوى الفعلي الذي نريد مراقبة ظهوره داخل الشاشة.
  /// Actual widget subtree whose visibility should be tracked.
  final Widget child;

  /// رد اختياري لإبلاغ الطبقات الأعلى عندما يعبر القسم حد الظهور المحدد.
  /// Optional callback that notifies higher layers when the section crosses
  /// the configured visibility threshold.
  final Function(bool)? onVisibilityChanged;

  /// الحد الأدنى من الظهور المطلوب قبل اعتبار القسم مرئيًا بشكل فعلي.
  /// Minimum visible fraction required before the section is considered truly
  /// visible.
  final double visibilityThreshold;
  const SectionVisibilityDetector({
    super.key,
    required this.sectionId,
    required this.child,
    this.onVisibilityChanged,
    this.visibilityThreshold = 0.5,
  });
  @override
  State<SectionVisibilityDetector> createState() =>
      _SectionVisibilityDetectorState();
}

class _SectionVisibilityDetectorState extends State<SectionVisibilityDetector> {
  bool _hasRecordedImpression = false;
  bool _isVisible = false;
  DateTime? _visibilityStartTime;
  bool _isDisposed = false;
  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('section_${widget.sectionId}'),
      onVisibilityChanged: (info) {
        final visiblePercentage = info.visibleFraction;
        final isNowVisible = visiblePercentage >= widget.visibilityThreshold;

        if (_isDisposed) return;
        if (isNowVisible != _isVisible) {
          if (!mounted) return;
          _isVisible = isNowVisible;

          if (isNowVisible) {
            _onSectionBecameVisible();
          } else {
            _onSectionBecameHidden();
          }

          if (!mounted || _isDisposed) return;
          widget.onVisibilityChanged?.call(isNowVisible);
        }
      },
      child: widget.child,
    );
  }

  void _onSectionBecameVisible() {
    if (_isDisposed || !mounted) return;
    _visibilityStartTime = DateTime.now();

    // نسجل الانطباع مرة واحدة لكل دورة ظهور حتى لا تتكرر الإحصائية أثناء
    // بقاء القسم ظاهرًا.
    // Record the impression only once per visibility cycle so analytics do not
    // double count while the section remains on screen.
    if (!_hasRecordedImpression) {
      _hasRecordedImpression = true;
      if (!_isDisposed && mounted) {
        context.read<HomeBloc>().add(
              RecordSectionImpressionEvent(sectionId: widget.sectionId),
            );
      }
    }
  }

  void _onSectionBecameHidden() {
    if (_isDisposed) return;
    if (_visibilityStartTime != null) {
      final duration = DateTime.now().difference(_visibilityStartTime!);

      // إذا استمر الظهور لثانيتين أو أكثر نعتبر ذلك مشاهدة ذات معنى يمكن
      // احتسابها كتفاعل.
      // If visibility lasts at least two seconds, treat it as a meaningful
      // engagement rather than a passing glance.
      if (duration.inSeconds >= 2) {
        if (!_isDisposed && mounted) {
          context.read<HomeBloc>().add(
                RecordSectionInteractionEvent(
                  sectionId: widget.sectionId,
                  interactionType: 'view',
                  metadata: {
                    'duration_seconds': duration.inSeconds,
                  },
                ),
              );
        }
      }
    }

    _visibilityStartTime = null;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _visibilityStartTime = null;
    super.dispose();
  }
}
