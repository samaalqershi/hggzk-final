import '../../../../../core/enums/booking_status.dart';
import '../../domain/entities/booking.dart';

/// Adapts booking payloads from the backend into the canonical booking entity
/// used by the portal.
///
/// يكيّف بيانات الحجز القادمة من الخادم إلى الكيان القياسي الذي تعتمد عليه
/// البوابة.
class BookingModel extends Booking {
  /// Creates the immutable booking snapshot used throughout booking flows.
  ///
  /// ينشئ لقطة الحجز غير القابلة للتعديل المستخدمة في جميع تدفقات الحجز.
  const BookingModel({
    required super.id,
    required super.userId,
    required super.unitId,
    required super.checkIn,
    required super.checkOut,
    required super.guestsCount,
    required super.totalPrice,
    required super.status,
    required super.bookedAt,
    required super.userName,
    required super.unitName,
    super.userEmail,
    super.userPhone,
    super.unitImage,
    super.propertyId,
    super.propertyName,
    super.notes,
    super.specialRequests,
    super.cancellationReason,
    super.cancelledAt,
    super.confirmedAt,
    super.checkedInAt,
    super.checkedOutAt,
    super.bookingSource,
    super.isWalkIn,
    super.paymentStatus,
  });

  /// Reads booking records from several backend shapes and normalizes pricing,
  /// status, and timestamp fields before they reach the UI.
  ///
  /// تقرأ هذه الدالة سجلات الحجز من أكثر من صيغة للـ backend ثم توحد
  /// السعر والحالة والطوابع الزمنية قبل وصولها إلى الواجهة.
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Price can arrive as a nested money object, a raw amount, or a flat
    // totalAmount field depending on the endpoint.
    Money parsedTotalPrice;
    final totalPriceField = json['totalPrice'];
    final String currency = json['currency']?.toString() ?? 'YER';

    if (totalPriceField is Map) {
      parsedTotalPrice =
          MoneyModel.fromJson(Map<String, dynamic>.from(totalPriceField));
    } else if (json['totalAmount'] != null) {
      final double amount = (json['totalAmount'] is num)
          ? (json['totalAmount'] as num).toDouble()
          : double.tryParse(json['totalAmount'].toString()) ?? 0.0;
      parsedTotalPrice = MoneyModel(
        amount: amount,
        currency: currency,
        formattedAmount: '$currency ${amount.toStringAsFixed(2)}',
      );
    } else if (totalPriceField is num) {
      final double amount = totalPriceField.toDouble();
      parsedTotalPrice = MoneyModel(
        amount: amount,
        currency: currency,
        formattedAmount: '$currency ${amount.toStringAsFixed(2)}',
      );
    } else {
      parsedTotalPrice = MoneyModel(
        amount: 0.0,
        currency: currency,
        formattedAmount: '$currency 0.00',
      );
    }

