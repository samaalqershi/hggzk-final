import 'package:equatable/equatable.dart';
import '../../domain/entities/booking.dart';

/// Base state for booking creation, lookup, and lifecycle updates.
/// الحالة الأساسية لإنشاء الحجز والبحث عنه وتحديث دورة حياته.
abstract class BookingState extends Equatable {
  /// Shared constructor for booking states.
  /// مُنشئ مشترك لحالات الحجز.
  const BookingState();

  /// Base booking state has no direct payload.
  /// الحالة الأساسية لا تحمل بيانات مباشرة.
  @override
  List<Object?> get props => [];
}

/// Idle state before any booking request starts.
/// حالة سكون قبل بدء أي طلب حجز.
class BookingInitial extends BookingState {
  /// Marks the neutral state of the booking bloc.
  /// يحدد الحالة المحايدة لبلوك الحجز.
  const BookingInitial();
}

/// Indicates that a booking-related request is being processed.
/// تشير إلى أن طلبًا متعلقًا بالحجز قيد المعالجة.
class BookingLoading extends BookingState {
  /// Used while the bloc waits for the repository response.
  /// تُستخدم أثناء انتظار رد المستودع.
  const BookingLoading();
}

/// Indicates that date or unit availability is being checked.
/// تشير إلى أن التحقق من التوفر جارٍ الآن.
class CheckingAvailability extends BookingState {
  /// Dedicated state for availability lookups.
  /// حالة مخصصة لعمليات التحقق من التوفر.
  const CheckingAvailability();
}

/// Holds a booking failure and tells the UI how aggressively to present it.
/// يحمل فشل الحجز ويحدد كيف يجب أن تعرضه الواجهة.
class BookingError extends BookingState {
  /// User-facing message describing the failure.
  /// رسالة موجهة للمستخدم تشرح سبب الفشل.
  final String message;

  /// Requests a dialog presentation for critical errors.
  /// يطلب إظهار الخطأ داخل مربع حوار عند الحاجة.
  final bool showAsDialog;

  /// Optional backend or provider error code.
  /// رمز الخطأ من الخادم أو المزود عند توفره.
  final String? code;

  /// Captures the failure details for the booking flow.
  /// يلتقط تفاصيل الفشل الخاصة بمسار الحجز.
  const BookingError({
    required this.message,
    this.showAsDialog = false,
    this.code,
  });

  /// Compares the message, code, and presentation style.
  /// يقارن الرسالة والرمز وطريقة العرض.
  @override
  List<Object> get props => [message, showAsDialog, code ?? ''];
}

/// Emitted when a booking is created successfully.
/// تصدر عند نجاح إنشاء الحجز.
class BookingCreated extends BookingState {
  /// Newly created booking returned from the backend.
  /// الحجز الجديد الذي يعيده الخادم.
  final Booking booking;

  /// يخزن الحجز المؤكد حتى تعرضه الواجهة مباشرة.
  const BookingCreated({required this.booking});

  /// Compares the created booking payload.
  /// يقارن حمولة الحجز المنشأ.
  @override
  List<Object> get props => [booking];
}

/// Contains the detailed booking payload used on the details screen.
/// يحتوي على بيانات الحجز التفصيلية المستخدمة في شاشة التفاصيل.
class BookingDetailsLoaded extends BookingState {
  /// Detailed booking model returned for inspection or editing.
  /// نموذج الحجز التفصيلي المعروض للفحص أو التعديل.
  final Booking booking;

  /// يخزن تفاصيل الحجز للشاشة الحالية.
  const BookingDetailsLoaded({required this.booking});

  /// Compares the loaded booking details.
  /// يقارن تفاصيل الحجز المحمّلة.
  @override
  List<Object> get props => [booking];
}

/// Emitted after a booking cancellation completes.
/// تصدر بعد اكتمال إلغاء الحجز.
class BookingCancelled extends BookingState {
  /// Signals that the booking is now cancelled.
  /// تشير إلى أن الحجز أصبح ملغيًا.
  const BookingCancelled();
}

/// Paginated list of bookings belonging to the current user.
/// قائمة حجوزات مجزأة إلى صفحات تخص المستخدم الحالي.
class UserBookingsLoaded extends BookingState {
  /// Loaded bookings for the current page range.
  /// الحجوزات المحمّلة للنطاق الحالي من الصفحات.
  final List<Booking> bookings;

  /// True when the backend still has more pages to fetch.
  /// تكون صحيحة عندما يتبقى المزيد من الصفحات في الخادم.
  final bool hasMore;

  /// One-based index of the page currently displayed.
  /// رقم الصفحة المعروضة حاليًا ويبدأ من 1.
  final int currentPage;

  /// Total number of bookings available from the source.
  /// العدد الإجمالي للحجوزات المتاحة من المصدر.
  final int totalCount;

