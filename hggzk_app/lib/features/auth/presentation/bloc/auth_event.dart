import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class LoginEvent extends AuthEvent {
  final String emailOrPhone;
  final String password;
  final bool rememberMe;

  const LoginEvent({
    required this.emailOrPhone,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [emailOrPhone, password, rememberMe];
}

class LoginWithRefreshTokenEvent extends AuthEvent {
  final String refreshToken;

  const LoginWithRefreshTokenEvent({required this.refreshToken});

  @override
  List<Object?> get props => [refreshToken];
}

class RegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String passwordConfirmation;

  const RegisterEvent({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        password,
        passwordConfirmation,
      ];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class ResetPasswordEvent extends AuthEvent {
  final String emailOrPhone;

  const ResetPasswordEvent({
    required this.emailOrPhone,
  });

  @override
  List<Object?> get props => [emailOrPhone];
}

class UpdateProfileEvent extends AuthEvent {
  final String name;
  final String? email;
  final String? phone;

  const UpdateProfileEvent({
    required this.name,
    this.email,
    this.phone,
  });

  @override
  List<Object?> get props => [name, email, phone];
}

class ChangePasswordEvent extends AuthEvent {
  final String currentPassword;
  final String newPassword;
  final String newPasswordConfirmation;

  const ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });

  @override
  List<Object?> get props =>
      [currentPassword, newPassword, newPasswordConfirmation];
}

class UploadProfileImageEvent extends AuthEvent {
  final String imagePath;

  const UploadProfileImageEvent({
    required this.imagePath,
  });

  @override
  List<Object?> get props => [imagePath];
}

class DeleteAccountEvent extends AuthEvent {
  final String? password;
  final String? socialProvider;
  final String? socialToken;
  final String? socialNonce;
  final String? reason;

  const DeleteAccountEvent({
    this.password,
    this.socialProvider,
    this.socialToken,
    this.socialNonce,
    this.reason,
  });

  @override
  List<Object?> get props => [
        password,
        socialProvider,
        socialToken,
        socialNonce,
        reason,
      ];
}

class SocialLoginEvent extends AuthEvent {
  final SocialLoginProvider provider;
  final String token;
  final String? nonce;
  final String? name;

  const SocialLoginEvent({
    required this.provider,
    required this.token,
    this.nonce,
    this.name,
  });

  @override
  List<Object?> get props => [provider, token, nonce, name];
}

enum SocialLoginProvider {
  google,
  facebook,
  apple,
}
