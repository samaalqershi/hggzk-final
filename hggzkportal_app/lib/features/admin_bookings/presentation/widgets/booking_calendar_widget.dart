// lib/features/admin_bookings/presentation/widgets/booking_calendar_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/booking_calendar/booking_calendar_state.dart';
import '../bloc/booking_calendar/booking_calendar_event.dart';

/// يعرض تقويمًا تفاعليًا لقراءة أحداث الحجوزات والتنقل بين الشهور.
/// Renders an interactive calendar for booking events and month navigation.
class BookingCalendarWidget extends StatefulWidget {
  /// يربط كل يوم بقائمة الأحداث الظاهرة فيه داخل التقويم.
  /// Maps each day to the booking events shown in the calendar.
  final Map<DateTime, List<CalendarEvent>> calendarData;

  /// يحدد الشهر المعروض حاليًا في رأس التقويم.
  /// Defines the month currently displayed in the calendar header.
  final DateTime currentMonth;

  /// يحدد نمط العرض الحالي حتى ينسجم التقويم مع السياق العام.
  /// Defines the current view mode so the calendar matches the surrounding context.
  final CalendarView currentView;

  /// يحدد اليوم المختار حاليًا إن وُجد.
  /// Holds the currently selected day, if any.
  final DateTime? selectedDate;

  /// يستدعى عند اختيار يوم جديد من التقويم.
  /// Called when the user selects a new day from the calendar.
  final Function(DateTime) onDateSelected;

  /// يستدعى عند انتقال المستخدم إلى شهر جديد.
  /// Called when the user navigates to a different month.
  final Function(DateTime) onMonthChanged;

  /// ينشئ ويدجت التقويم مع البيانات وروابط التفاعل الضرورية.
  /// Creates the calendar widget with its data and interaction callbacks.
  const BookingCalendarWidget({
    super.key,
    required this.calendarData,
    required this.currentMonth,
    required this.currentView,
    this.selectedDate,
    required this.onDateSelected,
    required this.onMonthChanged,
  });

  /// ينشئ حالة التقويم التي تدير الشهر المركّز ونمط العرض.
  /// Creates the calendar state that manages the focused month and format.
  @override
  State<BookingCalendarWidget> createState() => _BookingCalendarWidgetState();
}

/// يدير حالة التقويم الداخلية بما في ذلك الشهر المركّز ونوع العرض.
/// Manages the calendar state, including the focused month and display format.
class _BookingCalendarWidgetState extends State<BookingCalendarWidget> {
  /// يحدد صيغة عرض التقويم الحالية.
  /// Stores the current calendar format.
  late CalendarFormat _calendarFormat;

  /// يحدد اليوم أو الشهر الذي يظل التقويم متمحورًا حوله.
  /// Stores the day or month the calendar is currently focused on.
  late DateTime _focusedDay;

  /// يهيئ صيغة العرض المناسبة وينطلق من الشهر المحدد في الأصل.
  /// Initializes the proper format and starts from the provided month.
  @override
  void initState() {
    super.initState();
    _calendarFormat = _getCalendarFormat();
    _focusedDay = widget.currentMonth;
  }

  /// يترجم نمط العرض العام إلى صيغة `TableCalendar` المناسبة.
  /// Translates the overall view mode into the matching `TableCalendar` format.
  CalendarFormat _getCalendarFormat() {
    switch (widget.currentView) {
      case CalendarView.month:
        return CalendarFormat.month;
      case CalendarView.week:
        return CalendarFormat.week;
      case CalendarView.day:
        return CalendarFormat.week;
      default:
        return CalendarFormat.month;
    }
  }

  @override

