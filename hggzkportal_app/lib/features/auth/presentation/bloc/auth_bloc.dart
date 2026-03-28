import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/register_owner_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/upload_user_image_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/delete_owner_account_usecase.dart';
import '../../domain/usecases/portal_social_login_usecase.dart';
import '../../domain/usecases/complete_owner_profile_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../../services/notification_service.dart';
import '../../../../injection_container.dart' as di;

/// العربية: يدير كل مسارات المصادقة من تسجيل الدخول إلى تحديث الملف
/// الشخصي وإكمال ملف المالك وحذف الحساب، مع تنسيق الإشعارات المرافقة.
/// Orchestrates the full authentication surface from login to profile updates, owner onboarding, and account deletion while keeping notification side effects coordinated.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// العربية: يستخدمه البلوك لتشغيل تدفق تسجيل الدخول.
  /// Used by the bloc to execute the login flow.
  final LoginUseCase loginUseCase;

  /// العربية: ينفذ إنشاء حساب المستخدم العادي.
  /// Executes standard user registration.
  final RegisterUseCase registerUseCase;

  /// العربية: ينفذ إنشاء حساب مالك العقار.
  /// Executes property-owner registration.
  final RegisterOwnerUseCase registerOwnerUseCase;

  /// العربية: يعالج تسجيل الدخول عبر المزودات الاجتماعية.
  /// Receives social-provider sign-in.
  final PortalSocialLoginUseCase portalSocialLoginUseCase;

  /// العربية: يكمل ملف مالك العقار بعد التسجيل الأولي.
  /// Completes the owner profile after the initial registration.
  final CompleteOwnerProfileUseCase completeOwnerProfileUseCase;

  /// العربية: ينهي الجلسة الحالية.
  /// Ends the current session.
  final LogoutUseCase logoutUseCase;

  /// العربية: يرسل طلب إعادة تعيين كلمة المرور.
  /// Sends password-reset requests.
  final ResetPasswordUseCase resetPasswordUseCase;

  /// العربية: يفحص ما إذا كانت الجلسة ما زالت صالحة عند الإقلاع.
  /// Checks whether the session is still valid at startup.
  final CheckAuthStatusUseCase checkAuthStatusUseCase;

  /// العربية: يجلب المستخدم الحالي بعد التأكد من الجلسة.
  /// Fetches the current user after session validation.
  final GetCurrentUserUseCase getCurrentUserUseCase;

  /// العربية: يحدّث بيانات الملف الشخصي أو بيانات المالك.
  /// Updates profile or owner details.
  final UpdateProfileUseCase updateProfileUseCase;

  /// العربية: يرفع صورة الملف الشخصي.
  /// Uploads the profile image.
  final UploadUserImageUseCase uploadUserImageUseCase;

  /// العربية: يغيّر كلمة المرور الحالية.
  /// Changes the current password.
  final ChangePasswordUseCase changePasswordUseCase;

  /// العربية: يحذف حساب المالك عند الطلب.
  /// Deletes the owner account when requested.
  final DeleteOwnerAccountUseCase deleteOwnerAccountUseCase;

  /// العربية: يربط الاعتمادات اللازمة لتشغيل كل مسارات المصادقة من مكان واحد.
  /// Wires the dependencies needed to run every auth flow from one place.
  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.registerOwnerUseCase,
    required this.portalSocialLoginUseCase,
    required this.completeOwnerProfileUseCase,
    required this.logoutUseCase,
    required this.resetPasswordUseCase,
    required this.checkAuthStatusUseCase,
    required this.getCurrentUserUseCase,
    required this.updateProfileUseCase,
    required this.uploadUserImageUseCase,
    required this.changePasswordUseCase,
    required this.deleteOwnerAccountUseCase,
  }) : super(const AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<LoginWithRefreshTokenEvent>(_onLoginWithRefreshToken);
    on<RegisterEvent>(_onRegister);
    on<RegisterOwnerWithPropertyEvent>(_onRegisterOwner);
    on<LogoutEvent>(_onLogout);
    on<ResetPasswordEvent>(_onResetPassword);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UploadProfileImageEvent>(_onUploadProfileImage);
    on<ChangePasswordEvent>(_onChangePassword);
    on<DeleteOwnerAccountEvent>(_onDeleteOwnerAccount);
    on<SocialLoginEvent>(_onSocialLogin);
    on<CompleteOwnerProfileEvent>(_onCompleteOwnerProfile);
  }

  /// العربية: يتحقق من الجلسة المخزنة ويعيد ضبط الحالة وفق ما إذا كان
  /// المستخدم ما يزال مسجلاً أم لا.
  /// Verifies the stored session and resets state based on whether the user is still signed in.
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await checkAuthStatusUseCase(NoParams());

    await result.fold(
      (failure) async => emit(const AuthUnauthenticated()),
      (isAuthenticated) async {
        if (isAuthenticated) {
          final userResult = await getCurrentUserUseCase(NoParams());
          await userResult.fold(
            (failure) async => emit(const AuthUnauthenticated()),
            (user) async {
              emit(AuthAuthenticated(user: user));
              // Ensure FCM topics match current user after auto-login
              try {
                await di.sl<NotificationService>().refreshUserSubscriptions();
              } catch (_) {}
            },
          );
        } else {
          emit(const AuthUnauthenticated());
        }
      },
    );
  }

  /// العربية: يمرر بيانات الدخول إلى use case ثم ينعكس النجاح أو الفشل في
  /// الحالات المناسبة.
  /// Passes login credentials to the use case and reflects success or failure through the appropriate states.
  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final params = LoginParams(
      emailOrPhone: event.emailOrPhone,
      password: event.password,
      rememberMe: event.rememberMe,
    );

    final result = await loginUseCase(params);

    await result.fold(
      (failure) async =>
          emit(AuthError(message: _mapFailureToMessage(failure))),
      (authResponse) async {
        emit(AuthLoginSuccess(user: authResponse.user));
        emit(AuthAuthenticated(user: authResponse.user));
        // After login, (re)register FCM and subscribe to proper topics
        try {
          await di.sl<NotificationService>().refreshUserSubscriptions();
        } catch (_) {}
      },
    );
  }

  /// العربية: ينشئ حساب المستخدم العادي ثم يحدد ما إذا كان ينبغي اعتبار
  /// الجلسة جاهزة مباشرة.
  /// Builds the standard user account and decides whether the session should be treated as ready immediately.
  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final params = RegisterParams(
      name: event.name,
      email: event.email,
      phone: event.phone,
      password: event.password,
      passwordConfirmation: event.passwordConfirmation,
    );

    final result = await registerUseCase(params);

    await result.fold(
      (failure) async =>
          emit(AuthError(message: _mapFailureToMessage(failure))),
      (authResponse) async {
        emit(AuthRegistrationSuccess(user: authResponse.user));
        // لا نعتبره مصادق بالكامل قبل التحقق من البريد
        emit(AuthAuthenticated(user: authResponse.user));
      },
    );
  }

  /// العربية: يسجل مالك العقار مع بيانات المنشأة المرتبطة به ثم ينعكس
  /// النجاح إلى الواجهة.
  /// Registers a property owner together with the linked property data and then reflects the result in the UI.
  Future<void> _onRegisterOwner(
    RegisterOwnerWithPropertyEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final params = RegisterOwnerParams(
      name: event.name,
      email: event.email,
      phone: event.phone,
      password: event.password,
      propertyTypeId: event.propertyTypeId,
      propertyName: event.propertyName,
      city: event.city,
      address: event.address,
      latitude: event.latitude,
      longitude: event.longitude,
      starRating: event.starRating,
      description: event.description,
      currency: event.currency,
      walletAccounts: event.walletAccounts,
    );

    final result = await registerOwnerUseCase(params);

    await result.fold(
      (failure) async =>
          emit(AuthError(message: _mapFailureToMessage(failure))),
      (authResponse) async {
        emit(AuthRegistrationSuccess(user: authResponse.user));
        // المالك مصادق بعد التسجيل مباشرة
        emit(AuthAuthenticated(user: authResponse.user));
      },
    );
  }

  /// العربية: ينهي الجلسة ثم يزيل اشتراكات الإشعارات المرتبطة بالمستخدم.
  /// Ends the session and removes the user's notification subscriptions.
  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await logoutUseCase(NoParams());

    await result.fold(
      (failure) async =>
          emit(AuthError(message: _mapFailureToMessage(failure))),
      (_) async {
        // Unregister FCM and unsubscribe topics
        try {
          await di.sl<NotificationService>().unregisterFcmToken();
        } catch (_) {}
        emit(const AuthLogoutSuccess());
        emit(const AuthUnauthenticated());
      },
    );
  }

  /// العربية: يطلب إعادة تعيين كلمة المرور ثم يعرض النتيجة المناسبة.
  /// Requests a password reset and then surfaces the appropriate result.
  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final params = ResetPasswordParams(
      emailOrPhone: event.emailOrPhone,
    );

    final result = await resetPasswordUseCase(params);

    await result.fold(
      (failure) async =>
          emit(AuthError(message: _mapFailureToMessage(failure))),
      (_) async => emit(const AuthPasswordResetSent(
        message: 'تم إرسال تعليمات إعادة تعيين كلمة المرور',
      )),
    );
  }

  /// العربية: يرسل بيانات التحديث إلى use case ثم يعيد جلب المستخدم
  /// الحالي لإبقاء الحالة متزامنة.
  /// Sends the update payload to the use case and then re-fetches the current user to keep state in sync.
  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final params = UpdateProfileParams(
      name: event.name,
      email: event.email,
      phone: event.phone,
      walletAccounts: event.walletAccounts,
      propertyId: event.propertyId,
      propertyName: event.propertyName,
      propertyAddress: event.propertyAddress,
      propertyCity: event.propertyCity,
      propertyShortDescription: event.propertyShortDescription,
      propertyDescription: event.propertyDescription,
      propertyCurrency: event.propertyCurrency,
      propertyStarRating: event.propertyStarRating,
      propertyLatitude: event.propertyLatitude,
      propertyLongitude: event.propertyLongitude,
    );

    final result = await updateProfileUseCase(params);

    await result.fold(
      (failure) async =>
          emit(AuthError(message: _mapFailureToMessage(failure))),
      (_) async {
        final userResult = await getCurrentUserUseCase(NoParams());
        await userResult.fold(
          (failure) async =>
              emit(AuthError(message: _mapFailureToMessage(failure))),
          (user) async {
            emit(AuthProfileUpdateSuccess(user: user));
            emit(AuthAuthenticated(user: user));
          },
        );
      },
    );
  }

  /// العربية: يرفع صورة الملف الشخصي ثم يعيد المستخدم المحدث.
  /// Uploads the profile image and then returns the updated user.
  Future<void> _onUploadProfileImage(
    UploadProfileImageEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final params = UploadUserImageParams(
      imagePath: event.imagePath,
    );

    final result = await uploadUserImageUseCase(params);

    await result.fold(
      (failure) async =>
          emit(AuthError(message: _mapFailureToMessage(failure))),
      (user) async {
        emit(AuthProfileImageUploadSuccess(user: user));
        emit(AuthAuthenticated(user: user));
      },
    );
  }

  /// العربية: يغيّر كلمة المرور ويعلن النجاح أو الفشل مباشرة.
  /// Changes the password and reports success or failure immediately.
  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final params = ChangePasswordParams(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
      newPasswordConfirmation: event.newPasswordConfirmation,
    );

    final result = await changePasswordUseCase(params);

    await result.fold(
      (failure) async =>
          emit(AuthError(message: _mapFailureToMessage(failure))),
      (_) async => emit(const AuthPasswordChangeSuccess()),
    );
  }

  /// العربية: يحذف حساب المالك ثم يفصل التوكنات والاشتراكات المرتبطة به.
  /// Deletes the owner account and then disconnects the related tokens and subscriptions.
  Future<void> _onDeleteOwnerAccount(
    DeleteOwnerAccountEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final params = DeleteOwnerAccountParams(
      password: event.password,
      socialProvider: event.socialProvider,
      socialToken: event.socialToken,
      socialNonce: event.socialNonce,
      reason: event.reason,
    );

    final result = await deleteOwnerAccountUseCase(params);

    await result.fold(
      (failure) async =>
          emit(AuthError(message: _mapFailureToMessage(failure))),
      (_) async {
        try {
          await di.sl<NotificationService>().unregisterFcmToken();
        } catch (_) {}
        emit(const AuthAccountDeleteSuccess());
        emit(const AuthUnauthenticated());
      },
    );
  }

  /// العربية: يعالج تسجيل الدخول الاجتماعي ثم يزامن الاشتراكات والإشعارات.
  /// Receives social login and then syncs subscriptions and notifications.
  Future<void> _onSocialLogin(
    SocialLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final params = PortalSocialLoginParams(
      provider: event.provider.name,
      token: event.token,
      nonce: event.nonce,
      name: event.name,
    );

    final result = await portalSocialLoginUseCase(params);

    await result.fold(
      (failure) async =>
          emit(AuthError(message: _mapFailureToMessage(failure))),
      (authResponse) async {
        emit(AuthLoginSuccess(user: authResponse.user));
        emit(AuthAuthenticated(user: authResponse.user));
        try {
          await di.sl<NotificationService>().refreshUserSubscriptions();
        } catch (_) {}
      },
    );
  }

  /// العربية: يكمل ملف المالك ثم يثبت الجلسة المحدثة.
  /// Completes the owner profile and then promotes the updated session.
  Future<void> _onCompleteOwnerProfile(
    CompleteOwnerProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final params = CompleteOwnerProfileParams(
      name: event.name,
      phone: event.phone,
      propertyTypeId: event.propertyTypeId,
      propertyName: event.propertyName,
      city: event.city,
      address: event.address,
      latitude: event.latitude,
      longitude: event.longitude,
      starRating: event.starRating,
      description: event.description,
      currency: event.currency,
      walletAccounts: event.walletAccounts,
    );

    final result = await completeOwnerProfileUseCase(params);

    await result.fold(
      (failure) async =>
          emit(AuthError(message: _mapFailureToMessage(failure))),
      (authResponse) async {
        emit(AuthLoginSuccess(user: authResponse.user));
        emit(AuthAuthenticated(user: authResponse.user));
        try {
          await di.sl<NotificationService>().refreshUserSubscriptions();
        } catch (_) {}
      },
    );
  }

  /// العربية: يعيد إنشاء الجلسة اعتمادًا على refresh token محفوظ.
  /// Rebuilds the session from a stored refresh token.
  Future<void> _onLoginWithRefreshToken(
    LoginWithRefreshTokenEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final authRepository = di.sl<AuthRepository>();
    final result = await authRepository.refreshToken(
      refreshToken: event.refreshToken,
    );

    await result.fold(
      (failure) async =>
          emit(AuthError(message: _mapFailureToMessage(failure))),
      (authResponse) async {
        emit(AuthLoginSuccess(user: authResponse.user));
        emit(AuthAuthenticated(user: authResponse.user));
        try {
          await di.sl<NotificationService>().refreshUserSubscriptions();
        } catch (_) {}
      },
    );
  }

  /// العربية: يحول أنواع الأخطاء التقنية إلى رسائل مفهومة للمستخدم.
  /// Converts technical failure types into user-readable messages.
  String _mapFailureToMessage(Failure failure) {
    // إذا كانت رسالة الخطأ موجودة ومفيدة، استخدمها مباشرة
    if (failure.message.isNotEmpty &&
        failure.message != 'Server failure' &&
        failure.message != 'An unexpected error occurred') {
      return failure.message;
    }

    if (failure is ServerFailure) {
      if (failure.message.isNotEmpty && failure.message != 'Server failure') {
        return failure.message;
      }
      return 'حدث خطأ في الخادم. يرجى المحاولة مرة أخرى لاحقاً';
    }
    if (failure is CacheFailure) {
      return 'حدث خطأ في التخزين المحلي';
    }
    if (failure is NetworkFailure) {
      return failure.message.isNotEmpty && failure.message != 'Network failure'
          ? failure.message
          : 'يرجى التحقق من اتصالك بالإنترنت';
    }
    if (failure is ValidationFailure) {
      return failure.message;
    }
    if (failure is ValidationFailureWithErrors) {
      return failure.message;
    }
    if (failure is ApiFailure) {
      return failure.message;
    }
    if (failure is AuthenticationFailure) {
      return failure.message.isNotEmpty &&
              failure.message != 'Authentication failure'
          ? failure.message
          : 'بيانات الدخول غير صحيحة';
    }
    if (failure is UnauthorizedFailure) {
      return failure.message.isNotEmpty &&
              failure.message != 'Unauthorized access'
          ? failure.message
          : 'غير مصرح لك بالقيام بهذا الإجراء';
    }
    if (failure is SessionExpiredFailure) {
      return 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى';
    }
    if (failure is PermissionDeniedFailure) {
      return failure.message.isNotEmpty &&
              failure.message != 'Permission denied'
          ? failure.message
          : 'ليس لديك صلاحية للقيام بهذا الإجراء';
    }
    return failure.message.isNotEmpty
        ? failure.message
        : 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى';
  }
}
