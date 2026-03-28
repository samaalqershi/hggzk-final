import 'package:equatable/equatable.dart';
import '../../../../../../core/enums/booking_status.dart';
import '../../../domain/entities/booking.dart';
import 'booking_calendar_event.dart';

/// العربية: يعرّف حالات تقويم الحجوزات من التحميل الأولي إلى عرض الإحصائيات والاختيار.
/// English: Defines booking-calendar states from initial loading to statistics and selection views.
abstract class BookingCalendarState extends Equatable {
  /// العربية: ينشئ الأساس المشترك لحالات التقويم.
  /// English: Creates the shared base for calendar states.
  const BookingCalendarState();

  /// العربية: لا توجد حقول مشتركة، لذا تعتمد المساواة على الفئات الفرعية.
  /// English: No shared fields exist here, so equality is controlled by subclasses.
  @override
  List<Object?> get props => [];
}

/// العربية: تمثل الحالة قبل تحميل أي بيانات تقويم.
/// English: Represents the state before any calendar data is loaded.
class BookingCalendarInitial extends BookingCalendarState {}

/// العربية: تشير إلى أن بيانات التقويم تُجلب حاليًا.
/// English: Indicates that calendar data is currently being fetched.
class BookingCalendarLoading extends BookingCalendarState {}

/// العربية: تحمل الحجوزات وبيانات التقويم والاختيارات الحالية.
/// English: Holds the bookings, calendar data, and current selections.
class BookingCalendarLoaded extends BookingCalendarState {
  /// العربية: الحجوزات التي تم جلبها للنطاق الحالي.
  /// English: The bookings fetched for the current range.
  final List<Booking> bookings;

  /// العربية: خريطة الأيام إلى أحداث التقويم المرتبطة بها.
  /// English: A day-to-events map for the calendar entries.
  final Map<DateTime, List<CalendarEvent>> calendarData;

  /// العربية: الشهر المرجعي أو الفترة المعروضة حاليًا.
  /// English: The reference month or period currently displayed.
  final DateTime currentMonth;

  /// العربية: طريقة العرض الحالية مثل الشهر أو الأسبوع.
  /// English: The current calendar view such as month or week.
  final CalendarView currentView;

  /// العربية: التاريخ المحدد حاليًا داخل التقويم.
  /// English: The currently selected date in the calendar.
  final DateTime? selectedDate;

  /// العربية: الحجوزات المرتبطة بالتاريخ المحدد.
  /// English: The bookings associated with the selected date.
  final List<Booking>? selectedDateBookings;

  /// العربية: الحجز المحدد حاليًا من داخل التقويم.
  /// English: The booking currently selected from the calendar.
  final Booking? selectedBooking;

  /// العربية: يحدد ما إذا كانت وسيلة الإيضاح ظاهرة للمستخدم.
  /// English: Indicates whether the legend is visible to the user.
  final bool showLegend;

  /// العربية: ينشئ حالة التقويم المحمّلة بكل البيانات الحالية.
  /// English: Creates the fully loaded calendar state with its current data.
  const BookingCalendarLoaded({
    required this.bookings,
    required this.calendarData,
    required this.currentMonth,
    required this.currentView,
    this.selectedDate,
    this.selectedDateBookings,
    this.selectedBooking,
    this.showLegend = true,
  });

  /// العربية: ينشئ نسخة معدلة مع الاحتفاظ بالقيم غير المحددة كما هي.
  /// English: Creates a modified copy while preserving unspecified values.
  BookingCalendarLoaded copyWith({
    List<Booking>? bookings,
    Map<DateTime, List<CalendarEvent>>? calendarData,
    DateTime? currentMonth,
    CalendarView? currentView,
    DateTime? selectedDate,
    List<Booking>? selectedDateBookings,
    Booking? selectedBooking,
    bool? showLegend,
  }) {
    return BookingCalendarLoaded(
      bookings: bookings ?? this.bookings,
      calendarData: calendarData ?? this.calendarData,
      currentMonth: currentMonth ?? this.currentMonth,
      currentView: currentView ?? this.currentView,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedDateBookings: selectedDateBookings ?? this.selectedDateBookings,
      selectedBooking: selectedBooking ?? this.selectedBooking,
      showLegend: showLegend ?? this.showLegend,
    );
  }

  /// العربية: يحسب إحصائيات الشهر الحالية من الأحداث والحجوزات المتاحة.
  /// English: Computes the current month's statistics from the available bookings and events.
  MonthStatistics get monthStatistics {
    int checkIns = 0;
    int checkOuts = 0;
    double totalRevenue = 0;

    calendarData.forEach((date, events) {
      for (var event in events) {
        if (event.type == EventType.checkIn) checkIns++;
        if (event.type == EventType.checkOut) checkOuts++;

        // حساب الإيرادات
        final booking = bookings.firstWhere((b) => b.id == event.bookingId);
        if (event.type == EventType.checkIn) {
          totalRevenue += booking.totalPrice.amount;
        }
      }
    });

    return MonthStatistics(
      totalBookings: bookings.length,
      checkIns: checkIns,
      checkOuts: checkOuts,
      totalRevenue: totalRevenue,
      occupancyRate: _calculateOccupancyRate(),
    );
  }

