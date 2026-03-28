import 'package:equatable/equatable.dart';

/// العربية: يعرّف جميع أحداث شاشة تفاصيل الحجز من التحميل إلى الطباعة والإرسال.
/// English: Defines every booking-details action from loading and editing to printing and sending confirmations.
abstract class BookingDetailsEvent extends Equatable {
  /// العربية: ينشئ الأساس المشترك لأحداث تفاصيل الحجز.
  /// English: Creates the shared base for booking-details events.
  const BookingDetailsEvent();

  /// العربية: لا توجد قيم مشتركة، لذا تعتمد المساواة على الفئات الفرعية.
  /// English: No shared values exist here, so equality is controlled by subclasses.
  @override
  List<Object?> get props => [];
}

/// العربية: يطلب تحميل تفاصيل حجز واحد بالاعتماد على معرّفه.
/// English: Requests the full details for a single booking by its identifier.
class LoadBookingDetailsEvent extends BookingDetailsEvent {
  /// العربية: معرّف الحجز المطلوب تحميله.
  /// English: The identifier of the booking to load.
  final String bookingId;

  /// العربية: ينشئ طلب تحميل تفاصيل الحجز.
  /// English: Creates the booking-details load request.
  const LoadBookingDetailsEvent({required this.bookingId});

  /// العربية: يعتمد على معرّف الحجز في المقارنة القيمية.
  /// English: Uses the booking id for value equality.
  @override
  List<Object> get props => [bookingId];
}

/// العربية: يطلب إعادة تحميل التفاصيل الحالية للحجز نفسه.
/// English: Requests a reload of the current booking details.
class RefreshBookingDetailsEvent extends BookingDetailsEvent {
  /// العربية: ينشئ حدث التحديث دون معايير إضافية.
  /// English: Creates the refresh event with no additional parameters.
  const RefreshBookingDetailsEvent();
}

/// العربية: يطلب تعديل بيانات الحجز مثل التواريخ أو عدد الضيوف.
/// English: Requests a booking update such as dates or guest count changes.
class UpdateBookingDetailsEvent extends BookingDetailsEvent {
  /// العربية: معرّف الحجز المراد تعديله.
  /// English: The identifier of the booking to update.
  final String bookingId;

  /// العربية: تاريخ الوصول الجديد عند توفره.
  /// English: The new check-in date when available.
  final DateTime? checkIn;

  /// العربية: تاريخ المغادرة الجديد عند توفره.
  /// English: The new check-out date when available.
  final DateTime? checkOut;

  /// العربية: العدد الجديد للضيوف عند توفره.
  /// English: The updated guest count when available.
  final int? guestsCount;

  /// العربية: ينشئ حدث تعديل تفاصيل الحجز بالقيم المتاحة فقط.
  /// English: Creates the booking-details update event with only the supplied values.
  const UpdateBookingDetailsEvent({
    required this.bookingId,
    this.checkIn,
    this.checkOut,
    this.guestsCount,
  });

  /// العربية: يضم كل قيمة قابلة للتعديل في المقارنة القيمية.
  /// English: Includes every editable value in equality checks.
  @override
  List<Object?> get props => [bookingId, checkIn, checkOut, guestsCount];
}

/// العربية: يطلب إلغاء الحجز مع سبب الإلغاء وخيار استرجاع الدفعات.
/// English: Requests a booking cancellation with a reason and optional payment refunds.
class CancelBookingDetailsEvent extends BookingDetailsEvent {
  /// العربية: معرّف الحجز المراد إلغاؤه.
  /// English: The identifier of the booking to cancel.
  final String bookingId;

  /// العربية: سبب الإلغاء الذي سيحفظ في السجل أو يظهر للمستخدم.
  /// English: The cancellation reason stored in logs or shown to the user.
  final String cancellationReason;

  /// العربية: يحدد ما إذا كان يجب استرجاع الدفعات المرتبطة بالحجز.
  /// English: Indicates whether related payments should be refunded.
  final bool refundPayments;

  /// العربية: ينشئ حدث الإلغاء بكل بياناته المطلوبة.
  /// English: Creates the cancellation event with all required data.
  const CancelBookingDetailsEvent({
    required this.bookingId,
    required this.cancellationReason,
    this.refundPayments = false,
  });

