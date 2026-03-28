import 'package:equatable/equatable.dart';
import '../../domain/entities/booking_request.dart';

/// Base event for booking creation, editing, cancellation, and lookup flows.
/// الحدث الأساسي لمسارات إنشاء الحجز وتعديله وإلغائه والبحث عنه.
abstract class BookingEvent extends Equatable {
  /// Shared constructor for booking events.
  /// مُنشئ مشترك لأحداث الحجز.
  const BookingEvent();

  /// Base event carries no payload on its own.
  /// الحدث الأساسي لا يحمل بيانات بنفسه.
  @override
  List<Object?> get props => [];
}

/// Submits a new booking request.
/// يرسل طلب حجز جديد.
class CreateBookingEvent extends BookingEvent {
  /// Complete booking request payload.
  /// حمولة طلب الحجز الكاملة.
  final BookingRequest bookingRequest;

  /// Packages the request required to create the booking.
  /// يجمع الطلب اللازم لإنشاء الحجز.
  const CreateBookingEvent({required this.bookingRequest});

  /// Compares the booking request payload.
  /// يقارن حمولة طلب الحجز.
  @override
  List<Object> get props => [bookingRequest];
}

/// Loads a single booking record for the details screen.
/// يجلب سجل حجز واحدًا لشاشة التفاصيل.
class GetBookingDetailsEvent extends BookingEvent {
  /// Booking identifier to fetch.
  /// معرّف الحجز المطلوب.
  final String bookingId;

  /// User who owns the booking.
  /// المستخدم الذي يملك الحجز.
  final String userId;

  /// Identifies which booking detail should be loaded.
  /// يحدد أي تفاصيل حجز يجب تحميلها.
  const GetBookingDetailsEvent({
    required this.bookingId,
    required this.userId,
  });

  /// Compares the booking and user identifiers.
  /// يقارن معرّف الحجز ومعرّف المستخدم.
  @override
  List<Object> get props => [bookingId, userId];
}

/// Requests cancellation of an existing booking.
/// يطلب إلغاء حجز قائم.
class CancelBookingEvent extends BookingEvent {
  /// Booking that should be cancelled.
  /// الحجز الذي يجب إلغاؤه.
  final String bookingId;

  /// User performing the cancellation.
  /// المستخدم الذي ينفذ الإلغاء.
  final String userId;

  /// Human-readable cancellation reason.
  /// سبب الإلغاء بصيغة مفهومة.
  final String reason;

  /// Requests a refund when the booking policy allows it.
  /// يطلب استرداد المبلغ عندما تسمح سياسة الحجز بذلك.
  final bool refundPayments;

  /// Packages the cancellation metadata for the bloc.
  /// يجمع بيانات الإلغاء لتمريرها إلى البلوك.
  const CancelBookingEvent({
    required this.bookingId,
    required this.userId,
    required this.reason,
    this.refundPayments = false,
  });

  /// Compares the cancellation payload.
  /// يقارن حمولة الإلغاء.
  @override
  List<Object> get props => [bookingId, userId, reason, refundPayments];
}

/// Loads the current user's bookings with optional filtering and pagination.
/// يجلب حجوزات المستخدم الحالي مع التصفية والترقيم الاختياري.
class GetUserBookingsEvent extends BookingEvent {
  /// User whose bookings should be loaded.
  /// المستخدم الذي ستُجلب حجوزاته.
  final String userId;

  /// Optional booking status filter.
  /// فلتر اختياري حسب حالة الحجز.
  final String? status;

  /// One-based page index to fetch.
  /// رقم الصفحة المطلوب ويبدأ من 1.
  final int pageNumber;

  /// Number of bookings requested per page.
  /// عدد الحجوزات المطلوب في كل صفحة.
  final int pageSize;

  /// Indicates that the request should append to an existing list.
  /// يحدد ما إذا كان الطلب سيُضاف إلى القائمة الحالية.
  final bool loadMore;

  /// Bundles the filters used to retrieve the user's bookings.
  /// يجمع المرشحات المستخدمة لجلب حجوزات المستخدم.
  const GetUserBookingsEvent({
    required this.userId,
    this.status,
    this.pageNumber = 1,
    this.pageSize = 10,
    this.loadMore = false,
  });

  /// Compares the query inputs.
  /// يقارن مدخلات الاستعلام.
  @override
  List<Object?> get props => [userId, status, pageNumber, pageSize, loadMore];
}

/// Loads an aggregated summary of the user's bookings.
/// يجلب ملخصًا مجمعًا لحجوزات المستخدم.
class GetUserBookingsSummaryEvent extends BookingEvent {
  /// User whose bookings are being summarized.
  /// المستخدم الذي يجري تلخيص حجوزاته.
  final String userId;

  /// Optional year filter for the summary.
  /// فلتر سنة اختياري للملخص.
  final int? year;

  /// Packages the summary query parameters.
  /// يجمع معاملات استعلام الملخص.
  const GetUserBookingsSummaryEvent({
    required this.userId,
    this.year,
  });

  /// Compares the summary query.
  /// يقارن استعلام الملخص.
  @override
  List<Object?> get props => [userId, year];
}

/// Adds paid or optional services to an existing booking.
/// يضيف الخدمات المدفوعة أو الاختيارية إلى حجز قائم.
class AddServicesToBookingEvent extends BookingEvent {
  /// Booking that will receive the additional services.
  /// الحجز الذي ستُضاف إليه الخدمات.
  final String bookingId;

  /// Service being attached to the booking.
  /// الخدمة المراد ربطها بالحجز.
  final String serviceId;

