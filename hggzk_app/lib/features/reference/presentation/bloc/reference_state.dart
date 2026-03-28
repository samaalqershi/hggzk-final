// lib/features/reference/presentation/bloc/reference_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/currency.dart';

/// Base state for reference data flows. The bloc emits cities, currencies, or
/// combined reference payloads so dependent screens can stay consistent with
/// the selected locale context.
/// الحالة الأساسية لتدفقات البيانات المرجعية. يصدر الـ bloc المدن أو العملات
/// أو الحمولات المرجعية المجمعة حتى تبقى الشاشات التابعة متسقة مع سياق
/// المحلية المختارة.
abstract class ReferenceState extends Equatable {
  /// Builds the shared base for all reference states.
  /// ينشئ الأساس المشترك لكل حالات البيانات المرجعية.
  const ReferenceState();

  /// Reference states are compared by content so value-only updates do not
  /// trigger unnecessary rebuilds.
  /// تُقارن الحالات المرجعية بالمحتوى حتى لا تؤدي التحديثات القيمية وحدها
  /// إلى إعادة بناء غير ضرورية.
  @override
  List<Object?> get props => [];
}

// الحالة الأولية
/// Default idle state before reference data is requested.
/// حالة الخمول الافتراضية قبل طلب البيانات المرجعية.
class ReferenceInitial extends ReferenceState {
  /// Builds the initial reference state.
  /// ينشئ حالة البيانات المرجعية الابتدائية.
  const ReferenceInitial();
}

// حالة التحميل
/// Emitted while the reference repository is loading cities or currencies.
/// تصدر أثناء تحميل المدن أو العملات من المستودع المرجعي.
class ReferenceLoading extends ReferenceState {
  /// Builds the loading state for reference data fetches.
  /// ينشئ حالة التحميل الخاصة بجلب البيانات المرجعية.
  const ReferenceLoading();
}

// حالة تحميل المدن بنجاح
/// Holds the available cities together with the current selection state used
/// by pickers and search screens.
/// تحتفظ بالمدن المتاحة مع حالة الاختيار الحالية التي تستخدمها النوافذ
/// المنبثقة وشاشات البحث.
class CitiesLoaded extends ReferenceState {
  /// Cities available to pick from.
  /// المدن المتاحة للاختيار.
  final List<City> cities;

  /// Currently selected city id or name, depending on the calling screen.
  /// معرّف المدينة أو اسمها المختار حاليًا بحسب الشاشة المستدعية.
  final String? selectedCity;

  /// True when the loaded list comes from a search result rather than a full
  /// reference catalog.
  /// تكون صحيحة عندما تأتي القائمة من نتيجة بحث لا من الكتالوج الكامل.
  final bool isSearchResult;

  /// Builds the city-loaded state used by pickers and filters.
  /// ينشئ حالة المدن المحملة التي تستخدمها أدوات الاختيار والفلاتر.
  const CitiesLoaded({
    required this.cities,
    this.selectedCity,
    this.isSearchResult = false,
  });

  /// City states are compared by list and selection so the picker only rebuilds
  /// when visible choices change.
  /// تُقارن حالات المدن بالقائمة والاختيار حتى لا تعيد أداة الاختيار البناء
  /// إلا عندما تتغير الخيارات الظاهرة.
  @override
  List<Object?> get props => [cities, selectedCity, isSearchResult];
}

// حالة تحميل العملات بنجاح
/// Holds the available currencies and current selection used by locale-aware
/// forms or search filters.
/// تحتفظ بالعملات المتاحة والاختيار الحالي المستخدم في النماذج أو فلاتر
/// البحث الحساسة للمحلية.
class CurrenciesLoaded extends ReferenceState {
  /// Currency options exposed to the UI.
  /// خيارات العملات المعروضة للواجهة.
  final List<Currency> currencies;

  /// Currently selected currency code or label.
  /// رمز العملة أو تسميتها المختارة حاليًا.
  final String? selectedCurrency;

  /// True when the currency list originates from search rather than the full
  /// reference set.
  /// تكون صحيحة عندما تأتي قائمة العملات من البحث وليس من مجموعة المرجع
  /// الكاملة.
  final bool isSearchResult;

  /// Builds the currency-loaded state used by pricing and forms.
  /// ينشئ حالة العملات المحملة التي تستخدمها شاشات التسعير والنماذج.
  const CurrenciesLoaded({
    required this.currencies,
    this.selectedCurrency,
    this.isSearchResult = false,
  });