    return BookingModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      unitId: json['unitId']?.toString() ?? '',
      checkIn: DateTime.parse(json['checkIn'] ??
          json['checkInDate'] ??
          DateTime.now().toIso8601String()),
      checkOut: DateTime.parse(json['checkOut'] ??
          json['checkOutDate'] ??
          DateTime.now().toIso8601String()),
      guestsCount: json['guestsCount'] ?? json['totalGuests'] ?? 1,
      totalPrice: parsedTotalPrice,
      status: _parseBookingStatus(json['status']),
      bookedAt: DateTime.parse(json['bookedAt'] ??
          json['bookingDate'] ??
          json['createdAt'] ??
          DateTime.now().toIso8601String()),
      userName: json['userName'] ?? '',
      unitName: json['unitName'] ?? '',
      userEmail: json['userEmail'],
      userPhone: json['userPhone'],
      unitImage: json['unitImage'],
      propertyId: json['propertyId']?.toString(),
      propertyName: json['propertyName'],
      notes: json['notes'],
      specialRequests: json['specialRequests'],
      cancellationReason: json['cancellationReason'],
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'])
          : null,
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'])
          : null,
      checkedInAt: json['checkedInAt'] != null
          ? DateTime.parse(json['checkedInAt'])
          : null,
      checkedOutAt: json['checkedOutAt'] != null
          ? DateTime.parse(json['checkedOutAt'])
          : null,
      bookingSource: json['bookingSource'],
      isWalkIn: json['isWalkIn'],
      paymentStatus: json['paymentStatus'],
    );
  }

  /// Serializes the booking back into the API contract expected by admin
  /// workflows.
  ///
  /// يعيد الحجز إلى عقد الـ API المتوقع في تدفقات الإدارة.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'unitId': unitId,
      'checkIn': checkIn.toIso8601String(),
      'checkOut': checkOut.toIso8601String(),
      'guestsCount': guestsCount,
      'totalPrice': (totalPrice as MoneyModel).toJson(),
      'status': status.displayNameEn,
      'bookedAt': bookedAt.toIso8601String(),
      'userName': userName,
      'unitName': unitName,
      if (userEmail != null) 'userEmail': userEmail,
      if (userPhone != null) 'userPhone': userPhone,
      if (unitImage != null) 'unitImage': unitImage,
      if (propertyId != null) 'propertyId': propertyId,
      if (propertyName != null) 'propertyName': propertyName,
      if (notes != null) 'notes': notes,
      if (specialRequests != null) 'specialRequests': specialRequests,
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
      if (cancelledAt != null) 'cancelledAt': cancelledAt!.toIso8601String(),
      if (confirmedAt != null) 'confirmedAt': confirmedAt!.toIso8601String(),
      if (checkedInAt != null) 'checkedInAt': checkedInAt!.toIso8601String(),
      if (checkedOutAt != null) 'checkedOutAt': checkedOutAt!.toIso8601String(),
      if (bookingSource != null) 'bookingSource': bookingSource,
      if (isWalkIn != null) 'isWalkIn': isWalkIn,
      if (paymentStatus != null) 'paymentStatus': paymentStatus,
    };
  }

  /// Normalizes booking status labels that may arrive from different backend
  /// services.
  ///
  /// يوحد أسماء حالات الحجز التي قد تأتي من خدمات خلفية مختلفة.
  static BookingStatus _parseBookingStatus(dynamic status) {
    if (status == null) return BookingStatus.pending;

    final statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'pending':
        return BookingStatus.pending;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      case 'checkedin':
      case 'checked_in':
        return BookingStatus.checkedIn;
      default:
        return BookingStatus.pending;
    }
  }

  /// Rebuilds the model from an existing booking entity without re-parsing the
  /// source payload.
  ///
  /// يعيد إنشاء النموذج من كيان الحجز نفسه دون إعادة تحليل الحمولة الأصلية.
  factory BookingModel.fromEntity(Booking entity) {
    return BookingModel(
      id: entity.id,
      userId: entity.userId,
      unitId: entity.unitId,
      checkIn: entity.checkIn,
      checkOut: entity.checkOut,
      guestsCount: entity.guestsCount,
      totalPrice: entity.totalPrice,
      status: entity.status,
      bookedAt: entity.bookedAt,
      userName: entity.userName,
      unitName: entity.unitName,
      userEmail: entity.userEmail,
      userPhone: entity.userPhone,
      unitImage: entity.unitImage,
      propertyId: entity.propertyId,
      propertyName: entity.propertyName,
      notes: entity.notes,
      specialRequests: entity.specialRequests,
      cancellationReason: entity.cancellationReason,
      cancelledAt: entity.cancelledAt,
      confirmedAt: entity.confirmedAt,
      checkedInAt: entity.checkedInAt,
      checkedOutAt: entity.checkedOutAt,
      bookingSource: entity.bookingSource,
      isWalkIn: entity.isWalkIn,
      paymentStatus: entity.paymentStatus,
    );
  }
}

/// Concrete money model used when the booking API returns or expects a typed
/// money object.
///
/// نموذج مالي فعلي يستخدم عندما تعيد الواجهة الخلفية كائنًا ماليًا أو تتوقعه.
class MoneyModel extends Money {
  /// Creates the immutable money value used by booking totals.
  ///
  /// ينشئ القيمة المالية غير القابلة للتعديل المستخدمة في إجماليات الحجز.
  const MoneyModel({
    required super.amount,
    required super.currency,
    required super.formattedAmount,
  });

  /// Parses a backend money object and preserves the formatted string if the
  /// server already provided one.
  ///
  /// يحلل كائن المال القادم من الخادم مع الحفاظ على النص المنسق إذا كان
  /// الخادم قد وفره مسبقًا.
  factory MoneyModel.fromJson(Map<String, dynamic> json) {
    return MoneyModel(
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'YER',
      formattedAmount: json['formattedAmount'] ??
          '${json['currency'] ?? 'YER'} ${(json['amount'] ?? 0).toStringAsFixed(2)}',
    );
  }

  /// Serializes the money snapshot using the API field names.
  ///
  /// يعيد لقطة المال باستخدام أسماء الحقول المعتمدة في الـ API.
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency': currency,
      'formattedAmount': formattedAmount,
    };
  }

  /// Converts a domain-level money object into the model variant used by the
  /// data layer.
  ///
  /// يحول كائن المال من طبقة المجال إلى النسخة المستخدمة في طبقة البيانات.
  factory MoneyModel.fromEntity(Money entity) {
    return MoneyModel(
      amount: entity.amount,
      currency: entity.currency,
      formattedAmount: entity.formattedAmount,
    );
  }
}
