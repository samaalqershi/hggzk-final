import 'package:equatable/equatable.dart';
import '../../../../../../core/models/paginated_result.dart';
import '../../../domain/entities/booking.dart';
import '../../../domain/entities/booking_report.dart';
import '../../../domain/entities/booking_trends.dart';

/// العربية: يعرّف حالات شاشة قائمة الحجوزات وما يرتبط بها من عمليات ومرشحات.
/// English: Defines the booking-list UI states along with operations and filters.
abstract class BookingsListState extends Equatable {
  /// العربية: ينشئ الأساس المشترك لحالات قائمة الحجوزات.
  /// English: Creates the shared base for booking-list states.
  const BookingsListState();

  /// العربية: لا توجد حقول مشتركة هنا، وتُترك المساواة للفئات الفرعية.
  /// English: No shared fields exist here, so subclasses control equality.
  @override
  List<Object?> get props => [];
}

/// العربية: تمثل الحالة قبل بدء أي تحميل لقائمة الحجوزات.
/// English: Represents the state before any booking list has been loaded.
class BookingsListInitial extends BookingsListState {}

/// العربية: تشير إلى أن القائمة تُجلب حاليًا من الخادم.
/// English: Indicates that the booking list is currently being fetched.
class BookingsListLoading extends BookingsListState {}

/// العربية: تحمل الصفحة الحالية من الحجوزات مع أي بيانات مساندة مرتبطة بها.
/// English: Holds the current page of bookings together with related supporting data.
class BookingsListLoaded extends BookingsListState {
  /// العربية: الصفحة المجلوبة من الحجوزات مع الترقيم والميتاداتا.
  /// English: The fetched booking page with pagination and metadata.
  final PaginatedResult<Booking> bookings;

  /// العربية: الحجوزات التي اختارها المستخدم لعمليات جماعية.
  /// English: The bookings currently selected for bulk actions.
  final List<Booking> selectedBookings;

  /// العربية: معايير البحث أو الفلترة التي أنتجت هذه النتيجة.
  /// English: The search and filter criteria that produced this result.
  final BookingFilters? filters;

  /// العربية: ملخص الإحصائيات المرافق للقائمة عند توفره.
  /// English: The optional statistics summary returned with the list.
  final BookingReport? report;

  /// العربية: بيانات الاتجاهات المرافقة لهذه الصفحة عند توفرها.
  /// English: The optional trend data loaded alongside this page.
  final BookingTrends? trends;

  /// العربية: أي بيانات ميتاداتا إضافية أرجعتها الخدمة.
  /// English: Any extra metadata returned by the backend.
  final Map<String, dynamic>? stats;

  /// العربية: ينشئ حالة تحميل ناجحة بصفحة الحجوزات والبيانات الداعمة لها.
  /// English: Creates a successful load state for bookings and supporting data.
  const BookingsListLoaded({
    required this.bookings,
    this.selectedBookings = const [],
    this.filters,
    this.report,
    this.trends,
    this.stats,
  });

  /// العربية: ينشئ نسخة معدلة مع إبقاء القيم غير المحددة كما هي.
  /// English: Creates a modified copy while keeping unspecified values unchanged.
  BookingsListLoaded copyWith({
    PaginatedResult<Booking>? bookings,
    List<Booking>? selectedBookings,
    BookingFilters? filters,
    BookingReport? report,
    BookingTrends? trends,
    Map<String, dynamic>? stats,
  }) {
    return BookingsListLoaded(
      bookings: bookings ?? this.bookings,
      selectedBookings: selectedBookings ?? this.selectedBookings,
      filters: filters ?? this.filters,
      report: report ?? this.report,
      trends: trends ?? this.trends,
      stats: stats ?? this.stats,
    );
  }

  /// العربية: يضمن أن أي تغيير في البيانات أو الاختيار يعيد بناء الواجهة بدقة.
  /// English: Ensures changes in data or selection trigger precise UI updates.
  @override
  List<Object?> get props => [
        bookings,
        selectedBookings,
        filters,
        report,
        trends,
        stats,
      ];
}

/// العربية: تمثل فشلًا في جلب قائمة الحجوزات أو معالجتها.
/// English: Represents a failure while fetching or processing the booking list.
class BookingsListError extends BookingsListState {
  /// العربية: رسالة الخطأ القابلة للعرض للمستخدم أو السجل التشخيصي.
  /// English: The error message shown to the user or diagnostic logs.
  final String message;

