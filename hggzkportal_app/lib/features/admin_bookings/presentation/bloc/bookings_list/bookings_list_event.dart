import 'package:equatable/equatable.dart';

/// العربية: يعرّف جميع أحداث إدارة قائمة الحجوزات من التحميل إلى التحديد والعمليات الجماعية.
/// English: Defines all booking-list actions, from loading and filtering to selection and bulk operations.
abstract class BookingsListEvent extends Equatable {
  /// العربية: ينشئ الأساس المشترك لأحداث قائمة الحجوزات.
  /// English: Creates the shared base for booking-list events.
  const BookingsListEvent();

  /// العربية: لا توجد حقول مشتركة هنا، وتُترك المقارنة القيمية للفئات الفرعية.
  /// English: No shared fields exist here, so equality is delegated to subclasses.
  @override
  List<Object?> get props => [];
}

/// العربية: يطلب تحميل صفحة من الحجوزات ضمن نطاق زمني وفلاتر اختيارية محددة.
/// English: Requests a paginated booking fetch for a specific date range and optional filters.
class LoadBookingsEvent extends BookingsListEvent {
  /// العربية: بداية النطاق الزمني المطلوب تحميل الحجوزات ضمنه.
  /// English: The inclusive start of the date range used to query bookings.
  final DateTime startDate;

  /// العربية: نهاية النطاق الزمني المطلوب تحميل الحجوزات ضمنه.
  /// English: The inclusive end of the date range used to query bookings.
  final DateTime endDate;

  /// العربية: رقم الصفحة المطلوب جلبها من الخادم.
  /// English: The page number to request from the backend.
  final int pageNumber;

  /// العربية: عدد العناصر المطلوب إرجاعها في كل صفحة.
  /// English: The number of items to return per page.
  final int pageSize;

  /// العربية: يفلتر النتائج حسب المستخدم المرتبط بالحجز عند الحاجة.
  /// English: Optionally filters bookings by the associated user identifier.
  final String? userId;

  /// العربية: يفلتر النتائج باسم الضيف أو بريده الإلكتروني.
  /// English: Optionally filters by guest name or email.
  final String? guestNameOrEmail;

  /// العربية: يقيّد النتائج بوحدة سكنية محددة.
  /// English: Optionally restricts the result set to a specific unit.
  final String? unitId;

  /// العربية: يقيّد النتائج بمصدر الحجز مثل الويب أو المكتب.
  /// English: Optionally filters bookings by their source channel.
  final String? bookingSource;

  /// العربية: ينشئ طلب التحميل مع التصفية والصفحات المطلوبة.
  /// English: Creates the booking fetch request with the supplied filters and paging data.
  const LoadBookingsEvent({
    required this.startDate,
    required this.endDate,
    this.pageNumber = 1,
    this.pageSize = 10,
    this.userId,
    this.guestNameOrEmail,
    this.unitId,
    this.bookingSource,
  });

  /// العربية: يشارك جميع معايير الاستعلام في المقارنة القيمية للأحداث.
  /// English: Includes every query parameter in the event's value equality.
  @override
  List<Object?> get props => [
        startDate,
        endDate,
        pageNumber,
        pageSize,
        userId,
        guestNameOrEmail,
        unitId,
        bookingSource,
      ];
}

/// العربية: يعيد تحميل القائمة باستخدام آخر نطاق وفلاتر معروفة.
/// English: Rebuilds the list using the last known query and filters.
class RefreshBookingsEvent extends BookingsListEvent {
  /// العربية: ينشئ حدث تحديث بلا معايير إضافية.
  /// English: Creates a refresh event with no extra parameters.
  const RefreshBookingsEvent();
}

/// العربية: يطلب إلغاء حجز موجود مع سبب الإلغاء وخيار استرجاع الدفعات.
/// English: Requests cancellation of an existing booking with a reason and optional payment refund.
class CancelBookingEvent extends BookingsListEvent {
  /// العربية: معرّف الحجز المراد إلغاؤه.
  /// English: The identifier of the booking to cancel.
  final String bookingId;

  /// العربية: النص الذي يشرح سبب الإلغاء للمراجعة والتدقيق.
  /// English: The cancellation reason shown in the audit trail and UI.
  final String cancellationReason;

