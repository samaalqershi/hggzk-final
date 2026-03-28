import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_details.dart';
import 'booking_model.dart';
import '../../../../../core/enums/payment_method_enum.dart';
import 'dart:convert';

/// Normalizes booking-detail payloads coming from admin, mobile, and legacy
/// backends into the shape expected by the booking details screen.
///
/// يطبّع بيانات تفاصيل الحجز القادمة من الواجهات الخلفية المختلفة إلى
/// شكل واحد ثابت تعتمد عليه شاشة التفاصيل وعمليات التسجيل اللاحقة.
class BookingDetailsModel extends BookingDetails {
  /// Binds the parsed booking aggregate with its related payments, services,
  /// guest data, unit details, and property snapshot.
  ///
  /// يربط الحجز المُطبّع بكل العناصر المرتبطة به مثل الدفعات والخدمات
  /// وبيانات الضيف والوحدة والعقار حتى يبقى الكيان منسجمًا عند النقل بين الطبقات.
  const BookingDetailsModel({
    required super.booking,
    required super.payments,
    required super.services,
    super.activities,
    super.guestInfo,
    super.unitDetails,
    super.propertyDetails,
  });

  /// Accepts the different payload shapes returned by booking endpoints and
  /// reshapes them into a single detail model that the portal can render.
  ///
  /// تقبل هذه الدالة أكثر من صيغة للرد القادم من الخادم، ثم تعيد بناء
  /// الحجز والدفعات والخدمات والبيانات المساندة في نموذج موحّد يمكن للواجهة قراءته مباشرة.
  factory BookingDetailsModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? safeDecodeJsonMap(dynamic v) {
      try {
        if (v == null) return null;
        if (v is Map) return Map<String, dynamic>.from(v);
        if (v is String) {
          final decoded = jsonDecode(v);
          if (decoded is Map) return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
      return null;
    }

    double readDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    double extractAmountFromMoneyLike(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      if (value is Map) {
        return readDouble(value['amount']);
      }
      return 0;
    }

    // The backend may return either a nested booking object or a flat details
    // DTO that already contains booking totals, contact info, and images.
    final Object? bookingNode = json['booking'] ?? json;
    final Map<String, dynamic> bookingRaw = bookingNode is Map
        ? Map<String, dynamic>.from(bookingNode)
        : <String, dynamic>{};

    // Rebuild the booking payload into the canonical shape expected by
    // BookingModel.fromJson so the rest of the app can remain backend-agnostic.
    final bool isFlatDetailsDto = bookingRaw.isNotEmpty &&
        (bookingRaw.containsKey('totalAmount') ||
            bookingRaw.containsKey('bookingNumber') ||
            bookingRaw.containsKey('contactInfo') ||
            bookingRaw.containsKey('checkIn') ||
            bookingRaw.containsKey('checkInDate'));

    Map<String, dynamic> normalizedBookingMap;
    if (bookingNode == json && isFlatDetailsDto) {
      // Convert flat detail payloads into a BookingModel-compatible map.
      final String? currency = bookingRaw['currency']?.toString();
      final double baseAmount = readDouble(bookingRaw['totalAmount']);
      final double totalAmountWithServices =
          readDouble(bookingRaw['totalAmountWithServices']);
      final double totalPriceAmountFromField =
          extractAmountFromMoneyLike(bookingRaw['totalPrice']);
      final double totalAmount = totalAmountWithServices > 0
          ? totalAmountWithServices
          : (totalPriceAmountFromField > 0
              ? totalPriceAmountFromField
              : baseAmount);
      final String formattedAmount =
          '${currency ?? 'YER'} ${totalAmount.toStringAsFixed(2)}';

      final DateTime? actualCheckIn =
          _tryParseDate(bookingRaw['actualCheckInDate']);
      final DateTime? actualCheckOut =
          _tryParseDate(bookingRaw['actualCheckOutDate']);
      final DateTime? confirmedAt = _tryParseDate(bookingRaw['confirmedAt']);
      final DateTime? cancelledAt = _tryParseDate(bookingRaw['cancelledAt']);

      final List unitImages = (bookingRaw['unitImages'] is List)
          ? (bookingRaw['unitImages'] as List)
          : const [];

      // Contact info is reused when the backend omits the dedicated guest block.
      final Map<String, dynamic> contactInfo = Map<String, dynamic>.from(
          (bookingRaw['contactInfo'] is Map) ? bookingRaw['contactInfo'] : {});

      normalizedBookingMap = {
        'id': bookingRaw['id']?.toString() ?? '',
        'userId': bookingRaw['userId']?.toString() ?? '',
        'unitId': bookingRaw['unitId']?.toString() ?? '',
        'checkIn':
            (bookingRaw['checkIn'] ?? bookingRaw['checkInDate'])?.toString() ??
                DateTime.now().toIso8601String(),
        'checkOut': (bookingRaw['checkOut'] ?? bookingRaw['checkOutDate'])
                ?.toString() ??
            DateTime.now().toIso8601String(),
        'guestsCount': bookingRaw['guestsCount'] ??
            ((bookingRaw['adultGuests'] ?? 0) +
                (bookingRaw['childGuests'] ?? 0)),
        'totalPrice': {
          'amount': totalAmount,
          'currency': currency ?? 'YER',
          'formattedAmount': formattedAmount,
        },
        'status': bookingRaw['status']?.toString(),
        'bookedAt':
            (bookingRaw['bookedAt'] ?? bookingRaw['bookingDate'])?.toString() ??
                DateTime.now().toIso8601String(),
        'userName': bookingRaw['userName'] ?? '',
        'unitName': bookingRaw['unitName'] ?? '',
        'userEmail': bookingRaw['userEmail'] ?? contactInfo['email'],
        'userPhone': bookingRaw['userPhone'] ?? contactInfo['phoneNumber'],
        'unitImage':
            unitImages.isNotEmpty ? unitImages.first?.toString() : null,
        'propertyId': bookingRaw['propertyId']?.toString(),
        'propertyName': bookingRaw['propertyName'],
        'notes': bookingRaw['specialNotes'],
        'specialRequests': bookingRaw['specialRequests'],
        'cancellationReason': bookingRaw['cancellationReason'],
        'cancelledAt': cancelledAt?.toIso8601String(),
        'confirmedAt': confirmedAt?.toIso8601String(),
        'checkedInAt':
            (actualCheckIn ?? _tryParseDate(bookingRaw['checkedInAt']))
                ?.toIso8601String(),
        'checkedOutAt':
            (actualCheckOut ?? _tryParseDate(bookingRaw['checkedOutAt']))
                ?.toIso8601String(),
        'bookingSource': bookingRaw['bookingSource'],
        'isWalkIn': bookingRaw['isWalkIn'],
        'paymentStatus': bookingRaw['paymentStatus'],
      };
    } else {
      // Already in the canonical nested booking shape.
      normalizedBookingMap = bookingRaw;
    }

    List paymentsRaw = const [];
    if (json['payments'] is List) {
      // Preserve the original list so PaymentModel can normalize each entry.
      paymentsRaw = json['payments'] as List;
    }

    if (paymentsRaw.isEmpty && json['paymentDetails'] is List) {
      paymentsRaw = json['paymentDetails'] as List;
    }

    List servicesRaw = const [];
    if (json['services'] is List) servicesRaw = json['services'] as List;
    servicesRaw = servicesRaw.whereType<Map>().map((s) {
      final ms = Map<String, dynamic>.from(s);
      // Some APIs return service totals instead of a per-unit price. Convert
      // those records into the canonical Service shape used throughout the UI.
      if (ms.containsKey('totalPrice') || ms.containsKey('currency')) {
        final int qty = (ms['quantity'] ?? 1) is int
            ? (ms['quantity'] ?? 1)
            : int.tryParse(ms['quantity'].toString()) ?? 1;
        final double total = readDouble(ms['totalPrice']);
        final String cur = ms['currency']?.toString() ??
            (normalizedBookingMap['totalPrice']?['currency']?.toString() ??
                'YER');
        final double unitPrice = qty > 0 ? (total / qty) : total;
        return {
          'id': ms['id']?.toString() ?? '',
          'name': ms['name'] ?? '',
          'description': ms['description'] ?? '',
          'quantity': qty,
          'price': {
            'amount': unitPrice,
            'currency': cur,
            'formattedAmount': '$cur ${unitPrice.toStringAsFixed(2)}',
          },
          'icon': ms['icon'],
          'category': ms['category'],
        };
      }
      return ms;
    }).toList();

    List activitiesRaw = const [];
    if (json['activities'] is List) activitiesRaw = json['activities'] as List;

    // Guest information can be returned either as a dedicated object or as
    // a contact-info block shared with the booking header.
    final guestInfoRaw = json['guestInfo'] ?? json['contactInfo'];

    // Unit details may be omitted in older payloads, so image-only data is used
    // to keep the details panel useful instead of blank.
    Map<String, dynamic>? unitDetailsRaw;
    if (json['unitDetails'] is Map) {
      unitDetailsRaw = Map<String, dynamic>.from(json['unitDetails']);
    } else if (json['unitImages'] is List) {
      unitDetailsRaw = {
        'id': normalizedBookingMap['unitId'] ?? '',
        'name': normalizedBookingMap['unitName'] ?? '',
        'type': '',
        'capacity': normalizedBookingMap['guestsCount'] ?? 1,
        'amenities': const <String>[],
        'images': List<String>.from(
            (json['unitImages'] as List).map((e) => e.toString())),
      };
    }

    // The property snapshot is reconstructed when the backend only provides
    // an address field and not the full property object.
    Map<String, dynamic>? propertyDetailsRaw;
    if (json['propertyDetails'] is Map) {
      propertyDetailsRaw = Map<String, dynamic>.from(json['propertyDetails']);
    } else if (bookingRaw['propertyAddress'] != null ||
        json['propertyAddress'] != null) {
      propertyDetailsRaw = {
        'id': normalizedBookingMap['propertyId'] ?? '',
        'name': normalizedBookingMap['propertyName'] ?? '',
        'address':
            (bookingRaw['propertyAddress'] ?? json['propertyAddress'] ?? '')
                .toString(),
      };
    }

    // Preserve the captured policy snapshot so the portal can show the rules
    // that were active at booking time, even if the live policy changes later.
    try {
      final dynamic snapRaw =
          json['policySnapshot'] ?? bookingRaw['policySnapshot'];
      if (snapRaw is String && snapRaw.trim().isNotEmpty) {
        final Map<String, dynamic> snap = jsonDecode(snapRaw);
        final List policies = snap['Policies'] ?? const [];
        final Map<String, dynamic> policiesByType = {};
        for (final p in policies.whereType<Map>()) {
          final mp = Map<String, dynamic>.from(p);
          final String type = (mp['Type']?.toString() ?? '').toLowerCase();
          if (type.isEmpty) continue;
          policiesByType[type] = {
            'description': mp['Description'],
            'rules': safeDecodeJsonMap(mp['Rules']),
            'cancellationWindowDays': mp['CancellationWindowDays'],
            'requireFullPaymentBeforeConfirmation':
                mp['RequireFullPaymentBeforeConfirmation'],
            'minimumDepositPercentage': mp['MinimumDepositPercentage'],
            'minHoursBeforeCheckIn': mp['MinHoursBeforeCheckIn'],
          };
        }
        final saved = {
          'capturedAt': snap['CapturedAt'],
          'unitOverrides': snap['UnitOverrides'],
          'policiesByType': policiesByType,
        };
        propertyDetailsRaw ??= {
          'id': normalizedBookingMap['propertyId'] ?? '',
          'name': normalizedBookingMap['propertyName'] ?? '',
          'address':
              bookingRaw['propertyAddress'] ?? json['propertyAddress'] ?? '',
        };
        final Map<String, dynamic> existingPolicies = Map<String, dynamic>.from(
            propertyDetailsRaw['policies'] ?? <String, dynamic>{});
        existingPolicies['saved'] = saved;
        propertyDetailsRaw['policies'] = existingPolicies;
      }
    } catch (_) {}

    final processedPayments = paymentsRaw
        .whereType<Map>()
        .map((p) {
          try {
            return PaymentModel.fromJson(Map<String, dynamic>.from(p));
          } catch (e) {
            return null;
          }
        })
        .where((p) => p != null)
        .cast<PaymentModel>()
        .toList();

    return BookingDetailsModel(
      booking: BookingModel.fromJson(normalizedBookingMap),
      payments: processedPayments,
      services: servicesRaw
          .whereType<Map>()
          .map((s) => ServiceModel.fromJson(Map<String, dynamic>.from(s)))
          .toList(),
      activities: activitiesRaw
          .whereType<Map>()
          .map((a) =>
              BookingActivityModel.fromJson(Map<String, dynamic>.from(a)))
          .toList(),
      guestInfo: guestInfoRaw is Map
          ? GuestInfoModel.fromJson(Map<String, dynamic>.from(guestInfoRaw))
          : null,
      unitDetails: unitDetailsRaw != null
          ? UnitDetailsModel.fromJson(unitDetailsRaw)
          : null,
      propertyDetails: propertyDetailsRaw != null
          ? PropertyDetailsModel.fromJson(propertyDetailsRaw)
          : null,
    );
  }

  /// Emits the canonical booking-details payload expected by the booking APIs.
  ///
  /// يعيد بناء الحمولة القياسية لتفاصيل الحجز بما يتوافق مع تنسيق
  /// الواجهات الخلفية التي تتوقع بنية booking مع العناصر المرتبطة بها.
  Map<String, dynamic> toJson() {
    return {
      'booking': (booking as BookingModel).toJson(),
      'payments': payments.map((p) => (p as PaymentModel).toJson()).toList(),
      'services': services.map((s) => (s as ServiceModel).toJson()).toList(),
      'activities':
          activities.map((a) => (a as BookingActivityModel).toJson()).toList(),
      if (guestInfo != null)
        'guestInfo': (guestInfo as GuestInfoModel).toJson(),
      if (unitDetails != null)
        'unitDetails': (unitDetails as UnitDetailsModel).toJson(),
      if (propertyDetails != null)
        'propertyDetails': (propertyDetails as PropertyDetailsModel).toJson(),
    };
  }
}

/// Describes a single payment record attached to the booking, including the
/// captured amount, gateway method, and any refund metadata.
///
/// يصف سجل الدفعة المرتبط بالحجز بما فيه المبلغ وطريقة الدفع وحالة السداد
/// وأي بيانات استرجاع أو إلغاء أرجعتها الواجهة الخلفية.
class PaymentModel extends Payment {
  /// Holds a payment in its normalized form after amount parsing and enum
  /// resolution have already been completed.
  /// يحتفظ بالدفعة بعد تطبيعها كاملًا، أي بعد تحليل المبلغ وحسم قيم الـ enum
  /// المرتبطة بالطريقة والحالة.
  const PaymentModel({
    required super.id,
    required super.bookingId,
    required super.amount,
    required super.transactionId,
    required super.method,
    required super.status,
    required super.paymentDate,
    super.refundReason,
    super.refundedAt,
    super.receiptUrl,
  });

