import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';

class AvailabilityCalendarResult {
  final DateTime checkIn;
  final DateTime checkOut;

  const AvailabilityCalendarResult({
    required this.checkIn,
    required this.checkOut,
  });
}

class AvailabilityCalendarDialog extends StatefulWidget {
  final DateTime firstDay;
  final DateTime lastDay;
  final Set<DateTime> availableDates;
  final Set<DateTime> unpricedDates;
  final DateTime? initialCheckIn;
  final DateTime? initialCheckOut;

  const AvailabilityCalendarDialog({
    super.key,
    required this.firstDay,
    required this.lastDay,
    required this.availableDates,
    required this.unpricedDates,
    this.initialCheckIn,
    this.initialCheckOut,
  });

  static Future<AvailabilityCalendarResult?> show(
    BuildContext context, {
    required DateTime firstDay,
    required DateTime lastDay,
    required Set<DateTime> availableDates,
    required Set<DateTime> unpricedDates,
    DateTime? initialCheckIn,
    DateTime? initialCheckOut,
  }) {
    return showDialog<AvailabilityCalendarResult>(
      context: context,
      builder: (_) => AvailabilityCalendarDialog(
        firstDay: firstDay,
        lastDay: lastDay,
        availableDates: availableDates,
        unpricedDates: unpricedDates,
        initialCheckIn: initialCheckIn,
        initialCheckOut: initialCheckOut,
      ),
    );
  }

  @override
  State<AvailabilityCalendarDialog> createState() =>
      _AvailabilityCalendarDialogState();
}

class _AvailabilityCalendarDialogState
    extends State<AvailabilityCalendarDialog> {
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  late DateTime _focusedDay;
  late final Set<int> _availableKeys;
  late final Set<int> _unpricedKeys;

  @override
  void initState() {
    super.initState();
    _rangeStart = widget.initialCheckIn == null
        ? null
        : _dateOnly(widget.initialCheckIn!);
    _rangeEnd = widget.initialCheckOut == null
        ? null
        : _dateOnly(widget.initialCheckOut!);
    _focusedDay = _rangeStart ?? widget.firstDay;
    _availableKeys =
        widget.availableDates.map((d) => _dateKey(_dateOnly(d))).toSet();
    _unpricedKeys =
        widget.unpricedDates.map((d) => _dateKey(_dateOnly(d))).toSet();
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  int _dateKey(DateTime d) => (d.year * 10000) + (d.month * 100) + d.day;

  bool _isNightAvailable(DateTime d) {
    return _availableKeys.contains(_dateKey(_dateOnly(d)));
  }

  bool _isUnpricedDay(DateTime d) {
    return _unpricedKeys.contains(_dateKey(_dateOnly(d)));
  }

  bool _isCheckoutValid(DateTime start, DateTime end) {
    if (!end.isAfter(start)) return false;

    var cursor = _dateOnly(start);
    final endNightExclusive = _dateOnly(end);
    var steps = 0;

    while (cursor.isBefore(endNightExclusive) && steps < 400) {
      if (!_isNightAvailable(cursor)) return false;
      cursor = cursor.add(const Duration(days: 1));
      steps++;
    }
    return true;
  }

  bool _isDayEnabled(DateTime day) {
    final d = _dateOnly(day);
    return _isNightAvailable(d) && !_isUnpricedDay(d);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    final checkIn = _dateOnly(selectedDay);
    if (!_isNightAvailable(checkIn)) return;

    final checkOut = _dateOnly(checkIn.add(const Duration(days: 1)));
    if (!_isCheckoutValid(checkIn, checkOut)) return;

    Navigator.of(context).pop(
      AvailabilityCalendarResult(checkIn: checkIn, checkOut: checkOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.darkCard,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'اختر تاريخ الوصول',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: AppTheme.textMuted.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TableCalendar(
              firstDay: widget.firstDay,
              lastDay: widget.lastDay,
              focusedDay: _focusedDay,
              availableCalendarFormats: const {CalendarFormat.month: 'month'},
              startingDayOfWeek: StartingDayOfWeek.saturday,
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              rangeSelectionMode: RangeSelectionMode.toggledOff,
              enabledDayPredicate: _isDayEnabled,
              selectedDayPredicate: (day) {
                final d = _dateOnly(day);
                if (_rangeStart != null && d == _dateOnly(_rangeStart!)) {
                  return true;
                }
                return false;
              },
              onDaySelected: (day, focusedDay) {
                setState(() {
                  _rangeStart = _dateOnly(day);
                  _rangeEnd = null;
                  _focusedDay = focusedDay;
                });
                _onDaySelected(day, focusedDay);
              },
              onPageChanged: (focusedDay) =>
                  setState(() => _focusedDay = focusedDay),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  final normalizedDay = _dateOnly(day);
                  if (!_isUnpricedDay(normalizedDay)) {
                    return null;
                  }

                  return Positioned(
                    bottom: 4,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                defaultTextStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppTheme.textWhite.withOpacity(0.9),
                ),
                weekendTextStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppTheme.textWhite.withOpacity(0.9),
                ),
                disabledTextStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppTheme.textMuted.withOpacity(0.35),
                ),
                todayTextStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w700,
                ),
                todayDecoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.w700,
                ),
                leftChevronIcon: Icon(Icons.chevron_left,
                    color: AppTheme.textWhite.withOpacity(0.8)),
                rightChevronIcon: Icon(Icons.chevron_right,
                    color: AppTheme.textWhite.withOpacity(0.8)),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted,
                ),
                weekendStyle: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'الأيام ذات العلامة الحمراء غير مسعّرة بعد، ولا يمكن اختيارها للحجز.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