  /// العربية: يحدد ما إذا كان يجب استرجاع الدفعات المرتبطة بالحجز.
  /// English: Indicates whether related payments should be refunded.
  final bool refundPayments;

  /// العربية: ينشئ حدث الإلغاء بكل بياناته التشغيلية.
  /// English: Creates the booking cancellation request with its operational details.
  const CancelBookingEvent({
    required this.bookingId,
    required this.cancellationReason,
    this.refundPayments = false,
  });

  /// العربية: يضم معرّف الحجز وسبب الإلغاء وخيار الاسترجاع في المساواة القيمية.
  /// English: Includes the booking id, reason, and refund flag in value equality.
  @override
  List<Object> get props => [bookingId, cancellationReason, refundPayments];
}

/// العربية: يطلب تعديل بيانات الحجز مثل الإقامة أو عدد الضيوف.
/// English: Requests a booking update such as dates or guest count adjustments.
class UpdateBookingEvent extends BookingsListEvent {
  /// العربية: معرّف الحجز المراد تحديثه.
  /// English: The identifier of the booking to update.
  final String bookingId;

  /// العربية: تاريخ الوصول الجديد عند الحاجة.
  /// English: The new check-in date when provided.
  final DateTime? checkIn;

  /// العربية: تاريخ المغادرة الجديد عند الحاجة.
  /// English: The new check-out date when provided.
  final DateTime? checkOut;

  /// العربية: العدد الجديد للضيوف عند الحاجة.
  /// English: The updated guest count when provided.
  final int? guestsCount;

  /// العربية: ينشئ حدث تعديل الحجز مع الحقول الاختيارية القابلة للتحديث.
  /// English: Creates the booking update event with optional editable fields.
  const UpdateBookingEvent({
    required this.bookingId,
    this.checkIn,
    this.checkOut,
    this.guestsCount,
  });

  /// العربية: يجعل جميع قيم التعديل جزءًا من المقارنة القيمية.
  /// English: Makes every editable value part of equality comparisons.
  @override
  List<Object?> get props => [bookingId, checkIn, checkOut, guestsCount];
}

/// العربية: يطلب اعتماد الحجز بعد المراجعة البشرية أو الآلية.
/// English: Requests confirmation of a booking after review or approval.
class ConfirmBookingEvent extends BookingsListEvent {
  /// العربية: معرّف الحجز المراد تأكيده.
  /// English: The identifier of the booking to confirm.
  final String bookingId;

  /// العربية: ينشئ حدث تأكيد الحجز.
  /// English: Creates the booking confirmation event.
  const ConfirmBookingEvent({required this.bookingId});

  /// العربية: يضمن أن معرّف الحجز هو أساس مقارنة الحدث.
  /// English: Uses the booking id as the event's equality basis.
  @override
  List<Object> get props => [bookingId];
}

/// العربية: يطلب تسجيل وصول الضيف للحجز المحدد.
/// English: Requests a guest check-in for the selected booking.
class CheckInBookingEvent extends BookingsListEvent {
  /// العربية: معرّف الحجز الذي سيتم تسجيل الوصول له.
  /// English: The identifier of the booking being checked in.
  final String bookingId;

  /// العربية: ينشئ حدث تسجيل الوصول.
  /// English: Creates the check-in event.
  const CheckInBookingEvent({required this.bookingId});

  /// العربية: يعتمد فقط على معرّف الحجز عند المقارنة.
  /// English: Compares events using the booking id only.
  @override
  List<Object> get props => [bookingId];
}

/// العربية: يطلب تسجيل مغادرة الضيف للحجز المحدد.
/// English: Requests a guest check-out for the selected booking.
class CheckOutBookingEvent extends BookingsListEvent {
  /// العربية: معرّف الحجز الذي سيتم تسجيل المغادرة له.
  /// English: The identifier of the booking being checked out.
  final String bookingId;

  /// العربية: ينشئ حدث تسجيل المغادرة.
  /// English: Creates the check-out event.
  const CheckOutBookingEvent({required this.bookingId});

  /// العربية: يعتمد فقط على معرّف الحجز عند المقارنة.
  /// English: Compares events using the booking id only.
  @override
  List<Object> get props => [bookingId];
}