  /// Accepts several payment payload shapes and resolves them into a stable
  /// payment record regardless of how the backend formats money values.
  ///
  /// تتعامل هذه الدالة مع أكثر من شكل لبيانات الدفعة، ثم توحّدها إلى
  /// سجل واحد يمكن للنظام اعتماده في العرض والحسابات والتقارير.
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    Money amountObj;
    if (json['amount'] is Map) {
      amountObj =
          MoneyModel.fromJson(Map<String, dynamic>.from(json['amount']));
    } else if (json['amountMoney'] is Map) {
      amountObj =
          MoneyModel.fromJson(Map<String, dynamic>.from(json['amountMoney']));
    } else if (json['amount'] is num) {
      final currency = json['currency']?.toString() ?? 'YER';
      final amount = (json['amount'] as num).toDouble();
      amountObj = MoneyModel(
        amount: amount,
        currency: currency,
        formattedAmount: '$currency ${amount.toStringAsFixed(2)}',
      );
    } else {
      amountObj = MoneyModel(
        amount: 0,
        currency: 'YER',
        formattedAmount: 'YER 0.00',
      );
    }

    return PaymentModel(
      id: json['id']?.toString() ?? '',
      bookingId: json['bookingId']?.toString() ?? '',
      amount: amountObj,
      transactionId: json['transactionId']?.toString() ?? '',
      method: _parsePaymentMethod(json['method']),
      status: _parsePaymentStatus(json['status']),
      paymentDate: DateTime.parse(
          json['paymentDate']?.toString() ?? DateTime.now().toIso8601String()),
      refundReason: json['refundReason'],
      refundedAt: json['refundedAt'] != null
          ? DateTime.parse(json['refundedAt'])
          : null,
      receiptUrl: json['receiptUrl'],
    );
  }

