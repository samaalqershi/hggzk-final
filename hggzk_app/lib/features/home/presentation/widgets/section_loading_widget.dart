// lib/features/home/presentation/widgets/sections/section_loading_widget.dart

import 'package:flutter/material.dart';
import '../../../../core/widgets/loading_widget.dart';

/// يمثل عنصر التحميل الذي يظهر داخل أقسام الصفحة الرئيسية ريثما تصل
/// البيانات الفعلية من الخادم أو الكاش.
/// Represents the loading placeholder shown inside home sections while the real
/// data is still arriving from backend or cache.
class SectionLoadingWidget extends StatelessWidget {
  /// ينشئ عنصر التحميل المخصص لأقسام الصفحة الرئيسية.
  /// Creates the loading placeholder dedicated to home sections.
  const SectionLoadingWidget({super.key});

  /// يبني مساحة تحميل ثابتة الارتفاع حتى لا يقفز التخطيط أثناء الجلب.
  /// Builds a fixed-height loading space so layout does not jump during fetch.
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 250,
      child: Center(
        child: LoadingWidget(
          type: LoadingType.futuristic,
        ),
      ),
    );
  }
}
