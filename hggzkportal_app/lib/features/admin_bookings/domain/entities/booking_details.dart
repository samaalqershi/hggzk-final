import 'package:equatable/equatable.dart';
import '../../../../../core/enums/payment_method_enum.dart';
import 'booking.dart';

/// Aggregates the booking header with the operational records that depend on it
/// such as payments, services, activities, guest data, unit data, and property
/// context.
///
/// يجمع سجل الحجز الرئيسي مع العناصر التشغيلية المرتبطة به مثل الدفعات
/// والخدمات والأنشطة وبيانات الضيف والوحدة والعقار.
class BookingDetails extends Equatable {
  /// Core booking record used as the anchor for totals, dates, and status.
  ///
  /// سجل الحجز الأساسي الذي تُبنى عليه التواريخ والإجماليات والحالة.
  final Booking booking;

  /// Payment entries that were captured or registered for the booking.
  ///
  /// دفعات الحجز المسجلة سواء كانت مدفوعة فعليًا أو مرتبطة بالتأكيد أو الاسترداد.
  final List<Payment> payments;

  /// Extra services attached to the booking and billed alongside the stay.
  ///
  /// الخدمات الإضافية المضافة إلى الحجز والتي تدخل في الفاتورة الإجمالية.
  final List<Service> services;

  /// Timeline events that explain how the booking moved through its lifecycle.
  ///
  /// الأحداث الزمنية التي تشرح كيف تحرك الحجز عبر مراحل حياته.
  final List<BookingActivity> activities;

  /// Guest identity and contact information when the backend provides it as a
  /// separate block.
  ///
  /// بيانات الضيف ووسائل الاتصال به عندما يرسلها الخادم في كتلة مستقلة.
  final GuestInfo? guestInfo;

  /// Compact snapshot of the booked unit used by the details panel.
  ///
  /// لقطة مختصرة للوحدة المحجوزة تعتمد عليها لوحة التفاصيل.
  final UnitDetails? unitDetails;

  /// Property snapshot shown alongside the booking to preserve context such as
  /// name, address, and policy data.
  ///
  /// لقطة العقار المعروضة مع الحجز للحفاظ على سياق الاسم والعنوان والسياسات.
  final PropertyDetails? propertyDetails;

  /// Creates a fully assembled booking snapshot that downstream UI layers can
  /// render without reconnecting the related records manually.
  ///
  /// ينشئ لقطة حجز مكتملة تستطيع طبقات العرض استهلاكها مباشرة دون إعادة
  /// تجميع العلاقات يدويًا.
  const BookingDetails({
    required this.booking,
    required this.payments,
    required this.services,
    this.activities = const [],
    this.guestInfo,
    this.unitDetails,
    this.propertyDetails,
  });

  /// Sums only successful payments so the portal can compare what was actually
  /// collected against the booking total.
  ///
  /// يجمع الدفعات الناجحة فقط حتى تقارن الواجهة ما تم تحصيله فعليًا مع إجمالي الحجز.
  Money get totalPaid {
    final total = payments
        .where((p) => p.status == PaymentStatus.successful)
        .fold(0.0, (sum, payment) => sum + payment.amount.amount);

    return Money(
      amount: total,
      currency: booking.totalPrice.currency,
      formattedAmount: _formatMoney(total, booking.totalPrice.currency),
    );
  }

  /// Subtracts the successful payment total from the booking grand total.
  ///
  /// يطرح إجمالي الدفعات الناجحة من إجمالي الحجز لمعرفة الرصيد المتبقي.
  Money get remainingAmount {
    final remaining = booking.totalPrice.amount - totalPaid.amount;
    return Money(
      amount: remaining,
      currency: booking.totalPrice.currency,
      formattedAmount: _formatMoney(remaining, booking.totalPrice.currency),
    );
  }

  /// Indicates whether no balance remains after all successful payments.
  ///
  /// يحدد ما إذا كان الحجز قد سُدد بالكامل ولم يعد هناك رصيد متبقٍ.
  bool get isFullyPaid {
    return remainingAmount.amount <= 0;
  }

  /// Formats a money amount using the currency code shown in the portal.
  ///
  /// ينسق المبلغ باستخدام رمز العملة الظاهر في البوابة.
  String _formatMoney(double amount, String currency) {
    return '$currency ${amount.toStringAsFixed(2)}';
  }

  /// Keeps Equatable comparisons aligned with the complete booking snapshot.
  ///
  /// يضمن أن تعتمد مقارنة Equatable على لقطة الحجز كاملة.
  @override
  List<Object?> get props => [
        booking,
        payments,
        services,
        activities,
        guestInfo,
        unitDetails,
        propertyDetails,
      ];
}

