// lib/features/admin_bookings/presentation/pages/booking_details_page.dart

import 'dart:ui';

import 'package:hggzkportal/features/admin_bookings/domain/entities/booking.dart';
import 'package:hggzkportal/features/admin_bookings/domain/entities/booking_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/enums/booking_status.dart';
import '../../../../core/enums/payment_method_enum.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/utils/formatters.dart';
import '../bloc/booking_details/booking_details_bloc.dart';
import '../bloc/booking_details/booking_details_event.dart';
import '../bloc/booking_details/booking_details_state.dart';
import '../widgets/booking_status_badge.dart';
import '../widgets/booking_payment_summary.dart';
import '../widgets/booking_actions_dialog.dart';
import '../widgets/booking_confirmation_dialog.dart';
import '../widgets/check_in_out_dialog.dart';

/// Arabic: صفحة تعرض تفاصيل الحجز كاملة مع الإجراءات والدفعات والنشاط.
/// English: Page that shows the full booking details, actions, payments, and activity.
class BookingDetailsPage extends StatefulWidget {
  /// Arabic: معرّف الحجز الذي ستُعرض تفاصيله.
  /// English: The booking identifier whose details will be shown.
  final String bookingId;

  /// Arabic: ينشئ صفحة تفاصيل الحجز المحدد.
  /// English: Creates the details page for the selected booking.
  const BookingDetailsPage({
    super.key,
    required this.bookingId,
  });
  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

/// Arabic: يدير حالة تفاصيل الحجز بما في ذلك التمرير والعمليات والإشعارات.
/// English: Manages the booking details state, including scrolling, operations, and notifications.
class _BookingDetailsPageState extends State<BookingDetailsPage>
    with SingleTickerProviderStateMixin {
  /// Arabic: يتحكم في الحركة الافتتاحية لعناصر الصفحة.
  /// English: Drives the page entrance animation.
  late AnimationController _animationController;

  /// Arabic: يراقب موضع التمرير لتأثيرات الشريط العلوي.
  /// English: Tracks scroll position for app bar effects.
  late ScrollController _scrollController;

  /// Arabic: يسجل مقدار التمرير الحالي المستخدم في حسابات البارالاكس.
  /// English: Stores the current scroll offset used for parallax calculations.
  double _scrollOffset = 0;

  /// Arabic: يحفظ آخر سبب إلغاء تم اختياره لإعادة استخدامه عند الحاجة.
  /// English: Stores the latest chosen cancellation reason for reuse when needed.
  String? _lastCancellationReason;

  /// Arabic: يشير إلى أن الصفحة نفذت عملية تستدعي تحديث قائمة الحجوزات عند الرجوع.
  /// English: Indicates whether the page performed an operation that should refresh the bookings list on return.
  bool _hasChanges = false;

  /// Arabic: يجهز المتحكمات ثم يحمّل تفاصيل الحجز مع بدء الحركة.
  /// English: Initializes controllers, loads booking details, and starts the entrance animation.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      });
    _loadBookingDetails();
    _animationController.forward();
  }

  /// Arabic: يطلب تفاصيل الحجز المحدد من طبقة الـ bloc.
  /// English: Requests the selected booking's details from the bloc layer.
  void _loadBookingDetails() {
    context.read<BookingDetailsBloc>().add(
          LoadBookingDetailsEvent(bookingId: widget.bookingId),
        );
  }

