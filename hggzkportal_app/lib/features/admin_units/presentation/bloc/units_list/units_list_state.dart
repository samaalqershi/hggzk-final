// lib/features/admin_units/presentation/bloc/units_list/units_list_state.dart

part of 'units_list_bloc.dart';

/// يمثل هذا الكلاس المجرد UnitsListState العقد المشترك لمسار إدارة الوحدات.
/// This abstract class defines the shared contract for UnitsListState in the admin unit workflow.
abstract class UnitsListState extends Equatable {
  /// This constructor creates a new UnitsListState instance.
  /// ينشئ مثيلًا جديدًا من UnitsListState.
  const UnitsListState();

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [];
}

/// يمثل هذا الكلاس UnitsListInitial البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitsListInitial in the admin unit workflow.
class UnitsListInitial extends UnitsListState {}

/// يمثل هذا الكلاس UnitsListLoading البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitsListLoading in the admin unit workflow.
class UnitsListLoading extends UnitsListState {}

/// يمثل هذا الكلاس UnitsListLoaded البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitsListLoaded in the admin unit workflow.
class UnitsListLoaded extends UnitsListState {
  /// This field keeps the units value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة units التي يعتمد عليها مسار إدارة الوحدات.
  final List<Unit> units;

  /// يحتفظ هذا الحقل بقيمة selectedUnits التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the selectedUnits value used by the admin unit workflow.
  final List<Unit> selectedUnits;

  /// يحتفظ هذا الحقل بقيمة totalCount التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the totalCount value used by the admin unit workflow.
  final int totalCount;

  /// يحتفظ هذا الحقل بقيمة currentPage التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the currentPage value used by the admin unit workflow.
  final int currentPage;

  /// يحتفظ هذا الحقل بقيمة pageSize التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the pageSize value used by the admin unit workflow.
  final int pageSize;

  /// يحتفظ هذا الحقل بقيمة hasMore التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the hasMore value used by the admin unit workflow.
  final bool hasMore;

  /// يحتفظ هذا الحقل بقيمة searchQuery التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the searchQuery value used by the admin unit workflow.
  final String? searchQuery;

  /// يحتفظ هذا الحقل بقيمة filters التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the filters value used by the admin unit workflow.
  final Map<String, dynamic>? filters;

  /// يحتفظ هذا الحقل بقيمة stats التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the stats value used by the admin unit workflow.
  final Map<String, dynamic>? stats;

  /// ينشئ هذا المُنشئ مثيلاً من UnitsListLoaded.
  /// This constructor creates an instance of UnitsListLoaded.
  const UnitsListLoaded({
    required this.units,
    this.selectedUnits = const [],
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    this.hasMore = false,
    this.searchQuery,
    this.filters,
    this.stats,
  });

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [
        units,
        selectedUnits,
        totalCount,
        currentPage,
        pageSize,
        hasMore,
        searchQuery,
        filters,
        stats,
      ];

  /// ينفذ هذا الأسلوب عملية copyWith ضمن مسار إدارة الوحدات.
  /// This method performs the copyWith operation in the admin unit workflow.
  UnitsListLoaded copyWith({
    List<Unit>? units,
    List<Unit>? selectedUnits,
    int? totalCount,
    int? currentPage,
    int? pageSize,
    bool? hasMore,
    String? searchQuery,
    Map<String, dynamic>? filters,
    Map<String, dynamic>? stats,
  }) {
    return UnitsListLoaded(
      units: units ?? this.units,
      selectedUnits: selectedUnits ?? this.selectedUnits,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery,
      filters: filters,
      stats: stats ?? this.stats,
    );
  }
}

/// يمثل هذا الكلاس UnitsListError البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitsListError in the admin unit workflow.
class UnitsListError extends UnitsListState {
  /// This field keeps the message value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة message التي يعتمد عليها مسار إدارة الوحدات.
  final String message;

  /// ينشئ هذا المُنشئ مثيلاً من UnitsListError.
  /// This constructor creates an instance of UnitsListError.
  const UnitsListError({required this.message});

  /// يعيد هذا getter الخصائص المستخدمة للمقارنة بين الكائنات.
  /// This getter returns the properties used for equality comparisons.
  @override
  List<Object?> get props => [message];
}
