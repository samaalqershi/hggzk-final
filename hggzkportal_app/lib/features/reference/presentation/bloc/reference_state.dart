// lib/features/reference/presentation/bloc/reference_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/currency.dart';

/// العربية: يمثل حالات البيانات المرجعية من التحميل حتى عرض المدن والعملات والاختيارات المحفوظة.
/// Represents reference-data states from loading to displaying cities, currencies, and saved selections.
abstract class ReferenceState extends Equatable {
  /// العربية: تبقى حالات المرجع قابلة للمقارنة حتى لا تتغير الواجهة إلا عند تبدل البيانات نفسها.
  /// Reference states stay comparable so the UI only changes when the actual data changes.
  const ReferenceState();

  /// العربية: لا تحمل القاعدة حقولًا مشتركة، لذلك المساواة هنا على النوع.
  /// The base class carries no shared fields, so equality is type-based.
  @override
  List<Object?> get props => [];
}

/// حالة البدء قبل تحميل أي بيانات مرجعية.
/// The starting state before any reference data is loaded.
class ReferenceInitial extends ReferenceState {
  /// لا تضيف هذه الحالة أي بيانات إضافية.
  /// This state adds no extra data.
  const ReferenceInitial();
}

/// تعني أن البيانات المرجعية تُجلب الآن.
/// Indicates that reference data is currently being loaded.
class ReferenceLoading extends ReferenceState {
  /// لا تحتاج حقولًا لأن معناها الوحيد هو انتظار التحميل.
  /// No fields are needed because the meaning is simply loading.
  const ReferenceLoading();
}

/// تحمل قائمة المدن مع اسم المدينة المختارة سابقًا إن وجد.
/// Carries the city list together with the previously selected city
/// when available.
class CitiesLoaded extends ReferenceState {
  /// المدن المحملة والتي ستظهر في قوائم الاختيار.
  /// The loaded cities shown in selection lists.
  final List<City> cities;

  /// المدينة التي تم اختيارها مسبقًا.
  /// The city selected earlier.
  final String? selectedCity;

  /// يميز ما إذا كانت هذه الحالة ناتجة عن بحث أم عن تحميل كامل.
  /// Marks whether this state came from a search or a full load.
  final bool isSearchResult;

  /// يجهز لقطـة مدن جاهزة للعرض أو للبحث المحلي.
  /// Prepares a city snapshot ready for display or local search.
  const CitiesLoaded({
    required this.cities,
    this.selectedCity,
    this.isSearchResult = false,
  });

  /// تعتمد المساواة على قائمة المدن والاختيار وحالة البحث.
  /// Equality depends on the city list, selection, and search flag.
  @override
  List<Object?> get props => [cities, selectedCity, isSearchResult];
}

/// تحمل قائمة العملات مع العملة المختارة سابقًا.
/// Carries the currency list together with the previously selected
/// currency.
class CurrenciesLoaded extends ReferenceState {
  /// العملات المتاحة في الإعداد أو الفلاتر.
  /// The currencies available for setup or filtering.
  final List<Currency> currencies;

  /// العملة التي اختارها المستخدم سابقًا.
  /// The currency selected earlier by the user.
  final String? selectedCurrency;

  /// يوضح إن كانت الحالة ناتجة عن بحث محلي.
  /// Indicates whether the state came from local search.
  final bool isSearchResult;

  /// يجهز لقطـة العملات مع الاختيار الحالي وحالة البحث.
  /// Prepares a currency snapshot with the current selection and
  /// search state.
  const CurrenciesLoaded({
    required this.currencies,
    this.selectedCurrency,
    this.isSearchResult = false,
  });

  /// تعتمد المساواة على العملات والاختيار وحالة البحث.
  /// Equality depends on the currencies, selection, and search flag.
  @override
  List<Object?> get props => [currencies, selectedCurrency, isSearchResult];
}

/// تحمل بيانات المدن والعملات معًا لتعبئة الشاشات التي تحتاجهما في
/// وقت واحد.
/// Carries cities and currencies together for screens that need both
/// at the same time.
class ReferenceDataLoaded extends ReferenceState {
  /// قائمة المدن المرجعية.
  /// The reference city list.
  final List<City> cities;

  /// قائمة العملات المرجعية.
  /// The reference currency list.
  final List<Currency> currencies;

  /// العربية: اسم المدينة المحفوظة داخل اللقطة المركبة.
  /// Persisted city name inside the combined snapshot.
  final String? selectedCity;

  /// العربية: رمز العملة المحفوظة داخل اللقطة المركبة.
  /// Persisted currency code inside the combined snapshot.
  final String? selectedCurrency;

  /// يهيئ لقطة شاملة للاستخدام عندما تكون الشاشات بحاجة إلى
  /// المرجعين معًا.
  /// Initializes a combined snapshot for screens that need both
  /// references together.
  const ReferenceDataLoaded({
    required this.cities,
    required this.currencies,
    this.selectedCity,
    this.selectedCurrency,
  });

  /// تعتمد المساواة على البيانات المرجعية كلها والاختيار الحالي.
  /// Equality depends on all reference data and the current selection.
  @override
  List<Object?> get props =>
      [cities, currencies, selectedCity, selectedCurrency];
}

/// يؤكد اختيار مدينة ويعيد رسالة قصيرة للواجهة.
/// Confirms a city selection and returns a short UI message.
class CitySelected extends ReferenceState {
  /// المدينة التي جرى اختيارها.
  /// The city that was selected.
  final City city;

  /// رسالة النجاح التي يمكن عرضها للمستخدم.
  /// Success message that can be shown to the user.
  final String message;

  /// يلتقط نتيجة الاختيار ليستخدمها الحفظ أو التنبيه.
  /// Captures the selection result for persistence or feedback.
  const CitySelected({
    required this.city,
    required this.message,
  });

  /// تعتمد المساواة على المدينة والرسالة.
  /// Equality depends on the city and the message.
  @override
  List<Object?> get props => [city, message];
}

/// يؤكد اختيار عملة ويعيد رسالة مناسبة.
/// Confirms a currency selection and returns a matching message.
class CurrencySelected extends ReferenceState {
  /// العملة التي جرى اختيارها.
  /// The selected currency.
  final Currency currency;

  /// رسالة نجاح مرتبطة بالاختيار.
  /// A success message attached to the selection.
  final String message;

  /// يسجل النتيجة حتى تعرض الواجهة تأكيدًا واضحًا.
  /// Records the result so the UI can show clear confirmation.
  const CurrencySelected({
    required this.currency,
    required this.message,
  });

  /// تعتمد المساواة على العملة والرسالة.
  /// Equality depends on the currency and the message.
  @override
  List<Object?> get props => [currency, message];
}

/// تمثل فشلًا في جلب أو حفظ البيانات المرجعية.
/// Represents a failure in loading or persisting reference data.
class ReferenceError extends ReferenceState {
  /// رسالة الخطأ التي توضح ما الذي فشل.
  /// The error message that explains what failed.
  final String message;

  /// يحمل الوصف النصي الوحيد للفشل لأن الحالة بسيطة.
  /// Carries only the textual failure description because the state
  /// is simple.
  const ReferenceError({required this.message});

  /// تعتمد المساواة على الرسالة نفسها.
  /// Equality depends on the message itself.
  @override
  List<Object?> get props => [message];
}
