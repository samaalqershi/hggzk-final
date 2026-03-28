import 'package:equatable/equatable.dart';

/// العربية: يجمع كل أحداث المصادقة التي تغيّر حالة الجلسة أو الحساب.
/// Groups every authentication event that can change the session or account state.
abstract class AuthEvent extends Equatable {
  /// العربية: يجعل الأحداث قابلة للمقارنة وفق بياناتها فقط.
  /// Makes events comparable only by the data they carry.
  const AuthEvent();

  /// العربية: لا توجد حقول مشتركة على مستوى الأساس.
  /// No shared fields exist at the base level.
  @override
  List<Object?> get props => [];
}

/// العربية: يطلب فحص الجلسة الحالية عند تشغيل التطبيق.
/// Requests a session check when the app starts.
class CheckAuthStatusEvent extends AuthEvent {
  /// العربية: مجرد إشارة لبدء الفحص.
  /// Only signals that the check should begin.
  const CheckAuthStatusEvent();
}

/// العربية: يحمل بيانات الدخول التي يرسلها المستخدم لتسجيل الدخول.
/// Carries the credentials the user submits to sign in.
class LoginEvent extends AuthEvent {
  /// العربية: قيمة الدخول التي قد تكون بريدًا أو رقم هاتف.
  /// Login identifier, which may be an email or phone number.
  final String emailOrPhone;

  /// العربية: كلمة المرور المستخدمة مع بيانات الدخول.
  /// Password paired with the login identifier.
  final String password;

  /// العربية: يحدد إن كانت الجلسة يجب أن تُحفظ لفترة أطول.
  /// Indicates whether the session should be remembered longer.
  final bool rememberMe;

  /// العربية: يجمع بيانات الدخول في حدث واحد قابل للتمرير إلى البلوك.
  /// Wraps login credentials into one event the bloc can process.
  const LoginEvent({
    required this.emailOrPhone,
    required this.password,
    this.rememberMe = false,
  });

  /// العربية: تعتمد المقارنة على كل حقول الدخول.
  /// Equality depends on all login fields.
  @override
  List<Object?> get props => [emailOrPhone, password, rememberMe];
}

/// العربية: يحمل بيانات إنشاء حساب جديد للمستخدم العادي.
/// Carries the data needed to create a new standard user account.
class RegisterEvent extends AuthEvent {
  /// العربية: اسم المستخدم الكامل.
  /// Full name of the new user.
  final String name;

  /// العربية: البريد الإلكتروني المستخدم في التسجيل.
  /// Email address used during registration.
  final String email;

  /// العربية: رقم الهاتف المرتبط بالحساب.
  /// Phone number associated with the account.
  final String phone;

  /// العربية: كلمة المرور التي سينشأ بها الحساب.
  /// Password used to create the account.
  final String password;

  /// العربية: تأكيد كلمة المرور لمنع الأخطاء المطبعية.
  /// Password confirmation to catch typing mistakes.
  final String passwordConfirmation;

  /// العربية: يضم حقول التسجيل في حدث واضح واحد.
  /// Groups registration fields into one clear event.
  const RegisterEvent({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
  });

  /// العربية: تعتمد المقارنة على جميع حقول التسجيل.
  /// Equality depends on all registration fields.
  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        password,
        passwordConfirmation,
      ];
}

/// العربية: يحمل بيانات تسجيل مالك عقار جديد مع العقار المرتبط به.
/// Carries the data for registering a new property owner together with the linked property.
class RegisterOwnerWithPropertyEvent extends AuthEvent {
  /// العربية: اسم المستخدم الذي سيتم إنشاء حسابه.
  /// Name of the user whose account will be created.
  final String name;

  /// العربية: البريد الإلكتروني لصاحب الحساب الجديد.
  /// Email address for the new owner account.
  final String email;

  /// العربية: رقم الهاتف المرتبط بالمالك.
  /// Phone number associated with the owner.
  final String phone;

  /// العربية: كلمة المرور الأولية للحساب.
  /// Initial password for the account.
  final String password;

  /// العربية: معرف نوع العقار الذي يرتبط به التسجيل.
  /// Identifier of the property type tied to the registration.
  final String propertyTypeId;

  /// العربية: اسم العقار الذي سيُنشأ مع الحساب.
  /// Property name to create with the account.
  final String propertyName;

