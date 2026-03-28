// lib/features/admin_units/presentation/widgets/unit_availability_calendar.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';

/// يمثل هذا الكلاس UnitAvailabilityCalendar البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for UnitAvailabilityCalendar in the admin unit workflow.
class UnitAvailabilityCalendar extends StatefulWidget {
  /// This field keeps the unitId value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة unitId التي يعتمد عليها مسار إدارة الوحدات.
  final String unitId;

  /// ينفذ هذا الأسلوب عملية Function ضمن مسار إدارة الوحدات.
  /// This method performs the Function operation in the admin unit workflow.
  final Function(DateTime) onDateSelected;

  /// ينشئ هذا المُنشئ مثيلاً من UnitAvailabilityCalendar.
  /// This constructor creates an instance of UnitAvailabilityCalendar.
  const UnitAvailabilityCalendar({
    super.key,
    required this.unitId,
    required this.onDateSelected,
  });

  /// ينشئ هذا الأسلوب كائن الحالة الخاص بهذه الصفحة.
  /// This method performs the createState operation in the admin unit workflow.
  @override
  State<UnitAvailabilityCalendar> createState() =>
      _UnitAvailabilityCalendarState();
}

/// يمثل هذا الكلاس _UnitAvailabilityCalendarState البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for _UnitAvailabilityCalendarState in the admin unit workflow.
class _UnitAvailabilityCalendarState extends State<UnitAvailabilityCalendar>
    with SingleTickerProviderStateMixin {
  /// يحتفظ هذا الحقل بقيمة _animationController التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _animationController value used by the admin unit workflow.
  late AnimationController _animationController;

  /// يحتفظ هذا الحقل بقيمة _calendarFormat التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _calendarFormat value used by the admin unit workflow.
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  /// يحتفظ هذا الحقل بقيمة _selectedDay التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _selectedDay value used by the admin unit workflow.
  DateTime? _selectedDay;

  // Mock booked dates - Replace with actual data
  /// يحتفظ هذا الحقل بقيمة _bookedDates التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _bookedDates value used by the admin unit workflow.
  final Set<DateTime> _bookedDates = {
    DateTime.now().add(const Duration(days: 2)),
    DateTime.now().add(const Duration(days: 3)),
    DateTime.now().add(const Duration(days: 7)),
    DateTime.now().add(const Duration(days: 10)),
    DateTime.now().add(const Duration(days: 11)),
    DateTime.now().add(const Duration(days: 12)),
  };

  /// ينفذ هذا الأسلوب عملية initState ضمن مسار إدارة الوحدات.
  /// This method performs the initState operation in the admin unit workflow.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _selectedDay = _focusedDay;
  }

  /// ينفذ هذا الأسلوب عملية dispose ضمن مسار إدارة الوحدات.
  /// This method performs the dispose operation in the admin unit workflow.
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// ينفذ هذا الأسلوب عملية build ضمن مسار إدارة الوحدات.
  /// This method performs the build operation in the admin unit workflow.
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
      child: Column(
        children: [
          _buildCalendarHeader(),
          const SizedBox(height: 16),
          _buildCalendar(),
          const SizedBox(height: 20),
          _buildLegend(),
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildCalendarHeader ضمن مسار إدارة الوحدات.
  /// This method performs the _buildCalendarHeader operation in the admin unit workflow.
  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withValues(alpha: 0.1),
            AppTheme.primaryPurple.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'التوفر الشهري',
                style: AppTextStyles.heading3.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'اختر تاريخ لعرض التفاصيل',
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
          _buildCalendarFormatToggle(),
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildCalendarFormatToggle ضمن مسار إدارة الوحدات.
  /// This method performs the _buildCalendarFormatToggle operation in the admin unit workflow.
  Widget _buildCalendarFormatToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          _buildFormatButton(
            icon: CupertinoIcons.calendar_today,
            format: CalendarFormat.week,
            label: 'أسبوع',
          ),
          _buildFormatButton(
            icon: CupertinoIcons.calendar,
            format: CalendarFormat.month,
            label: 'شهر',
          ),
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildFormatButton ضمن مسار إدارة الوحدات.
  /// This method performs the _buildFormatButton operation in the admin unit workflow.
  Widget _buildFormatButton({
    required IconData icon,
    required CalendarFormat format,
    required String label,
  }) {
    final isSelected = _calendarFormat == format;

    return GestureDetector(
      onTap: () {
        setState(() => _calendarFormat = format);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppTheme.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? Colors.white : AppTheme.textMuted,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildCalendar ضمن مسار إدارة الوحدات.
  /// This method performs the _buildCalendar operation in the admin unit workflow.
  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.5),
            AppTheme.darkCard.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.2),
        ),
      ),
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        locale: 'ar',
        startingDayOfWeek: StartingDayOfWeek.saturday,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        eventLoader: (day) {
          // Return events for the day
          if (_bookedDates.any((date) => isSameDay(date, day))) {
            return ['booked'];
          }
          return [];
        },
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            widget.onDateSelected(selectedDay);
          }
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.primaryBlue,
          ),
          holidayTextStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.warning,
          ),
          defaultTextStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
          ),
          selectedTextStyle: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          todayTextStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
          markerDecoration: BoxDecoration(
            color: AppTheme.error,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primaryBlue,
              width: 2,
            ),
          ),
          defaultDecoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          weekendDecoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          holidayDecoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          markerSize: 6,
          markersMaxCount: 1,
          markersAnchor: 0.7,
          cellMargin: const EdgeInsets.all(4),
          cellPadding: const EdgeInsets.all(0),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: Icon(
            CupertinoIcons.chevron_left,
            color: AppTheme.textWhite,
            size: 20,
          ),
          rightChevronIcon: Icon(
            CupertinoIcons.chevron_right,
            color: AppTheme.textWhite,
            size: 20,
          ),
          titleTextStyle: AppTextStyles.heading3.copyWith(
            color: AppTheme.textWhite,
          ),
          decoration: const BoxDecoration(),
          headerMargin: const EdgeInsets.only(bottom: 16),
          titleTextFormatter: (date, locale) {
            final months = [
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
          },
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppTextStyles.caption.copyWith(
            color: AppTheme.textMuted,
          ),
          weekendStyle: AppTextStyles.caption.copyWith(
            color: AppTheme.primaryBlue,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppTheme.darkBorder.withValues(alpha: 0.2),
              ),
            ),
          ),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isNotEmpty) {
              return Positioned(
                bottom: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppTheme.error,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.error.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildLegend ضمن مسار إدارة الوحدات.
  /// This method performs the _buildLegend operation in the admin unit workflow.
  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem(
            color: AppTheme.success,
            label: 'متاح',
            icon: CupertinoIcons.checkmark_circle_fill,
          ),
          _buildLegendItem(
            color: AppTheme.error,
            label: 'محجوز',
            icon: CupertinoIcons.xmark_circle_fill,
          ),
          _buildLegendItem(
            color: AppTheme.primaryBlue,
            label: 'اليوم',
            icon: CupertinoIcons.calendar_today,
          ),
          _buildLegendItem(
            gradient: AppTheme.primaryGradient,
            label: 'محدد',
            icon: CupertinoIcons.calendar_badge_plus,
          ),
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildLegendItem ضمن مسار إدارة الوحدات.
  /// This method performs the _buildLegendItem operation in the admin unit workflow.
  Widget _buildLegendItem({
    Color? color,
    Gradient? gradient,
    required String label,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color?.withValues(alpha: 0.2),
            gradient: gradient,
            shape: BoxShape.circle,
            border: color != null
                ? Border.all(
                    color: color,
                    width: 2,
                  )
                : null,
          ),
          child: Icon(
            icon,
            size: 12,
            color: gradient != null ? Colors.white : color,
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
}