/// Represents one transaction attached to a booking and used for payment and
/// refund tracking.
///
/// يمثل معاملة واحدة مرتبطة بالحجز وتستخدم في تتبع السداد والاسترداد.
class Payment extends Equatable {
  /// Stable identifier used by the admin portal and payment history views.
  ///
  /// معرّف ثابت تستخدمه بوابة الإدارة وشاشات سجل المدفوعات.
  final String id;

  /// Identifier of the booking that owns this transaction.
  ///
  /// معرّف الحجز الذي تنتمي إليه هذه المعاملة.
  final String bookingId;

  /// Monetary amount captured or refunded for this payment record.
  ///
  /// المبلغ المالي الذي تم تحصيله أو استرداده لهذا السجل.
  final Money amount;

  /// Gateway or backend transaction reference, if one was issued.
  ///
  /// مرجع المعاملة الصادر من بوابة الدفع أو الخادم إن وُجد.
  final String transactionId;

  /// Payment method used when the transaction was registered.
  ///
  /// طريقة الدفع التي استُخدمت عند تسجيل المعاملة.
  final PaymentMethod method;

  /// Current lifecycle status of the transaction, such as successful or
  /// pending.
  ///
  /// الحالة الحالية للمعاملة مثل ناجحة أو قيد الانتظار.
  final PaymentStatus status;

  /// Timestamp recorded by the backend for when the payment was created.
  ///
  /// الطابع الزمني الذي سجله الخادم عند إنشاء الدفعة.
  final DateTime paymentDate;

  /// Reason supplied when the payment was refunded or reversed.
  ///
  /// السبب الذي رافق عملية الاسترداد أو الإلغاء.
  final String? refundReason;

  /// Timestamp of the refund action when a reversal has already happened.
  ///
  /// وقت تنفيذ الاسترداد عندما تكون العملية قد أُنجزت بالفعل.
  final DateTime? refundedAt;

  /// Optional receipt or proof-of-payment URL exposed by the backend.
  ///
  /// رابط الإيصال أو إثبات الدفع إن وفره الخادم.
  final String? receiptUrl;

  /// Creates an immutable transaction record that can be reused by summaries,
  /// audit views, and refund actions.
  ///
  /// ينشئ سجل معاملة غير قابل للتعديل يمكن استخدامه في الملخصات وسجلات
  /// التدقيق وإجراءات الاسترداد.
  const Payment({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.transactionId,
    required this.method,
    required this.status,
    required this.paymentDate,
    this.refundReason,
    this.refundedAt,
    this.receiptUrl,
  });

  /// Keeps equality checks scoped to the business-relevant payment fields.
  ///
  /// يربط المقارنة بالحقول ذات الدلالة العملية للدفعة.
  @override
  List<Object?> get props => [
        id,
        bookingId,
        amount,
        transactionId,
        method,
        status,
        paymentDate,
        refundReason,
        refundedAt,
        receiptUrl,
      ];
}

/// Represents a booking add-on line item that can be priced and counted
/// independently from the nightly stay.
///
/// يمثل بند خدمة إضافية للحجز يمكن تسعيره وعدّه بشكل مستقل عن الإقامة نفسها.
class Service extends Equatable {
  /// Unique identifier of the service definition or booking line item.
  ///
  /// المعرّف الفريد لتعريف الخدمة أو لسطر الخدمة في الحجز.
  final String id;

  /// Display name shown to portal users when reviewing the booking.
  ///
  /// اسم العرض الذي يظهر لمستخدم البوابة عند مراجعة الحجز.
  final String name;

  /// Short explanation of what the service adds to the booking.
  ///
  /// وصف مختصر لما تضيفه الخدمة إلى الحجز.
  final String description;

  /// Unit price used to calculate the service line total.
  ///
  /// سعر الوحدة المستخدم لحساب إجمالي بند الخدمة.
  final Money price;

  /// Number of units booked for this add-on.
  ///
  /// عدد الوحدات المطلوبة لهذه الخدمة الإضافية.
  final int quantity;

  /// Optional icon or visual hint used in the portal UI.
  ///
  /// أيقونة أو مؤشر بصري اختياري تستعمله الواجهة.
  final String? icon;

  /// Optional grouping label that helps organize services in the UI.
  ///
  /// تصنيف اختياري يساعد على تنظيم الخدمات داخل الواجهة.
  final String? category;

