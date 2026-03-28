import 'package:equatable/equatable.dart';
import 'package:hggzk/features/booking/domain/entities/payment.dart';
import '../../../../core/enums/booking_status.dart';

/// Canonical booking record used by details, history, and payment flows.
/// سجل الحجز الأساسي المستخدم في التفاصيل والسجل ومسارات الدفع.
class Booking extends Equatable {
  /// Backend identifier for the booking record.
  /// المعرّف الخلفي لسجل الحجز.
  final String id;

  /// Human-readable booking number shown in the UI.
  /// رقم الحجز الظاهر للمستخدم.
  final String bookingNumber;

  /// Account that owns the booking.
  /// الحساب الذي يملك الحجز.
  final String userId;

  /// Display name of the guest who booked.
  /// الاسم الظاهر للضيف الذي قام بالحجز.
  final String userName;

  /// Property that contains the booked unit.
  /// العقار الذي يحتوي الوحدة المحجوزة.
  final String propertyId;

  /// Property name shown on cards and details.
  /// اسم العقار الظاهر في البطاقات والتفاصيل.
  final String propertyName;

  /// Optional property address for richer summaries.
  /// عنوان العقار الاختياري لعرض ملخص أغنى.
  final String? propertyAddress;

  /// Optional unit identifier when the booking targets a specific unit.
  /// معرّف الوحدة الاختياري عندما يرتبط الحجز بوحدة محددة.
  final String? unitId;

  /// Optional unit name for detail screens.
  /// اسم الوحدة الاختياري لشاشات التفاصيل.
  final String? unitName;

  /// Scheduled arrival date.
  /// تاريخ الوصول المجدول.
  final DateTime checkInDate;

  /// Scheduled departure date.
  /// تاريخ المغادرة المجدول.
  final DateTime checkOutDate;

  /// Length of stay in nights.
  /// مدة الإقامة بالليالي.
  final int numberOfNights;

  /// Adult guest count.
  /// عدد الضيوف البالغين.
  final int adultGuests;

  /// Child guest count.
  /// عدد الضيوف الأطفال.
  final int childGuests;

  /// Combined guest count used by availability and pricing logic.
  /// إجمالي الضيوف المستخدم في التوفر والتسعير.
  final int totalGuests;

  /// Base booking amount before extra services.
  /// المبلغ الأساسي قبل الخدمات الإضافية.
  final double totalAmount;

  /// Optional commission withheld by the platform.
  /// العمولة الاختيارية التي تحتجزها المنصة.
  final double? platformCommissionAmount;

  /// Final amount payable after adjustments.
  /// المبلغ النهائي المستحق بعد التعديلات.
  final double? finalAmount;

  /// Currency code used for all monetary values.
  /// رمز العملة المستخدم لكل القيم المالية.
  final String currency;

  /// Booking lifecycle state.
  /// حالة دورة حياة الحجز.
  final BookingStatus status;

  /// Timestamp when the booking was created.
  /// وقت إنشاء الحجز.
  final DateTime bookingDate;

  /// Real arrival timestamp when check-in happened.
  /// وقت الوصول الفعلي عند تسجيل الدخول.
  final DateTime? actualCheckInDate;

  /// Real departure timestamp when check-out happened.
  /// وقت المغادرة الفعلي عند تسجيل الخروج.
  final DateTime? actualCheckOutDate;

  /// Free-form requests attached by the guest.
  /// الطلبات الحرة التي أضافها الضيف.
  final String? specialRequests;

  /// Reason captured when the booking is cancelled.
  /// السبب المسجل عند إلغاء الحجز.
  final String? cancellationReason;

  /// Source channel that created the booking.
  /// قناة الإنشاء التي جاءت منها الحجز.
  final String? bookingSource;

  /// True when the booking was created as a walk-in.
  /// تكون صحيحة عندما يُنشأ الحجز مباشرة دون قناة إلكترونية.
  final bool isWalkIn;

  /// Optional customer rating assigned after completion.
  /// تقييم اختياري يضيفه العميل بعد الإكمال.
  final int? customerRating;

