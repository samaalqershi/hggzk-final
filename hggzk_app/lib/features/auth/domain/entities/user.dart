import 'package:equatable/equatable.dart';

/// يمثل المستخدم المصادق داخل تطبيق العميل مع البيانات اللازمة لتخصيص
/// التجربة واتخاذ قرارات التوجيه المرتبطة بالتحقق والحساب.
/// Represents the authenticated client user with the data needed to
/// personalize the experience and drive verification-aware routing decisions.
class User extends Equatable {
  /// المعرّف الفريد للمستخدم كما يأتي من الخادم.
  /// Unique user identifier as returned by the backend.
  final String userId;

  /// الاسم الظاهر للمستخدم داخل التطبيق.
  /// Display name shown for the user across the app.
  final String name;

  /// البريد الإلكتروني الأساسي المرتبط بالحساب.
  /// Primary email address associated with the account.
  final String email;

  /// رقم الهاتف المسجل للحساب.
  /// Phone number registered on the account.
  final String phone;

  /// الأدوار أو الصلاحيات التي منحت لهذا المستخدم.
  /// Roles or permissions currently assigned to the user.
  final List<String> roles;

  /// رابط الصورة الشخصية إن كان المستخدم قد رفع صورة.
  /// Profile image URL when the user has uploaded one.
  final String? profileImage;

  /// وقت توثيق البريد الإلكتروني إن كان التحقق قد اكتمل.
  /// Timestamp for email verification when the user has completed that step.
  final DateTime? emailVerifiedAt;

  /// وقت توثيق رقم الهاتف إن وُجد مسار تحقق للهاتف.
  /// Timestamp for phone verification when that verification path exists.
  final DateTime? phoneVerifiedAt;

  /// وقت إنشاء الحساب في النظام.
  /// Timestamp describing when the account was created.
  final DateTime createdAt;

  /// آخر وقت عُدلت فيه بيانات المستخدم.
  /// Timestamp of the latest update applied to the user record.
  final DateTime updatedAt;

  /// يبني كيان المستخدم الكامل كما تعتمد عليه بقية طبقات المصادقة.
  /// Creates the full user entity consumed by the rest of the auth flow.
  const User({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.roles,
    this.profileImage,
    this.emailVerifiedAt,
    this.phoneVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// يوضح ما إذا كان البريد الإلكتروني قد تم التحقق منه بالفعل.
  /// Indicates whether email verification has already been completed.
  bool get isEmailVerified => emailVerifiedAt != null;

  /// يوضح ما إذا كان رقم الهاتف قد تم التحقق منه.
  /// Indicates whether phone verification has been completed.
  bool get isPhoneVerified => phoneVerifiedAt != null;

  /// يعامل المستخدم كمتحقق إذا اكتمل أحد مساري التحقق المعتمدين.
  /// Treats the user as verified when either supported verification path has
  /// completed.
  bool get isVerified => isEmailVerified || isPhoneVerified;

  @override
  List<Object?> get props => [
        userId,
        name,
        email,
        phone,
        roles,
        profileImage,
        emailVerifiedAt,
        phoneVerifiedAt,
        createdAt,
        updatedAt,
      ];
}