  /// العربية: ينشئ حالة الخطأ مع الرسالة التي تشرح السبب.
  /// English: Creates the error state with a message describing the failure.
  const BookingsListError({required this.message});

  /// العربية: يعتمد على نص الخطأ فقط في المقارنة.
  /// English: Uses the error message as the only comparison value.
  @override
  List<Object> get props => [message];
}

/// العربية: تمثل عملية على القائمة ما زالت قيد التنفيذ مثل الإلغاء أو التحديث.
/// English: Represents an in-progress list operation such as cancel, update, or refresh.
class BookingOperationInProgress extends BookingsListState {
  /// العربية: الصفحة الحالية التي يبقى عرضها أثناء تنفيذ العملية.
  /// English: The current page kept visible while the operation runs.
  final PaginatedResult<Booking> bookings;

  /// العربية: الحجوزات التي كانت محددة قبل بدء العملية.
  /// English: The bookings selected before the operation started.
  final List<Booking> selectedBookings;

  /// العربية: اسم العملية الجارية مثل `refresh` أو `cancel`.
  /// English: The running operation name such as `refresh` or `cancel`.
  final String operation;

  /// العربية: معرّف الحجز المرتبط بهذه العملية عند الحاجة.
  /// English: The booking identifier associated with this operation when relevant.
  final String? bookingId;

  /// العربية: ينشئ حالة العملية الجارية مع الاحتفاظ بالبيانات المرئية.
  /// English: Creates the in-progress state while preserving visible data.
  const BookingOperationInProgress({
    required this.bookings,
    required this.selectedBookings,
    required this.operation,
    this.bookingId,
  });

  /// العربية: يعتمد على الصفحة والاختيار واسم العملية لتحديد الحالة.
  /// English: Uses the page, selection, and operation name to compare states.
  @override
  List<Object?> get props => [bookings, selectedBookings, operation, bookingId];
}

/// العربية: تمثل نجاح عملية على القائمة مثل الحفظ أو التأكيد أو الإلغاء.
/// English: Represents a successful list operation such as save, confirm, or cancel.
class BookingOperationSuccess extends BookingsListState {
  /// العربية: الصفحة الحالية التي تظل معروضة بعد نجاح العملية.
  /// English: The current page that remains visible after the operation succeeds.
  final PaginatedResult<Booking> bookings;

  /// العربية: الحجوزات التي بقيت محددة بعد نجاح العملية.
  /// English: The bookings that remain selected after success.
  final List<Booking> selectedBookings;

  /// العربية: الرسالة التأكيدية الموجهة إلى الواجهة أو المستخدم.
  /// English: The confirmation message shown to the UI or user.
  final String message;

  /// العربية: معرّف الحجز الذي نجحت العملية عليه عند وجوده.
  /// English: The booking identifier the operation succeeded on, when available.
  final String? bookingId;

  /// العربية: ينشئ حالة النجاح مع الرسالة والبيانات المرئية الحالية.
  /// English: Creates the success state with the message and current visible data.
  const BookingOperationSuccess({
    required this.bookings,
    required this.selectedBookings,
    required this.message,
    this.bookingId,
  });

  /// العربية: يقارن النجاح وفق البيانات الحالية والرسالة والهدف المنفذ.
  /// English: Compares success states by current data, message, and target booking.
  @override
  List<Object?> get props => [bookings, selectedBookings, message, bookingId];
}

/// العربية: تمثل فشل العملية المنفذة مع إبقاء بيانات القائمة المتاحة.
/// English: Represents a failed operation while preserving the visible booking data.
class BookingOperationFailure extends BookingsListState {
  /// العربية: الصفحة الحالية التي تبقى ظاهرة رغم فشل العملية.
  /// English: The current page kept visible despite the failure.
  final PaginatedResult<Booking> bookings;

  /// العربية: الحجوزات التي كانت محددة لحظة الفشل.
  /// English: The bookings that were selected when the failure occurred.
  final List<Booking> selectedBookings;

  /// العربية: رسالة الفشل التي تشرح سبب عدم نجاح العملية.
  /// English: The failure message explaining why the operation did not succeed.
  final String message;

  /// العربية: معرّف الحجز المرتبط بالفشل إن وُجد.
  /// English: The related booking identifier when one exists.
  final String? bookingId;

