import 'package:equatable/equatable.dart';

/// Wraps arbitrary serialized metadata that augments a section definition.
///
/// يغلّف البيانات الوصفية المرنة التي توسّع تعريف القسم.
class SectionMetadata extends Equatable {
  /// Free-form metadata map.
  ///
  /// خريطة بيانات وصفية حرة.
  final Map<String, dynamic> values;

  /// Creates the metadata wrapper used by section editors.
  ///
  /// ينشئ غلاف البيانات الوصفية المستخدم في محررات الأقسام.
  const SectionMetadata({this.values = const {}});

  /// Merges another metadata block over the current values.
  ///
  /// يدمج كتلة بيانات وصفية أخرى فوق القيم الحالية.
  SectionMetadata merge(SectionMetadata other) {
    return SectionMetadata(values: {...values, ...other.values});
  }

  /// Keeps equality aligned with the metadata map.
  ///
  /// يربط المقارنة بخريطة البيانات الوصفية.
  @override
  List<Object?> get props => [values];
}
