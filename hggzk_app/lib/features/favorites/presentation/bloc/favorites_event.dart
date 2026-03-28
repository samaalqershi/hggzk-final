import 'package:equatable/equatable.dart';

/// Base event for the favorites bloc. The concrete events load the collection,
/// mutate membership, or ask the repository to re-check a property's status.
/// الحدث الأساسي لـ bloc المفضلة. الأحداث المشتقة تحمل المجموعة أو تغيّر
/// العضوية أو تطلب من المستودع إعادة فحص حالة عقار.
abstract class FavoritesEvent extends Equatable {
  /// Forms the shared base so list loads, additions, removals, and refreshes
  /// can be handled as one event stream.
  /// يشكّل الأساس المشترك كي تُعالج التحميلات والإضافات والإزالات والتحديثات
  /// ضمن مسار أحداث واحد.
  const FavoritesEvent();

  /// Favorites events stay deterministic by comparing only the actionable
  /// payload fields.
  /// تبقى أحداث المفضلة حتمية لأن المقارنة تعتمد فقط على الحقول المؤثرة.
  @override
  List<Object?> get props => [];
}

/// Loads the current user's favorites collection from the repository.
/// يحمل مجموعة مفضلة المستخدم الحالية من المستودع.
class LoadFavoritesEvent extends FavoritesEvent {
  /// Requests the latest favorites list for the active user.
  /// يطلب أحدث قائمة مفضلة للمستخدم الحالي.
  const LoadFavoritesEvent();
}

/// Adds one property to the current user's favorites list.
/// يضيف عقارًا واحدًا إلى قائمة المفضلة للمستخدم الحالي.
class AddToFavoritesEvent extends FavoritesEvent {
  /// Property being added.
  /// العقار الذي تتم إضافته.
  final String propertyId;

  /// User who owns the favorites list.
  /// المستخدم مالك قائمة المفضلة.
  final String userId;

  /// Adds a property to the favorites store for the specified user.
  /// يضيف عقارًا إلى مخزن المفضلة للمستخدم المحدد.
  const AddToFavoritesEvent({
    required this.propertyId,
    required this.userId,
  });

  /// Membership changes are compared by the target property and user.
  /// تُقارن تغييرات العضوية بالعقار المستهدف والمستخدم.
  @override
  List<Object?> get props => [propertyId, userId];
}

/// Removes one property from the current user's favorites list.
/// يزيل عقارًا واحدًا من قائمة المفضلة للمستخدم الحالي.
class RemoveFromFavoritesEvent extends FavoritesEvent {
  /// Property that should be removed from the favorites list.
  /// العقار الذي يجب حذفه من قائمة المفضلة.
  final String propertyId;

  /// User whose favorites list is being updated.
  /// المستخدم الذي تُحدّث قائمة مفضلته.
  final String userId;

  /// Removes a property from the favorites store for the specified user.
  /// يزيل عقارًا من مخزن المفضلة للمستخدم المحدد.
  const RemoveFromFavoritesEvent({
    required this.propertyId,
    required this.userId,
  });

  /// Removal requests are compared by the property and user they target.
  /// تُقارن طلبات الإزالة بالعقار والمستخدم اللذين تستهدفهما.
  @override
  List<Object?> get props => [propertyId, userId];
}

/// Checks whether a given property is already in the current favorites list.
/// يفحص ما إذا كان عقار معين موجودًا بالفعل في قائمة المفضلة الحالية.
class CheckFavoriteStatusEvent extends FavoritesEvent {
  /// Property whose favorite membership should be checked.
  /// العقار الذي يجب التحقق من عضويته في المفضلة.
  final String propertyId;

  /// User whose favorites list is being inspected.
  /// المستخدم الذي تُفحص قائمة مفضلته.
  final String userId;

  /// Asks the repository whether the property is already liked by the user.
  /// يسأل المستودع إن كان العقار مضافًا للمستخدم بالفعل.
  const CheckFavoriteStatusEvent({
    required this.propertyId,
    required this.userId,
  });

  /// Status checks are compared by property and user identity.
  /// تُقارن فحوصات الحالة بهوية العقار والمستخدم.
  @override
  List<Object?> get props => [propertyId, userId];
}

/// Re-queries the favorites list after a change elsewhere in the app.
/// يعيد استعلام قائمة المفضلة بعد تغيير حدث في مكان آخر من التطبيق.
class RefreshFavoritesEvent extends FavoritesEvent {
  /// Re-runs the load flow after an external change or pull-to-refresh.
  /// يعيد تنفيذ مسار التحميل بعد تغيير خارجي أو سحب للتحديث.
  const RefreshFavoritesEvent();
}

/// Clears any cached favorites data from the bloc state.
/// يمسح أي بيانات مفضلة مخزنة في حالة الـ bloc.
class ClearFavoritesEvent extends FavoritesEvent {
  /// Clears the bloc-held snapshot so the next screen render starts clean.
  /// يمسح اللقطة المحفوظة في الـ bloc كي يبدأ العرض التالي من حالة نظيفة.
  const ClearFavoritesEvent();
}