  /// Serializes the payment back into the backend key naming used by the
  /// admin booking endpoints.
  ///
  /// يعيد الدفعة إلى نفس البنية التي يتوقعها خادم الإدارة عند الحفظ أو
  /// إعادة الإرسال، مع الإبقاء على مفاتيح الحقول كما هي في الـ API.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'amount': (amount as MoneyModel).toJson(),
      'transactionId': transactionId,
      'method': method.backendValue,
      'status': status.displayNameEn,
      'paymentDate': paymentDate.toIso8601String(),
      if (refundReason != null) 'refundReason': refundReason,
      if (refundedAt != null) 'refundedAt': refundedAt!.toIso8601String(),
      if (receiptUrl != null) 'receiptUrl': receiptUrl,
    };
  }

  /// Resolves the payment method from backend values that may arrive as enums,
  /// integers, or localized strings.
  ///
  /// يحوّل طريقة الدفع القادمة من الخادم بصيغ مختلفة إلى قيمة enum ثابتة
  /// حتى لا تتشتت قواعد الدفع داخل الواجهة.
  static PaymentMethod _parsePaymentMethod(dynamic method) {
    if (method == null) return PaymentMethod.cash;
    if (method is int) {
      return PaymentMethodExtension.fromBackendValue(method);
    }
    if (method is String) {
      return PaymentMethodExtension.fromString(method);
    }
    return PaymentMethod.cash;
  }

  /// Resolves the payment status from backend payloads that may mix enum
  /// names, display labels, or serialized strings.
  ///
  /// يحول حالة الدفع القادمة من الخادم إلى القيمة الداخلية الموحدة التي
  /// تعتمد عليها الشاشات والتقارير.
  static PaymentStatus _parsePaymentStatus(dynamic status) {
    if (status == null) return PaymentStatus.pending;
    return PaymentStatusExtension.fromString(status.toString());
  }
}