  /// العربية: المدينة التي يقع فيها العقار.
  /// City where the property is located.
  final String city;

  /// العربية: عنوان العقار التفصيلي.
  /// Detailed property address.
  final String address;

  /// العربية: خط العرض إن كان متوفرًا.
  /// Latitude when available.
  final double? latitude;

  /// العربية: خط الطول إن كان متوفرًا.
  /// Longitude when available.
  final double? longitude;

  /// العربية: التقييم النجمي الابتدائي للعقار.
  /// Initial star rating for the property.
  final int starRating;

  /// العربية: الوصف الاختياري للعقار.
  /// Optional property description.
  final String? description;

  /// العربية: رمز العملة المستخدم في العقار.
  /// Currency code used by the property.
  final String? currency;

  /// العربية: حسابات المحفظة المرتبطة بالعقار.
  /// Wallet accounts attached to the property.
  final List<Map<String, dynamic>>? walletAccounts;

  /// العربية: يجمّع بيانات المالك والعقار في حدث واحد متكامل.
  /// Packages owner and property data into one complete event.
  const RegisterOwnerWithPropertyEvent({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.propertyTypeId,
    required this.propertyName,
    required this.city,
    required this.address,
    this.latitude,
    this.longitude,
    this.starRating = 3,
    this.description,
    this.currency,
    this.walletAccounts,
  });

  /// العربية: تعتمد المقارنة على كل القيم التي تشكل التسجيل الكامل.
  /// Equality depends on all fields that define the complete registration.
  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        password,
        propertyTypeId,
        propertyName,
        city,
        address,
        latitude,
        longitude,
        starRating,
        description,
        currency,
        walletAccounts,
      ];
}

/// العربية: يطلب إنهاء الجلسة الحالية.
/// Requests that the current session be closed.
class LogoutEvent extends AuthEvent {
  /// العربية: مجرد إشارة لبدء تسجيل الخروج.
  /// Only signals that logout should begin.
  const LogoutEvent();
}

/// العربية: يطلب إرسال رابط أو رمز إعادة التعيين.
/// Requests a password-reset link or code.
class ResetPasswordEvent extends AuthEvent {
  /// العربية: قيمة الدخول التي قد تكون بريدًا أو هاتفًا.
  /// Login identifier, which may be an email or phone number.
  final String emailOrPhone;

  /// العربية: يحمل البيانات اللازمة لطلب إعادة التعيين.
  /// Holds the data required to request a reset.
  const ResetPasswordEvent({
    required this.emailOrPhone,
  });

  /// العربية: تعتمد المقارنة على قيمة الدخول فقط.
  /// Equality depends on the login identifier only.
  @override
  List<Object?> get props => [emailOrPhone];
}

/// العربية: يحمل بيانات تحديث الملف الشخصي أو بيانات المالك.
/// Carries profile or owner details to be updated.
class UpdateProfileEvent extends AuthEvent {
  /// العربية: الاسم المعروض للمستخدم.
  /// User display name.
  final String name;

  /// العربية: البريد الإلكتروني الاختياري.
  /// Optional email address.
  final String? email;

  /// العربية: رقم الهاتف الاختياري.
  /// Optional phone number.
  final String? phone;

  /// العربية: حسابات المحفظة المرتبطة بالمستخدم.
  /// Wallet accounts linked to the user.
  final List<Map<String, dynamic>>? walletAccounts;

  /// العربية: معرف العقار إن كان التحديث يخص مالكًا.
  /// Property identifier when the update belongs to an owner.
  final String? propertyId;

  /// العربية: اسم العقار المرتبط بالتحديث.
  /// Property name tied to the update.
  final String? propertyName;

  /// العربية: عنوان العقار المرتبط بالتحديث.
  /// Property address tied to the update.
  final String? propertyAddress;

  /// العربية: المدينة المرتبطة بالعقار.
  /// City linked to the property.
  final String? propertyCity;

  /// العربية: الوصف المختصر للعقار.
  /// Short property description.
  final String? propertyShortDescription;

  /// العربية: وصف العقار الكامل.
  /// Full property description.
  final String? propertyDescription;

  /// العربية: رمز العملة المرتبط بالعقار.
  /// Currency code linked to the property.
  final String? propertyCurrency;

