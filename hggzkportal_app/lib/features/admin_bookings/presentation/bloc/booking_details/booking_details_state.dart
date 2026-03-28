import 'package:hggzkportal/features/admin_reviews/domain/entities/review.dart'
    as admin_review;
import 'package:equatable/equatable.dart';
import '../../../domain/entities/booking.dart';
import '../../../domain/entities/booking_details.dart';

/// العربية: يعرّف حالات شاشة تفاصيل الحجز وما يرتبط بها من عمليات وتعاملات جانبية.
/// English: Defines the booking-details screen states and their related operations.
abstract class BookingDetailsState extends Equatable {
  /// العربية: ينشئ الأساس المشترك لحالات تفاصيل الحجز.
  /// English: Creates the shared base for booking-details states.
  const BookingDetailsState();

  /// العربية: لا توجد حقول مشتركة، لذا تعتمد المقارنة القيمية على الفئات الفرعية.
  /// English: No shared fields exist here, so equality is delegated to subclasses.
  @override
  List<Object?> get props => [];
}

/// العربية: تمثل الحالة قبل تحميل أي تفاصيل للحجز.
/// English: Represents the state before any booking details are loaded.
class BookingDetailsInitial extends BookingDetailsState {}

/// العربية: تشير إلى أن تفاصيل الحجز تُجلب حاليًا.
/// English: Indicates that booking details are currently being fetched.
class BookingDetailsLoading extends BookingDetailsState {}

/// العربية: تحمل البيانات التفصيلية الكاملة للحجز والخدمات المرتبطة به.
/// English: Holds the full booking details and any related services.
class BookingDetailsLoaded extends BookingDetailsState {
  /// العربية: الحجز الأساسي الذي تُبنى عليه صفحة التفاصيل.
  /// English: The primary booking object that drives the details view.
  final Booking booking;

  /// العربية: التفاصيل الموسعة للحجز عند توفرها من الخادم.
  /// English: The expanded booking details returned by the backend when available.
  final BookingDetails? bookingDetails;

  /// العربية: الخدمات المربوطة بالحجز الحالي.
  /// English: The services attached to the current booking.
  final List<Service> services;

  /// العربية: يحدد ما إذا كانت البيانات تُحدَّث دون تفريغ الواجهة.
  /// English: Indicates whether the data is being refreshed without clearing the view.
  final bool isRefreshing;

  /// العربية: التقييم المرتبط بالحجز إن وُجد.
  /// English: The review associated with the booking when one exists.
  final admin_review.Review? review;

  /// العربية: ينشئ حالة التحميل الناجح لكل بيانات الحجز الظاهرة.
  /// English: Creates the successful load state for all visible booking data.
  const BookingDetailsLoaded({
    required this.booking,
    this.bookingDetails,
    required this.services,
    this.isRefreshing = false,
    this.review,
  });

  /// العربية: ينشئ نسخة جديدة مع استبدال الحقول المحددة فقط.
  /// English: Creates a modified copy while replacing only the provided fields.
  BookingDetailsLoaded copyWith({
    Booking? booking,
    BookingDetails? bookingDetails,
    List<Service>? services,
    bool? isRefreshing,
    admin_review.Review? review,
  }) {
    return BookingDetailsLoaded(
      booking: booking ?? this.booking,
      bookingDetails: bookingDetails ?? this.bookingDetails,
      services: services ?? this.services,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      review: review ?? this.review,
    );
  }

  /// العربية: يضمن أن أي تغيّر في التفاصيل أو الخدمات أو التقييم يعكس نفسه في الواجهة.
  /// English: Ensures changes in details, services, or review trigger the correct UI rebuild.
  @override
  List<Object?> get props =>
      [booking, bookingDetails, services, isRefreshing, review];
}

/// العربية: تمثل فشلًا في تحميل أو معالجة تفاصيل الحجز.
/// English: Represents a failure while loading or processing booking details.
class BookingDetailsError extends BookingDetailsState {
  /// العربية: الرسالة التي تشرح سبب الفشل.
  /// English: The message explaining the failure.
  final String message;

  /// العربية: ينشئ حالة الخطأ مع رسالتها.
  /// English: Creates the error state with its message.
  const BookingDetailsError({required this.message});

