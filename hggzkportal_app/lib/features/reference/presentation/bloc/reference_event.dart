// lib/features/reference/presentation/bloc/reference_event.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/currency.dart';

/// العربية: يجمع أحداث البيانات المرجعية في مسار واحد حتى تشترك المدن
/// والعملات والاختيارات المحفوظة في نفس منطق التحميل والتحديث.
/// Groups reference-data actions in one place so cities, currencies, and persisted selections share the same loading and refresh logic.
abstract class ReferenceEvent extends Equatable {
  /// العربية: تبقى الأحداث غير قابلة للتغيير كي يعتمد الـ BLoC على بياناتها فقط عند المقارنة.
  /// Events remain immutable so the BLoC can rely on event data alone when comparing transitions.
  const ReferenceEvent();

  /// العربية: لا يحمل الأساس حقولًا مشتركة، لذلك تبقى المساواة هنا على مستوى النوع فقط.
  /// The base type has no shared fields, so equality stays type-based only.
  @override
  List<Object?> get props => [];
}

/// يطلب قائمة المدن، مع خيار التحديث القسري عندما يريد المطور
/// تجاوز الكاش.
/// Requests the city list, with an optional forced refresh when the
/// caller wants to bypass cache.
class LoadCitiesEvent extends ReferenceEvent {
  /// العربية: يحدد ما إذا كان ينبغي تجاهل الكاش المحلي وإعادة الجلب من المصدر.
  /// Indicates whether local cache should be ignored and data should be fetched again.
  final bool forceRefresh;

  /// العربية: يحمل فقط إشارة تجاوز الكاش لأن بقية السلوك ثابت.
  /// Carries only the cache-bypass flag because the rest of the behavior is fixed.
  const LoadCitiesEvent({this.forceRefresh = false});

  /// يعتمد هذا الحدث على خيار التحديث القسري فقط.
  /// This event depends only on the forced-refresh flag.
  @override
  List<Object?> get props => [forceRefresh];
}

/// يطلب قائمة العملات بنفس منطق الكاش الخاص بالمدن.
/// Requests the currency list using the same cache-aware pattern as
/// cities.
class LoadCurrenciesEvent extends ReferenceEvent {
  /// العربية: يحدد ما إذا كان يجب تجاوز البيانات المحفوظة محليًا.
  /// Indicates whether locally cached data should be skipped.
  final bool forceRefresh;

  /// العربية: يحمل فقط إشارة التحديث القسري.
  /// Carries only the forced-refresh signal.
  const LoadCurrenciesEvent({this.forceRefresh = false});

  /// تعتمد المقارنة على إشارة التحديث فقط.
  /// Equality depends only on the refresh flag.
  @override
  List<Object?> get props => [forceRefresh];
}

/// يطلب تحميل المدن والعملات معًا عندما تحتاج الواجهة إلى نقطة
/// بداية كاملة بدل تحميل كل نوع بشكل منفصل.
/// Requests both cities and currencies together when the UI needs a
/// complete starting point instead of loading each type separately.
class LoadReferenceDataEvent extends ReferenceEvent {
  /// هذا الحدث مجرد إشارة لجلب البيانات المرجعية دفعة واحدة.
  /// This event is only a signal to fetch the reference data in one
  /// pass.
  const LoadReferenceDataEvent();
}

/// يسجل اختيار مدينة واحدة حتى يُحفظ ويعود للواجهة.
/// Records a single city selection so it can be stored and reflected
/// back in the UI.
class SelectCityEvent extends ReferenceEvent {
  /// المدينة التي اختارها المستخدم.
  /// The city chosen by the user.
  final City city;

  /// يحمل المدينة المختارة فقط لأن الحفظ يعتمد عليها مباشرة.
  /// Carries only the selected city because persistence depends on it
  /// directly.
  const SelectCityEvent({required this.city});

  /// تعتمد المساواة على المدينة المختارة نفسها.
  /// Equality depends on the selected city itself.
  @override
  List<Object?> get props => [city];
}