  /// العربية: التقييم النجمي للعقار.
  /// Property star rating.
  final int? propertyStarRating;

  /// العربية: خط العرض الخاص بموقع العقار.
  /// Property latitude.
  final double? propertyLatitude;

  /// العربية: خط الطول الخاص بموقع العقار.
  /// Property longitude.
  final double? propertyLongitude;

  /// العربية: يضم حقول التحديث الشخصية وحقول العقار في حدث واحد.
  /// Packs profile and property update data into one event.
  const UpdateProfileEvent({
    required this.name,
    this.email,
    this.phone,
    this.walletAccounts,
    this.propertyId,
    this.propertyName,
    this.propertyAddress,
    this.propertyCity,
    this.propertyShortDescription,
    this.propertyDescription,
    this.propertyCurrency,
    this.propertyStarRating,
    this.propertyLatitude,
    this.propertyLongitude,
  });

  /// العربية: تعتمد المقارنة على جميع القيم التي تشكل التحديث النهائي.
  /// Equality depends on all fields that define the final update.
  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        walletAccounts,
        propertyId,
        propertyName,
        propertyAddress,
        propertyCity,
        propertyShortDescription,
        propertyDescription,
        propertyCurrency,
        propertyStarRating,
        propertyLatitude,
        propertyLongitude,
      ];
}

/// العربية: يطلب تغيير كلمة المرور الحالية إلى كلمة جديدة.
/// Requests changing the current password to a new one.
class ChangePasswordEvent extends AuthEvent {
  /// العربية: كلمة المرور الحالية.
  /// Current password.
  final String currentPassword;

  /// العربية: كلمة المرور الجديدة.
  /// New password.
  final String newPassword;

  /// العربية: تأكيد كلمة المرور الجديدة.
  /// Confirmation of the new password.
  final String newPasswordConfirmation;

  /// العربية: يجمع قيم تغيير كلمة المرور في حدث واحد.
  /// Wraps password-change values into one event.
  const ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });

  /// العربية: تعتمد المقارنة على كلمات المرور الثلاث.
  /// Equality depends on the three password fields.
  @override
  List<Object?> get props =>
      [currentPassword, newPassword, newPasswordConfirmation];
}

/// العربية: يطلب رفع صورة جديدة للملف الشخصي.
/// Requests uploading a new profile image.
class UploadProfileImageEvent extends AuthEvent {
  /// العربية: مسار الملف المحلي للصورة.
  /// Local file path of the image.
  final String imagePath;

  /// العربية: يحمل مسار الصورة فقط لأن عملية الرفع تعتمد عليه مباشرة.
  /// Carries only the image path because upload depends on it directly.
  const UploadProfileImageEvent({
    required this.imagePath,
  });

  /// العربية: تعتمد المقارنة على مسار الصورة.
  /// Equality depends on the image path.
  @override
  List<Object?> get props => [imagePath];
}

/// العربية: يطلب تسجيل الدخول عبر مزود اجتماعي محدد.
/// Requests sign-in through a specific social provider.
class SocialLoginEvent extends AuthEvent {
  /// العربية: مزود تسجيل الدخول الاجتماعي.
  /// Social login provider.
  final SocialLoginProvider provider;

  /// العربية: التوكن أو رمز الاعتماد القادم من المزود.
  /// Token or credential coming from the provider.
  final String token;

  /// العربية: nonce اختياري لبعض المزودين.
  /// Optional nonce for some providers.
  final String? nonce;

  /// العربية: الاسم المعروض إن كان المزود يوفّره.
  /// Display name if the provider supplies one.
  final String? name;

  /// العربية: يضم بيانات الدخول الاجتماعي في حدث واحد قابل للمعالجة.
  /// Bundles social login data into one processable event.
  const SocialLoginEvent({
    required this.provider,
    required this.token,
    this.nonce,
    this.name,
  });

  /// العربية: تعتمد المقارنة على المزود والتوكن والحقول الاختيارية.
  /// Equality depends on the provider, token, and optional fields.
  @override
  List<Object?> get props => [provider, token, nonce, name];
}

/// العربية: يكمّل ملف مالك العقار بعد أن يبدأ التسجيل الأساسي.
/// Completes an owner profile after the base registration has started.
class CompleteOwnerProfileEvent extends AuthEvent {
  /// العربية: اسم المالك.
  /// Owner name.
  final String name;