  /// Creates an immutable service line item for the booking snapshot.
  ///
  /// ينشئ بند خدمة غير قابل للتعديل داخل لقطة الحجز.
  const Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    this.icon,
    this.category,
  });

  /// Computes the extended price for this service line.
  ///
  /// يحسب السعر الإجمالي لبند الخدمة.
  Money get totalPrice {
    return Money(
      amount: price.amount * quantity,
      currency: price.currency,
      formattedAmount:
          '${price.currency} ${(price.amount * quantity).toStringAsFixed(2)}',
    );
  }

  /// Keeps Equatable aligned with the aggregate snapshot and its related
  /// children.
  ///
  /// يضمن أن تعتمد المقارنة على اللقطة الكاملة وما يرتبط بها من عناصر.
  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        quantity,
        icon,
        category,
      ];
}

/// Represents one event in the booking lifecycle, such as confirmation,
/// check-in, cancellation, or notes added by staff.
///
/// يمثل حدثًا واحدًا في دورة حياة الحجز مثل التأكيد أو تسجيل الدخول أو الإلغاء
/// أو أي ملاحظة يضيفها الفريق.
class BookingActivity extends Equatable {
  /// Stable identifier for the activity log entry.
  ///
  /// المعرّف الثابت لسجل النشاط.
  final String id;

  /// Machine-readable verb that classifies the activity.
  ///
  /// الفعل القابل للقراءة آليًا الذي يصنف نوع النشاط.
  final String action;

  /// Human-readable explanation shown in the timeline or audit trail.
  ///
  /// الشرح البشري الظاهر في التسلسل الزمني أو سجل التدقيق.
  final String description;

  /// Time at which the activity was recorded.
  ///
  /// وقت تسجيل النشاط.
  final DateTime timestamp;

  /// Optional user who triggered the activity.
  ///
  /// المستخدم الذي قد يكون قد تسبب في هذا النشاط إن وُجد.
  final String? userId;

  /// Optional display name for the actor behind the activity.
  ///
  /// اسم العرض للمستخدم المرتبط بالنشاط إن توفر.
  final String? userName;

  /// Creates one immutable lifecycle entry for the booking timeline.
  ///
  /// ينشئ سجلًا زمنيًا غير قابل للتعديل لدورة حياة الحجز.
  const BookingActivity({
    required this.id,
    required this.action,
    required this.description,
    required this.timestamp,
    this.userId,
    this.userName,
  });

  /// Keeps equality aligned with the actual activity record fields.
  ///
  /// يربط المقارنة بالحقول الفعلية لسجل النشاط.
  @override
  List<Object?> get props => [
        id,
        action,
        description,
        timestamp,
        userId,
        userName,
      ];
}

/// Holds the guest identity and contact fields that the booking flow needs
/// when traveler details are stored separately from the main booking.
///
/// يحتفظ بهوية الضيف وحقول التواصل المطلوبة في تدفق الحجز عندما تحفظ
/// بيانات المسافر بشكل منفصل عن الحجز نفسه.
class GuestInfo extends Equatable {
  /// Guest full name as displayed in the portal.
  ///
  /// اسم الضيف الكامل كما يظهر في البوابة.
  final String name;

  /// Main email address used for receipts and contact.
  ///
  /// البريد الإلكتروني الأساسي المستخدم للإيصالات والتواصل.
  final String email;

  /// Main phone number used by staff when contacting the guest.
  ///
  /// رقم الهاتف الأساسي الذي يستخدمه الفريق عند التواصل مع الضيف.
  final String phone;

  /// Optional nationality captured during the booking flow.
  ///
  /// الجنسية الاختيارية التي تُجمع أثناء الحجز.
  final String? nationality;

  /// Optional identity or passport number.
  ///
  /// رقم الهوية أو الجواز إن كان مطلوبًا.
  final String? idNumber;

  /// Optional label describing the type of identity document.
  ///
  /// تسمية اختيارية توضّح نوع وثيقة الهوية.
  final String? idType;

  /// Optional postal or street address for the guest.
  ///
  /// العنوان البريدي أو عنوان الشارع الخاص بالضيف.
  final String? address;

  /// Creates the guest identity snapshot used by booking summaries.
  ///
  /// ينشئ لقطة هوية الضيف المستخدمة في ملخصات الحجز.
  const GuestInfo({
    required this.name,
    required this.email,
    required this.phone,
    this.nationality,
    this.idNumber,
    this.idType,
    this.address,
  });

