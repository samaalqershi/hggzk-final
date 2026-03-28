import 'package:equatable/equatable.dart';

/// العربية: يعرّف أحداث شاشة تقويم الحجوزات من التنقل الزمني إلى التصفية والاختيار.
/// English: Defines booking-calendar events from date navigation to filtering and selection.
abstract class BookingCalendarEvent extends Equatable {
  /// العربية: ينشئ الأساس المشترك لأحداث التقويم.
  /// English: Creates the shared base for calendar events.
  const BookingCalendarEvent();

  /// العربية: لا توجد حقول مشتركة، لذا تعتمد المساواة على الفئات الفرعية.
  /// English: No shared fields exist here, so equality is controlled by subclasses.
  @override
  List<Object?> get props => [];
}

/// العربية: يطلب تحميل الحجوزات الظاهرة داخل نطاق التقويم الحالي.
/// English: Requests the bookings visible within the current calendar range.
class LoadCalendarBookingsEvent extends BookingCalendarEvent {
  /// العربية: الشهر أو اليوم المرجعي الذي يُبنى عليه نطاق التحميل.
  /// English: The reference month or day used to build the loading range.
  final DateTime month;

  /// العربية: طريقة عرض التقويم المطلوبة مثل الشهر أو الأسبوع.
  /// English: The requested calendar view such as month or week.
  final CalendarView view;

  /// العربية: ينشئ طلب تحميل حجوزات التقويم.
  /// English: Creates the calendar-bookings load request.
  const LoadCalendarBookingsEvent({
    required this.month,
    this.view = CalendarView.month,
  });

  /// العربية: يعتمد على الشهر وطريقة العرض في المقارنة.
  /// English: Uses the month and view in equality checks.
  @override
  List<Object> get props => [month, view];
}

/// العربية: يغيّر الشهر المرجعي المستخدم في عرض التقويم.
/// English: Changes the reference month used by the calendar view.
class ChangeCalendarMonthEvent extends BookingCalendarEvent {
  /// العربية: الشهر المطلوب عرضه.
  /// English: The month to display.
  final DateTime month;

  /// العربية: ينشئ حدث تغيير الشهر.
  /// English: Creates the month-change event.
  const ChangeCalendarMonthEvent({required this.month});

  /// العربية: يعتمد على الشهر المختار فقط.
  /// English: Uses the selected month only for equality.
  @override
  List<Object> get props => [month];
}

/// العربية: يغيّر نمط عرض التقويم بين اليوم والأسبوع والشهر والسنة.
/// English: Changes the calendar display mode between day, week, month, and year.
class ChangeCalendarViewEvent extends BookingCalendarEvent {
  /// العربية: طريقة العرض الجديدة.
  /// English: The new calendar view.
  final CalendarView view;

  /// العربية: ينشئ حدث تغيير طريقة العرض.
  /// English: Creates the view-change event.
  const ChangeCalendarViewEvent({required this.view});

  /// العربية: يعتمد على طريقة العرض الجديدة فقط.
  /// English: Uses the selected view only for equality.
  @override
  List<Object> get props => [view];
}

/// العربية: يختار تاريخًا معينًا داخل التقويم لعرض الحجوزات المرتبطة به.
/// English: Selects a specific date in the calendar to show its related bookings.
class SelectCalendarDateEvent extends BookingCalendarEvent {
  /// العربية: التاريخ المطلوب تحديده.
  /// English: The date to select.
  final DateTime date;

  /// العربية: ينشئ حدث اختيار التاريخ.
  /// English: Creates the date-selection event.
  const SelectCalendarDateEvent({required this.date});

  /// العربية: يعتمد على التاريخ المحدد فقط.
  /// English: Uses the selected date only for equality.
  @override
  List<Object> get props => [date];
}

/// العربية: يختار حجزًا معينًا لعرض تفاصيله من داخل التقويم.
/// English: Selects a specific booking to show its details from the calendar.
class SelectCalendarBookingEvent extends BookingCalendarEvent {
  /// العربية: معرّف الحجز المطلوب.
  /// English: The booking identifier to select.
  final String bookingId;

  /// العربية: ينشئ حدث اختيار الحجز.
  /// English: Creates the booking-selection event.
  const SelectCalendarBookingEvent({required this.bookingId});

  /// العربية: يعتمد على معرّف الحجز فقط.
  /// English: Uses the booking id only for equality.
  @override
  List<Object> get props => [bookingId];
}

/// العربية: يفلتر التقويم بحسب الوحدة السكنية عند الحاجة.
/// English: Filters the calendar by a unit when needed.
class FilterCalendarByUnitEvent extends BookingCalendarEvent {
  /// العربية: معرّف الوحدة أو القيمة الفارغة لإلغاء الفلتر.
  /// English: The unit identifier or null to clear the filter.
  final String? unitId;

  /// العربية: ينشئ حدث الفلترة حسب الوحدة.
  /// English: Creates the unit-filter event.
  const FilterCalendarByUnitEvent({this.unitId});

  /// العربية: يعتمد على معرّف الوحدة فقط.
  /// English: Uses the unit id only for equality.
  @override
  List<Object?> get props => [unitId];
}

/// العربية: يفلتر التقويم بحسب العقار المحدد.
/// English: Filters the calendar by the selected property.
class FilterCalendarByPropertyEvent extends BookingCalendarEvent {
  /// العربية: معرّف العقار المطلوب.
  /// English: The property identifier to filter by.
  final String propertyId;

  /// العربية: ينشئ حدث الفلترة حسب العقار.
  /// English: Creates the property-filter event.
  const FilterCalendarByPropertyEvent({required this.propertyId});

  /// العربية: يعتمد على معرّف العقار فقط.
  /// English: Uses the property id only for equality.
  @override
  List<Object> get props => [propertyId];
}

/// العربية: يطلب إعادة تحميل بيانات التقويم الحالية.
/// English: Requests a refresh of the current calendar data.
class RefreshCalendarEvent extends BookingCalendarEvent {
  /// العربية: ينشئ حدث التحديث بلا مدخلات إضافية.
  /// English: Creates the refresh event with no additional inputs.
  const RefreshCalendarEvent();
}

/// العربية: يبدل ظهور وسيلة الإيضاح الخاصة بألوان أو رموز التقويم.
/// English: Toggles the calendar legend that explains colors or icons.
class ToggleCalendarLegendEvent extends BookingCalendarEvent {
  /// العربية: ينشئ حدث تبديل وسيلة الإيضاح.
  /// English: Creates the legend-toggle event.
  const ToggleCalendarLegendEvent();
}

/// العربية: تمثل أوضاع عرض التقويم المتاحة.
/// English: Represents the available calendar display modes.
enum CalendarView {
  /// العربية: عرض يوم واحد.
  /// English: Day view.
  day,

  /// العربية: عرض أسبوع كامل.
  /// English: Week view.
  week,

  /// العربية: عرض شهر كامل.
  /// English: Month view.
  month,

  /// العربية: عرض سنة كاملة.
  /// English: Year view.
  year,
}