  /// Number of service units to add.
  /// عدد وحدات الخدمة المطلوب إضافتها.
  final int quantity;

  /// Captures the service attachment request.
  /// يلتقط طلب إرفاق الخدمة.
  const AddServicesToBookingEvent({
    required this.bookingId,
    required this.serviceId,
    required this.quantity,
  });

  /// Compares the add-service request.
  /// يقارن طلب إضافة الخدمة.
  @override
  List<Object> get props => [bookingId, serviceId, quantity];
}

/// Checks whether a unit is available for the chosen date range.
/// يتحقق مما إذا كانت الوحدة متاحة للفترة المختارة.
class CheckAvailabilityEvent extends BookingEvent {
  /// Unit being checked.
  /// الوحدة الجاري التحقق منها.
  final String unitId;

  /// Arrival date for the request.
  /// تاريخ الوصول المطلوب.
  final DateTime checkIn;

  /// Departure date for the request.
  /// تاريخ المغادرة المطلوب.
  final DateTime checkOut;

  /// Adult guest count.
  /// عدد الضيوف البالغين.
  final int adultsCount;

  /// Child guest count.
  /// عدد الضيوف الأطفال.
  final int childrenCount;

  /// Combined total used by the backend for validation.
  /// الإجمالي المدمج المستخدم من الخادم للتحقق.
  final int guestsCount;

  /// Optional booking to exclude when checking overlapping dates.
  /// حجز اختياري يُستثنى عند فحص التداخل الزمني.
  final String? excludeBookingId;

  /// Builds the availability query and normalizes guest totals.
  /// يبني استعلام التوفر ويطبع إجمالي الضيوف بشكل موحد.
  const CheckAvailabilityEvent({
    required this.unitId,
    required this.checkIn,
    required this.checkOut,
    required this.adultsCount,
    required this.childrenCount,
    this.excludeBookingId,
  }) : guestsCount = adultsCount + childrenCount;

  /// Compares the full availability query.
  /// يقارن استعلام التوفر الكامل.
  @override
  List<Object?> get props => [
        unitId,
        checkIn,
        checkOut,
        adultsCount,
        childrenCount,
        guestsCount,
        excludeBookingId
      ];
}

/// Updates an existing booking with new dates, guest counts, or services.
/// يحدّث حجزًا قائمًا بتواريخ أو عدد ضيوف أو خدمات جديدة.
class UpdateBookingEvent extends BookingEvent {
  /// Booking identifier being modified.
  /// معرّف الحجز الجاري تعديله.
  final String bookingId;

  /// Optional new check-in date.
  /// تاريخ الوصول الجديد اختياريًا.
  final DateTime? checkIn;

  /// Optional new check-out date.
  /// تاريخ المغادرة الجديد اختياريًا.
  final DateTime? checkOut;

  /// Optional updated guest count.
  /// عدد الضيوف المحدّث اختياريًا.
  final int? guestsCount;

  /// Optional service payload to replace or extend the booking services.
  /// حمولة خدمات اختيارية لاستبدال خدمات الحجز أو توسيعها.
  final List<Map<String, dynamic>>? services;

  /// Packages the editable booking fields for submission.
  /// يجمع حقول الحجز القابلة للتعديل للإرسال.
  const UpdateBookingEvent({
    required this.bookingId,
    this.checkIn,
    this.checkOut,
    this.guestsCount,
    this.services,
  });

  /// Compares the update payload.
  /// يقارن حمولة التحديث.
  @override
  List<Object?> get props =>
      [bookingId, checkIn, checkOut, guestsCount, services];
}

/// Replaces the local booking form snapshot.
/// يستبدل اللقطة المحلية لنموذج الحجز.
class UpdateBookingFormEvent extends BookingEvent {
  /// Serialized form contents.
  /// محتوى النموذج التسلسلي.
  final Map<String, dynamic> formData;

  /// Captures the latest form values for state restoration.
  /// يلتقط القيم الأحدث للنموذج لاستعادة الحالة.
  const UpdateBookingFormEvent({required this.formData});

  /// Compares the serialized form snapshot.
  /// يقارن لقطة النموذج المسلسلة.
  @override
  List<Object> get props => [formData];
}

/// يعيد بلوك الحجز إلى حالته الابتدائية الهادئة.
class ResetBookingStateEvent extends BookingEvent {
  /// No payload is needed to reset the flow.
  /// لا تحتاج عملية الإرجاع إلى حالة البداية إلى حمولة إضافية.
  const ResetBookingStateEvent();
}

/// Initiates payment for an existing booking.
/// يبدأ دفعًا مرتبطًا بحجز قائم.
class ProcessBookingPaymentEvent extends BookingEvent {
  /// Booking that is being paid for.
  /// الحجز الذي يتم سداده.
  final String bookingId;

  /// User paying for the booking.
  /// المستخدم الذي يدفع قيمة الحجز.
  final String userId;

  /// Amount to charge.
  /// المبلغ المطلوب خصمه.
  final double amount;

  /// Selected payment method name.
  /// اسم طريقة الدفع المختارة.
  final String paymentMethod;

  /// Optional provider-specific payment metadata.
  /// بيانات دفع اختيارية خاصة بالمزود.
  final Map<String, dynamic>? paymentDetails;

  /// Packs the booking payment request for the bloc.
  /// يجمع طلب دفع الحجز داخل حدث واحد.
  const ProcessBookingPaymentEvent({
    required this.bookingId,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    this.paymentDetails,
  });

  /// Compares the payment request payload.
  /// يقارن حمولة طلب الدفع.
  @override
  List<Object?> get props =>
      [bookingId, userId, amount, paymentMethod, paymentDetails];
}