  /// يبني الحاوية الرئيسية التي تجمع الرأس والتقويم والأسطورة.
  /// Builds the main container that combines the header, calendar, and legend.
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              _buildHeader(),
              _buildCalendar(),
              _buildLegend(),
            ],
          ),
        ),
      ),
    );
  }

  /// يبني رأس التقويم مع عنوان الشهر وأزرار التنقل.
  /// Builds the calendar header with the month title and navigation buttons.
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.darkBorder.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.calendar,
            color: AppTheme.primaryBlue,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            _formatMonthYear(_focusedDay),
            style: AppTextStyles.heading3.copyWith(
              color: AppTheme.textWhite,
            ),
          ),
          const Spacer(),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  /// يعرض أزرار الانتقال للشهر السابق والحالي واللاحق.
  /// Shows the previous, current, and next month navigation buttons.
  Widget _buildNavigationButtons() {
    return Row(
      children: [
        _buildNavButton(
          icon: CupertinoIcons.chevron_right,
          onTap: () {
            setState(() {
              _focusedDay = DateTime(
                _focusedDay.year,
                _focusedDay.month - 1,
              );
            });
            widget.onMonthChanged(_focusedDay);
          },
        ),
        const SizedBox(width: 8),
        _buildNavButton(
          icon: CupertinoIcons.calendar_today,
          onTap: () {
            setState(() {
              _focusedDay = DateTime.now();
            });
            widget.onMonthChanged(_focusedDay);
          },
        ),
        const SizedBox(width: 8),
        _buildNavButton(
          icon: CupertinoIcons.chevron_left,
          onTap: () {
            setState(() {
              _focusedDay = DateTime(
                _focusedDay.year,
                _focusedDay.month + 1,
              );
            });
            widget.onMonthChanged(_focusedDay);
          },
        ),
      ],
    );
  }

  /// يبني زر تنقل صغيرًا بإطار وزر لمس متناسق.
  /// Builds a compact navigation button with consistent styling.
  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 18,
              color: AppTheme.textWhite,
            ),
          ),
        ),
      ),
    );
  }

  /// يبني عنصر `TableCalendar` مع الأحداث والأنماط وخيارات التحديد.
  /// Builds the `TableCalendar` with events, styles, and selection behavior.
  Widget _buildCalendar() {
    return TableCalendar<CalendarEvent>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) {
        return isSameDay(widget.selectedDate, day);
      },
      eventLoader: (day) {
        return widget.calendarData[DateTime(day.year, day.month, day.day)] ??
            [];
      },
      startingDayOfWeek: StartingDayOfWeek.sunday,
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,

        // Default cell decoration
        defaultDecoration: BoxDecoration(
          color: AppTheme.darkBackground.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
        ),

        // Weekend cell decoration
        weekendDecoration: BoxDecoration(
          color: AppTheme.darkBackground.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),

        // Selected cell decoration
        selectedDecoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),

        // Today cell decoration
        todayDecoration: BoxDecoration(
          color: AppTheme.primaryBlue.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.primaryBlue,
            width: 2,
          ),
        ),

        // Text styles
        defaultTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppTheme.textWhite,
        ),
        weekendTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppTheme.textMuted,
        ),
        selectedTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        todayTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppTheme.primaryBlue,
          fontWeight: FontWeight.bold,
        ),

        // Marker decoration
        markerDecoration: BoxDecoration(
          color: AppTheme.primaryPurple,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 3,
        markersAlignment: Alignment.bottomCenter,
        markerSize: 6,
        markerMargin: const EdgeInsets.symmetric(horizontal: 1),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        leftChevronVisible: false,
        rightChevronVisible: false,
        headerPadding: EdgeInsets.zero,
        headerMargin: EdgeInsets.zero,
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: AppTextStyles.caption.copyWith(
          color: AppTheme.textMuted,
          fontWeight: FontWeight.w600,
        ),
        weekendStyle: AppTextStyles.caption.copyWith(
          color: AppTheme.textMuted.withValues(alpha: 0.6),
          fontWeight: FontWeight.w600,
        ),
      ),
      onDaySelected: (selectedDay, focusedDay) {
        widget.onDateSelected(selectedDay);
        setState(() {
          _focusedDay = focusedDay;
        });
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
        widget.onMonthChanged(focusedDay);
      },
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          if (events.isEmpty) return null;

          return Positioned(
            bottom: 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: events.take(3).map((event) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _getEventColor(event.type),
                    shape: BoxShape.circle,
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  /// يعرض أسطورة الألوان لشرح أنواع الأحداث في التقويم.
  /// Displays the color legend that explains calendar event types.
  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.darkBorder.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(
            color: AppTheme.success,
            label: 'تسجيل وصول',
          ),
          _buildLegendItem(
            color: AppTheme.error,
            label: 'تسجيل مغادرة',
          ),
          _buildLegendItem(
            color: AppTheme.primaryBlue,
            label: 'إقامة',
          ),
        ],
      ),
    );
  }

  /// يبني عنصرًا واحدًا من عناصر الأسطورة مع اللون والعنوان.
  /// Builds one legend item with its color swatch and label.
  Widget _buildLegendItem({
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }

  /// يختار اللون المناسب لنوع الحدث الظاهر في التقويم.
  /// Resolves the matching color for the event type shown in the calendar.
  Color _getEventColor(EventType type) {
    switch (type) {
      case EventType.checkIn:
        return AppTheme.success;
      case EventType.checkOut:
        return AppTheme.error;
      case EventType.stay:
        return AppTheme.primaryBlue;
    }
  }

  /// ينسّق الشهر والسنة بصيغة عربية موجزة لعنوان الرأس.
  /// Formats the month and year as a concise Arabic header label.
  String _formatMonthYear(DateTime date) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