  /// Staff notes recorded when the stay is completed.
  /// ملاحظات الموظف المسجلة عند اكتمال الإقامة.
  final String? completionNotes;

  /// Additional services attached to the booking.
  /// الخدمات الإضافية المرتبطة بالحجز.
  final List<BookingService> services;

  /// Payments linked to this booking.
  /// المدفوعات المرتبطة بهذا الحجز.
  final List<Payment> payments;

  /// Cached unit images used by detail cards.
  /// صور الوحدة المخزنة لعرضها في البطاقات.
  final List<String> unitImages;

  /// Contact details supplied at booking time.
  /// معلومات التواصل المقدمة وقت الحجز.
  final ContactInfo contactInfo;

  /// True when cancellation is still allowed.
  /// تكون صحيحة عندما يكون الإلغاء ما يزال مسموحًا.
  final bool canCancel;

  /// Explains why cancellation is blocked.
  /// يوضح سبب منع الإلغاء.
  final String? cancelNotAllowedReason;

  /// Machine-readable code for the cancellation restriction.
  /// رمز آلي لمنع الإلغاء.
  final String? cancelNotAllowedCode;

  /// True when a review can be submitted for the stay.
  /// تكون صحيحة عندما يمكن إرسال تقييم للإقامة.
  final bool canReview;

  /// Optional review left by the user.
  /// التقييم الاختياري الذي يتركه المستخدم.
  final BookingUserReview? userReview;

  /// True when booking edits are still possible.
  /// تكون صحيحة عندما تظل التعديلات على الحجز ممكنة.
  final bool canModify;

  /// Saved policy text at the time the booking was made.
  /// نص السياسة المحفوظ وقت إنشاء الحجز.
  final String? policySnapshot;

  /// Timestamp when the policy snapshot was captured.
  /// وقت التقاط لقطة السياسة.
  final DateTime? policySnapshotAt;

  /// True when payment has already been completed.
  /// تكون صحيحة عندما تكون الدفعة مكتملة.
  final bool isPaid;

  /// يخزن لقطة الحجز التي تستخدمها الواجهة ومسارات العمل.
  const Booking({
    required this.id,
    required this.bookingNumber,
    required this.userId,
    required this.userName,
    required this.propertyId,
    required this.propertyName,
    this.propertyAddress,
    this.unitId,
    this.unitName,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfNights,
    required this.adultGuests,
    required this.childGuests,
    required this.totalGuests,
    required this.totalAmount,
    this.platformCommissionAmount,
    this.finalAmount,
    required this.currency,
    required this.status,
    required this.bookingDate,
    this.actualCheckInDate,
    this.actualCheckOutDate,
    this.specialRequests,
    this.cancellationReason,
    this.bookingSource,
    this.isWalkIn = false,
    this.customerRating,
    this.completionNotes,
    this.services = const [],
    this.payments = const [],
    this.unitImages = const [],
    required this.contactInfo,
    this.canCancel = false,
    this.cancelNotAllowedReason,
    this.cancelNotAllowedCode,
    this.canReview = false,
    this.userReview,
    this.canModify = false,
    this.policySnapshot,
    this.policySnapshotAt,
    this.isPaid = false,
  });

  /// Computes the total amount including all attached services.
  /// يحسب المبلغ الإجمالي مع كل الخدمات المضافة.
  double get totalAmountWithServices {
    double baseAmount = totalAmount;
    double servicesTotal =
        services.fold(0.0, (sum, service) => sum + service.totalPrice);
    return baseAmount + servicesTotal;
  }