  /// العربية: رقم الهاتف للمالك.
  /// Owner phone number.
  final String phone;

  /// العربية: نوع العقار.
  /// Property type.
  final String propertyTypeId;

  /// العربية: اسم العقار.
  /// Property name.
  final String propertyName;

  /// العربية: المدينة.
  /// City.
  final String city;

  /// العربية: العنوان.
  /// Address.
  final String address;

  /// العربية: خط العرض.
  /// Latitude.
  final double? latitude;

  /// العربية: خط الطول.
  /// Longitude.
  final double? longitude;

  /// العربية: التقييم النجمي.
  /// Star rating.
  final int starRating;

  /// العربية: وصف اختياري.
  /// Optional description.
  final String? description;

  /// العربية: العملة.
  /// Currency code.
  final String? currency;

  /// العربية: حسابات المحفظة.
  /// Wallet accounts.
  final List<Map<String, dynamic>>? walletAccounts;

  /// العربية: يضم بيانات إكمال الملف في حدث واحد واضح.
  /// Packages the profile-completion data into one clear event.
  const CompleteOwnerProfileEvent({
    required this.name,
    required this.phone,
    required this.propertyTypeId,
    required this.propertyName,
    required this.city,
    required this.address,
    this.latitude,
    this.longitude,
    this.starRating = 3,
    this.description,
    this.currency,
    this.walletAccounts,
  });

  /// العربية: تعتمد المقارنة على كل الحقول التي تكمل الملف.
  /// Equality depends on all fields that complete the profile.
  @override
  List<Object?> get props => [
        name,
        phone,
        propertyTypeId,
        propertyName,
        city,
        address,
        latitude,
        longitude,
        starRating,
        description,
        currency,
        walletAccounts,
      ];
}

/// العربية: يطلب تسجيل الدخول عبر refresh token محفوظ.
/// Requests login through a stored refresh token.
class LoginWithRefreshTokenEvent extends AuthEvent {
  /// العربية: توكن التحديث.
  /// Refresh token.
  final String refreshToken;

  /// العربية: يحمل توكن التحديث لإعادة إنشاء الجلسة.
  /// Carries the refresh token to rebuild the session.
  const LoginWithRefreshTokenEvent({required this.refreshToken});

  /// العربية: تعتمد المقارنة على توكن التحديث.
  /// Equality depends on the refresh token.
  @override
  List<Object?> get props => [refreshToken];
}

/// العربية: يطلب حذف حساب المالك مع سبب الحذف أو بيانات مزود اجتماعي إن
/// كانت هي وسيلة الدخول الأخيرة.
/// Requests owner-account deletion with a reason or social auth data when that was the last login method.
class DeleteOwnerAccountEvent extends AuthEvent {
  /// العربية: كلمة المرور إن كان الحذف يتطلب تحققًا مباشرًا.
  /// Password when direct verification is required.
  final String? password;

  /// العربية: اسم مزود الدخول الاجتماعي إن لزم.
  /// Social provider name when needed.
  final String? socialProvider;

  /// العربية: التوكن الاجتماعي إن لزم.
  /// Social token when needed.
  final String? socialToken;

  /// العربية: nonce الاجتماعي إن لزم.
  /// Social nonce when needed.
  final String? socialNonce;

  /// العربية: سبب الحذف الذي قد يُسجل للتدقيق.
  /// Deletion reason that may be recorded for auditing.
  final String? reason;

  /// العربية: يجمع بيانات حذف الحساب في حدث واحد مرن.
  /// Groups account-deletion data into one flexible event.
  const DeleteOwnerAccountEvent({
    this.password,
    this.socialProvider,
    this.socialToken,
    this.socialNonce,
    this.reason,
  });

  /// العربية: تعتمد المقارنة على كل الحقول التي قد ترافق عملية الحذف.
  /// Equality depends on all fields that may accompany deletion.
  @override
  List<Object?> get props => [
        password,
        socialProvider,
        socialToken,
        socialNonce,
        reason,
      ];
}

/// العربية: يصف مزود تسجيل الدخول الاجتماعي المستخدم في الحدث.
/// Describes the social login provider used in the event.
enum SocialLoginProvider {
  google,
  facebook,
  apple,
}
