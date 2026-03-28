// lib/features/admin_bookings/presentation/widgets/booking_payment_summary.dart

import 'dart:ui';
import 'package:hggzkportal/features/admin_bookings/presentation/bloc/booking_details/booking_details_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/booking.dart' show Booking, Money;
import '../../domain/entities/booking_details.dart'
    show BookingDetails, Payment, Service;
import '../../../../core/enums/payment_method_enum.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../pages/register_payment_page.dart';
import '../bloc/booking_details/booking_details_bloc.dart';
import '../bloc/booking_details/booking_details_event.dart';
import '../bloc/register_payment/register_payment_bloc.dart';
import '../../../../injection_container.dart';

/// تعرض ملخص المدفوعات للحجز مع ما تم دفعه والخدمات والمتبقي.
/// Shows the booking payment summary with paid amounts, services, and remaining balance.
class BookingPaymentSummary extends StatelessWidget {
  /// بيانات الحجز الأساسية المستخدمة كمرجع للحساب والعرض.
  /// Core booking data used as the reference for calculations and display.
  final Booking booking;

  /// تفاصيل الحجز الموسعة عندما تكون محمّلة من الخادم.
  /// Expanded booking details when loaded from the backend.
  final BookingDetails? bookingDetails;

  /// قائمة الدفعات المرتبطة بالحجز.
  /// Payments associated with the booking.
  final List<Payment> payments;

  /// الخدمات الإضافية التي ترفع الإجمالي النهائي.
  /// Extra services that affect the final total.
  final List<Service> services;

  /// يستدعى عند طلب عرض الفاتورة.
  /// Called when the invoice should be shown.
  final VoidCallback? onShowInvoice;

  /// متحكم حالة تفاصيل الحجز المستخدم داخل الواجهة.
  /// Booking-details state manager used by the UI.
  final BookingDetailsBloc? bookingDetailsBloc;

  /// يحدد ما إذا كانت اللوحة تعرض حالة إعادة تحميل.
  /// Indicates whether the summary is currently refreshing.
  final bool isRefreshing;

  /// ينشئ لوحة الملخص مع المدخلات الأساسية والاختيارية.
  /// Creates the summary card with its required and optional inputs.
  const BookingPaymentSummary({
    super.key,
    required this.booking,
    this.bookingDetails,
    List<Payment>? payments,
    List<Service>? services,
    this.onShowInvoice,
    this.bookingDetailsBloc,
    this.isRefreshing = false,
  })  : payments = payments ?? const [],
        services = services ?? const [];

