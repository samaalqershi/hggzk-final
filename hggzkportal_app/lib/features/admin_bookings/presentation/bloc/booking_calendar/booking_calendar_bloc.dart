import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/booking.dart';
import '../../../domain/usecases/bookings/get_bookings_by_date_range_usecase.dart';
import '../../../domain/usecases/bookings/get_bookings_by_unit_usecase.dart';
import '../../../domain/usecases/bookings/get_bookings_by_property_usecase.dart';
import 'booking_calendar_event.dart';
import 'booking_calendar_state.dart';

/// العربية: يدير بيانات تقويم الحجوزات بما في ذلك التنقل بين الأشهر والاختيار والفلترة.
/// English: Manages booking-calendar data including month navigation, selection, and filtering.
class BookingCalendarBloc
    extends Bloc<BookingCalendarEvent, BookingCalendarState> {
  /// العربية: يجلب الحجوزات حسب نطاق التاريخ الحالي للتقويم.
  /// English: Fetches bookings for the calendar's current date range.
  final GetBookingsByDateRangeUseCase getBookingsByDateRangeUseCase;

  /// العربية: يجلب الحجوزات الخاصة بوحدة معينة عند الحاجة.
  /// English: Fetches bookings for a specific unit when needed.
  final GetBookingsByUnitUseCase getBookingsByUnitUseCase;

  /// العربية: يجلب الحجوزات الخاصة بعقار محدد عند تطبيق الفلتر.
  /// English: Fetches bookings for a specific property when the filter is applied.
  final GetBookingsByPropertyUseCase getBookingsByPropertyUseCase;

  /// العربية: يحتفظ بالشهر المرجعي المستخدم في التنقل وإعادة التحميل.
  /// English: Stores the reference month used for navigation and refreshes.
  DateTime _currentMonth = DateTime.now();

  /// العربية: يحفظ فلتر الوحدة النشط عند تطبيقه.
  /// English: Stores the active unit filter when applied.
  String? _currentUnitId;

  /// العربية: يحفظ وضع عرض التقويم النشط.
  /// English: Stores the active calendar view mode.
  CalendarView _currentView = CalendarView.month;

  /// العربية: ينشئ BLoC التقويم ويربط كل حدث بمعالجه المناسب.
  /// English: Creates the calendar bloc and wires every event to its handler.
  BookingCalendarBloc({
    required this.getBookingsByDateRangeUseCase,
    required this.getBookingsByUnitUseCase,
    required this.getBookingsByPropertyUseCase,
  }) : super(BookingCalendarInitial()) {
    on<LoadCalendarBookingsEvent>(_onLoadCalendarBookings);
    on<ChangeCalendarMonthEvent>(_onChangeCalendarMonth);
    on<ChangeCalendarViewEvent>(_onChangeCalendarView);
    on<SelectCalendarDateEvent>(_onSelectCalendarDate);
    on<SelectCalendarBookingEvent>(_onSelectCalendarBooking);
    on<FilterCalendarByUnitEvent>(_onFilterCalendarByUnit);
    on<FilterCalendarByPropertyEvent>(_onFilterCalendarByProperty);
    on<RefreshCalendarEvent>(_onRefreshCalendar);
    on<ToggleCalendarLegendEvent>(_onToggleCalendarLegend);
  }

  /// العربية: يحمّل الحجوزات ضمن النطاق الناتج عن الشهر وطريقة العرض الحالية.
  /// English: Loads bookings within the range derived from the current month and view.
  Future<void> _onLoadCalendarBookings(
    LoadCalendarBookingsEvent event,
    Emitter<BookingCalendarState> emit,
  ) async {
    emit(BookingCalendarLoading());

    _currentMonth = event.month;
    _currentView = event.view;

    // حساب نطاق التواريخ بناءً على العرض
    final dateRange = _calculateDateRange(event.month, event.view);

    final result = await getBookingsByDateRangeUseCase(
      GetBookingsByDateRangeParams(
        startDate: dateRange.start,
        endDate: dateRange.end,
        unitId: _currentUnitId,
        pageSize: 20, // جلب جميع الحجوزات للشهر
      ),
    );

    result.fold(
      (failure) => emit(BookingCalendarError(message: failure.message)),
      (bookings) {
        final calendarData = _processBookingsForCalendar(
          bookings.items,
          dateRange.start,
          dateRange.end,
        );

        emit(BookingCalendarLoaded(
          bookings: bookings.items,
          calendarData: calendarData,
          currentMonth: event.month,
          currentView: event.view,
          selectedDate: null,
          selectedBooking: null,
          showLegend: true,
        ));
      },
    );
  }

  /// العربية: يبدّل الشهر المرجعي ثم يعيد تحميل بيانات التقويم وفقًا له.
  /// English: Changes the reference month and reloads the calendar data accordingly.
  Future<void> _onChangeCalendarMonth(
    ChangeCalendarMonthEvent event,
    Emitter<BookingCalendarState> emit,
  ) async {
    add(LoadCalendarBookingsEvent(
      month: event.month,
      view: _currentView,
    ));
  }

  /// العربية: يغيّر طريقة العرض ثم يعيد تحميل البيانات بالنطاق المناسب.
  /// English: Changes the calendar view and reloads data with a matching range.
  Future<void> _onChangeCalendarView(
    ChangeCalendarViewEvent event,
    Emitter<BookingCalendarState> emit,
  ) async {
    add(LoadCalendarBookingsEvent(
      month: _currentMonth,
      view: event.view,
    ));
  }

  /// العربية: يحدد تاريخًا داخل التقويم ويستخرج الحجوزات التي تغطيه.
  /// English: Selects a date in the calendar and extracts the bookings that span it.
  Future<void> _onSelectCalendarDate(
    SelectCalendarDateEvent event,
    Emitter<BookingCalendarState> emit,
  ) async {
    if (state is BookingCalendarLoaded) {
      final currentState = state as BookingCalendarLoaded;

      // جلب الحجوزات لليوم المحدد
      final dayBookings = currentState.bookings.where((booking) {
        return (booking.checkIn.isBefore(event.date) ||
                booking.checkIn.isAtSameMomentAs(event.date)) &&
            (booking.checkOut.isAfter(event.date) ||
                booking.checkOut.isAtSameMomentAs(event.date));
      }).toList();

      emit(currentState.copyWith(
        selectedDate: event.date,
        selectedDateBookings: dayBookings,
      ));
    }
  }

  /// العربية: يختار الحجز المطابق للمعرّف لعرض تفاصيله ضمن التقويم.
  /// English: Selects the booking matching the id so its details can be shown in the calendar.
  Future<void> _onSelectCalendarBooking(
    SelectCalendarBookingEvent event,
    Emitter<BookingCalendarState> emit,
  ) async {
    if (state is BookingCalendarLoaded) {
      final currentState = state as BookingCalendarLoaded;
      final booking = currentState.bookings.firstWhere(
        (b) => b.id == event.bookingId,
      );

      emit(currentState.copyWith(selectedBooking: booking));
    }
  }

  /// العربية: يضبط فلتر الوحدة ثم يعيد تحميل نطاق التقويم نفسه.
  /// English: Sets the unit filter and reloads the same calendar range.
  Future<void> _onFilterCalendarByUnit(
    FilterCalendarByUnitEvent event,
    Emitter<BookingCalendarState> emit,
  ) async {
    _currentUnitId = event.unitId;
    add(LoadCalendarBookingsEvent(
      month: _currentMonth,
      view: _currentView,
    ));
  }

  /// العربية: يطبق فلتر العقار ويعيد بناء بيانات التقويم للنطاق نفسه.
  /// English: Applies the property filter and rebuilds calendar data for the same range.
  Future<void> _onFilterCalendarByProperty(
    FilterCalendarByPropertyEvent event,
    Emitter<BookingCalendarState> emit,
  ) async {
    if (state is BookingCalendarLoaded) {
      final currentState = state as BookingCalendarLoaded;
      emit(BookingCalendarLoading());

      final dateRange = _calculateDateRange(_currentMonth, _currentView);

      final result = await getBookingsByPropertyUseCase(
        GetBookingsByPropertyParams(
          propertyId: event.propertyId,
          startDate: dateRange.start,
          endDate: dateRange.end,
          pageSize: 20,
        ),
      );

      result.fold(
        (failure) => emit(BookingCalendarError(message: failure.message)),
        (bookings) {
          final calendarData = _processBookingsForCalendar(
            bookings.items,
            dateRange.start,
            dateRange.end,
          );

          emit(BookingCalendarLoaded(
            bookings: bookings.items,
            calendarData: calendarData,
            currentMonth: _currentMonth,
            currentView: _currentView,
            selectedDate: currentState.selectedDate,
            selectedBooking: null,
            showLegend: currentState.showLegend,
          ));
        },
      );
    }
  }

  /// العربية: يعيد تحميل بيانات التقويم باستخدام آخر إعدادات معروفة.
  /// English: Reloads calendar data using the last known settings.
  Future<void> _onRefreshCalendar(
    RefreshCalendarEvent event,
    Emitter<BookingCalendarState> emit,
  ) async {
    add(LoadCalendarBookingsEvent(
      month: _currentMonth,
      view: _currentView,
    ));
  }

  /// العربية: يبدّل ظهور وسيلة الإيضاح دون تغيير بيانات التقويم الأساسية.
  /// English: Toggles the legend visibility without changing the core calendar data.
  Future<void> _onToggleCalendarLegend(
    ToggleCalendarLegendEvent event,
    Emitter<BookingCalendarState> emit,
  ) async {
    if (state is BookingCalendarLoaded) {
      final currentState = state as BookingCalendarLoaded;
      emit(currentState.copyWith(showLegend: !currentState.showLegend));
    }
  }

  /// العربية: يحول الشهر وطريقة العرض إلى نطاق تاريخ مناسب للجلب.
  /// English: Converts the month and view mode into a fetchable date range.
  DateRange _calculateDateRange(DateTime month, CalendarView view) {
    DateTime start, end;

    switch (view) {
      case CalendarView.day:
        start = DateTime(month.year, month.month, month.day);
        end = start.add(const Duration(days: 1));
        break;
      case CalendarView.week:
        final weekday = month.weekday;
        start = month.subtract(Duration(days: weekday - 1));
        end = start.add(const Duration(days: 7));
        break;
      case CalendarView.month:
        start = DateTime(month.year, month.month, 1);
        end = DateTime(month.year, month.month + 1, 0);
        break;
      case CalendarView.year:
        start = DateTime(month.year, 1, 1);
        end = DateTime(month.year, 12, 31);
        break;
    }

    return DateRange(start: start, end: end);
  }

  /// العربية: يحوّل الحجوزات إلى أحداث تقويم مرتبة حسب اليوم لعرضها بصريًا.
  /// English: Converts bookings into day-grouped calendar events for visual presentation.
  Map<DateTime, List<CalendarEvent>> _processBookingsForCalendar(
    List<Booking> bookings,
    DateTime start,
    DateTime end,
  ) {
    final Map<DateTime, List<CalendarEvent>> calendarData = {};

    for (var booking in bookings) {
      // إضافة أحداث لكل يوم في نطاق الحجز
      DateTime currentDate = booking.checkIn;
      while (currentDate.isBefore(booking.checkOut) ||
          currentDate.isAtSameMomentAs(booking.checkOut)) {
        final dateKey = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
        );

        if (!calendarData.containsKey(dateKey)) {
          calendarData[dateKey] = [];
        }

        EventType eventType = EventType.stay;
        if (currentDate.isAtSameMomentAs(booking.checkIn)) {
          eventType = EventType.checkIn;
        } else if (currentDate.isAtSameMomentAs(booking.checkOut)) {
          eventType = EventType.checkOut;
        }

        calendarData[dateKey]!.add(CalendarEvent(
          bookingId: booking.id,
          title: '${booking.userName} - ${booking.unitName}',
          type: eventType,
          status: booking.status,
        ));

        currentDate = currentDate.add(const Duration(days: 1));
      }
    }

    return calendarData;
  }
}

/// العربية: يمثل نطاقًا زمنيًا بسيطًا يعتمد عليه BLoC عند طلب بيانات التقويم.
/// English: Represents the simple time range used by the bloc when requesting calendar data.
class DateRange {
  /// العربية: بداية النطاق الزمني.
  /// English: The start of the time range.
  final DateTime start;

  /// العربية: نهاية النطاق الزمني.
  /// English: The end of the time range.
  final DateTime end;

  /// العربية: ينشئ نطاق التاريخ من البداية إلى النهاية.
  /// English: Creates the date range from start to end.
  DateRange({required this.start, required this.end});
}