  /// العربية: يعتمد على معرّف الحجز وسبب الإلغاء وخيار الاسترجاع.
  /// English: Compares by booking id, cancellation reason, and refund flag.
  @override
  List<Object> get props => [bookingId, cancellationReason, refundPayments];
}

/// العربية: يطلب اعتماد الحجز بعد مراجعة بياناته.
/// English: Requests confirmation of a booking after its data is reviewed.
class ConfirmBookingDetailsEvent extends BookingDetailsEvent {
  /// العربية: معرّف الحجز المراد تأكيده.
  /// English: The identifier of the booking to confirm.
  final String bookingId;

  /// العربية: ينشئ حدث تأكيد الحجز.
  /// English: Creates the booking confirmation event.
  const ConfirmBookingDetailsEvent({required this.bookingId});

  /// العربية: يعتمد على معرّف الحجز فقط.
  /// English: Uses the booking id only for equality.
  @override
  List<Object> get props => [bookingId];
}

/// العربية: يطلب تسجيل وصول الضيف للحجز الحالي.
/// English: Requests a check-in for the current booking.
class CheckInBookingDetailsEvent extends BookingDetailsEvent {
  /// العربية: معرّف الحجز المراد تسجيل الوصول له.
  /// English: The identifier of the booking to check in.
  final String bookingId;

  /// العربية: ينشئ حدث تسجيل الوصول.
  /// English: Creates the check-in event.
  const CheckInBookingDetailsEvent({required this.bookingId});

  /// العربية: يعتمد على معرّف الحجز فقط.
  /// English: Uses the booking id only for equality.
  @override
  List<Object> get props => [bookingId];
}

/// العربية: يطلب تسجيل مغادرة الضيف للحجز الحالي.
/// English: Requests a check-out for the current booking.
class CheckOutBookingDetailsEvent extends BookingDetailsEvent {
  /// العربية: معرّف الحجز المراد تسجيل المغادرة له.
  /// English: The identifier of the booking to check out.
  final String bookingId;

  /// العربية: ينشئ حدث تسجيل المغادرة.
  /// English: Creates the check-out event.
  const CheckOutBookingDetailsEvent({required this.bookingId});

  /// العربية: يعتمد على معرّف الحجز فقط.
  /// English: Uses the booking id only for equality.
  @override
  List<Object> get props => [bookingId];
}

/// العربية: يضيف خدمة إلى الحجز الحالي.
/// English: Adds a service to the current booking.
class AddServiceEvent extends BookingDetailsEvent {
  /// العربية: معرّف الحجز الذي ستضاف إليه الخدمة.
  /// English: The booking identifier that receives the service.
  final String bookingId;

  /// العربية: معرّف الخدمة المطلوب إضافتها.
  /// English: The identifier of the service to add.
  final String serviceId;

  /// العربية: ينشئ حدث إضافة الخدمة.
  /// English: Creates the service-addition event.
  const AddServiceEvent({
    required this.bookingId,
    required this.serviceId,
  });

  /// العربية: يعتمد على الحجز والخدمة معًا.
  /// English: Compares by both booking and service identifiers.
  @override
  List<Object> get props => [bookingId, serviceId];
}

/// العربية: يزيل خدمة من الحجز الحالي.
/// English: Removes a service from the current booking.
class RemoveServiceEvent extends BookingDetailsEvent {
  /// العربية: معرّف الحجز الذي ستزال منه الخدمة.
  /// English: The booking identifier that loses the service.
  final String bookingId;

  /// العربية: معرّف الخدمة المطلوب إزالتها.
  /// English: The identifier of the service to remove.
  final String serviceId;

  /// العربية: ينشئ حدث إزالة الخدمة.
  /// English: Creates the service-removal event.
  const RemoveServiceEvent({
    required this.bookingId,
    required this.serviceId,
  });

  /// العربية: يعتمد على الحجز والخدمة معًا.
  /// English: Compares by both booking and service identifiers.
  @override
  List<Object> get props => [bookingId, serviceId];
}

/// العربية: يطلب تحميل الخدمات المربوطة بالحجز حتى يمكن عرضها أو تعديلها.
/// English: Requests the services attached to a booking so they can be displayed or edited.
class LoadBookingServicesEvent extends BookingDetailsEvent {
  /// العربية: معرّف الحجز المطلوب جلب خدماته.
  /// English: The identifier of the booking whose services should be loaded.
  final String bookingId;

