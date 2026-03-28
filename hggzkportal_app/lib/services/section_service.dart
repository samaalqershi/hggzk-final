import 'package:hggzkportal/core/enums/section_target.dart';
import 'package:hggzkportal/core/enums/section_type.dart';
import 'package:hggzkportal/core/enums/section_content_type.dart';
import 'package:hggzkportal/core/models/paginated_result.dart';
import 'package:hggzkportal/features/admin_sections/domain/entities/section.dart';
import 'package:hggzkportal/features/admin_sections/domain/usecases/sections/create_section_usecase.dart';
import 'package:hggzkportal/features/admin_sections/domain/usecases/sections/delete_section_usecase.dart';
import 'package:hggzkportal/features/admin_sections/domain/usecases/sections/get_all_sections_usecase.dart';
import 'package:hggzkportal/features/admin_sections/domain/usecases/sections/toggle_section_status_usecase.dart';
import 'package:hggzkportal/features/admin_sections/domain/usecases/sections/get_section_by_id_usecase.dart';
import 'package:hggzkportal/features/admin_sections/domain/usecases/sections/update_section_usecase.dart';

/// Presents a service-oriented wrapper around section CRUD use cases so admin
/// screens can manage sections without dealing with raw domain plumbing.
/// يقدّم غلافًا خدميًا حول use cases الخاصة بالأقسام حتى تدير شاشات الإدارة
/// الأقسام من دون التعامل مع طبقات المجال مباشرة.
class SectionService {
  /// Use case that loads the section list.
  /// use case يجلب قائمة الأقسام.
  final GetAllSectionsUseCase getAllSections;

  /// Use case that creates new sections.
  /// use case ينشئ أقسامًا جديدة.
  final CreateSectionUseCase createSection;

  /// Use case that updates an existing section.
  /// use case يحدّث قسمًا موجودًا.
  final UpdateSectionUseCase updateSection;

  /// Use case that deletes a section.
  /// use case يحذف قسمًا.
  final DeleteSectionUseCase deleteSection;

  /// Use case that flips the active/inactive status of a section.
  /// use case يبدّل حالة القسم بين فعال وغير فعال.
  final ToggleSectionStatusUseCase toggleStatus;

  /// Use case that loads a single section by id.
  /// use case يجلب قسمًا واحدًا بواسطة المعرف.
  final GetSectionByIdUseCase getById;

  /// Injects the section use cases used by the portal administration flow.
  /// يحقن use cases الخاصة بالأقسام المستخدمة في مسار الإدارة.
  const SectionService({
    required this.getAllSections,
    required this.createSection,
    required this.updateSection,
    required this.deleteSection,
    required this.toggleStatus,
    required this.getById,
  });

  /// Loads a paginated, filterable list of sections for admin pages.
  /// يحمّل قائمة أقسام قابلة للترقيم والتصفية لشاشات الإدارة.
  Future<PaginatedResult<Section>> fetchSections({
    int? pageNumber,
    int? pageSize,
    SectionTarget? target,
    SectionTypeEnum? type,
    SectionContentType? contentType,
  }) async {
    final result = await getAllSections(GetAllSectionsParams(
      pageNumber: pageNumber,
      pageSize: pageSize,
      target: target,
      type: type,
      contentType: contentType,
    ));
    return result.fold((l) => PaginatedResult.empty(), (r) => r);
  }

  /// Persists a new section and returns the saved entity when successful.
  /// ينشئ قسمًا جديدًا ويعيد الكيان المحفوظ عند النجاح.
  Future<Section?> create(Section section) async {
    final result = await createSection(CreateSectionParams(section));
    return result.fold((l) => null, (r) => r);
  }

  /// Updates section details while keeping the rest of the entity intact.
  /// يحدّث تفاصيل القسم مع الإبقاء على بقية الكيان كما هو.
  Future<Section?> update(String sectionId, Section section) async {
    final result = await updateSection(
        UpdateSectionParams(sectionId: sectionId, section: section));
    return result.fold((l) => null, (r) => r);
  }

  // Note: Background image for Section is textual (URL). Use the unified images API to upload media
  // and then set the `backgroundImage` string on the Section via update().

  /// Deletes a section by its identifier.
  /// يحذف قسمًا بواسطة معرفه.
  Future<bool> remove(String sectionId) async {
    final result = await deleteSection(DeleteSectionParams(sectionId));
    return result.fold((l) => false, (r) => r);
  }

  /// Switches a section between active and inactive states.
  /// يبدّل القسم بين الحالة النشطة وغير النشطة.
  Future<bool> setActive(String sectionId, bool isActive) async {
    final result = await toggleStatus(
        ToggleSectionStatusParams(sectionId: sectionId, isActive: isActive));
    return result.fold((l) => false, (r) => r);
  }

  /// Loads one section for editing or inspection.
  /// يحمّل قسمًا واحدًا للمراجعة أو التعديل.
  Future<Section?> fetchById(String sectionId) async {
    final result = await getById(GetSectionByIdParams(sectionId));
    return result.fold((l) => null, (r) => r);
  }
}
