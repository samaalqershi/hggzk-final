import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/favorite.dart';
import '../../domain/usecases/get_favorites_usecase.dart';
import '../../domain/usecases/add_to_favorites_usecase.dart';
import '../../domain/usecases/remove_from_favorites_usecase.dart';
import '../../domain/usecases/check_favorite_status_usecase.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

/// Keeps the favorites list, add/remove actions, and membership checks in one
/// predictable stream.
/// يحافظ على قائمة المفضلة وأفعال الإضافة والإزالة وفحص العضوية في مسار
/// واحد متوقع.
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  /// Loads the current favorites collection from the domain layer.
  /// يجلب مجموعة المفضلة الحالية من طبقة المجال.
  final GetFavoritesUseCase getFavoritesUseCase;

  /// Adds a property to the favorites collection.
  /// يضيف عقارًا إلى مجموعة المفضلة.
  final AddToFavoritesUseCase addToFavoritesUseCase;

  /// Removes a property from the favorites collection.
  /// يزيل عقارًا من مجموعة المفضلة.
  final RemoveFromFavoritesUseCase removeFromFavoritesUseCase;

  /// Checks whether a property is already in the user list.
  /// يتحقق مما إذا كان العقار موجودًا في قائمة المستخدم.
  final CheckFavoriteStatusUseCase checkFavoriteStatusUseCase;

  /// Builds the bloc that powers favorites screens and membership updates.
  /// يبني الـ bloc الذي يشغّل شاشات المفضلة وتحديثات العضوية.
  FavoritesBloc({
    required this.getFavoritesUseCase,
    required this.addToFavoritesUseCase,
    required this.removeFromFavoritesUseCase,
    required this.checkFavoriteStatusUseCase,
  }) : super(const FavoritesInitial()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<AddToFavoritesEvent>(_onAddToFavorites);
    on<RemoveFromFavoritesEvent>(_onRemoveFromFavorites);
    on<CheckFavoriteStatusEvent>(_onCheckFavoriteStatus);
    on<RefreshFavoritesEvent>(_onRefreshFavorites);
    on<ClearFavoritesEvent>(_onClearFavorites);
  }

  /// Loads the latest favorites list for initial screen rendering.
  /// يحمل أحدث قائمة مفضلة لعرض الشاشة الأولية.
  Future<void> _onLoadFavorites(
    LoadFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(const FavoritesLoading());

    final result = await getFavoritesUseCase(NoParams());

    await result.fold(
      (failure) async =>
          emit(FavoritesError(message: _mapFailureToMessage(failure))),
      (favorites) async => emit(FavoritesLoaded(favorites: favorites)),
    );
  }

  /// Adds a property and refreshes the list so the UI stays in sync.
  /// يضيف عقارًا ثم يحدّث القائمة كي تبقى الواجهة متزامنة.
  Future<void> _onAddToFavorites(
    AddToFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(const FavoritesLoading());

    final params = AddToFavoritesParams(
      propertyId: event.propertyId,
      userId: event.userId,
    );

    final result = await addToFavoritesUseCase(params);

    await result.fold(
      (failure) async =>
          emit(FavoritesError(message: _mapFailureToMessage(failure))),
      (favorite) async {
        // Reload favorites after adding
        final favoritesResult = await getFavoritesUseCase(NoParams());
        await favoritesResult.fold(
          (failure) async =>
              emit(FavoritesError(message: _mapFailureToMessage(failure))),
          (favorites) async => emit(FavoritesLoaded(favorites: favorites)),
        );
      },
    );
  }

  /// Removes a property and reloads the list to reflect the change.
  /// يزيل عقارًا ثم يعيد تحميل القائمة لتعكس التغيير.
  Future<void> _onRemoveFromFavorites(
    RemoveFromFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(const FavoritesLoading());

    final params = RemoveFromFavoritesParams(
      propertyId: event.propertyId,
      userId: event.userId,
    );

    final result = await removeFromFavoritesUseCase(params);

    await result.fold(
      (failure) async =>
          emit(FavoritesError(message: _mapFailureToMessage(failure))),
      (_) async {
        // Reload favorites after removing
        final favoritesResult = await getFavoritesUseCase(NoParams());
        await favoritesResult.fold(
          (failure) async =>
              emit(FavoritesError(message: _mapFailureToMessage(failure))),
          (favorites) async => emit(FavoritesLoaded(favorites: favorites)),
        );
      },
    );
  }

  /// Queries whether a property is already marked as favorite.
  /// يستعلم إن كان العقار مميزًا كمفضلة بالفعل.
  Future<void> _onCheckFavoriteStatus(
    CheckFavoriteStatusEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    final params = CheckFavoriteStatusParams(
      propertyId: event.propertyId,
      userId: event.userId,
    );

    final result = await checkFavoriteStatusUseCase(params);

    await result.fold(
      (failure) async =>
          emit(FavoritesError(message: _mapFailureToMessage(failure))),
      (isFavorite) async => emit(FavoriteStatusChecked(isFavorite: isFavorite)),
    );
  }

  /// Forces a fresh favorites load after user-driven refresh actions.
  /// يفرض تحميلًا جديدًا للمفضلة بعد إجراءات التحديث من المستخدم.
  Future<void> _onRefreshFavorites(
    RefreshFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(const FavoritesLoading());

    final result = await getFavoritesUseCase(NoParams());

    await result.fold(
      (failure) async =>
          emit(FavoritesError(message: _mapFailureToMessage(failure))),
      (favorites) async => emit(FavoritesLoaded(favorites: favorites)),
    );
  }

  /// Resets the bloc to its empty initial state.
  /// يعيد الـ bloc إلى حالته الابتدائية الفارغة.
  Future<void> _onClearFavorites(
    ClearFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(const FavoritesInitial());
  }

  /// Translates domain failures into user-facing error text.
  /// يترجم فشل طبقة المجال إلى رسالة خطأ قابلة للعرض.
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'حدث خطأ في الخادم. يرجى المحاولة مرة أخرى لاحقاً';
      case CacheFailure:
        return 'حدث خطأ في التخزين المحلي';
      case NetworkFailure:
        return 'يرجى التحقق من اتصالك بالإنترنت';
      case ValidationFailure:
        return (failure as ValidationFailure).message;
      case AuthenticationFailure:
        return 'يجب تسجيل الدخول لإضافة المفضلة';
      case UnauthorizedFailure:
        return 'غير مصرح لك بالقيام بهذا الإجراء';
      default:
        return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى';
    }
  }
}