  /// Compares the booking snapshot.
  /// يقارن لقطة الحجز.
  @override
  List<Object?> get props => [
        id,
        bookingNumber,
        userId,
        userName,
        propertyId,
        propertyName,
        propertyAddress,
        unitId,
        unitName,
        checkInDate,
        checkOutDate,
        numberOfNights,
        adultGuests,
        childGuests,
        totalGuests,
        totalAmount,
        platformCommissionAmount,
        finalAmount,
        currency,
        status,
        bookingDate,
        actualCheckInDate,
        actualCheckOutDate,
        specialRequests,
        cancellationReason,
        bookingSource,
        isWalkIn,
        customerRating,
        completionNotes,
        services,
        payments,
        unitImages,
        contactInfo,
        canCancel,
        cancelNotAllowedReason,
        cancelNotAllowedCode,
        canReview,
        userReview,
        canModify,
        policySnapshot,
        policySnapshotAt,
        isPaid,
      ];
}

/// العربية: يمثل `BookingUserReview`.
class BookingUserReview extends Equatable {
  /// العربية: يخزن القيمة `id`.
  final String id;

  /// العربية: يخزن القيمة `bookingId`.
  final String bookingId;

  /// العربية: يخزن القيمة `propertyId`.
  final String propertyId;

  /// العربية: يخزن القيمة `cleanliness`.
  final int cleanliness;

  /// العربية: يخزن القيمة `service`.
  final int service;

  /// العربية: يخزن القيمة `location`.
  final int location;

  /// العربية: يخزن القيمة `value`.
  final int value;

  /// العربية: يخزن القيمة `averageRating`.
  final double averageRating;

  /// العربية: يخزن القيمة `comment`.
  final String comment;

  /// العربية: يخزن القيمة `createdAt`.
  final DateTime createdAt;

  /// العربية: يخزن القيمة `responseText`.
  final String? responseText;

  /// العربية: يخزن القيمة `responseDate`.
  final DateTime? responseDate;

  /// العربية: يحدد ما إذا كانت القيمة `isPendingApproval` مفعلة.
  final bool isPendingApproval;

  /// العربية: يحدد ما إذا كانت القيمة `isDisabled` مفعلة.
  final bool isDisabled;

  /// العربية: ينشئ مثيلًا جديدًا من `BookingUserReview`.
  const BookingUserReview({
    required this.id,
    required this.bookingId,
    required this.propertyId,
    required this.cleanliness,
    required this.service,
    required this.location,
    required this.value,
    required this.averageRating,
    required this.comment,
    required this.createdAt,
    this.responseText,
    this.responseDate,
    required this.isPendingApproval,
    required this.isDisabled,
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [
        id,
        bookingId,
        propertyId,
        cleanliness,
        service,
        location,
        value,
        averageRating,
        comment,
        createdAt,
        responseText,
        responseDate,
        isPendingApproval,
        isDisabled,
      ];
}

/// العربية: يوفر الخدمات التي ينفذها `BookingService`.
class BookingService extends Equatable {
  /// العربية: يخزن القيمة `id`.
  final String id;

  /// العربية: يخزن القيمة `serviceId`.
  final String serviceId;

  /// العربية: يخزن القيمة `serviceName`.
  final String serviceName;

  /// العربية: يخزن القيمة `quantity`.
  final int quantity;

  /// العربية: يخزن القيمة `unitPrice`.
  final double unitPrice;

  /// العربية: يخزن القيمة `totalPrice`.
  final double totalPrice;

  /// العربية: يخزن القيمة `currency`.
  final String currency;

  /// العربية: ينشئ مثيلًا جديدًا من `BookingService`.
  const BookingService({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.currency,
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [
        id,
        serviceId,
        serviceName,
        quantity,
        unitPrice,
        totalPrice,
        currency,
      ];
}

/// العربية: يمثل `ContactInfo`.
class ContactInfo extends Equatable {
  /// العربية: يخزن القيمة `phoneNumber`.
  final String phoneNumber;

  /// العربية: يخزن القيمة `email`.
  final String email;

  /// العربية: يخزن القيمة `alternativePhone`.
  final String? alternativePhone;

  /// العربية: ينشئ مثيلًا جديدًا من `ContactInfo`.
  const ContactInfo({
    required this.phoneNumber,
    required this.email,
    this.alternativePhone,
  });

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object?> get props => [
        phoneNumber,
        email,
        alternativePhone,
      ];
}