/// Captures a service line item attached to a booking and keeps the unit price
/// and quantity aligned with the totals shown in the portal.
///
/// يمثل بند الخدمة المضاف إلى الحجز مع الحفاظ على سعر الوحدة والكمية
/// بما يطابق الأرقام المعروضة في بوابة الإدارة.
class ServiceModel extends Service {
  /// Captures the immutable service payload used by the admin screens so the
  /// same pricing and quantity values can travel between API mapping and UI.
  ///
  /// ينشئ تمثيل الخدمة كما تحتاجه شاشات الإدارة حتى تبقى بيانات السعر
  /// والكمية متطابقة بين التحويل من الخادم والعرض داخل الواجهة.
  const ServiceModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.quantity,
    super.icon,
    super.category,
  });

  /// Builds a service line item from the payload returned by the booking API.
  ///
  /// تنشئ بند الخدمة من الحمولة القادمة من الواجهة الخلفية بعد أن تكون
  /// القيم المالية قد تم تطبيعها مسبقًا.
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price:
          MoneyModel.fromJson(Map<String, dynamic>.from(json['price'] ?? {})),
      quantity: json['quantity'] ?? 1,
      icon: json['icon'],
      category: json['category'],
    );
  }

  /// Serializes the service line item using the same structure expected by the
  /// backend booking endpoints.
  ///
  /// تعيد خدمة الحجز إلى البنية نفسها التي يستخدمها الخادم عند الحفظ أو التحديث.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': (price as MoneyModel).toJson(),
      'quantity': quantity,
      if (icon != null) 'icon': icon,
      if (category != null) 'category': category,
    };
  }
}

