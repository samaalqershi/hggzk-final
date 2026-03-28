// lib/features/reference/presentation/bloc/reference_event.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/currency.dart';

/// Describes the event definition for `ReferenceEvent`.
/// العربية: يمثل تعريف الحدث `ReferenceEvent`.
abstract class ReferenceEvent extends Equatable {
  /// Builds a new `ReferenceEvent` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `ReferenceEvent`.
  const ReferenceEvent();

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [];
}

// تحميل المدن
/// Describes the event definition for `LoadCitiesEvent`.
/// العربية: يمثل تعريف الحدث `LoadCitiesEvent`.
class LoadCitiesEvent extends ReferenceEvent {
  /// Keeps the `forceRefresh` value.
  /// العربية: يخزن القيمة `forceRefresh`.
  final bool forceRefresh;

  /// Builds a new `LoadCitiesEvent` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `LoadCitiesEvent`.
  const LoadCitiesEvent({this.forceRefresh = false});

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [forceRefresh];
}

// تحميل العملات
/// Describes the event definition for `LoadCurrenciesEvent`.
/// العربية: يمثل تعريف الحدث `LoadCurrenciesEvent`.
class LoadCurrenciesEvent extends ReferenceEvent {
  /// Keeps the `forceRefresh` value.
  /// العربية: يخزن القيمة `forceRefresh`.
  final bool forceRefresh;

  /// Builds a new `LoadCurrenciesEvent` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `LoadCurrenciesEvent`.
  const LoadCurrenciesEvent({this.forceRefresh = false});

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [forceRefresh];
}

// تحميل كل البيانات المرجعية
/// Describes the event definition for `LoadReferenceDataEvent`.
/// العربية: يمثل تعريف الحدث `LoadReferenceDataEvent`.
class LoadReferenceDataEvent extends ReferenceEvent {
  /// Builds a new `LoadReferenceDataEvent` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `LoadReferenceDataEvent`.
  const LoadReferenceDataEvent();
}

// اختيار مدينة
/// Describes the event definition for `SelectCityEvent`.
/// العربية: يمثل تعريف الحدث `SelectCityEvent`.
class SelectCityEvent extends ReferenceEvent {
  /// Keeps the `city` value.
  /// العربية: يخزن القيمة `city`.
  final City city;

  /// Builds a new `SelectCityEvent` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `SelectCityEvent`.
  const SelectCityEvent({required this.city});

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [city];
}

// اختيار عملة
/// Describes the event definition for `SelectCurrencyEvent`.
/// العربية: يمثل تعريف الحدث `SelectCurrencyEvent`.
class SelectCurrencyEvent extends ReferenceEvent {
  /// Keeps the `currency` value.
  /// العربية: يخزن القيمة `currency`.
  final Currency currency;

  /// Builds a new `SelectCurrencyEvent` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `SelectCurrencyEvent`.
  const SelectCurrencyEvent({required this.currency});

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [currency];
}

// البحث في المدن
/// Describes the event definition for `SearchCitiesEvent`.
/// العربية: يمثل تعريف الحدث `SearchCitiesEvent`.
class SearchCitiesEvent extends ReferenceEvent {
  /// Keeps the `query` value.
  /// العربية: يخزن القيمة `query`.
  final String query;

  /// Builds a new `SearchCitiesEvent` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `SearchCitiesEvent`.
  const SearchCitiesEvent({required this.query});

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [query];
}

// البحث في العملات
/// Describes the event definition for `SearchCurrenciesEvent`.
/// العربية: يمثل تعريف الحدث `SearchCurrenciesEvent`.
class SearchCurrenciesEvent extends ReferenceEvent {
  /// Keeps the `query` value.
  /// العربية: يخزن القيمة `query`.
  final String query;

  /// Builds a new `SearchCurrenciesEvent` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `SearchCurrenciesEvent`.
  const SearchCurrenciesEvent({required this.query});

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [query];
}

// تحميل المدينة المختارة
/// Describes the event definition for `LoadSelectedCityEvent`.
/// العربية: يمثل تعريف الحدث `LoadSelectedCityEvent`.
class LoadSelectedCityEvent extends ReferenceEvent {
  /// Builds a new `LoadSelectedCityEvent` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `LoadSelectedCityEvent`.
  const LoadSelectedCityEvent();
}

// تحميل العملة المختارة
/// Describes the event definition for `LoadSelectedCurrencyEvent`.
/// العربية: يمثل تعريف الحدث `LoadSelectedCurrencyEvent`.
class LoadSelectedCurrencyEvent extends ReferenceEvent {
  /// Builds a new `LoadSelectedCurrencyEvent` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `LoadSelectedCurrencyEvent`.
  const LoadSelectedCurrencyEvent();
}

// مسح الاختيارات
/// Describes the event definition for `ClearSelectionEvent`.
/// العربية: يمثل تعريف الحدث `ClearSelectionEvent`.
class ClearSelectionEvent extends ReferenceEvent {
  /// Keeps the `clearCity` value.
  /// العربية: يخزن القيمة `clearCity`.
  final bool clearCity;

  /// Keeps the `clearCurrency` value.
  /// العربية: يخزن القيمة `clearCurrency`.
  final bool clearCurrency;

  /// Builds a new `ClearSelectionEvent` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `ClearSelectionEvent`.
  const ClearSelectionEvent({
    this.clearCity = true,
    this.clearCurrency = true,
  });

  /// Exposes the equality properties for this instance.
  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [clearCity, clearCurrency];
}

// تحديث البيانات المرجعية
/// Describes the event definition for `RefreshReferenceDataEvent`.
/// العربية: يمثل تعريف الحدث `RefreshReferenceDataEvent`.
class RefreshReferenceDataEvent extends ReferenceEvent {
  /// Builds a new `RefreshReferenceDataEvent` instance.
  /// العربية: ينشئ مثيلًا جديدًا من `RefreshReferenceDataEvent`.
  const RefreshReferenceDataEvent();
}