  /// Currency states are compared by payload so the UI responds only when the
  /// visible currency set changes.
  /// تُقارن حالات العملات بالحمولة حتى تتفاعل الواجهة فقط عند تغير مجموعة
  /// العملات الظاهرة.
  @override
  List<Object?> get props => [currencies, selectedCurrency, isSearchResult];
}

// حالة تحميل كل البيانات المرجعية
/// Holds both reference collections together when a screen needs cities and
/// currencies at the same time.
/// تحتفظ بالمجموعتين المرجعيتين معًا عندما تحتاج الشاشة إلى المدن والعملات
/// في الوقت نفسه.
class ReferenceDataLoaded extends ReferenceState {
  /// Available cities.
  /// المدن المتاحة.
  final List<City> cities;

  /// Available currencies.
  /// العملات المتاحة.
  final List<Currency> currencies;

  /// Current city selection.
  /// اختيار المدينة الحالي.
  final String? selectedCity;

  /// Current currency selection.
  /// اختيار العملة الحالي.
  final String? selectedCurrency;

  /// Builds the combined reference state used by screens that need both data
  /// sets together.
  /// ينشئ حالة المرجع المجمعة التي تستخدمها الشاشات التي تحتاج المجموعتين
  /// معًا.
  const ReferenceDataLoaded({
    required this.cities,
    required this.currencies,
    this.selectedCity,
    this.selectedCurrency,
  });

  /// Combined reference snapshots compare both lists and selections.
  /// تُقارن لقطات المرجع المجمعة بالقائمتين والاختيارات.
  @override
  List<Object?> get props =>
      [cities, currencies, selectedCity, selectedCurrency];
}

// حالة اختيار مدينة بنجاح
/// Emitted after a city has been chosen and the UI needs to react with a short
/// confirmation message.
/// تصدر بعد اختيار مدينة ويحتاج العرض إلى الرد برسالة تأكيد قصيرة.
class CitySelected extends ReferenceState {
  /// The city that was selected.
  /// المدينة التي تم اختيارها.
  final City city;

  /// Short message for success banners or snackbars.
  /// رسالة قصيرة لشرائط النجاح أو التنبيهات السريعة.
  final String message;

  /// Builds the city selection state.
  /// ينشئ حالة اختيار المدينة.
  const CitySelected({
    required this.city,
    required this.message,
  });

  /// Selection states are compared by the chosen entity and the message shown
  /// to the user.
  /// تُقارن حالات الاختيار بالعنصر المختار وبالرسالة المعروضة للمستخدم.
  @override
  List<Object?> get props => [city, message];
}

// حالة اختيار عملة بنجاح
/// Emitted after a currency is chosen and the UI needs the confirmation copy
/// to reflect that change.
/// تصدر بعد اختيار عملة وتحتاج الواجهة إلى رسالة تأكيد تعكس هذا التغيير.
class CurrencySelected extends ReferenceState {
  /// The currency that was selected.
  /// العملة التي تم اختيارها.
  final Currency currency;

  /// Short message for user feedback.
  /// رسالة قصيرة لتغذية المستخدم الراجعة.
  final String message;

  /// Builds the currency selection state.
  /// ينشئ حالة اختيار العملة.
  const CurrencySelected({
    required this.currency,
    required this.message,
  });

  /// Selection states are compared by the chosen currency and the confirmation
  /// message.
  /// تُقارن حالات الاختيار بالعملة المختارة وبرسالة التأكيد.
  @override
  List<Object?> get props => [currency, message];
}

// حالة الخطأ
/// Indicates that loading reference data failed and the UI should show the
/// provided message.
/// تشير إلى فشل تحميل البيانات المرجعية وأن الواجهة يجب أن تعرض الرسالة
/// الممررة.
class ReferenceError extends ReferenceState {
  /// User-facing explanation for the failure.
  /// شرح موجّه للمستخدم عن سبب الفشل.
  final String message;

  /// Builds the reference failure state.
  /// ينشئ حالة فشل البيانات المرجعية.
  const ReferenceError({required this.message});

  /// Error states are compared by message so repeated failures stay stable.
  /// تُقارن حالات الخطأ بالرسالة حتى تبقى الأخطاء المتكررة مستقرة.
  @override
  List<Object?> get props => [message];
}