/// Describes a timeline entry for booking actions such as confirmation,
/// cancellation, check-in, or check-out.
///
/// يصف سجلًا زمنيًا لأحداث الحجز مثل التأكيد أو الإلغاء أو تسجيل الدخول
/// والخروج حتى تستطيع شاشة المسار الزمني عرض التسلسل بدقة.
class BookingActivityModel extends BookingActivity {
  /// Creates the timeline activity object used by booking audit and history
  /// widgets after the API payload is normalized.
  ///
  /// ينشئ كائن نشاط الخط الزمني المستخدم في التدقيق وسجل الحجز بعد تطبيع
  /// حمولة الواجهة الخلفية.
  const BookingActivityModel({
    required super.id,
    required super.action,
    required super.description,
    required super.timestamp,
    super.userId,
    super.userName,
  });

  /// Parses an activity record exactly as the timeline view needs it.
  ///
  /// تحلل سجل النشاط بالشكل الذي تحتاجه شاشة التسلسل الزمني مباشرة.
  factory BookingActivityModel.fromJson(Map<String, dynamic> json) {
    return BookingActivityModel(
      id: json['id']?.toString() ?? '',
      action: json['action'] ?? '',
      description: json['description'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['userId']?.toString(),
      userName: json['userName'],
    );
  }

  /// Serializes the activity entry using a timeline-friendly ISO timestamp.
  ///
  /// تعيد عنصر النشاط بصيغة مناسبة للحفظ مع طابع زمني بصيغة ISO.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      if (userId != null) 'userId': userId,
      if (userName != null) 'userName': userName,
    };
  }
}