/// يسجل اختيار العملة كي تُستخدم في التنسيق والتفضيلات.
/// Records the selected currency so formatting and preferences can
/// reuse it.
class SelectCurrencyEvent extends ReferenceEvent {
  /// العملة التي اختارها المستخدم.
  /// The currency chosen by the user.
  final Currency currency;

  /// يحمل العملة المختارة فقط لأن بقية المعلومات لا تغيّر نتيجة
  /// الإعداد.
  /// Carries only the selected currency because the rest of the
  /// fields do not change the setup outcome.
  const SelectCurrencyEvent({required this.currency});

  /// تعتمد المقارنة على العملة المختارة.
  /// Equality depends on the chosen currency.
  @override
  List<Object?> get props => [currency];
}

/// يبحث داخل المدن المحفوظة محليًا لتغذية قوائم الاختيار الفوري.
/// Searches the cached city list to power instant selection UIs.
class SearchCitiesEvent extends ReferenceEvent {
  /// نص البحث الذي يحدد النتائج المطابقة.
  /// The search text that determines matching results.
  final String query;

  /// يحمل نص البحث فقط لأن التصفية محلية.
  /// Carries only the search string because filtering is local.
  const SearchCitiesEvent({required this.query});

  /// يعتمد الحدث على نص البحث وحده.
  /// The event depends only on the search string.
  @override
  List<Object?> get props => [query];
}

/// يبحث داخل العملات المحفوظة ليبقى التبديل بينها سريعًا.
/// Searches the cached currency list so switching between them stays
/// fast.
class SearchCurrenciesEvent extends ReferenceEvent {
  /// كلمة البحث أو جزء منها.
  /// The search term or a fragment of it.
  final String query;

  /// يحمل نص البحث فقط لأن النتائج تُفلتر محليًا.
  /// Carries only the query because the results are filtered locally.
  const SearchCurrenciesEvent({required this.query});

  /// تعتمد المقارنة على نص البحث.
  /// Equality depends on the query text.
  @override
  List<Object?> get props => [query];
}

/// يعيد المدينة المحفوظة سابقًا كي تظهر الواجهة الاختيار الحالي.
/// Rehydrates the previously saved city so the UI can show the current
/// selection.
class LoadSelectedCityEvent extends ReferenceEvent {
  /// لا يحمل حقولًا لأنه فقط يطلب القراءة من التخزين المحلي.
  /// No fields are needed because it only requests a local read.
  const LoadSelectedCityEvent();
}

/// يعيد العملة المحفوظة حتى تظل التفضيلات متسقة بعد إعادة الفتح.
/// Rehydrates the stored currency so preferences stay consistent
/// after relaunch.
class LoadSelectedCurrencyEvent extends ReferenceEvent {
  /// مجرد إشارة للقراءة من التخزين المحلي.
  /// Just a signal to read from local storage.
  const LoadSelectedCurrencyEvent();
}

/// يمسح الاختيار المحفوظ عندما يحتاج التدفق إلى إعادة ضبط كامل.
/// Clears the persisted selections when the flow needs a full reset.
class ClearSelectionEvent extends ReferenceEvent {
  /// يحدد ما إذا كان يجب مسح المدينة.
  /// Indicates whether the city should be cleared.
  final bool clearCity;

  /// يحدد ما إذا كان يجب مسح العملة.
  /// Indicates whether the currency should be cleared.
  final bool clearCurrency;

  /// يسمح بمسح أحد الاختيارين أو كليهما دون تغيير بنية الحدث.
  /// Allows clearing one or both selections without changing the
  /// event shape.
  const ClearSelectionEvent({
    this.clearCity = true,
    this.clearCurrency = true,
  });

  /// تعتمد المقارنة على مؤشري المسح معًا.
  /// Equality depends on both clear flags.
  @override
  List<Object?> get props => [clearCity, clearCurrency];
}

/// يجبر إعادة جلب البيانات المرجعية حتى لو كان الكاش موجودًا.
/// Forces a reload of the reference data even when cache exists.
class RefreshReferenceDataEvent extends ReferenceEvent {
  /// لا يحمل حقولًا لأن الغرض هو التحديث القسري فقط.
  /// No fields are needed because the purpose is forced refresh only.
  const RefreshReferenceDataEvent();
}