/// العربية: يطلب البحث النصي داخل الحجوزات المعروضة.
/// English: Requests a text search across the visible bookings.
class SearchBookingsEvent extends BookingsListEvent {
  /// العربية: النص أو العبارة المستخدمة في البحث.
  /// English: The search term or phrase used to match bookings.
  final String searchTerm;

  /// العربية: ينشئ حدث البحث بالنص المطلوب.
  /// English: Creates the search event with the provided term.
  const SearchBookingsEvent({required this.searchTerm});

  /// العربية: يضم نص البحث في مقارنة الحدث حتى تتغير النتيجة عند تغيّره.
  /// English: Includes the search term so equality changes when the query changes.
  @override
  List<Object> get props => [searchTerm];
}

/// العربية: يطلب تطبيق فلاتر متقدمة على قائمة الحجوزات.
/// English: Requests applying advanced filters to the booking list.
class FilterBookingsEvent extends BookingsListEvent {
  /// العربية: بداية نطاق التصفية الزمني عند تحديده.
  /// English: The optional start of the filtering date range.
  final DateTime? startDate;

  /// العربية: نهاية نطاق التصفية الزمني عند تحديده.
  /// English: The optional end of the filtering date range.
  final DateTime? endDate;

  /// العربية: فلتر المستخدم المرتبط بالحجز.
  /// English: A filter by the associated user identifier.
  final String? userId;

  /// العربية: فلتر اسم الضيف أو البريد الإلكتروني.
  /// English: A filter by guest name or email.
  final String? guestNameOrEmail;

  /// العربية: فلتر الوحدة السكنية.
  /// English: A filter by the unit identifier.
  final String? unitId;

  /// العربية: فلتر مصدر الحجز.
  /// English: A filter by booking source.
  final String? bookingSource;

  /// العربية: ينشئ حدث الفلترة بالقيم المتاحة فقط.
  /// English: Creates the filter event using only the supplied criteria.
  const FilterBookingsEvent({
    this.startDate,
    this.endDate,
    this.userId,
    this.guestNameOrEmail,
    this.unitId,
    this.bookingSource,
  });

  /// العربية: يجعل كل معيار فلترة جزءًا من المقارنة القيمية.
  /// English: Includes every filter criterion in value equality.
  @override
  List<Object?> get props => [
        startDate,
        endDate,
        userId,
        guestNameOrEmail,
        unitId,
        bookingSource,
      ];
}

/// العربية: يغيّر الصفحة الحالية في القائمة مع الحفاظ على نفس معايير الاستعلام.
/// English: Changes the current page while keeping the active query filters.
class ChangePageEvent extends BookingsListEvent {
  /// العربية: رقم الصفحة المطلوب عرضه.
  /// English: The target page number to display.
  final int pageNumber;

  /// العربية: ينشئ حدث تغيير الصفحة.
  /// English: Creates the page change event.
  const ChangePageEvent({required this.pageNumber});

  /// العربية: يعتمد على رقم الصفحة فقط.
  /// English: Uses the page number as the only comparison value.
  @override
  List<Object> get props => [pageNumber];
}

/// العربية: يغيّر عدد العناصر الظاهرة في كل صفحة من القائمة.
/// English: Changes how many bookings are shown per page.
class ChangePageSizeEvent extends BookingsListEvent {
  /// العربية: العدد الجديد للعناصر في كل صفحة.
  /// English: The new number of items to show per page.
  final int pageSize;

  /// العربية: ينشئ حدث تغيير حجم الصفحة.
  /// English: Creates the page-size change event.
  const ChangePageSizeEvent({required this.pageSize});

  /// العربية: يعتمد على حجم الصفحة الجديد فقط.
  /// English: Uses the page size as the only comparison value.
  @override
  List<Object> get props => [pageSize];
}

/// العربية: يضيف حجزًا واحدًا إلى مجموعة الاختيار الحالية.
/// English: Adds a single booking to the current selection set.
class SelectBookingEvent extends BookingsListEvent {
  /// العربية: معرّف الحجز المراد تحديده.
  /// English: The identifier of the booking to select.
  final String bookingId;

  /// العربية: ينشئ حدث اختيار الحجز.
  /// English: Creates the single-booking selection event.
  const SelectBookingEvent({required this.bookingId});