  /// العربية: يعتمد على رسالة الخطأ فقط.
  /// English: Uses the error message only for equality.
  @override
  List<Object> get props => [message];
}

/// العربية: تمثل عملية تعديل أو إلغاء أو اعتماد جارية على الحجز.
/// English: Represents an in-progress booking operation such as update, cancel, or confirm.
class BookingDetailsOperationInProgress extends BookingDetailsState {
  /// العربية: الحجز الأساسي الذي تبقى بياناته معروضة أثناء العملية.
  /// English: The primary booking kept visible while the operation runs.
  final Booking booking;

  /// العربية: التفاصيل الموسعة للحجز عند توفرها.
  /// English: The expanded booking details when available.
  final BookingDetails? bookingDetails;

  /// العربية: الخدمات الحالية المرتبطة بالحجز.
  /// English: The services currently attached to the booking.
  final List<Service> services;

  /// العربية: اسم العملية الجارية مثل `update` أو `cancel`.
  /// English: The running operation name such as `update` or `cancel`.
  final String operation;

  /// العربية: ينشئ حالة العملية الجارية مع الاحتفاظ بالبيانات المرئية.
  /// English: Creates the in-progress state while preserving visible data.
  const BookingDetailsOperationInProgress({
    required this.booking,
    this.bookingDetails,
    required this.services,
    required this.operation,
  });

  /// العربية: يعتمد على الحجز والتفاصيل والخدمات واسم العملية.
  /// English: Uses the booking, details, services, and operation name for equality.
  @override
  List<Object?> get props => [booking, bookingDetails, services, operation];
}

/// العربية: تمثل نجاح عملية على الحجز مع رسالة تؤكد النتيجة.
/// English: Represents a successful booking operation with a result message.
class BookingDetailsOperationSuccess extends BookingDetailsState {
  /// العربية: الحجز الأساسي المرتبط بالنجاح.
  /// English: The primary booking associated with the success state.
  final Booking booking;

  /// العربية: التفاصيل الموسعة للحجز عند توفرها.
  /// English: The expanded booking details when available.
  final BookingDetails? bookingDetails;

  /// العربية: الخدمات المرتبطة بالحجز لحظة نجاح العملية.
  /// English: The services attached to the booking when the operation succeeded.
  final List<Service> services;

  /// العربية: الرسالة التي تؤكد نجاح العملية للمستخدم.
  /// English: The message confirming the successful operation to the user.
  final String message;

  /// العربية: ينشئ حالة النجاح مع الرسالة والبيانات الحالية.
  /// English: Creates the success state with the message and current data.
  const BookingDetailsOperationSuccess({
    required this.booking,
    this.bookingDetails,
    required this.services,
    required this.message,
  });

  /// العربية: يحوّل حالة النجاح إلى نسخة الحالة المحمّلة نفسها عند الحاجة للمتابعة.
  /// English: Converts the success state back into a loaded snapshot when follow-up rendering is needed.
  BookingDetailsLoaded copyWith() {
    return BookingDetailsLoaded(
      booking: booking,
      bookingDetails: bookingDetails,
      services: services,
    );
  }

  /// العربية: يعتمد على البيانات المعروضة والرسالة النهائية.
  /// English: Uses the visible data and final message for equality.
  @override
  List<Object?> get props => [booking, bookingDetails, services, message];
}

/// العربية: تمثل فشل عملية على الحجز مع الاحتفاظ بالبيانات الظاهرة.
/// English: Represents a failed booking operation while preserving visible data.
class BookingDetailsOperationFailure extends BookingDetailsState {
  /// العربية: الحجز الأساسي الذي تبقى بياناته معروضة بعد الفشل.
  /// English: The primary booking that remains visible after the failure.
  final Booking booking;

  /// العربية: التفاصيل الموسعة للحجز عند توفرها.
  /// English: The expanded booking details when available.
  final BookingDetails? bookingDetails;

  /// العربية: الخدمات المرتبطة بالحجز أثناء الفشل.
  /// English: The services attached to the booking during the failure state.
  final List<Service> services;

