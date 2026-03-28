import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_result.dart' as core;

import '../entities/property_type.dart' as domain;
import '../entities/unit_type.dart' as domain;
import '../entities/property_types_with_units.dart' as domain_combined;
import '../entities/section.dart' as section_domain;
import '../../data/models/section_item_models.dart';

/// يعرّف العقدة التي تعتمد عليها الصفحة الرئيسية لجلب الأقسام الديناميكية
/// ومحتواها وأنواع العقارات والوحدات، مع تسجيل التفاعلات التحليلية المهمة.
/// Defines the contract that powers the home screen with dynamic sections,
/// their content, property and unit types, plus the analytics interactions that
/// measure user behavior.
abstract class HomeRepository {
  /// يسجل أن قسمًا معينًا ظهر للمستخدم بما يكفي لاحتسابه ظهورًا فعليًا في
  /// تقارير التحليل.
  /// Records that a section stayed visible long enough to count as a real
  /// impression in analytics reports.
  Future<Either<Failure, void>> recordSectionImpression(
      {required String sectionId});

  /// يسجل التفاعل الذي حدث داخل قسم أو على عنصر تابع له حتى يمكن فهم ما الذي
  /// جذب المستخدم أو دفعه لإكمال الرحلة.
  /// Records the interaction that happened within a section or on one of its
  /// items so we can understand what attracted the user or advanced the flow.
  Future<Either<Failure, void>> recordSectionInteraction(
      {required String sectionId,
      required String interactionType,
      String? itemId,
      Map<String, dynamic>? metadata});

  /// يجلب تعريفات الأقسام التي تشكل بنية الصفحة الرئيسية، مع دعم الترقيم
  /// والتصفية والتحديث الإجباري عند الحاجة.
  /// Fetches the section definitions that shape the home screen, with support
  /// for pagination, filtering, and forced refresh when needed.
  Future<Either<Failure, core.PaginatedResult<section_domain.Section>>>
      getSections(
          {int pageNumber,
          int pageSize,
          String? target,
          String? type,
          bool forceRefresh});

  /// يجلب العناصر التابعة لقسم واحد، مثل العقارات أو الوحدات، حتى تستطيع
  /// الواجهة بناء القوائم الأفقية والصفحات الموسعة الخاصة به.
  /// Loads the items that belong to one section, such as properties or units,
  /// so the UI can build its carousels and expanded views.
  Future<Either<Failure, core.PaginatedResult<SectionPropertyItemModel>>>
      getSectionPropertyItems(
          {required String sectionId,
          int pageNumber,
          int pageSize,
          bool forceRefresh});

  /// يعيد أنواع العقارات التي تظهر كنقطة دخول أساسية في الصفحة الرئيسية
  /// وتغذي بقية خيارات التصفح والبحث.
  /// Returns the property types exposed as a primary entry point on the home
  /// screen and used to drive later browsing and search choices.
  Future<Either<Failure, List<domain.PropertyType>>> getPropertyTypes();

  /// يجلب أنواع الوحدات التابعة لنوع العقار المختار حتى تبقى الفلاتر
  /// والحقول الديناميكية متسقة مع السياق الحالي.
  /// Loads the unit types that belong to the selected property type so filters
  /// and dynamic fields stay aligned with the current context.
  Future<Either<Failure, List<domain.UnitType>>> getUnitTypes(
      {required String propertyTypeId});

  /// يجمع أنواع العقارات وأنواع الوحدات التابعة لها في استجابة واحدة لتقليل
  /// عدد الطلبات اللازمة قبل أن تصبح الصفحة الرئيسية جاهزة للتفاعل.
  /// Combines property types with their dependent unit types in one response to
  /// reduce the number of requests needed before the home screen is
  /// interactive.
  Future<Either<Failure, domain_combined.PropertyTypesWithUnits>>
      getPropertyTypesWithUnits();
}
