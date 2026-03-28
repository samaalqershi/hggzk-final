import 'package:equatable/equatable.dart';
import '../../../../../core/enums/booking_status.dart';

/// Represents the core booking record that anchors status, pricing, and
/// lifecycle operations across the portal.
///
/// يمثل سجل الحجز الأساسي الذي ترتكز عليه الحالة والتسعير وعمليات دورة الحياة
/// داخل البوابة.
class Booking extends Equatable {
  /// Stable booking identifier used by every downstream workflow.
  ///
  /// معرّف الحجز الثابت المستخدم في جميع التدفقات اللاحقة.
  final String id;

  /// User who created or owns the booking.
  ///
  /// المستخدم الذي أنشأ الحجز أو يملكه.
  final String userId;

  /// Reserved unit identifier.
  ///
  /// معرّف الوحدة المحجوزة.
  final String unitId;

  /// Planned arrival timestamp.
  ///
  /// وقت الوصول المخطط له.
  final DateTime checkIn;

  /// Planned departure timestamp.
  ///
  /// وقت المغادرة المخطط له.
  final DateTime checkOut;

  /// Total guest count included in the reservation.
  ///
  /// إجمالي عدد الضيوف المشمولين في الحجز.
  final int guestsCount;

  /// Final booking amount before any payment allocation.
  ///
  /// المبلغ النهائي للحجز قبل توزيع الدفعات.
  final Money totalPrice;

  /// Operational booking status used by the workflow engine.
  ///
  /// حالة الحجز التشغيلية المستخدمة في سير العمل.
  final BookingStatus status;

  /// Timestamp at which the booking was created.
  ///
  /// وقت إنشاء الحجز.
  final DateTime bookedAt;

  /// Display name of the guest or customer.
  ///
  /// اسم العرض للضيف أو العميل.
  final String userName;

  /// Display name of the booked unit.
  ///
  /// اسم العرض للوحدة المحجوزة.
  final String unitName;

  /// Optional email address used for receipts and notifications.
  ///
  /// البريد الإلكتروني الاختياري المستخدم للإيصالات والإشعارات.
  final String? userEmail;

  /// Optional phone number used for follow-up.
  ///
  /// رقم الهاتف الاختياري المستخدم للمتابعة.
  final String? userPhone;

  /// Primary image for the booked unit.
  ///
  /// الصورة الرئيسية للوحدة المحجوزة.
  final String? unitImage;

  /// Property that owns the booking.
  ///
  /// العقار الذي يملك الحجز.
  final String? propertyId;

  /// Display name of the property.
  ///
  /// اسم العرض للعقار.
  final String? propertyName;

  /// Internal notes captured by staff.
  ///
  /// الملاحظات الداخلية التي يسجلها الفريق.
  final String? notes;

  /// Guest requests that need attention during the stay.
  ///
  /// طلبات الضيف الخاصة التي تحتاج معالجة أثناء الإقامة.
  final String? specialRequests;

  /// Reason recorded when the booking is cancelled.
  ///
  /// السبب المسجل عند إلغاء الحجز.
  final String? cancellationReason;

  /// Timestamp of cancellation, when applicable.
  ///
  /// وقت الإلغاء إن وُجد.
  final DateTime? cancelledAt;

  /// Timestamp of confirmation, when applicable.
  ///
  /// وقت التأكيد إن وُجد.
  final DateTime? confirmedAt;

  /// Actual check-in timestamp, when the guest arrives.
  ///
  /// وقت تسجيل الوصول الفعلي عند وصول الضيف.
  final DateTime? checkedInAt;

  /// Actual check-out timestamp, when the guest departs.
  ///
  /// وقت تسجيل المغادرة الفعلي عند مغادرة الضيف.
  final DateTime? checkedOutAt;

  /// Channel or origin that created the booking.
  ///
  /// القناة أو المصدر الذي أنشأ الحجز.
  final String? bookingSource;

  /// Indicates whether the booking was created in person.
  ///
  /// يوضح ما إذا كان الحجز قد تم حضوريًا.
  final bool? isWalkIn;

  /// Payment state mirrored from the finance workflow.
  ///
  /// حالة الدفع المنعكسة من سير العمل المالي.
  final String? paymentStatus;

  /// Creates the immutable booking aggregate used throughout the portal.
  ///
  /// ينشئ مجمع الحجز غير القابل للتعديل المستخدم في جميع أجزاء البوابة.
  const Booking({
    required this.id,
    required this.userId,
    required this.unitId,
    required this.checkIn,
    required this.checkOut,
    required this.guestsCount,
    required this.totalPrice,
    required this.status,
    required this.bookedAt,
    required this.userName,
    required this.unitName,
    this.userEmail,
    this.userPhone,
    this.unitImage,
    this.propertyId,
    this.propertyName,
    this.notes,
    this.specialRequests,
    this.cancellationReason,
    this.cancelledAt,
    this.confirmedAt,
    this.checkedInAt,
    this.checkedOutAt,
    this.bookingSource,
    this.isWalkIn,
    this.paymentStatus,
  });