/// Holds the guest identity and contact data that the booking summary needs
/// when the backend separates traveler details from the booking itself.
///
/// يحتفظ ببيانات هوية الضيف ووسائل الاتصال به عندما تفصل الواجهة الخلفية
/// معلومات المسافر عن سجل الحجز الرئيسي.
class GuestInfoModel extends GuestInfo {
  /// Creates the guest-contact snapshot consumed by admin detail screens after
  /// booking payloads are normalized.
  ///
  /// ينشئ لقطة بيانات الضيف التي تستهلكها شاشات الإدارة بعد تطبيع حمولة الحجز.
  const GuestInfoModel({
    required super.name,
    required super.email,
    required super.phone,
    super.nationality,
    super.idNumber,
    super.idType,
    super.address,
  });

  /// Extracts guest contact fields from the payload used by the booking APIs.
  ///
  /// تستخرج بيانات التواصل الخاصة بالضيف من الحمولة القادمة من واجهات الحجز.
  factory GuestInfoModel.fromJson(Map<String, dynamic> json) {
    return GuestInfoModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      nationality: json['nationality'],
      idNumber: json['idNumber'],
      idType: json['idType'],
      address: json['address'],
    );
  }

  /// Serializes the guest profile without adding any portal-specific wrappers.
  ///
  /// تعيد ملف الضيف بصيغته المباشرة دون تغليف إضافي خاص بالبوابة.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      if (nationality != null) 'nationality': nationality,
      if (idNumber != null) 'idNumber': idNumber,
      if (idType != null) 'idType': idType,
      if (address != null) 'address': address,
    };
  }
}

/// Describes the booked unit and the limited details required by the booking
/// details screen, including its images and capacity.
///
/// يصف الوحدة المحجوزة بالمعلومات التي تحتاجها شاشة التفاصيل مثل الصور
/// والسعة والنوع حتى تبقى الواجهة غنية حتى مع payload ناقص.
class UnitDetailsModel extends UnitDetails {
  /// Creates the unit snapshot used in booking details so accommodation facts
  /// remain available even when the booking entity is partially loaded.
  ///
  /// ينشئ لقطة الوحدة المستخدمة في تفاصيل الحجز حتى تبقى معلومات السكن
  /// متاحة حتى لو كانت بيانات الحجز الأساسية جزئية.
  const UnitDetailsModel({
    required super.id,
    required super.name,
    required super.type,
    required super.capacity,
    required super.amenities,
    required super.images,
    super.description,
    super.location,
  });