  /// Arabic: يعرض السياسات المحفوظة المرتبطة بالعقار أو الوحدة إذا كانت موجودة.
  /// English: Renders any saved policies associated with the property or unit when available.
  Widget _buildSavedPoliciesSection(BookingDetailsLoaded state) {
    final policies = state.bookingDetails?.propertyDetails?.policies;
    if (policies == null) return const SizedBox.shrink();
    final saved = policies['saved'];
    if (saved is! Map) return const SizedBox.shrink();

    final capRaw = saved['capturedAt'];
    final DateTime? capturedAt =
        capRaw != null ? DateTime.tryParse(capRaw.toString()) : null;
    final Map<String, dynamic> unitOverrides = (saved['unitOverrides'] is Map)
        ? Map<String, dynamic>.from(saved['unitOverrides'])
        : <String, dynamic>{};
    final Map<String, dynamic> byType = (saved['policiesByType'] is Map)
        ? Map<String, dynamic>.from(saved['policiesByType'])
        : <String, dynamic>{};

    final items = <Widget>[];
    if (capturedAt != null) {
      items.add(_buildDetailRow(
        label: 'تاريخ حفظ السياسات',
        value: Formatters.formatDateTime(capturedAt),
        icon: CupertinoIcons.calendar_today,
      ));
    }
    if (unitOverrides.isNotEmpty) {
      items.add(const SizedBox(height: 8));
      items.add(_buildDetailRow(
        label: 'السماح بالإلغاء (حسب الوحدة)',
        value: (unitOverrides['AllowsCancellation'] == true)
            ? 'مسموح'
            : 'غير مسموح',
        icon: CupertinoIcons.xmark_shield_fill,
      ));
      if (unitOverrides['CancellationWindowDays'] != null) {
        items.add(_buildDetailRow(
          label: 'نافذة الإلغاء (أيام)',
          value: unitOverrides['CancellationWindowDays'].toString(),
          icon: CupertinoIcons.timer,
        ));
      }
    }

    if (byType.isNotEmpty) {
      items.add(const SizedBox(height: 8));
      byType.forEach((key, value) {
        final v = value is Map
            ? Map<String, dynamic>.from(value)
            : <String, dynamic>{};
        final String title = _policyTitle(key);
        final String? desc = v['description']?.toString();
        items.add(Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.darkBackground.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: AppTheme.darkBorder.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(CupertinoIcons.shield_fill,
                      size: 16, color: AppTheme.primaryBlue),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (desc != null && desc.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppTheme.textMuted),
                ),
              ],
              if (v['cancellationWindowDays'] != null) ...[
                const SizedBox(height: 6),
                _buildDetailRow(
                  label: 'نافذة الإلغاء (أيام)',
                  value: v['cancellationWindowDays'].toString(),
                  icon: CupertinoIcons.timer,
                ),
              ],
              if (v['minHoursBeforeCheckIn'] != null) ...[
                const SizedBox(height: 6),
                _buildDetailRow(
                  label: 'ساعات الحد الأدنى قبل الوصول',
                  value: v['minHoursBeforeCheckIn'].toString(),
                  icon: CupertinoIcons.clock,
                ),
              ],
              if (v['requireFullPaymentBeforeConfirmation'] != null) ...[
                const SizedBox(height: 6),
                _buildDetailRow(
                  label: 'يتطلب دفع كامل قبل التأكيد',
                  value: (v['requireFullPaymentBeforeConfirmation'] == true)
                      ? 'نعم'
                      : 'لا',
                  icon: CupertinoIcons.creditcard,
                ),
              ],
              if (v['minimumDepositPercentage'] != null) ...[
                const SizedBox(height: 6),
                _buildDetailRow(
                  label: 'الدفعة المقدمة الدنيا (%)',
                  value: v['minimumDepositPercentage'].toString(),
                  icon: CupertinoIcons.percent,
                ),
              ],
            ],
          ),
        ));
      });
    }

    if (items.isEmpty) return const SizedBox.shrink();
    return _buildGlassCard(
      title: 'سياسات الحجز المحفوظة',
      icon: CupertinoIcons.shield_lefthalf_fill,
      child: Column(children: items),
    );
  }

  /// Arabic: يحول مفتاح السياسة إلى عنوان عربي مناسب للعرض.
  /// English: Converts a policy key into a readable Arabic title.
  String _policyTitle(String key) {
    switch (key.toLowerCase()) {
      case 'cancellation':
        return 'سياسة الإلغاء';
      case 'modification':
        return 'سياسة التعديل';
      case 'checkin':
      case 'check_in':
        return 'سياسة تسجيل الوصول';
      case 'children':
        return 'سياسة الأطفال';
      case 'pets':
        return 'سياسة الحيوانات الأليفة';
      default:
        return 'سياسة: $key';
    }
  }

  /// Arabic: يحرر المتحكمات قبل إزالة الصفحة من الشجرة.
  /// English: Disposes the controllers before the page leaves the widget tree.
  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Arabic: يبني واجهة التفاصيل مع الاستماع لنتائج العمليات والحالات المختلفة.
  /// English: Builds the details UI while listening to operation results and state changes.
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.pop(_hasChanges);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: BlocConsumer<BookingDetailsBloc, BookingDetailsState>(
          listener: (context, state) {
            // معالجة حالات النجاح والفشل
            if (state is BookingDetailsLoaded && state.isRefreshing) {
              // ✅ تم تحديث البيانات (مثل إضافة دفعة) - يجب تحديث قائمة الحجوزات عند الرجوع
              _hasChanges = true;
            }
            if (state is BookingDetailsOperationSuccess) {
              // ✅ تمت عملية بنجاح - يجب تحديث قائمة الحجوزات عند الرجوع
              _hasChanges = true;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.message,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: AppTheme.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 2),
                ),
              );
            } else if (state is BookingDetailsOperationFailure) {
              // إذا كانت هناك مدفوعات تمنع الإلغاء، اعرض خيار الاسترداد ثم الإلغاء
              if (state.message == 'PAYMENTS_EXIST') {
                showDialog<void>(
                  context: context,
                  builder: (ctx) => BookingConfirmationDialog(
                    type: BookingConfirmationType.cancel,
                    bookingId: widget.bookingId,
                    customTitle: 'لا يمكن الإلغاء',
                    customSubtitle:
                        'لا يمكن إلغاء حجز يحتوي على مدفوعات. هل تريد استرداد المدفوعات ثم إلغاء الحجز؟',
                    customConfirmText: 'نعم، استرد ثم ألغِ',
                    onConfirm: () {
                      context.read<BookingDetailsBloc>().add(
                            CancelBookingDetailsEvent(
                              bookingId: widget.bookingId,
                              cancellationReason: _lastCancellationReason ??
                                  'إلغاء مع استرداد المدفوعات',
                              refundPayments: true,
                            ),
                          );
                    },
                  ),
                );
                return; // لا نعرض SnackBar خطأ في هذه الحالة
              } else if (state.message == 'CANCELLATION_AFTER_CHECKIN') {
                _showPolicyDialog(
                  title: 'لا يمكن إلغاء الحجز',
                  description:
                      'لا يمكن إلغاء الحجز بعد وقت تسجيل الوصول حسب سياسة الإلغاء.',
                );
                return;
              } else if (state.message == 'CANCELLATION_WINDOW_EXCEEDED') {
                _showPolicyDialog(
                  title: 'غير مسموح بالإلغاء',
                  description:
                      'لا يمكن إلغاء الحجز خلال نافذة الإلغاء المحددة في سياسة الحجز.',
                );
                return;
              } else if (state.message == 'REFUND_EXCEEDS_POLICY') {
                _showPolicyDialog(
                  title: 'طلب الاسترداد مرفوض',
                  description:
                      'المبلغ المطلوب للاسترداد يتجاوز الحد المسموح حسب سياسة الإلغاء لهذا الحجز.',
                );
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.message,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: AppTheme.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          builder: (context, state) {
            // عرض محتوى الصفحة حتى أثناء العمليات
            if (state is BookingDetailsLoading) {
              return const LoadingWidget(
                type: LoadingType.futuristic,
                message: 'جاري تحميل تفاصيل الحجز...',
              );
            }

            if (state is BookingDetailsError) {
              return CustomErrorWidget(
                message: state.message,
                onRetry: _loadBookingDetails,
              );
            }

            // عرض المحتوى لجميع الحالات التي تحتوي على بيانات
            if (state is BookingDetailsLoaded ||
                state is BookingDetailsOperationInProgress ||
                state is BookingDetailsOperationSuccess ||
                state is BookingDetailsOperationFailure) {
              final booking = _getBookingFromState(state);
              final bookingDetails = _getBookingDetailsFromState(state);
              final services = _getServicesFromState(state);
              final isRefreshing =
                  state is BookingDetailsLoaded ? state.isRefreshing : false;

              if (booking == null) {
                return const LoadingWidget(
                  type: LoadingType.futuristic,
                  message: 'جاري تحميل تفاصيل الحجز...',
                );
              }

              return _buildContent(BookingDetailsLoaded(
                booking: booking,
                bookingDetails: bookingDetails,
                services: services,
                isRefreshing: isRefreshing,
              ));
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  /// Arabic: يعرض حوارًا يشرح سبب منع بعض عمليات الحجز.
  /// English: Shows a dialog that explains why certain booking actions are blocked.
  void _showPolicyDialog({
    required String title,
    required String description,
  }) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogCtx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.warning.withValues(alpha: 0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.warning.withValues(alpha: 0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.warning.withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    Icons.rule_folder_rounded,
                    color: AppTheme.warning,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: AppTextStyles.heading3.copyWith(
                    color: AppTheme.textWhite,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'فهمت',
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Arabic: يجمع أقسام التفاصيل داخل شاشة قابلة للتمرير.
  /// English: Assembles the detail sections into a scrollable screen.
  Widget _buildContent(BookingDetailsLoaded state) {
    final booking = state.booking;

    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(state),
            SliverToBoxAdapter(
              child: AnimationLimiter(
                child: Column(
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 400),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 30,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: [
                      _buildBookingStatusCard(state),
                      _buildBookingInfoCard(state),
                      _buildGuestInfoCard(state),
                      _buildUnitInfoCard(state),
                      _buildPaymentSection(state),
                      _buildPaymentsListSection(state),
                      _buildSavedPoliciesSection(state),
                      _buildActivityTimeline(state),
                      _buildReviewSection(state),
                      // Reserve vertical space so floating bottom actions
                      // do not cover interactive content (e.g. "تسجيل دفعة").
                      SizedBox(
                        height: _hasBottomActions(booking)
                            ? _bottomActionsReservedHeight(context)
                            : 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        _buildBottomActions(state),
        _buildOperationOverlay(),
      ],
    );
  }

  /// Arabic: يبني شريط العنوان الموسع مع أزرار الإجراءات السريعة.
  /// English: Builds the expanded app bar with quick action buttons.
  Widget _buildSliverAppBar(BookingDetailsLoaded state) {
    final booking = state.booking;
    final parallaxOffset = _scrollOffset * 0.5;

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppTheme.darkBackground,
      leading: _buildBackButton(),
      actions: [
        // _buildActionButton(
        //   icon: CupertinoIcons.share,
        //   onPressed: () => _shareBooking(booking.id),
        // ),
        _buildActionButton(
          icon: CupertinoIcons.time,
          onPressed: () => context.push('/admin/bookings/${booking.id}/audit'),
        ),
        _buildActionButton(
          icon: CupertinoIcons.doc_text,
          onPressed: () =>
              context.push('/admin/financial/transactions', extra: {
            'bookingId': booking.id,
          }),
        ),
        // _buildActionButton(
        //   icon: CupertinoIcons.doc_text,
        //   onPressed: () => _printBooking(booking.id),
        // ),
        _buildActionButton(
          icon: CupertinoIcons.printer,
          onPressed: () => _printBooking(booking.id),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background image with parallax
            if (booking.unitImage != null)
              Transform.translate(
                offset: Offset(0, parallaxOffset),
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(booking.unitImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.darkBackground.withValues(alpha: 0.7),
                          AppTheme.darkBackground,
                        ],
                        stops: const [0.3, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            // Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'حجز #${booking.id.substring(0, 8)}',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                booking.unitName,
                                style: AppTextStyles.heading1.copyWith(
                                  color: AppTheme.textWhite,
                                  shadows: [
                                    Shadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        BookingStatusBadge(status: booking.status),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: CupertinoIcons.calendar,
                      label: 'تاريخ الحجز',
                      value: Formatters.formatDate(booking.bookedAt),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Arabic: يعرض بطاقة حالة الحجز الحالية والملخص الزمني لها.
  /// English: Shows the current booking status card and its temporal summary.
  Widget _buildBookingStatusCard(BookingDetailsLoaded state) {
    final booking = state.booking;

    return _buildGlassCard(
      title: 'حالة الحجز',
      icon: CupertinoIcons.checkmark_seal_fill,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'حجز #${booking.id.substring(0, 8)}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      booking.unitName,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              BookingStatusBadge(status: booking.status),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            label: 'الحالة',
            value: booking.status.displayName,
            icon: CupertinoIcons.info_circle_fill,
          ),
          _buildDetailRow(
            label: 'تاريخ الحجز',
            value: Formatters.formatDate(booking.bookedAt),
            icon: CupertinoIcons.calendar,
          ),
        ],
      ),
    );
  }

  /// Arabic: ينشئ زر الرجوع أعلى صفحة التفاصيل.
  /// English: Builds the back button in the details header.
  Widget _buildBackButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).pop(_hasChanges),
          borderRadius: BorderRadius.circular(12),
          child: Icon(
            CupertinoIcons.arrow_right,
            color: AppTheme.textWhite,
            size: 20,
          ),
        ),
      ),
    );
  }

  /// Arabic: يبني زر إجراء صغيرًا في شريط العنوان.
  /// English: Builds a compact action button in the app bar.
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              color: AppTheme.textWhite,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  /// Arabic: يعرض معلومات الحجز الأساسية مثل الوصول والمغادرة والخصائص المهمة.
  /// English: Shows the core booking information such as check-in, check-out, and key attributes.
  Widget _buildBookingInfoCard(BookingDetailsLoaded state) {
    final booking = state.booking;

    return _buildGlassCard(
      title: 'معلومات الحجز',
      icon: CupertinoIcons.doc_text_fill,
      child: Column(
        children: [
          _buildDetailRow(
            label: 'تاريخ الوصول',
            value: Formatters.formatDate(booking.checkIn),
            icon: CupertinoIcons.arrow_down_circle,
          ),
          _buildDetailRow(
            label: 'تاريخ المغادرة',
            value: Formatters.formatDate(booking.checkOut),
            icon: CupertinoIcons.arrow_up_circle,
          ),
          _buildDetailRow(
            label: 'عدد الليالي',
            value: '${booking.nights} ليلة',
            icon: CupertinoIcons.moon_fill,
          ),
          _buildDetailRow(
            label: 'عدد الضيوف',
            value: '${booking.guestsCount} ضيف',
            icon: CupertinoIcons.person_2_fill,
          ),
          if (booking.bookingSource != null)
            _buildDetailRow(
              label: 'مصدر الحجز',
              value: booking.bookingSource!,
              icon: CupertinoIcons.link,
            ),
          if (booking.isWalkIn == true)
            _buildDetailRow(
              label: 'حجز مباشر (Walk-in)',
              value: 'نعم',
              icon: CupertinoIcons.person_crop_circle_badge_checkmark,
            ),
          if (booking.confirmedAt != null)
            _buildDetailRow(
              label: 'تاريخ التأكيد',
              value: Formatters.formatDateTime(booking.confirmedAt!),
              icon: CupertinoIcons.checkmark_seal_fill,
            ),
          if (booking.checkedInAt != null)
            _buildDetailRow(
              label: 'تسجيل الوصول الفعلي',
              value: Formatters.formatDateTime(booking.checkedInAt!),
              icon: CupertinoIcons.arrow_down_circle_fill,
            ),
          if (booking.checkedOutAt != null)
            _buildDetailRow(
              label: 'تسجيل المغادرة الفعلي',
              value: Formatters.formatDateTime(booking.checkedOutAt!),
              icon: CupertinoIcons.arrow_up_circle_fill,
            ),
          if (booking.cancellationReason != null)
            _buildDetailRow(
              label: 'سبب الإلغاء',
              value: booking.cancellationReason!,
              icon: CupertinoIcons.xmark_octagon_fill,
              isMultiline: true,
            ),
          if (booking.paymentStatus != null)
            _buildDetailRow(
              label: 'حالة الدفع',
              value: booking.paymentStatus!,
              icon: CupertinoIcons.creditcard_fill,
            ),
          if (booking.notes != null)
            _buildDetailRow(
              label: 'ملاحظات',
              value: booking.notes!,
              icon: CupertinoIcons.text_bubble,
              isMultiline: true,
            ),
          if (booking.specialRequests != null)
            _buildDetailRow(
              label: 'طلبات خاصة',
              value: booking.specialRequests!,
              icon: CupertinoIcons.square_list_fill,
              isMultiline: true,
            ),
        ],
      ),
    );
  }

  /// Arabic: يعرض معلومات الضيف المرتبط بالحجز.
  /// English: Shows the guest information associated with the booking.
  Widget _buildGuestInfoCard(BookingDetailsLoaded state) {
    final booking = state.booking;
    final guestInfo = state.bookingDetails?.guestInfo;

    return _buildGlassCard(
      title: 'معلومات الضيف',
      icon: CupertinoIcons.person_circle_fill,
      child: Column(
        children: [
          _buildDetailRow(
            label: 'الاسم',
            value: booking.userName,
            icon: CupertinoIcons.person,
          ),
          if (booking.userEmail != null)
            _buildDetailRow(
              label: 'البريد الإلكتروني',
              value: booking.userEmail!,
              icon: CupertinoIcons.mail,
            ),
          if (booking.userPhone != null)
            _buildDetailRow(
              label: 'رقم الهاتف',
              value: booking.userPhone!,
              icon: CupertinoIcons.phone,
            ),
          if (guestInfo?.nationality != null)
            _buildDetailRow(
              label: 'الجنسية',
              value: guestInfo!.nationality!,
              icon: CupertinoIcons.flag,
            ),
        ],
      ),
    );
  }

  /// Arabic: يعرض تفاصيل الوحدة أو العقار الذي تم الحجز فيه.
  /// English: Shows the unit or property details for the booking.
  Widget _buildUnitInfoCard(BookingDetailsLoaded state) {
    final booking = state.booking;
    final unitDetails = state.bookingDetails?.unitDetails;
    final propertyDetails = state.bookingDetails?.propertyDetails;

    return _buildGlassCard(
      title: 'معلومات الوحدة',
      icon: CupertinoIcons.home,
      child: Column(
        children: [
          _buildDetailRow(
            label: 'اسم الوحدة',
            value: booking.unitName,
            icon: CupertinoIcons.building_2_fill,
          ),
          if (booking.propertyName != null)
            _buildDetailRow(
              label: 'العقار',
              value: booking.propertyName!,
              icon: CupertinoIcons.location,
            ),
          if (propertyDetails?.address != null &&
              propertyDetails!.address.isNotEmpty)
            _buildDetailRow(
              label: 'عنوان العقار',
              value: propertyDetails.address,
              icon: CupertinoIcons.map_pin_ellipse,
              isMultiline: true,
            ),
          if (unitDetails?.type != null)
            _buildDetailRow(
              label: 'النوع',
              value: unitDetails!.type,
              icon: CupertinoIcons.square_grid_2x2,
            ),
          if (unitDetails?.capacity != null)
            _buildDetailRow(
              label: 'السعة',
              value: '${unitDetails!.capacity} شخص',
              icon: CupertinoIcons.person_3_fill,
            ),
        ],
      ),
    );
  }

  /// Arabic: يعرض ملخص الدفعات والحالة المالية للحجز.
  /// English: Shows the payment summary and financial status for the booking.
  Widget _buildPaymentSection(BookingDetailsLoaded state) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Builder(builder: (builderContext) {
        return BookingPaymentSummary(
          booking: state.booking,
          bookingDetails: state.bookingDetails,
          payments: state.bookingDetails?.payments,
          services: state.services,
          onShowInvoice: () => _printBooking(state.booking.id),
          bookingDetailsBloc: builderContext.read<BookingDetailsBloc>(),
          isRefreshing: state.isRefreshing,
        );
      }),
    );
  }

  /// Arabic: يعرض سجل الدفعات المفصل مع الحالة والتواريخ.
  /// English: Shows the detailed payment history with status and dates.
  Widget _buildPaymentsListSection(BookingDetailsLoaded state) {
    final payments = state.bookingDetails?.payments ?? [];
    if (payments.isEmpty) return const SizedBox.shrink();

    return _buildGlassCard(
      title: 'سجل المدفوعات',
      icon: CupertinoIcons.creditcard_fill,
      child: Column(
        children: [
          ...payments.asMap().entries.map((entry) {
            final index = entry.key;
            final payment = entry.value;
            final isSuccessful = payment.status == PaymentStatus.successful;
            final isPending = payment.status == PaymentStatus.pending;

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 20,
                child: FadeInAnimation(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          (isSuccessful
                                  ? AppTheme.success
                                  : isPending
                                      ? AppTheme.warning
                                      : AppTheme.error)
                              .withValues(alpha: 0.05),
                          AppTheme.darkBackground.withValues(alpha: 0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (isSuccessful
                                ? AppTheme.success
                                : isPending
                                    ? AppTheme.warning
                                    : AppTheme.error)
                            .withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isSuccessful
                                  ? AppTheme.success
                                  : isPending
                                      ? AppTheme.warning
                                      : AppTheme.error)
                              .withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // يمكن إضافة عرض تفاصيل الدفعة هنا
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Payment Method Icon
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      (isSuccessful
                                              ? AppTheme.success
                                              : isPending
                                                  ? AppTheme.warning
                                                  : AppTheme.error)
                                          .withValues(alpha: 0.2),
                                      (isSuccessful
                                              ? AppTheme.success
                                              : isPending
                                                  ? AppTheme.warning
                                                  : AppTheme.error)
                                          .withValues(alpha: 0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getPaymentMethodIcon(payment.method),
                                  color: isSuccessful
                                      ? AppTheme.success
                                      : isPending
                                          ? AppTheme.warning
                                          : AppTheme.error,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Payment Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            payment.method.displayNameAr,
                                            style: AppTextStyles.bodyLarge
                                                .copyWith(
                                              color: AppTheme.textWhite,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: (isSuccessful
                                                    ? AppTheme.success
                                                    : isPending
                                                        ? AppTheme.warning
                                                        : AppTheme.error)
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            payment.status.displayNameAr,
                                            style:
                                                AppTextStyles.caption.copyWith(
                                              color: isSuccessful
                                                  ? AppTheme.success
                                                  : isPending
                                                      ? AppTheme.warning
                                                      : AppTheme.error,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          CupertinoIcons.calendar,
                                          size: 12,
                                          color: AppTheme.textMuted,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            Formatters.formatDateTime(
                                                payment.paymentDate),
                                            style:
                                                AppTextStyles.caption.copyWith(
                                              color: AppTheme.textMuted,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (payment
                                            .transactionId.isNotEmpty) ...[
                                          const SizedBox(width: 8),
                                          Icon(
                                            CupertinoIcons.number,
                                            size: 12,
                                            color: AppTheme.textMuted,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              payment.transactionId,
                                              style: AppTextStyles.caption
                                                  .copyWith(
                                                color: AppTheme.textMuted,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Amount
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    payment.amount.formattedAmount,
                                    style: AppTextStyles.heading3.copyWith(
                                      color: isSuccessful
                                          ? AppTheme.success
                                          : isPending
                                              ? AppTheme.warning
                                              : AppTheme.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (payment.refundedAt != null) ...[
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.info
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'مسترد',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppTheme.info,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),

          // Payment Summary Footer
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withValues(alpha: 0.05),
                  AppTheme.darkBackground.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryBlue.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.info_circle_fill,
                      color: AppTheme.primaryBlue,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'إجمالي المدفوعات',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${payments.length} دفعة',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Arabic: يعرض نشاطات الحجز مرتبة زمنيًا.
  /// English: Shows the booking activity entries in chronological order.
  Widget _buildActivityTimeline(BookingDetailsLoaded state) {
    final activities = state.bookingDetails?.activities ?? [];
    if (activities.isEmpty) return const SizedBox.shrink();

    return _buildGlassCard(
      title: 'سجل النشاطات',
      icon: CupertinoIcons.time,
      child: Column(
        children: activities.map((activity) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.darkBackground.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.darkBorder.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.clock_fill,
                    color: AppTheme.primaryBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppTheme.textWhite,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.formatDateTime(activity.timestamp),
                        style: AppTextStyles.caption.copyWith(
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Arabic: يعرض تقييم الضيف وتعليقاته وصوره إن وجدت.
  /// English: Shows the guest review, comments, and images when present.
  Widget _buildReviewSection(BookingDetailsLoaded state) {
    final review = state.review;
    if (review == null) return const SizedBox.shrink();

    return _buildGlassCard(
      title: 'تقييم الضيف',
      icon: CupertinoIcons.star_fill,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(5, (index) {
              final value = review.averageRating;
              final filled = index < value.floor();
              final half = index == value.floor() && (value % 1) != 0;
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  half
                      ? CupertinoIcons.star_lefthalf_fill
                      : (filled
                          ? CupertinoIcons.star_fill
                          : CupertinoIcons.star),
                  size: 18,
                  color: AppTheme.warning,
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          if (review.comment.isNotEmpty)
            _buildDetailRow(
              label: 'تعليق',
              value: review.comment,
              icon: CupertinoIcons.text_bubble,
              isMultiline: true,
            ),
          const SizedBox(height: 8),
          _buildDetailRow(
            label: 'النظافة',
            value: review.cleanliness.toStringAsFixed(1),
            icon: CupertinoIcons.sparkles,
          ),
          _buildDetailRow(
            label: 'الخدمة',
            value: review.service.toStringAsFixed(1),
            icon: CupertinoIcons.person_2,
          ),
          _buildDetailRow(
            label: 'الموقع',
            value: review.location.toStringAsFixed(1),
            icon: CupertinoIcons.location_solid,
          ),
          _buildDetailRow(
            label: 'القيمة',
            value: review.value.toStringAsFixed(1),
            icon: CupertinoIcons.money_dollar,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            label: 'تاريخ التقييم',
            value: Formatters.formatDate(review.createdAt),
            icon: CupertinoIcons.calendar_today,
          ),
          if (review.responseText != null && review.responseText!.isNotEmpty)
            _buildDetailRow(
              label: 'رد الإدارة',
              value: review.responseText!,
              icon: CupertinoIcons.reply,
              isMultiline: true,
            ),
          if (review.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: review.images.map((img) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(img.url),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Arabic: يعرض طبقة حجب عند تنفيذ العمليات أو تحديث الدفعات.
  /// English: Shows a blocking overlay while operations or payment refreshes are running.
  Widget _buildOperationOverlay() {
    return BlocBuilder<BookingDetailsBloc, BookingDetailsState>(
      builder: (context, state) {
        bool show = false;
        String message = 'جاري تنفيذ العملية...';

        if (state is BookingDetailsOperationInProgress) {
          show = true;
          message = 'جاري تنفيذ العملية...';
        } else if (state is BookingDetailsLoaded && state.isRefreshing) {
          show = true;
          message = 'جاري تحديث المدفوعات...';
        }

        if (!show) return const SizedBox.shrink();

        return Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              color: AppTheme.darkBackground.withValues(alpha: 0.4),
              alignment: Alignment.center,
              child: LoadingWidget(
                type: LoadingType.futuristic,
                message: message,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Arabic: يعرض أزرار الإجراءات السفلية حسب صلاحيات الحجز الحالية.
  /// English: Shows bottom action buttons according to the current booking capabilities.
  Widget _buildBottomActions(BookingDetailsLoaded state) {
    final booking = state.booking;
    if (!_hasBottomActions(booking)) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              if (booking.canCheckIn)
                Expanded(
                  child: _buildActionButtonLarge(
                    label: 'تسجيل وصول',
                    icon: CupertinoIcons.arrow_down_circle_fill,
                    gradient: AppTheme.primaryGradient,
                    onPressed: () => _showCheckInDialog(booking.id),
                  ),
                ),
              if (booking.canCheckOut)
                Expanded(
                  child: _buildActionButtonLarge(
                    label: 'تسجيل مغادرة',
                    icon: CupertinoIcons.arrow_up_circle_fill,
                    gradient: AppTheme.primaryGradient,
                    onPressed: () => _showCheckOutDialog(booking.id),
                  ),
                ),
              if (booking.canCancel) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButtonLarge(
                    label: 'إلغاء الحجز',
                    icon: CupertinoIcons.xmark_circle_fill,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.error.withValues(alpha: 0.8),
                        AppTheme.error,
                      ],
                    ),
                    onPressed: () => _cancelBooking(booking.id),
                  ),
                ),
              ],
              if (booking.canConfirm) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButtonLarge(
                    label: 'تأكيد الحجز',
                    icon: CupertinoIcons.checkmark_circle_fill,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.success.withValues(alpha: 0.8),
                        AppTheme.success,
                      ],
                    ),
                    onPressed: () => _confirmBooking(booking.id),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Arabic: يتحقق مما إذا كان هناك أي إجراء سفلي متاح للحجز.
  /// English: Checks whether any bottom actions are available for the booking.
  bool _hasBottomActions(Booking booking) {
    return booking.canCheckIn ||
        booking.canCheckOut ||
        booking.canCancel ||
        booking.canConfirm;
  }

  /// Arabic: يحسب الارتفاع المحجوز لأسفل الشاشة حتى لا تُغطى العناصر التفاعلية.
  /// English: Calculates the reserved height so floating actions do not cover content.
  double _bottomActionsReservedHeight(BuildContext context) {
    // 44 button height + 16 vertical padding top/bottom + safe area + buffer
    return 44 + 32 + MediaQuery.of(context).padding.bottom + 28;
  }

  /// Arabic: يبني زرًا كبيرًا يستخدم في شريط الإجراءات السفلي.
  /// English: Builds a large button used inside the bottom action bar.
  Widget _buildActionButtonLarge({
    required String label,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppTextStyles.buttonSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Arabic: يلف المحتوى داخل بطاقة زجاجية شفافة تناسب الواجهة الداكنة.
  /// English: Wraps content in a glass-style card suited to the dark theme.
  Widget _buildGlassCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowDark.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        color: AppTheme.primaryBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: AppTextStyles.heading3.copyWith(
                        color: AppTheme.textWhite,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Arabic: يختار الأيقونة المناسبة لطريقة الدفع المعروضة.
  /// English: Selects the icon that matches the displayed payment method.
  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return CupertinoIcons.money_dollar;
      case PaymentMethod.creditCard:
        return CupertinoIcons.creditcard;
      case PaymentMethod.paypal:
        return CupertinoIcons.globe;
      default:
        return CupertinoIcons.device_phone_portrait;
    }
  }

  /// Arabic: يعرض سطر تفاصيل موحدًا مع أيقونة وعنوان وقيمة.
  /// English: Renders a unified detail row with icon, label, and value.
  Widget _buildDetailRow({
    required String label,
    required String value,
    required IconData icon,
    bool isMultiline = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.darkBorder.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppTheme.textMuted,
            size: 18,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
              maxLines: isMultiline ? null : 1,
              overflow:
                  isMultiline ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Arabic: يعرض صفًا بسيطًا داخل بطاقات المعلومات المختصرة.
  /// English: Renders a simple row inside the compact information cards.
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.textMuted,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Arabic: يفتح حوار تسجيل الوصول قبل تنفيذ العملية.
  /// English: Opens the check-in dialog before the action is executed.
  void _showCheckInDialog(String bookingId) {
    final bloc = context.read<BookingDetailsBloc>();
    showDialog(
      fullscreenDialog: true,
      context: context,
      builder: (dialogContext) => CheckInOutDialog(
        bookingId: bookingId,
        isCheckIn: true,
        onConfirm: () {
          bloc.add(
            CheckInBookingDetailsEvent(bookingId: bookingId),
          );
        },
      ),
    );
  }

  /// Arabic: يفتح حوار تسجيل المغادرة قبل تنفيذ العملية.
  /// English: Opens the check-out dialog before the action is executed.
  void _showCheckOutDialog(String bookingId) {
    final bloc = context.read<BookingDetailsBloc>();
    showDialog(
      fullscreenDialog: true,
      context: context,
      builder: (dialogContext) => CheckInOutDialog(
        bookingId: bookingId,
        isCheckIn: false,
        onConfirm: () {
          bloc.add(
            CheckOutBookingDetailsEvent(bookingId: bookingId),
          );
        },
      ),
    );
  }

  /// Arabic: يبدأ مسار إلغاء الحجز بما في ذلك اختيار السبب والتأكيد النهائي.
  /// English: Starts the booking cancellation flow, including reason selection and final confirmation.
  void _cancelBooking(String bookingId) async {
    debugPrint('🔵 [BookingDetailsPage] عرض ديالوج الإلغاء للحجز: $bookingId');

    // First: Show reason selection dialog
    final result = await showDialog<String?>(
      fullscreenDialog: true,
      context: context,
      builder: (dialogContext) => BookingActionsDialog(
        bookingId: bookingId,
        action: BookingAction.cancel,
      ),
    );

    debugPrint('🔵 [BookingDetailsPage] نتيجة الديالوج: $result');

    // Second: If reason selected, show confirmation dialog
    if (result != null && mounted) {
      final state = context.read<BookingDetailsBloc>().state;
      String? bookingReference;

      if (state is BookingDetailsLoaded) {
        bookingReference = state.booking.id;
      }

      showBookingConfirmationDialog(
        context: context,
        type: BookingConfirmationType.cancel,
        bookingId: bookingId,
        bookingReference: bookingReference,
        onConfirm: () {
          debugPrint(
              '✅ [BookingDetailsPage] إرسال حدث إلغاء الحجز مع السبب: $result');
          _lastCancellationReason = result;
          context.read<BookingDetailsBloc>().add(
                CancelBookingDetailsEvent(
                  bookingId: bookingId,
                  cancellationReason: result,
                  refundPayments: false,
                ),
              );
        },
      );
    } else {
      debugPrint('⚠️ [BookingDetailsPage] لم يتم اختيار سبب الإلغاء');
    }
  }

  /// Arabic: يبدأ مسار تأكيد الحجز بعد التحقق من المرجع الحالي.
  /// English: Starts the booking confirmation flow after resolving the current reference.
  void _confirmBooking(String bookingId) {
    final state = context.read<BookingDetailsBloc>().state;
    String? bookingReference;

    if (state is BookingDetailsLoaded) {
      bookingReference = state.booking.id;
    }

    showBookingConfirmationDialog(
      context: context,
      type: BookingConfirmationType.confirm,
      bookingId: bookingId,
      bookingReference: bookingReference,
      onConfirm: () {
        context.read<BookingDetailsBloc>().add(
              ConfirmBookingDetailsEvent(bookingId: bookingId),
            );
      },
    );
  }

  /// Arabic: يرسل حدث طباعة أو إنشاء نسخة قابلة للطباعة من الحجز.
  /// English: Dispatches the event that prints or generates a printable booking copy.
  void _printBooking(String bookingId) {
    context.read<BookingDetailsBloc>().add(
          PrintBookingDetailsEvent(bookingId: bookingId),
        );
  }

  /// Arabic: يستخرج كيان الحجز من أي حالة من حالات التفاصيل المدعومة.
  /// English: Extracts the booking entity from any supported details state.
  Booking? _getBookingFromState(BookingDetailsState state) {
    if (state is BookingDetailsLoaded) return state.booking;
    if (state is BookingDetailsOperationInProgress) return state.booking;
    if (state is BookingDetailsOperationSuccess) return state.booking;
    if (state is BookingDetailsOperationFailure) return state.booking;
    return null;
  }

  /// Arabic: يستخرج تفاصيل الحجز الموسعة من الحالة الحالية إن كانت موجودة.
  /// English: Extracts the extended booking details from the current state when available.
  BookingDetails? _getBookingDetailsFromState(BookingDetailsState state) {
    if (state is BookingDetailsLoaded) return state.bookingDetails;
    if (state is BookingDetailsOperationInProgress) return state.bookingDetails;
    if (state is BookingDetailsOperationSuccess) return state.bookingDetails;
    if (state is BookingDetailsOperationFailure) return state.bookingDetails;
    return null;
  }

  /// Arabic: يستخرج قائمة الخدمات المرتبطة بالحجز من الحالة الحالية.
  /// English: Extracts the list of services associated with the booking from the current state.
  List<Service> _getServicesFromState(BookingDetailsState state) {
    if (state is BookingDetailsLoaded) return state.services;
    if (state is BookingDetailsOperationInProgress) return state.services;
    if (state is BookingDetailsOperationSuccess) return state.services;
    if (state is BookingDetailsOperationFailure) return state.services;
    return [];
  }
}