  /// Calculates the number of nights between the arrival and departure dates.
  ///
  /// يحسب عدد الليالي بين تاريخ الوصول وتاريخ المغادرة.
  int get nights {
    return checkOut.difference(checkIn).inDays;
  }

  /// Indicates whether the current booking status still allows cancellation.
  ///
  /// يحدد ما إذا كانت حالة الحجز الحالية ما تزال تسمح بالإلغاء.
  bool get canCancel {
    return status == BookingStatus.pending || status == BookingStatus.confirmed;
  }

  /// Indicates whether the booking can still move to the confirmed state.
  ///
  /// يحدد ما إذا كان يمكن نقل الحجز إلى حالة التأكيد.
  bool get canConfirm {
    return status == BookingStatus.pending;
  }

  /// Indicates whether check-in is allowed based on status and arrival time.
  ///
  /// يحدد ما إذا كان تسجيل الوصول مسموحًا بحسب الحالة ووقت الوصول.
  bool get canCheckIn {
    return status == BookingStatus.confirmed &&
        DateTime.now().isAfter(checkIn.subtract(const Duration(hours: 2)));
  }

  /// Indicates whether the stay has progressed far enough to allow check-out.
  ///
  /// يحدد ما إذا كانت الإقامة وصلت لمرحلة تسمح بتسجيل المغادرة.
  bool get canCheckOut {
    return status == BookingStatus.checkedIn;
  }

  /// Returns a new booking with selected fields replaced for state updates.
  ///
  /// يعيد نسخة جديدة من الحجز مع استبدال الحقول المحددة فقط أثناء تحديث الحالة.
  Booking copyWith({
    String? id,
    String? userId,
    String? unitId,
    DateTime? checkIn,
    DateTime? checkOut,
    int? guestsCount,
    Money? totalPrice,
    BookingStatus? status,
    DateTime? bookedAt,
    String? userName,
    String? unitName,
    String? userEmail,
    String? userPhone,
    String? unitImage,
    String? propertyId,
    String? propertyName,
    String? notes,
    String? specialRequests,
    String? cancellationReason,
    DateTime? cancelledAt,
    DateTime? confirmedAt,
    DateTime? checkedInAt,
    DateTime? checkedOutAt,
    String? bookingSource,
    bool? isWalkIn,
    String? paymentStatus,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      unitId: unitId ?? this.unitId,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      guestsCount: guestsCount ?? this.guestsCount,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      bookedAt: bookedAt ?? this.bookedAt,
      userName: userName ?? this.userName,
      unitName: unitName ?? this.unitName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      unitImage: unitImage ?? this.unitImage,
      propertyId: propertyId ?? this.propertyId,
      propertyName: propertyName ?? this.propertyName,
      notes: notes ?? this.notes,
      specialRequests: specialRequests ?? this.specialRequests,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      checkedOutAt: checkedOutAt ?? this.checkedOutAt,
      bookingSource: bookingSource ?? this.bookingSource,
      isWalkIn: isWalkIn ?? this.isWalkIn,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }

  /// Keeps equality aligned with the full booking lifecycle record.
  ///
  /// يربط المقارنة بسجل الحجز الكامل.
  @override
  List<Object?> get props => [
        id,
        userId,
        unitId,
        checkIn,
        checkOut,
        guestsCount,
        totalPrice,
        status,
        bookedAt,
        userName,
        unitName,
        userEmail,
        userPhone,
        unitImage,
        propertyId,
        propertyName,
        notes,
        specialRequests,
        cancellationReason,
        cancelledAt,
        confirmedAt,
        checkedInAt,
        checkedOutAt,
        bookingSource,
        isWalkIn,
        paymentStatus,
      ];
}

/// Captures a monetary value together with the currency code and its already
/// formatted display string.
///
/// يحتفظ بقيمة مالية مع رمز العملة والنص المنسق الجاهز للعرض.
class Money extends Equatable {
  /// Numeric amount used in calculations.
  ///
  /// القيمة الرقمية المستخدمة في الحسابات.
  final double amount;

  /// ISO or business currency code used to interpret the amount.
  ///
  /// رمز العملة القياسي أو التجاري المستخدم لتفسير المبلغ.
  final String currency;

  /// Preformatted presentation string shown directly in the UI.
  ///
  /// النص المنسق مسبقًا والمستخدم مباشرة في الواجهة.
  final String formattedAmount;

  /// Creates the immutable money snapshot shared by booking and payment flows.
  ///
  /// ينشئ لقطة مالية غير قابلة للتعديل تشاركها تدفقات الحجز والدفع.
  const Money({
    required this.amount,
    required this.currency,
    required this.formattedAmount,
  });

  /// Returns a copy with selectively replaced monetary fields.
  ///
  /// يعيد نسخة مع استبدال الحقول المالية المحددة فقط.
  Money copyWith({
    double? amount,
    String? currency,
    String? formattedAmount,
  }) {
    return Money(
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      formattedAmount: formattedAmount ?? this.formattedAmount,
    );
  }

  /// Keeps equality aligned with the rendered monetary value.
  ///
  /// يربط المقارنة بالقيمة المالية المعروضة.
  @override
  List<Object> get props => [amount, currency, formattedAmount];
}