  /// العربية: ينشئ حدث تحميل الخدمات.
  /// English: Creates the service-loading event.
  const LoadBookingServicesEvent({required this.bookingId});

  /// العربية: يعتمد على معرّف الحجز فقط.
  /// English: Uses the booking id only for equality.
  @override
  List<Object> get props => [bookingId];
}

/// العربية: يطلب تحميل النشاطات المسجلة للحجز لأغراض التدقيق أو العرض الزمني.
/// English: Requests the activity log for the booking for audit or timeline display.
class LoadBookingActivitiesEvent extends BookingDetailsEvent {
  /// العربية: معرّف الحجز المطلوب جلب نشاطاته.
  /// English: The identifier of the booking whose activities should be loaded.
  final String bookingId;

  /// العربية: ينشئ حدث تحميل النشاطات.
  /// English: Creates the activity-loading event.
  const LoadBookingActivitiesEvent({required this.bookingId});

  /// العربية: يعتمد على معرّف الحجز فقط.
  /// English: Uses the booking id only for equality.
  @override
  List<Object> get props => [bookingId];
}

/// العربية: يطلب تحميل المدفوعات المرتبطة بالحجز لعرضها أو تدقيقها.
/// English: Requests the payments tied to the booking for display or review.
class LoadBookingPaymentsEvent extends BookingDetailsEvent {
  /// العربية: معرّف الحجز المطلوب جلب مدفوعاته.
  /// English: The identifier of the booking whose payments should be loaded.
  final String bookingId;

  /// العربية: ينشئ حدث تحميل المدفوعات.
  /// English: Creates the payment-loading event.
  const LoadBookingPaymentsEvent({required this.bookingId});

  /// العربية: يعتمد على معرّف الحجز فقط.
  /// English: Uses the booking id only for equality.
  @override
  List<Object> get props => [bookingId];
}

/// العربية: يطلب إنشاء ملف قابل للطباعة لملخص الحجز أو الفاتورة.
/// English: Requests a printable PDF version of the booking summary or invoice.
class PrintBookingDetailsEvent extends BookingDetailsEvent {
  /// العربية: معرّف الحجز المطلوب طباعته.
  /// English: The identifier of the booking to print.
  final String bookingId;

  /// العربية: ينشئ حدث الطباعة.
  /// English: Creates the print event.
  const PrintBookingDetailsEvent({required this.bookingId});

  /// العربية: يعتمد على معرّف الحجز فقط.
  /// English: Uses the booking id only for equality.
  @override
  List<Object> get props => [bookingId];
}

/// العربية: يطلب تجهيز تفاصيل الحجز للمشاركة عبر الوسيلة المتاحة.
/// English: Requests that booking details be prepared for sharing through the available channel.
class ShareBookingDetailsEvent extends BookingDetailsEvent {
  /// العربية: معرّف الحجز المطلوب مشاركته.
  /// English: The identifier of the booking to share.
  final String bookingId;

  /// العربية: ينشئ حدث المشاركة.
  /// English: Creates the share event.
  const ShareBookingDetailsEvent({required this.bookingId});

  /// العربية: يعتمد على معرّف الحجز فقط.
  /// English: Uses the booking id only for equality.
  @override
  List<Object> get props => [bookingId];
}

/// العربية: يطلب إرسال تأكيد الحجز إلى البريد أو الهاتف عند توفرهما.
/// English: Requests sending the booking confirmation to email or phone when available.
class SendBookingConfirmationEvent extends BookingDetailsEvent {
  /// العربية: معرّف الحجز الذي سيُرسل له التأكيد.
  /// English: The identifier of the booking receiving the confirmation.
  final String bookingId;

  /// العربية: البريد الإلكتروني المستهدف للإرسال عند توفره.
  /// English: The target email address when available.
  final String? email;

  /// العربية: رقم الهاتف المستهدف للإرسال عند توفره.
  /// English: The target phone number when available.
  final String? phone;

  /// العربية: ينشئ حدث إرسال تأكيد الحجز مع قنوات الاتصال الاختيارية.
  /// English: Creates the confirmation-send event with optional contact channels.
  const SendBookingConfirmationEvent({
    required this.bookingId,
    this.email,
    this.phone,
  });

  /// العربية: يعتمد على معرّف الحجز وقنوات الإرسال الاختيارية.
  /// English: Uses the booking id and optional delivery channels for equality.
  @override
  List<Object?> get props => [bookingId, email, phone];
}