  /// Keeps equality focused on the contact snapshot.
  ///
  /// يربط المقارنة بلقطة بيانات التواصل فقط.
  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        nationality,
        idNumber,
        idType,
        address,
      ];
}

/// Describes the booked unit with the subset of fields that the portal uses
/// to summarize occupancy and presentation details.
///
/// يصف الوحدة المحجوزة بالحقول التي تحتاجها البوابة لتلخيص الإشغال ومعلومات العرض.
class UnitDetails extends Equatable {
  /// Unit identifier used by booking, inventory, and image views.
  ///
  /// معرّف الوحدة المستخدم في الحجز والمخزون والصور.
  final String id;

  /// Display name of the unit in the admin experience.
  ///
  /// اسم العرض للوحدة داخل تجربة الإدارة.
  final String name;

  /// Unit type or category label, such as room or apartment.
  ///
  /// نوع الوحدة أو فئتها مثل غرفة أو شقة.
  final String type;

  /// Maximum guest count used when the UI summarizes occupancy.
  ///
  /// الحد الأقصى للضيوف المستخدم في تلخيص السعة داخل الواجهة.
  final int capacity;

  /// Amenity labels attached to the unit snapshot.
  ///
  /// تسميات المزايا المرتبطة بلقطة الوحدة.
  final List<String> amenities;

  /// Image URLs used by the booking and property detail views.
  ///
  /// روابط الصور المستخدمة في شاشات الحجز والعقار.
  final List<String> images;

  /// Optional marketing description for the unit.
  ///
  /// وصف تسويقي اختياري للوحدة.
  final String? description;

  /// Optional location note or coordinates payload.
  ///
  /// ملاحظة الموقع أو حمولة الإحداثيات إن وُجدت.
  final String? location;

  /// Creates the compact unit snapshot used by booking details.
  ///
  /// ينشئ لقطة الوحدة المختصرة المستخدمة في تفاصيل الحجز.
  const UnitDetails({
    required this.id,
    required this.name,
    required this.type,
    required this.capacity,
    required this.amenities,
    required this.images,
    this.description,
    this.location,
  });

  /// Keeps equality tied to the visible unit snapshot.
  ///
  /// يربط المقارنة بلقطة الوحدة الظاهرة.
  @override
  List<Object?> get props => [
        id,
        name,
        type,
        capacity,
        amenities,
        images,
        description,
        location,
      ];
}

/// Describes the property snapshot that frames the booking in the portal,
/// including contact data and policy metadata.
///
/// يصف لقطة العقار التي تمنح الحجز سياقه داخل البوابة، بما في ذلك بيانات
/// التواصل وبيانات السياسات.
class PropertyDetails extends Equatable {
  /// Identifier of the property that owns the booking.
  ///
  /// معرّف العقار الذي يملك الحجز.
  final String id;

  /// Property display name used in booking summaries.
  ///
  /// اسم العرض للعقار المستخدم في الملخصات.
  final String name;

  /// Human-readable address shown to staff and managers.
  ///
  /// العنوان المقروء بشريًا الظاهر للفريق والإدارة.
  final String address;

  /// Optional contact number for the property owner or front desk.
  ///
  /// رقم الاتصال الاختياري لمالك العقار أو مكتب الاستقبال.
  final String? phone;

  /// Optional email address for property-level communication.
  ///
  /// بريد إلكتروني اختياري للتواصل على مستوى العقار.
  final String? email;

  /// Property-level check-in time included in guest instructions.
  ///
  /// وقت تسجيل الدخول الخاص بالعقار والمستخدم في إرشادات الضيف.
  final String? checkInTime;

  /// Property-level check-out time included in guest instructions.
  ///
  /// وقت تسجيل الخروج الخاص بالعقار والمستخدم في إرشادات الضيف.
  final String? checkOutTime;

  /// Policy metadata captured at booking time or returned by the property API.
  ///
  /// بيانات السياسات الملتقطة وقت الحجز أو القادمة من API العقار.
  final Map<String, dynamic>? policies;

  /// Creates the property snapshot displayed beside the booking.
  ///
  /// ينشئ لقطة العقار المعروضة إلى جانب الحجز.
  const PropertyDetails({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    this.email,
    this.checkInTime,
    this.checkOutTime,
    this.policies,
  });

  /// Keeps equality focused on the property snapshot used in the portal.
  ///
  /// يربط المقارنة بلقطة العقار المستخدمة في البوابة.
  @override
  List<Object?> get props => [
        id,
        name,
        address,
        phone,
        email,
        checkInTime,
        checkOutTime,
        policies,
      ];
}