  /// يبني لوحة الملخص مع الحسابات التفصيلية والصفوف المساندة.
  /// Builds the summary panel with its detailed calculations and helper rows.
  @override
  Widget build(BuildContext context) {
    final effectivePayments = bookingDetails?.payments ?? payments;
    final effectiveServices = services.isNotEmpty
        ? services
        : (bookingDetails?.services ?? const <Service>[]);

    final servicesTotal = effectiveServices.fold(0.0, (sum, service) {
      return sum + service.price.amount * service.quantity;
    });

    final detailsTotalMoney = bookingDetails?.booking.totalPrice;
    final fallbackTotalMoney = booking.totalPrice;
    final currency =
        (detailsTotalMoney?.currency ?? fallbackTotalMoney.currency);

    final hasValidDetailsTotal =
        detailsTotalMoney != null && detailsTotalMoney.amount > 0;
    final sourceTotalAmount = hasValidDetailsTotal
        ? detailsTotalMoney.amount
        : fallbackTotalMoney.amount;

    final bool looksLikeBaseOnly =
        sourceTotalAmount > 0 && sourceTotalAmount < servicesTotal;

    final inferredTotalAmount = looksLikeBaseOnly
        ? (sourceTotalAmount + servicesTotal)
        : sourceTotalAmount;
    final inferredBaseAmount = (looksLikeBaseOnly
            ? sourceTotalAmount
            : (inferredTotalAmount - servicesTotal))
        .clamp(0.0, double.infinity)
        .toDouble();

    final servicesTotalMoney = _createMoney(servicesTotal, currency);
    final bookingBaseMoney = _createMoney(inferredBaseAmount, currency);
    final totalPriceMoney = _createMoney(inferredTotalAmount, currency);

    final totalPaidMoney =
        _calculateTotalPaidMoney(effectivePayments, totalPriceMoney.currency);
    final remainingMoney = _createMoney(
        totalPriceMoney.amount - totalPaidMoney.amount,
        totalPriceMoney.currency);
    final isFullyPaid = remainingMoney.amount <= 0;
    final isCancelled = booking.status.name == 'cancelled';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowDark.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.darkCard.withValues(alpha: 0.8),
                  AppTheme.darkCard.withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isFullyPaid
                    ? AppTheme.success.withValues(alpha: 0.3)
                    : AppTheme.warning.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                _buildHeader(isFullyPaid),
                _buildSummary(
                  bookingBaseMoney,
                  servicesTotalMoney,
                  totalPriceMoney,
                  totalPaidMoney,
                  remainingMoney,
                ),
                if (effectiveServices.isNotEmpty)
                  _buildServicesDetails(
                      effectiveServices, totalPriceMoney.currency),
                if (effectivePayments.isNotEmpty)
                  _buildPaymentsList(effectivePayments),
                _buildFooter(context, isFullyPaid, isCancelled),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// يبني رأس الملخص الذي يوضح حالة السداد الحالية.
  /// Builds the summary header that explains the current payment state.
  Widget _buildHeader(bool isFullyPaid) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFullyPaid
              ? [
                  AppTheme.success.withValues(alpha: 0.15),
                  AppTheme.success.withValues(alpha: 0.05),
                ]
              : [
                  AppTheme.warning.withValues(alpha: 0.15),
                  AppTheme.warning.withValues(alpha: 0.05),
                ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.darkBorder.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isFullyPaid
                    ? [
                        AppTheme.success,
                        AppTheme.success.withValues(alpha: 0.7)
                      ]
                    : [
                        AppTheme.warning,
                        AppTheme.warning.withValues(alpha: 0.7)
                      ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isFullyPaid
                  ? CupertinoIcons.checkmark_seal_fill
                  : CupertinoIcons.clock_fill,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ملخص المدفوعات',
                style: AppTextStyles.heading3.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isFullyPaid
                      ? AppTheme.success.withValues(alpha: 0.1)
                      : AppTheme.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isFullyPaid ? 'مدفوع بالكامل' : 'دفعة جزئية',
                  style: AppTextStyles.caption.copyWith(
                    color: isFullyPaid ? AppTheme.success : AppTheme.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// يعرض تفاصيل الخدمات الإضافية التي دخلت في حساب الإجمالي.
  /// Shows the extra services included in the total calculation.
  Widget _buildServicesDetails(List<Service> services, String currency) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.square_stack_fill,
                size: 16,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'الخدمات الإضافية',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${services.length} خدمة',
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...services.map((service) {
            final unitPrice =
                Formatters.formatCurrency(service.price.amount, currency);
            final totalPrice = Formatters.formatCurrency(
                service.price.amount * service.quantity, currency);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.darkBackground.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.darkBorder.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          service.name,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppTheme.textWhite,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        totalPrice,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'الكمية: ${service.quantity}',
                        style: AppTextStyles.caption
                            .copyWith(color: AppTheme.textMuted),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'سعر الوحدة: $unitPrice',
                        style: AppTextStyles.caption
                            .copyWith(color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                  if (service.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      service.description,
                      style: AppTextStyles.caption
                          .copyWith(color: AppTheme.textMuted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// يبني صفوف الملخص المالي التي توضح الأساس والخدمات والإجمالي والمتبقي.
  /// Builds the financial summary rows for base, services, total, and remaining.
  Widget _buildSummary(
    Money bookingBase,
    Money servicesTotal,
    Money totalPrice,
    Money totalPaid,
    Money remainingMoney,
  ) {
    final hasRemaining = remainingMoney.amount > 0;
    final remainingDisplay = hasRemaining
        ? _formatMoney(remainingMoney)
        : _formatMoney(_createMoney(0, remainingMoney.currency));

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildSummaryRow(
            label: 'سعر الحجز',
            value: _formatMoney(bookingBase),
            icon: CupertinoIcons.house_fill,
            color: AppTheme.textWhite,
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            label: 'إجمالي الخدمات',
            value: _formatMoney(servicesTotal),
            icon: CupertinoIcons.square_stack_fill,
            color: AppTheme.primaryBlue,
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            label: 'المبلغ الإجمالي',
            value: _formatMoney(totalPrice),
            icon: CupertinoIcons.tag_fill,
            color: AppTheme.textWhite,
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            label: 'المبلغ المدفوع',
            value: _formatMoney(totalPaid),
            icon: CupertinoIcons.checkmark_circle_fill,
            color: AppTheme.success,
            isLoading: isRefreshing,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: hasRemaining
                    ? [
                        AppTheme.warning.withValues(alpha: 0.15),
                        AppTheme.warning.withValues(alpha: 0.05),
                      ]
                    : [
                        AppTheme.success.withValues(alpha: 0.15),
                        AppTheme.success.withValues(alpha: 0.05),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasRemaining
                    ? AppTheme.warning.withValues(alpha: 0.3)
                    : AppTheme.success.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasRemaining
                      ? CupertinoIcons.exclamationmark_triangle_fill
                      : CupertinoIcons.checkmark_seal_fill,
                  color: hasRemaining ? AppTheme.warning : AppTheme.success,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'المبلغ المتبقي',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: isRefreshing
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              hasRemaining
                                  ? AppTheme.warning
                                  : AppTheme.success,
                            ),
                          ),
                        )
                      : Text(
                          remainingDisplay,
                          style: AppTextStyles.heading2.copyWith(
                            color: hasRemaining
                                ? AppTheme.warning
                                : AppTheme.success,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// يبني صفًا واحدًا داخل الملخص المالي مع التسمية والقيمة واللون.
  /// Builds a single financial summary row with label, value, and color.
  Widget _buildSummaryRow({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    bool isLoading = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: color.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
        const Spacer(),
        isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            : Text(
                value,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ],
    );
  }

  /// يعرض قائمة الدفعات المنفذة مع حالتها ووسيلة الدفع الخاصة بها.
  /// Renders the executed payments list with status and payment method.
  Widget _buildPaymentsList(List<Payment> payments) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'سجل المدفوعات',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...payments.map((payment) => _buildPaymentItem(payment)),
        ],
      ),
    );
  }

  /// يبني بطاقة دفعة واحدة مع المبلغ والطريقة والحالة.
  /// Builds one payment card with amount, method, and status.
  Widget _buildPaymentItem(Payment payment) {
    final isSuccessful = payment.status == PaymentStatus.successful;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSuccessful
              ? AppTheme.success.withValues(alpha: 0.2)
              : AppTheme.error.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSuccessful
                  ? AppTheme.success.withValues(alpha: 0.1)
                  : AppTheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getPaymentMethodIcon(payment.method),
              size: 18,
              color: isSuccessful ? AppTheme.success : AppTheme.error,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.method.displayNameAr,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textWhite,
                  ),
                ),
                Text(
                  Formatters.formatDateTime(payment.paymentDate),
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                payment.amount.formattedAmount,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSuccessful ? AppTheme.success : AppTheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSuccessful
                      ? AppTheme.success.withValues(alpha: 0.1)
                      : AppTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  payment.status.displayNameAr,
                  style: AppTextStyles.caption.copyWith(
                    color: isSuccessful ? AppTheme.success : AppTheme.error,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// يبني التذييل الذي يربط الحالة المالية بإجراء المستخدم التالي.
  /// Builds the footer that links the financial state to the next user action.
  Widget _buildFooter(
      BuildContext context, bool isFullyPaid, bool isCancelled) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground.withValues(alpha: 0.3),
        border: Border(
          top: BorderSide(
            color: AppTheme.darkBorder.withValues(alpha: 0.1),
          ),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          if (!isFullyPaid && !isCancelled) ...[
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.warning.withValues(alpha: 0.8),
                      AppTheme.warning,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.warning.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      debugPrint('🔵 Register Payment button tapped');
                      debugPrint('🔵 bookingDetailsBloc: $bookingDetailsBloc');
                      debugPrint(
                          '🔵 bookingDetailsBloc != null: ${bookingDetailsBloc != null}');

                      if (bookingDetailsBloc != null) {
                        debugPrint(
                            '🔵 Bloc state: ${bookingDetailsBloc!.state.runtimeType}');
                        if (bookingDetailsBloc!.state is BookingDetailsLoaded) {
                          final state =
                              bookingDetailsBloc!.state as BookingDetailsLoaded;
                          debugPrint('🔵 Booking ID: ${state.booking.id}');
                          debugPrint(
                              '🔵 Total Amount: ${state.booking.totalPrice.amount}');
                          debugPrint(
                              '🔵 Payments: ${state.bookingDetails?.payments.length ?? 0}');
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MultiBlocProvider(
                              providers: [
                                BlocProvider.value(
                                  value: bookingDetailsBloc!,
                                ),
                                BlocProvider(
                                  create: (context) =>
                                      sl<RegisterPaymentBloc>(),
                                ),
                              ],
                              child: RegisterPaymentPage(
                                bookingId: booking.id,
                              ),
                            ),
                          ),
                        ).then((result) {
                          if (result == true) {
                            bookingDetailsBloc!
                                .add(const RefreshBookingDetailsEvent());
                          }
                        });
                      } else {
                        debugPrint('❌ bookingDetailsBloc is null!');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                const Text('حدث خطأ في تحميل بيانات الحجز'),
                            backgroundColor: AppTheme.error,
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.money_dollar_circle,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'تسجيل دفعة',
                            style: AppTextStyles.buttonMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.darkCard.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.darkBorder.withValues(alpha: 0.3),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onShowInvoice,
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.doc_text,
                          color: AppTheme.textMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'عرض الفاتورة',
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// يحسب إجمالي ما دُفع مع توحيد العملة المستخدمة في العرض.
  /// Calculates the total paid amount while normalizing the display currency.
  Money _calculateTotalPaidMoney(List<Payment> payments, String currency) {
    final paidAmount = payments
        .where((p) => p.status == PaymentStatus.successful)
        .fold(0.0, (sum, payment) => sum + payment.amount.amount);

    return _createMoney(paidAmount, currency);
  }

  /// يختار الأيقونة المناسبة لطريقة الدفع المعروضة.
  /// Chooses the icon that matches the displayed payment method.
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

  /// ينشئ قيمة مالية موحدة من مبلغ خام وعملة محددة.
  /// Creates a normalized money value from a raw amount and currency code.
  Money _createMoney(double amount, String currency) {
    return Money(
      amount: amount,
      currency: currency,
      formattedAmount: Formatters.formatCurrency(amount, currency),
    );
  }

  /// ينسق القيمة المالية للعرض داخل الواجهة.
  /// Formats the money value for display in the UI.
  String _formatMoney(Money money) {
    if (money.formattedAmount.trim().isNotEmpty) {
      return money.formattedAmount;
    }
    return Formatters.formatCurrency(money.amount, money.currency);
  }
}
