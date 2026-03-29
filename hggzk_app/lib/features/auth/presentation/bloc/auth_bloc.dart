import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hggzk/core/localization/app_localizations.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/social_login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/upload_user_image_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:hggzk/app/dependency_injection/injection_container.dart' as di;

/// ينسّق عمليات المصادقة على مستوى الواجهة، من فحص الجلسة إلى تسجيل الدخول
/// والتسجيل وتحديث الملف الشخصي.
/// Coordinates presentation-layer authentication flows, from session checks to
/// login, registration, and profile updates.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// حالة الاستخدام الخاصة بتسجيل الدخول التقليدي.
  /// Use case dedicated to classic sign-in.
  final LoginUseCase loginUseCase;

  /// حالة الاستخدام الخاصة بإنشاء الحساب.
  /// Use case dedicated to registration.
  final RegisterUseCase registerUseCase;

  /// حالة الاستخدام الخاصة بإنهاء الجلسة.
  /// Use case responsible for logout.
  final LogoutUseCase logoutUseCase;

  /// حالة الاستخدام الخاصة بإعادة تعيين كلمة المرور.
  /// Use case that starts password recovery.
  final ResetPasswordUseCase resetPasswordUseCase;

  /// حالة الاستخدام الخاصة بفحص حالة الجلسة الحالية.
  /// Use case that checks the current session status.
  final CheckAuthStatusUseCase checkAuthStatusUseCase;

  /// حالة الاستخدام الخاصة بجلب ملف المستخدم الحالي.
  /// Use case that fetches the current user profile.
  final GetCurrentUserUseCase getCurrentUserUseCase;

  /// حالة الاستخدام الخاصة بتحديث الملف الشخصي.
  /// Use case that updates the user profile.
  final UpdateProfileUseCase updateProfileUseCase;

  /// حالة الاستخدام الخاصة برفع صورة الملف الشخصي.
  /// Use case that uploads a profile image.
  final UploadUserImageUseCase uploadUserImageUseCase;

  /// حالة الاستخدام الخاصة بتغيير كلمة المرور.
  /// Use case that changes the password.
  final ChangePasswordUseCase changePasswordUseCase;

  /// حالة الاستخدام الخاصة بحذف الحساب.
  /// Use case that deletes the account.
  final DeleteAccountUseCase deleteAccountUseCase;

  /// حالة الاستخدام الخاصة بالمصادقة الاجتماعية.
  /// Use case that handles social authentication.
  final SocialLoginUseCase socialLoginUseCase;

  /// ينشئ الـ bloc ويصل كل حدث بالمعالج الموافق له.
  /// Creates the bloc and wires each incoming event to its handler.
  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.resetPasswordUseCase,
    required this.checkAuthStatusUseCase,
    required this.getCurrentUserUseCase,
    required this.updateProfileUseCase,
    required this.uploadUserImageUseCase,
    required this.changePasswordUseCase,
    required this.deleteAccountUseCase,
    required this.socialLoginUseCase,
  }) : super(const AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<LoginWithRefreshTokenEvent>(_onLoginWithRefreshToken);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<ResetPasswordEvent>(_onResetPassword);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UploadProfileImageEvent>(_onUploadProfileImage);
    on<ChangePasswordEvent>(_onChangePassword);
    on<DeleteAccountEvent>(_onDeleteAccount);
    on<SocialLoginEvent>(_onSocialLogin);
  }
  Future<void> _onDeleteAccount(
    DeleteAccountEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final params = DeleteAccountParams(
      password: event.password,
      socialProvider: event.socialProvider,
      socialToken: event.socialToken,
      socialNonce: event.socialNonce,
      reason: event.reason,
    );

    final result = await deleteAccountUseCase(params);

    await result.fold(
      (failure) async =>
          emit(AuthError(message: _mapFailureToMessage(failure))),
      (_) async {
        emit(const AuthAccountDeleteSuccess());
        emit(const AuthUnauthenticated());
      },
    );
  }

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
            (user) async => emit(AuthAuthenticated(user: user)),
          );
        } else {
          emit(const AuthUnauthenticated());
        }
      },
    );
  }

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
      },
    );
  }

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
      },
    );
  }

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
        emit(AuthAuthenticated(user: authResponse.user));
      },
    );
  }

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
        emit(const AuthLogoutSuccess());
        emit(const AuthUnauthenticated());
      },
    );
  }

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
      (_) async => emit(AuthPasswordResetSent(
        message: AppLocalizations.translateSync('auth.forgot.successBody'),
      )),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final params = UpdateProfileParams(
      name: event.name,
      email: event.email,
      phone: event.phone,
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

  Future<void> _onSocialLogin(
    SocialLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final providerString = _mapProvider(event.provider);
    final params = SocialLoginParams(
      provider: providerString,
      token: event.token,
      nonce: event.nonce,
      name: event.name,
    );
    final result = await socialLoginUseCase(params);
    await result.fold(
      (failure) async =>
          emit(AuthError(message: _mapFailureToMessage(failure))),
      (authResponse) async {
        emit(AuthLoginSuccess(user: authResponse.user));
        emit(AuthAuthenticated(user: authResponse.user));
      },
    );
  }

  String _mapProvider(SocialLoginProvider provider) {
    switch (provider) {
      case SocialLoginProvider.google:
        return 'google';
      case SocialLoginProvider.facebook:
        return 'facebook';
      case SocialLoginProvider.apple:
        return 'apple';
    }
  }

  String _mapFailureToMessage(Failure failure) {
    final rawMessage = failure.rawMessage.trim();

    // إذا كانت رسالة الخطأ موجودة ومفيدة، استخدمها مباشرة
    if (failure.message.isNotEmpty &&
        rawMessage != AppLocalizations.translateSync('common.serverError') &&
        rawMessage !=
            AppLocalizations.translateSync('common.unexpectedError')) {
      return failure.message;
    }

    switch (failure.runtimeType) {
      case ServerFailure:
        final serverFailure = failure as ServerFailure;
        // استخدم رسالة الخطأ الفعلية إذا كانت موجودة
        if (serverFailure.message.isNotEmpty &&
            serverFailure.rawMessage !=
                AppLocalizations.translateSync('common.serverError')) {
          return serverFailure.message;
        }
        return AppLocalizations.translateSync('auth.errors.server');
      case CacheFailure:
        return AppLocalizations.translateSync('auth.errors.localStorage');
      case NetworkFailure:
        return failure.message.isNotEmpty &&
                rawMessage !=
                    AppLocalizations.translateSync('common.noInternet')
            ? failure.message
            : AppLocalizations.translateSync('auth.errors.network');
      case ValidationFailure:
        return (failure as ValidationFailure).message;
      case ValidationFailureWithErrors:
        return (failure as ValidationFailureWithErrors).message;
      case ApiFailure:
        return (failure as ApiFailure).message;
      case AuthenticationFailure:
        final authFailure = failure as AuthenticationFailure;
        return authFailure.message.isNotEmpty &&
                authFailure.rawMessage !=
                    AppLocalizations.translateSync('common.unauthorized')
            ? authFailure.message
            : AppLocalizations.translateSync('auth.errors.invalidCredentials');
      case UnauthorizedFailure:
        return failure.message.isNotEmpty &&
                rawMessage !=
                    AppLocalizations.translateSync('common.unauthorized')
            ? failure.message
            : AppLocalizations.translateSync('auth.errors.unauthorizedAction');
      case SessionExpiredFailure:
        return AppLocalizations.translateSync('auth.errors.sessionExpired');
      case PermissionDeniedFailure:
        return failure.message.isNotEmpty &&
                rawMessage !=
                    AppLocalizations.translateSync('common.permissionDenied')
            ? failure.message
            : AppLocalizations.translateSync('auth.errors.permissionDenied');
      default:
        return failure.message.isNotEmpty
            ? failure.message
            : AppLocalizations.translateSync('auth.errors.unexpected');
    }
  }
}
