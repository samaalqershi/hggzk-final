// lib/features/admin_bookings/presentation/pages/booking_calendar_page.dart

import 'package:hggzkportal/features/admin_bookings/domain/entities/booking.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../bloc/booking_calendar/booking_calendar_bloc.dart';
import '../bloc/booking_calendar/booking_calendar_event.dart';
import '../bloc/booking_calendar/booking_calendar_state.dart';
import '../widgets/booking_calendar_widget.dart';
import '../widgets/booking_status_badge.dart';
import 'package:go_router/go_router.dart';

/// Arabic: صفحة تقويم تعرض الحجوزات بحسب اليوم أو الأسبوع أو الشهر.
/// English: Calendar page that presents bookings by day, week, or month.
class BookingCalendarPage extends StatefulWidget {
  /// Arabic: ينشئ صفحة التقويم بدون أي مدخلات إضافية.
  /// English: Creates the calendar page without any additional inputs.
  const BookingCalendarPage({super.key});
  @override
  State<BookingCalendarPage> createState() => _BookingCalendarPageState();
}

/// Arabic: يدير حالة صفحة التقويم، بما في ذلك وضع العرض والانتقال للحجوزات.
/// English: Manages the calendar page state, including view mode and navigation to bookings.
class _BookingCalendarPageState extends State<BookingCalendarPage>
    with SingleTickerProviderStateMixin {
  /// Arabic: يتحكم في حركة الدخول السلسة لعناصر الصفحة.
  /// English: Drives the page entrance animation.
  late AnimationController _animationController;

  /// Arabic: يحفظ اليوم المرجعي الذي تُحمّل حوله بيانات التقويم.
  /// English: Stores the reference day used when loading calendar data.
  final DateTime _focusedDay = DateTime.now();

  /// Arabic: يحدد نمط العرض الحالي للتقويم.
  /// English: Tracks the current calendar view mode.
  CalendarView _currentView = CalendarView.month;

  /// Arabic: يهيئ المحرك الحركي ثم يطلب بيانات التقويم الافتراضية.
  /// English: Initializes the animation controller and loads the default calendar data.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadCalendarData();
    _animationController.forward();
  }

  /// Arabic: يطلب بيانات الحجوزات الخاصة بالفترة والواجهة الحالية.
  /// English: Requests booking data for the current date range and view mode.
  void _loadCalendarData() {
    context.read<BookingCalendarBloc>().add(
          LoadCalendarBookingsEvent(
            month: _focusedDay,
            view: _currentView,
          ),
        );
  }

  /// Arabic: يحرر متحكم الحركة قبل إزالة الصفحة.
  /// English: Disposes the animation controller before the page is removed.
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Arabic: يبني واجهة التقويم ومحتوى الحجوزات المرتبط بها.
  /// English: Builds the calendar UI and its associated booking content.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          _buildCalendarSection(),
          _buildSelectedDayBookings(),
        ],
      ),
    );
  }

  /// Arabic: ينشئ شريط العنوان المثبت مع أزرار تبديل العرض.
  /// English: Builds the pinned header with the view-toggle actions.
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: AppTheme.darkBackground,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Text(
          'تقويم الحجوزات',
          style: AppTextStyles.heading1.copyWith(
            color: AppTheme.textWhite,
            shadows: [
              Shadow(
                color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryBlue.withValues(alpha: 0.1),
                AppTheme.darkBackground,
              ],
            ),
          ),
        ),
      ),
      actions: [
        _buildViewToggle(),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Arabic: يعرض أزرار التبديل بين الشهر والأسبوع واليوم.
  /// English: Shows the controls for switching between month, week, and day views.
  Widget _buildViewToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          _buildViewButton(
            icon: CupertinoIcons.calendar,
            isSelected: _currentView == CalendarView.month,
            onTap: () => _changeView(CalendarView.month),
          ),
          _buildViewButton(
            icon: CupertinoIcons.calendar_today,
            isSelected: _currentView == CalendarView.week,
            onTap: () => _changeView(CalendarView.week),
          ),
          _buildViewButton(
            icon: CupertinoIcons.list_bullet,
            isSelected: _currentView == CalendarView.day,
            onTap: () => _changeView(CalendarView.day),
          ),
        ],
      ),
    );
  }

  /// Arabic: يبني زر عرض واحد داخل شريط التبديل.
  /// English: Builds a single view button inside the toggle group.
  Widget _buildViewButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppTheme.primaryBlue : AppTheme.textMuted,
          size: 20,
        ),
      ),
    );
  }

  /// Arabic: يعرض ويدجت التقويم نفسه أو حالات التحميل والخطأ.
  /// English: Renders the calendar widget or its loading and error states.
  Widget _buildCalendarSection() {
    return SliverToBoxAdapter(
      child: BlocBuilder<BookingCalendarBloc, BookingCalendarState>(
        builder: (context, state) {
          if (state is BookingCalendarLoading) {
            return const SizedBox(
              height: 400,
              child: LoadingWidget(
                type: LoadingType.futuristic,
                message: 'جاري تحميل التقويم...',
              ),
            );
          }

          if (state is BookingCalendarError) {
            return SizedBox(
              height: 400,
              child: CustomErrorWidget(
                message: state.message,
                onRetry: _loadCalendarData,
              ),
            );
          }

          if (state is BookingCalendarLoaded) {
            return BookingCalendarWidget(
              calendarData: state.calendarData,
              currentMonth: state.currentMonth,
              currentView: state.currentView,
              selectedDate: state.selectedDate,
              onDateSelected: (date) {
                context.read<BookingCalendarBloc>().add(
                      SelectCalendarDateEvent(date: date),
                    );
              },
              onMonthChanged: (month) {
                context.read<BookingCalendarBloc>().add(
                      ChangeCalendarMonthEvent(month: month),
                    );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Arabic: يعرض الحجوزات المرتبطة باليوم المحدد إن وجدت.
  /// English: Shows bookings linked to the selected day when available.
  Widget _buildSelectedDayBookings() {
    return BlocBuilder<BookingCalendarBloc, BookingCalendarState>(
      builder: (context, state) {
        if (state is! BookingCalendarLoaded ||
            state.selectedDateBookings == null ||
            state.selectedDateBookings!.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.darkCard.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.darkBorder.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.calendar_today,
                      color: AppTheme.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'حجوزات ${_formatDate(state.selectedDate!)}',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppTheme.textWhite,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${state.selectedDateBookings!.length} حجز',
                        style: AppTextStyles.caption.copyWith(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...state.selectedDateBookings!.map((booking) {
                  return _buildBookingCard(booking);
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Arabic: يبني بطاقة مختصرة لعرض حجز واحد ضمن اليوم المحدد.
  /// English: Builds a compact card for one booking on the selected day.
  Widget _buildBookingCard(Booking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToDetails(booking.id),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      booking.unitName.substring(0, 2).toUpperCase(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.unitName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppTheme.textWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.userName,
                        style: AppTextStyles.caption.copyWith(
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                BookingStatusBadge(status: booking.status),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Arabic: يبدّل نمط عرض التقويم ويطلب البيانات المناسبة له.
  /// English: Switches the calendar view mode and reloads the matching data.
  void _changeView(CalendarView view) {
    setState(() => _currentView = view);
    context.read<BookingCalendarBloc>().add(
          ChangeCalendarViewEvent(view: view),
        );
  }

  /// Arabic: ينتقل إلى صفحة تفاصيل الحجز المحدد.
  /// English: Navigates to the selected booking's details page.
  void _navigateToDetails(String bookingId) {
    context.push('/admin/bookings/$bookingId');
  }

  /// Arabic: يحول التاريخ إلى صيغة قصيرة مناسبة للعرض داخل الصفحة.
  /// English: Formats a date into a concise in-page display string.
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