  /// True while the next page is being appended.
  /// تكون صحيحة أثناء إضافة الصفحة التالية.
  final bool isLoadingMore;

  /// Optional summary of bookings grouped by status.
  /// ملخص اختياري للحجوزات مجمّع حسب الحالة.
  final Map<dynamic, dynamic>? statusCounts;

  /// يخزن القائمة وبيانات الترقيم معًا.
  const UserBookingsLoaded({
    required this.bookings,
    required this.hasMore,
    required this.currentPage,
    required this.totalCount,
    this.isLoadingMore = false,
    this.statusCounts,
  });

  /// Builds a copy so the bloc can update only the changed page fields.
  /// ينشئ نسخة تسمح للبلوك بتحديث الحقول المتغيرة فقط.
  UserBookingsLoaded copyWith({
    List<Booking>? bookings,
    bool? hasMore,
    int? currentPage,
    int? totalCount,
    bool? isLoadingMore,
    Map<dynamic, dynamic>? statusCounts,
  }) {
    return UserBookingsLoaded(
      bookings: bookings ?? this.bookings,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      statusCounts: statusCounts ?? this.statusCounts,
    );
  }

  /// Compares the list and pagination fields for stable rebuilds.
  /// يقارن القائمة وحقول الترقيم لضمان إعادة بناء مستقرة.
  @override
  List<Object> get props => [
        bookings,
        hasMore,
        currentPage,
        totalCount,
        isLoadingMore,
        statusCounts ?? const {}
      ];
}

/// Summary counters for the user's bookings by status or other facets.
/// أرقام ملخصة لحجوزات المستخدم حسب الحالة أو غيرها من الأبعاد.
class UserBookingsSummaryLoaded extends BookingState {
  /// Aggregated booking statistics returned by the backend.
  /// الإحصاءات المجمعة للحجوزات التي يعيدها الخادم.
  final Map<String, dynamic> summary;

  /// يخزن حمولة الملخص للوحة المعلومات أو الفلاتر.
  const UserBookingsSummaryLoaded({required this.summary});

  /// Compares the summary payload.
  /// يقارن حمولة الملخص.
  @override
  List<Object> get props => [summary];
}

/// Emitted after optional services are appended to a booking.
/// تصدر بعد إضافة الخدمات الاختيارية إلى الحجز.
class ServicesAddedToBooking extends BookingState {
  /// Updated booking returned after service changes.
  /// الحجز المحدّث بعد تعديل الخدمات.
  final Booking booking;

  /// يخزن الحجز المحدّث للخطوة التالية في الواجهة.
  const ServicesAddedToBooking({required this.booking});

  /// Compares the updated booking payload.
  /// يقارن حمولة الحجز المحدّث.
  @override
  List<Object> get props => [booking];
}

/// Result of checking whether a unit can be booked for the requested dates.
/// نتيجة التحقق مما إذا كان الوحدة قابلة للحجز للتواريخ المطلوبة.
class AvailabilityChecked extends BookingState {
  /// True when the selected unit can be booked.
  /// تكون صحيحة عندما تكون الوحدة المختارة قابلة للحجز.
  final bool isAvailable;

  /// Nightly price used for the availability summary.
  /// سعر الليلة المستخدم في ملخص التوفر.
  final double? pricePerNight;

  /// Total calculated cost for the selected stay.
  /// التكلفة الإجمالية المحسوبة للإقامة المحددة.
  final double? totalPrice;

  /// Currency code for the price values.
  /// رمز العملة لقيم الأسعار.
  final String? currency;

  /// Number of nights included in the estimate.
  /// عدد الليالي المشمولة في التقدير.
  final int? totalDays;

  /// Bundles the availability result and the related price estimate.
  /// يجمع نتيجة التوفر مع تقدير السعر المرتبط بها.
  const AvailabilityChecked({
    required this.isAvailable,
    this.pricePerNight,
    this.totalPrice,
    this.currency,
    this.totalDays,
  });

  /// Compares the availability result and the calculated estimate.
  /// يقارن نتيجة التوفر والتقدير المحسوب.
  @override
  List<Object?> get props => [
        isAvailable,
        pricePerNight,
        totalPrice,
        currency,
        totalDays,
      ];
}

/// العربية: يمثل `BookingFormUpdated`.
class BookingFormUpdated extends BookingState {
  /// العربية: يخزن القيمة `formData`.
  final Map<String, dynamic> formData;

  /// العربية: ينشئ مثيلًا جديدًا من `BookingFormUpdated`.
  const BookingFormUpdated({required this.formData});

  /// العربية: يعيد خصائص المساواة الخاصة بهذا الكائن.
  @override
  List<Object> get props => [formData];
}

/// العربية: يمثل `BookingUpdated`.
class BookingUpdated extends BookingState {
  /// العربية: ينشئ مثيلًا جديدًا من `BookingUpdated`.
  const BookingUpdated();
}