  /// العربية: الرسالة التي تشرح سبب عدم نجاح العملية.
  /// English: The message explaining why the operation did not succeed.
  final String message;

  /// العربية: ينشئ حالة الفشل مع الرسالة والبيانات الحالية.
  /// English: Creates the failure state with the message and current data.
  const BookingDetailsOperationFailure({
    required this.booking,
    this.bookingDetails,
    required this.services,
    required this.message,
  });

  /// العربية: يعتمد على البيانات الظاهرة ورسالة الفشل.
  /// English: Uses the visible data and failure message for equality.
  @override
  List<Object?> get props => [booking, bookingDetails, services, message];
}

/// العربية: تمثل تجهيز تفاصيل الحجز للطباعة أو التصدير إلى ملف.
/// English: Represents preparing booking details for printing or file export.
class BookingDetailsPrinting extends BookingDetailsState {
  /// العربية: الحجز الأساسي الجاري تجهيزه للطباعة.
  /// English: The primary booking being prepared for printing.
  final Booking booking;

  /// العربية: التفاصيل الموسعة المستخدمة في الفاتورة أو المستند.
  /// English: The expanded booking details used in the invoice or document.
  final BookingDetails? bookingDetails;

  /// العربية: الخدمات التي ستظهر في المستند المطبوع.
  /// English: The services that will appear in the printed document.
  final List<Service> services;

  /// العربية: ينشئ حالة الطباعة مع الاحتفاظ بالبيانات التي ستُصدر.
  /// English: Creates the printing state while preserving the data being exported.
  const BookingDetailsPrinting({
    required this.booking,
    this.bookingDetails,
    required this.services,
  });

  /// العربية: يعتمد على كل البيانات الظاهرة أثناء الطباعة.
  /// English: Uses all visible printing data for equality.
  @override
  List<Object?> get props => [booking, bookingDetails, services];
}

/// العربية: تمثل تجهيز تفاصيل الحجز للمشاركة عبر قناة خارجية.
/// English: Represents preparing booking details for sharing through an external channel.
class BookingDetailsSharing extends BookingDetailsState {
  /// العربية: الحجز الأساسي الجاري تجهيزه للمشاركة.
  /// English: The primary booking being prepared for sharing.
  final Booking booking;

  /// العربية: التفاصيل الموسعة التي ستُشارك.
  /// English: The expanded booking details to be shared.
  final BookingDetails? bookingDetails;

  /// العربية: الخدمات التي ستتضمنها المشاركة.
  /// English: The services included in the share payload.
  final List<Service> services;

  /// العربية: ينشئ حالة المشاركة مع البيانات الحالية.
  /// English: Creates the sharing state with the current data.
  const BookingDetailsSharing({
    required this.booking,
    this.bookingDetails,
    required this.services,
  });

  /// العربية: يعتمد على كل البيانات الظاهرة أثناء المشاركة.
  /// English: Uses all visible sharing data for equality.
  @override
  List<Object?> get props => [booking, bookingDetails, services];
}

/// العربية: تمثل تجهيز إرسال تأكيد الحجز قبل عودة النتيجة النهائية.
/// English: Represents preparing to send the booking confirmation before the final result.
class BookingDetailsSendingConfirmation extends BookingDetailsState {
  /// العربية: الحجز الأساسي الجاري إرسال تأكيده.
  /// English: The primary booking whose confirmation is being sent.
  final Booking booking;

  /// العربية: التفاصيل الموسعة المرتبطة بالحجز عند توفرها.
  /// English: The expanded booking details when available.
  final BookingDetails? bookingDetails;

  /// العربية: الخدمات المرتبطة بالحجز أثناء الإرسال.
  /// English: The services attached to the booking during sending.
  final List<Service> services;

  /// العربية: ينشئ حالة إرسال التأكيد مع البيانات الحالية.
  /// English: Creates the sending-confirmation state with current data.
  const BookingDetailsSendingConfirmation({
    required this.booking,
    this.bookingDetails,
    required this.services,
  });

  /// العربية: يعتمد على كل البيانات الظاهرة أثناء الإرسال.
  /// English: Uses all visible sending data for equality.
  @override
  List<Object?> get props => [booking, bookingDetails, services];
}