  /// العربية: يضمن أن معرّف الحجز وحده هو أساس المقارنة.
  /// English: Uses the booking id only for equality.
  @override
  List<Object> get props => [bookingId];
}

/// العربية: يزيل حجزًا واحدًا من مجموعة الاختيار الحالية.
/// English: Removes a single booking from the current selection set.
class DeselectBookingEvent extends BookingsListEvent {
  /// العربية: معرّف الحجز المراد إلغاء تحديده.
  /// English: The identifier of the booking to deselect.
  final String bookingId;

  /// العربية: ينشئ حدث إلغاء اختيار الحجز.
  /// English: Creates the deselection event.
  const DeselectBookingEvent({required this.bookingId});

  /// العربية: يعتمد على معرّف الحجز فقط.
  /// English: Compares events using the booking id only.
  @override
  List<Object> get props => [bookingId];
}

/// العربية: يستبدل الاختيار الحالي بمجموعة جديدة من الحجوزات.
/// English: Replaces the current selection with a new booking set.
class SelectMultipleBookingsEvent extends BookingsListEvent {
  /// العربية: قائمة معرّفات الحجوزات المطلوب تحديدها.
  /// English: The list of booking identifiers to select.
  final List<String> bookingIds;

  /// العربية: ينشئ حدث التحديد المتعدد.
  /// English: Creates the multi-selection event.
  const SelectMultipleBookingsEvent({required this.bookingIds});

  /// العربية: يعتمد على مجموعة المعرّفات المختارة.
  /// English: Compares events by the selected id list.
  @override
  List<Object> get props => [bookingIds];
}

/// العربية: يمسح كل الحجوزات المختارة حاليًا.
/// English: Clears the full current selection set.
class ClearSelectionEvent extends BookingsListEvent {
  /// العربية: ينشئ حدث مسح الاختيار.
  /// English: Creates the clear-selection event.
  const ClearSelectionEvent();
}

/// العربية: يطلب مؤشرات أو ملخصات إحصائية للحجوزات ضمن فترة محددة.
/// English: Requests statistical summaries for bookings within a given period.
class LoadBookingStatsEvent extends BookingsListEvent {
  /// العربية: بداية النطاق الزمني للإحصائيات.
  /// English: The start of the statistics date range.
  final DateTime startDate;

  /// العربية: نهاية النطاق الزمني للإحصائيات.
  /// English: The end of the statistics date range.
  final DateTime endDate;

  /// العربية: معرّف العقار عند الحاجة لتضييق نطاق الإحصائيات.
  /// English: Optional property identifier used to scope the statistics.
  final String? propertyId;

  /// العربية: ينشئ حدث تحميل الإحصائيات.
  /// English: Creates the booking statistics request.
  const LoadBookingStatsEvent({
    required this.startDate,
    required this.endDate,
    this.propertyId,
  });

  /// العربية: يضم جميع معايير الفترة والعقار في المقارنة.
  /// English: Includes the period and property scope in equality checks.
  @override
  List<Object?> get props => [startDate, endDate, propertyId];
}

/// العربية: يطلب بيانات الاتجاهات التاريخية للحجوزات ضمن فترة محددة.
/// English: Requests historical booking trend data for a given period.
class LoadBookingTrendsEvent extends BookingsListEvent {
  /// العربية: بداية النطاق الزمني للاتجاهات.
  /// English: The start of the trend analysis range.
  final DateTime startDate;

  /// العربية: نهاية النطاق الزمني للاتجاهات.
  /// English: The end of the trend analysis range.
  final DateTime endDate;

  /// العربية: معرّف العقار عند الحاجة لتصفية اتجاهاته فقط.
  /// English: Optional property identifier used to scope the trends.
  final String? propertyId;

  /// العربية: ينشئ حدث تحميل اتجاهات الحجوزات.
  /// English: Creates the booking trend request.
  const LoadBookingTrendsEvent({
    required this.startDate,
    required this.endDate,
    this.propertyId,
  });

  /// العربية: يضم معايير الفترة والعقار في المقارنة القيمية.
  /// English: Includes the period and property scope in equality checks.
  @override
  List<Object?> get props => [startDate, endDate, propertyId];
}
