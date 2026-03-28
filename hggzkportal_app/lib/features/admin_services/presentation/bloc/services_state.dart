import 'package:equatable/equatable.dart';
import '../../../../core/models/paginated_result.dart';
import '../../domain/entities/service.dart';
import '../../domain/entities/service_details.dart';

/// 📊 States للخدمات
abstract class ServicesState extends Equatable {
  /// العربية: ينشئ مثيلًا جديدًا من `ServicesState`.
  const ServicesState();
  @override
  List<Object?> get props => [];
}

/// حالة ابتدائية
class ServicesInitial extends ServicesState {}

/// حالة التحميل
class ServicesLoading extends ServicesState {}

/// حالة النجاح في تحميل الخدمات
class ServicesLoaded extends ServicesState {
  /// العربية: يخزن القيمة `services`.
  final List<Service> services;
  final PaginatedResult<Service>? paginatedServices;
  final String? selectedPropertyId;
  final String? searchQuery;
  final int totalServices;
  final int paidServices;
  final bool isLoadingMore;
  const ServicesLoaded({
    required this.services,
    this.paginatedServices,
    this.selectedPropertyId,
    this.searchQuery,
    this.totalServices = 0,
    this.paidServices = 0,
    this.isLoadingMore = false,
  });
  @override
  List<Object?> get props => [
        services,
        paginatedServices,
        selectedPropertyId,
        searchQuery,
        totalServices,
        paidServices,
        isLoadingMore,
      ];
  ServicesLoaded copyWith({
    List<Service>? services,
    PaginatedResult<Service>? paginatedServices,
    String? selectedPropertyId,
    String? searchQuery,
    int? totalServices,
    int? paidServices,
    bool? isLoadingMore,
  }) {
    return ServicesLoaded(
      services: services ?? this.services,
      paginatedServices: paginatedServices ?? this.paginatedServices,
      selectedPropertyId: selectedPropertyId ?? this.selectedPropertyId,
      searchQuery: searchQuery ?? this.searchQuery,
      totalServices: totalServices ?? this.totalServices,
      paidServices: paidServices ?? this.paidServices,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// حالة الخطأ
class ServicesError extends ServicesState {
  /// العربية: يخزن القيمة `message`.
  final String message;
  const ServicesError(this.message);
  @override
  List<Object> get props => [message];
}

/// حالة العملية قيد التنفيذ
class ServiceOperationInProgress extends ServicesState {}

/// حالة نجاح العملية
class ServiceOperationSuccess extends ServicesState {
  /// العربية: يخزن القيمة `message`.
  final String message;
  const ServiceOperationSuccess(this.message);
  @override
  List<Object> get props => [message];
}

/// ⏳ حالات خاصة بالحذف لإظهار اللودر المستقبلي والنتيجة
class ServicesDeleting extends ServicesState {}
class ServicesDeleteSuccess extends ServicesState {}
class ServicesDeleteFailed extends ServicesState {
  /// العربية: يخزن القيمة `message`.
  final String message;
  const ServicesDeleteFailed(this.message);
  @override
  List<Object> get props => [message];
}

/// حالة تحميل تفاصيل الخدمة
class ServiceDetailsLoading extends ServicesState {}

/// حالة نجاح تحميل التفاصيل
class ServiceDetailsLoaded extends ServicesState {
  /// العربية: يخزن القيمة `serviceDetails`.
  final ServiceDetails serviceDetails;
  const ServiceDetailsLoaded(this.serviceDetails);
  @override
  List<Object> get props => [serviceDetails];
}
