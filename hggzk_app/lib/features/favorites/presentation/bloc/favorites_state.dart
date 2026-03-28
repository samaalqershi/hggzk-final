import 'package:equatable/equatable.dart';
import '../../domain/entities/favorite.dart';

/// Base state for the favorites feature. Concrete states carry the loaded
/// favorites list, status checks, or a user-facing failure message so the UI
/// can stay in sync with repository calls.
/// الحالة الأساسية لميزة المفضلة. الحالات المشتقة تنقل قائمة المفضلة المحملة
/// أو نتيجة التحقق من الحالة أو رسالة الخطأ ليبقى العرض متزامنًا مع طلبات
/// المستودع.
abstract class FavoritesState extends Equatable {
  /// Builds the shared base for every favorites state.
  /// ينشئ الأساس المشترك لكل حالات المفضلة.
  const FavoritesState();

  /// Favorites states are compared by content so the UI only rebuilds when
  /// the actual favorites data changes.
  /// تُقارن حالات المفضلة بالمحتوى حتى تعيد الواجهة البناء فقط عندما تتغير
  /// البيانات الفعلية.
  @override
  List<Object?> get props => [];
}

/// Idle state before the favorites collection has been loaded.
/// حالة الخمول قبل تحميل مجموعة المفضلة.
class FavoritesInitial extends FavoritesState {
  /// Builds the initial favorites state.
  /// ينشئ حالة المفضلة الابتدائية.
  const FavoritesInitial();
}

/// Emitted while the favorites repository is fetching the current list.
/// تصدر أثناء جلب قائمة المفضلة من المستودع.
class FavoritesLoading extends FavoritesState {
  /// Builds the loading state used during favorites fetches.
  /// ينشئ حالة التحميل المستخدمة أثناء جلب المفضلة.
  const FavoritesLoading();
}

/// Holds the visible favorites list after the repository returns successfully.
/// تحتفظ بقائمة المفضلة الظاهرة بعد نجاح الاسترجاع من المستودع.
class FavoritesLoaded extends FavoritesState {
  /// Current list of favorite properties shown in the UI.
  /// قائمة العقارات المفضلة الحالية المعروضة في الواجهة.
  final List<Favorite> favorites;

  /// Builds the loaded favorites state.
  /// ينشئ حالة المفضلة المحملة.
  const FavoritesLoaded({required this.favorites});

  /// Loaded states are compared by the list content so reorder or refresh
  /// events behave predictably.
  /// تُقارن الحالات المحملة بمحتوى القائمة حتى تتصرف إعادة الترتيب أو
  /// التحديث بشكل متوقع.
  @override
  List<Object?> get props => [favorites];
}

/// Holds the result of a one-off favorite membership check, typically used by
/// property cards or detail pages.
/// تحتفظ بنتيجة فحص وجود العنصر في المفضلة، وغالبًا ما تستخدمها بطاقات
/// العقارات أو صفحات التفاصيل.
class FavoriteStatusChecked extends FavoritesState {
  /// True when the current property is already in the favorites list.
  /// تكون صحيحة عندما يكون العقار الحالي موجودًا بالفعل في المفضلة.
  final bool isFavorite;

  /// Builds the status-check state used by a single card or detail view.
  /// ينشئ حالة فحص المفضلة المستخدمة من بطاقة أو صفحة تفاصيل واحدة.
  const FavoriteStatusChecked({required this.isFavorite});

  /// The bloc compares status checks by their boolean result.
  /// يقارن الـ bloc فحوصات الحالة بحسب القيمة المنطقية الناتجة.
  @override
  List<Object?> get props => [isFavorite];
}

/// Indicates that the favorites request failed and the UI should surface the
/// issue to the user.
/// تشير إلى فشل طلب المفضلة وأن الواجهة يجب أن تعرض المشكلة للمستخدم.
class FavoritesError extends FavoritesState {
  /// User-facing explanation for the favorites failure.
  /// رسالة توضيحية موجهة للمستخدم عن سبب الفشل.
  final String message;

  /// Builds the error state for favorites operations.
  /// ينشئ حالة الخطأ لعمليات المفضلة.
  const FavoritesError({required this.message});

  /// Error states are compared by message so repeated failures do not create
  /// unnecessary rebuilds.
  /// تُقارن حالات الخطأ بالرسالة حتى لا تولد الأخطاء المتكررة إعادة بناء
  /// غير ضرورية.
  @override
  List<Object?> get props => [message];
}