  /// Rebuilds the unit snapshot from the payload returned by the booking API.
  ///
  /// تعيد بناء لقطة الوحدة من البيانات القادمة من الواجهة الخلفية.
  factory UnitDetailsModel.fromJson(Map<String, dynamic> json) {
    return UnitDetailsModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      capacity: json['capacity'] ?? 1,
      amenities: List<String>.from(json['amenities'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      description: json['description'],
      location: json['location'],
    );
  }

  /// Serializes the unit snapshot back into the shape used by the backend.
  ///
  /// تعيد لقطة الوحدة إلى الشكل الذي يتوقعه الخادم عند الحفظ أو النقل.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'capacity': capacity,
      'amenities': amenities,
      'images': images,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
    };
  }
}

/// Captures the property snapshot that accompanies a booking so the details
/// screen can show the property name, address, and policy context.
///
/// يحتفظ بلقطة العقار المرافقة للحجز حتى تعرض شاشة التفاصيل الاسم والعنوان
/// وسياق السياسات المرتبطة بوقت الحجز.
class PropertyDetailsModel extends PropertyDetails {
  /// Creates the property snapshot used by booking details so property contact
  /// data and policy context remain attached to the reservation.
  ///
  /// ينشئ لقطة العقار المستخدمة في تفاصيل الحجز حتى تبقى بيانات التواصل
  /// وسياق السياسات مرتبطين بالحجز.
  const PropertyDetailsModel({
    required super.id,
    required super.name,
    required super.address,
    super.phone,
    super.email,
    super.checkInTime,
    super.checkOutTime,
    super.policies,
  });

  /// Extracts the property subset needed by the booking details view.
  ///
  /// تستخرج الجزء الخاص بالعقار الذي تحتاجه شاشة تفاصيل الحجز.
  factory PropertyDetailsModel.fromJson(Map<String, dynamic> json) {
    return PropertyDetailsModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'],
      email: json['email'],
      checkInTime: json['checkInTime'],
      checkOutTime: json['checkOutTime'],
      policies: json['policies'] as Map<String, dynamic>?,
    );
  }

  /// Serializes the property snapshot while preserving optional policy fields.
  ///
  /// تعيد لقطة العقار مع الحقول الاختيارية الخاصة بالسياسات عند وجودها.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (checkInTime != null) 'checkInTime': checkInTime,
      if (checkOutTime != null) 'checkOutTime': checkOutTime,
      if (policies != null) 'policies': policies,
    };
  }
}

/// Parses date values that can arrive as ISO strings, epoch values, or already
/// materialized `DateTime` instances.
///
/// يحلل قيم التاريخ التي قد تأتي بصيغة ISO أو كطابع زمني رقمي أو ككائن
/// `DateTime` جاهز من طبقة وسيطة.
DateTime? _tryParseDate(dynamic raw) {
  if (raw == null) return null;
  if (raw is DateTime) return raw;

  if (raw is num) {
    return _dateTimeFromEpoch(raw.toInt());
  }

  final String value = raw.toString().trim();
  if (value.isEmpty) return null;

  final DateTime? parsed = DateTime.tryParse(value);
  if (parsed != null) return parsed;

  final int? epoch = int.tryParse(value);
  if (epoch != null) {
    return _dateTimeFromEpoch(epoch);
  }

  return null;
}

/// Converts epoch timestamps in seconds, milliseconds, or microseconds into a
/// local `DateTime` value.
///
/// يحول الطوابع الزمنية بصيغ الثواني أو المللي ثانية أو الميكرو ثانية إلى
/// قيمة `DateTime` محلية مناسبة للعرض.
DateTime? _dateTimeFromEpoch(int epoch) {
  if (epoch <= 0) return null;

  if (epoch < 1000000000000) {
    return DateTime.fromMillisecondsSinceEpoch(epoch * 1000, isUtc: true)
        .toLocal();
  }

  if (epoch < 1000000000000000) {
    return DateTime.fromMillisecondsSinceEpoch(epoch, isUtc: true).toLocal();
  }

  return DateTime.fromMicrosecondsSinceEpoch(epoch, isUtc: true).toLocal();
}