  /// العربية: ينشئ حالة الفشل مع التفاصيل اللازمة لعرضها أو تسجيلها.
  /// English: Creates the failure state with details suitable for UI or logging.
  const BookingOperationFailure({
    required this.bookings,
    required this.selectedBookings,
    required this.message,
    this.bookingId,
  });

  /// العربية: يعتمد على الصفحة والاختيار ورسالة الفشل والهدف المنفذ.
  /// English: Compares failure states by page, selection, message, and target booking.
  @override
  List<Object?> get props => [bookings, selectedBookings, message, bookingId];
}

/// العربية: تمثل معايير التصفية النشطة المستخدمة لتجميع قائمة الحجوزات.
/// English: Represents the active filter criteria used to shape the booking list.
class BookingFilters extends Equatable {
  /// العربية: بداية نطاق التاريخ المطبق على النتائج.
  /// English: The start date of the applied result window.
  final DateTime? startDate;

  /// العربية: نهاية نطاق التاريخ المطبق على النتائج.
  /// English: The end date of the applied result window.
  final DateTime? endDate;

  /// العربية: فلتر المستخدم المرتبط بالحجز.
  /// English: A filter by the associated user identifier.
  final String? userId;

  /// العربية: فلتر اسم الضيف أو البريد الإلكتروني.
  /// English: A filter by guest name or email.
  final String? guestNameOrEmail;

  /// العربية: فلتر الوحدة السكنية المحددة.
  /// English: A filter by the unit identifier.
  final String? unitId;

  /// العربية: فلتر مصدر الحجز.
  /// English: A filter by booking source.
  final String? bookingSource;

  /// العربية: فلتر الحالة التشغيلية للحجز.
  /// English: A filter by booking status.
  final String? status;

  /// العربية: فلتر حالة الدفع الخاصة بالحجز.
  /// English: A filter by booking payment status.
  final String? paymentStatus;

  /// العربية: يحدد ما إذا كانت النتائج يجب أن تقتصر على الحجوزات المباشرة.
  /// English: Limits results to walk-in bookings when true.
  final bool? isWalkIn;

  /// العربية: الحد الأدنى لسعر الحجز المطلوب في النتائج.
  /// English: The minimum total booking price allowed in the result set.
  final double? minTotalPrice;

  /// العربية: الحد الأدنى لعدد الضيوف المطلوب في النتائج.
  /// English: The minimum guest count required in the result set.
  final int? minGuestsCount;

  /// العربية: ينشئ مجموعة الفلاتر النشطة مع القيم الاختيارية المطلوبة فقط.
  /// English: Creates the active filter set with only the criteria provided.
  const BookingFilters({
    this.startDate,
    this.endDate,
    this.userId,
    this.guestNameOrEmail,
    this.unitId,
    this.bookingSource,
    this.status,
    this.paymentStatus,
    this.isWalkIn,
    this.minTotalPrice,
    this.minGuestsCount,
  });

  /// العربية: ينشئ نسخة جديدة مع استبدال القيم المحددة فقط.
  /// English: Creates a new filter set while replacing only the provided values.
  BookingFilters copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
    String? guestNameOrEmail,
    String? unitId,
    String? bookingSource,
    String? status,
    String? paymentStatus,
    bool? isWalkIn,
    double? minTotalPrice,
    int? minGuestsCount,
  }) {
    return BookingFilters(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      userId: userId ?? this.userId,
      guestNameOrEmail: guestNameOrEmail ?? this.guestNameOrEmail,
      unitId: unitId ?? this.unitId,
      bookingSource: bookingSource ?? this.bookingSource,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      isWalkIn: isWalkIn ?? this.isWalkIn,
      minTotalPrice: minTotalPrice ?? this.minTotalPrice,
      minGuestsCount: minGuestsCount ?? this.minGuestsCount,
    );
  }

  /// العربية: يعتمد على كل معيار فلترة لضمان تطابق دقيق بين الحالات.
  /// English: Uses every filter criterion to keep state comparisons exact.
  @override
  List<Object?> get props => [
        startDate,
        endDate,
        userId,
        guestNameOrEmail,
        unitId,
        bookingSource,
        status,
        paymentStatus,
        isWalkIn,
        minTotalPrice,
        minGuestsCount,
      ];
}