  /// العربية: يحسب نسبة الإشغال بناءً على عدد الأيام المحتلة داخل الشهر.
  /// English: Calculates the occupancy rate from the occupied days within the month.
  double _calculateOccupancyRate() {
    if (bookings.isEmpty) return 0;

    int totalDays = 0;
    int occupiedDays = 0;

    final daysInMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    totalDays = daysInMonth;

    calendarData.forEach((date, events) {
      if (events.isNotEmpty) occupiedDays++;
    });

    return (occupiedDays / totalDays) * 100;
  }

  /// العربية: يعتمد على كل البيانات الظاهرة والاختيارات الحالية لضمان إعادة بناء دقيقة للواجهة.
  /// English: Uses all visible data and current selections to ensure precise UI rebuilds.
  @override
  List<Object?> get props => [
        bookings,
        calendarData,
        currentMonth,
        currentView,
        selectedDate,
        selectedDateBookings,
        selectedBooking,
        showLegend,
      ];
}

/// العربية: تمثل فشلًا في تحميل أو معالجة بيانات التقويم.
/// English: Represents a failure while loading or processing calendar data.
class BookingCalendarError extends BookingCalendarState {
  /// العربية: رسالة الخطأ التي تشرح سبب الفشل.
  /// English: The error message explaining the failure.
  final String message;

  /// العربية: ينشئ حالة الخطأ مع الرسالة.
  /// English: Creates the error state with its message.
  const BookingCalendarError({required this.message});

  /// العربية: يعتمد على رسالة الخطأ فقط.
  /// English: Uses the error message only for equality.
  @override
  List<Object> get props => [message];
}

/// العربية: تمثل حدثًا واحدًا معروضًا على تاريخ محدد داخل التقويم.
/// English: Represents a single event shown on a specific date in the calendar.
class CalendarEvent extends Equatable {
  /// العربية: معرّف الحجز الذي ينتمي إليه الحدث.
  /// English: The booking identifier that owns this calendar event.
  final String bookingId;

  /// العربية: العنوان النصي الظاهر في واجهة التقويم.
  /// English: The text title shown in the calendar UI.
  final String title;

  /// العربية: نوع الحدث مثل وصول أو مغادرة أو إقامة.
  /// English: The event type such as check-in, check-out, or stay.
  final EventType type;

  /// العربية: حالة الحجز الأصلية المرتبطة بالحدث.
  /// English: The original booking status associated with the event.
  final BookingStatus status;

  /// العربية: ينشئ حدث التقويم مع جميع البيانات المطلوبة للعرض.
  /// English: Creates the calendar event with all data required for display.
  const CalendarEvent({
    required this.bookingId,
    required this.title,
    required this.type,
    required this.status,
  });

  /// العربية: يعتمد على الهوية والعنوان والنوع والحالة.
  /// English: Uses the booking id, title, type, and status for equality.
  @override
  List<Object> get props => [bookingId, title, type, status];
}

/// العربية: يحدد نوع العلامة الزمنية المعروضة في التقويم.
/// English: Identifies the kind of time marker shown in the calendar.
enum EventType {
  /// العربية: يوم الوصول إلى الحجز.
  /// English: Booking check-in day.
  checkIn,

  /// العربية: يوم المغادرة من الحجز.
  /// English: Booking check-out day.
  checkOut,

  /// العربية: الأيام الواقعة بين الوصول والمغادرة.
  /// English: Days that fall between check-in and check-out.
  stay,
}

/// العربية: تلخص أهم أرقام الشهر المعروض في التقويم.
/// English: Summarizes the key figures for the month shown in the calendar.
class MonthStatistics extends Equatable {
  /// العربية: إجمالي الحجوزات ضمن النطاق الحالي.
  /// English: The total bookings in the current range.
  final int totalBookings;

  /// العربية: عدد عمليات تسجيل الوصول.
  /// English: The number of check-in events.
  final int checkIns;

  /// العربية: عدد عمليات تسجيل المغادرة.
  /// English: The number of check-out events.
  final int checkOuts;

  /// العربية: إجمالي الإيرادات المحسوبة من الحجوزات.
  /// English: The total revenue calculated from bookings.
  final double totalRevenue;

  /// العربية: نسبة الإشغال للشهر الحالي.
  /// English: The occupancy rate for the current month.
  final double occupancyRate;

  /// العربية: ينشئ ملخص الشهر بالإحصائيات الأساسية.
  /// English: Creates the monthly summary with its core statistics.
  const MonthStatistics({
    required this.totalBookings,
    required this.checkIns,
    required this.checkOuts,
    required this.totalRevenue,
    required this.occupancyRate,
  });

  /// العربية: يعتمد على جميع القيم العددية في الإحصائيات.
  /// English: Uses all numeric statistics for equality.
  @override
  List<Object> get props => [
        totalBookings,
        checkIns,
        checkOuts,
        totalRevenue,
        occupancyRate,
      ];
}
