import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/enums/payment_method_enum.dart';
import 'package:hggzk/app/navigation/switch_main_tab_notification.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../payment/presentation/bloc/payment_bloc.dart';
import '../../../payment/presentation/bloc/payment_event.dart';
import '../../../payment/presentation/bloc/payment_state.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_state.dart';
import '../bloc/booking_event.dart';
import '../widgets/payment_methods_widget.dart';

/// العربية: يمثل عنصر الصفحة `BookingPaymentPage`.
class BookingPaymentPage extends StatefulWidget {
  /// العربية: يخزن القيمة `bookingData`.
  final Map<String, dynamic> bookingData;

  /// العربية: ينشئ مثيلًا جديدًا من `BookingPaymentPage`.
  const BookingPaymentPage({
    super.key,
    required this.bookingData,
  });

  /// العربية: ينشئ كائن الحالة الخاص بهذا العنصر.
  @override
  State<BookingPaymentPage> createState() => _BookingPaymentPageState();
}

/// العربية: يمثل الحالة الخاصة بـ `BookingPaymentPageState`.
class _BookingPaymentPageState extends State<BookingPaymentPage>
    with SingleTickerProviderStateMixin {
  /// العربية: يخزن القيمة `controller`.
  late AnimationController _controller;

  /// العربية: يخزن القيمة `selectedPaymentMethod`.
  PaymentMethod? _selectedPaymentMethod;

  /// العربية: يخزن القيمة `acceptTerms`.
  bool _acceptTerms = false;

  /// العربية: يخزن القيمة `holdNoticeShown`.
  bool _holdNoticeShown = false;
  final TextEditingController _walletCodeController = TextEditingController();

  /// العربية: يعيد القيمة `returnToPrevious`.
  bool get _returnToPrevious => widget.bookingData['returnToPrevious'] == true;

  // ═══════════════════════════════════════════════════════════════
  // حساب الأسعار
  // ═══════════════════════════════════════════════════════════════
  /// العربية: يعيد القيمة `nights`.
  int get _nights {
    final checkIn = widget.bookingData['checkIn'] as DateTime;
    final checkOut = widget.bookingData['checkOut'] as DateTime;
    return checkOut.difference(checkIn).inDays;
  }

  /// العربية: يعيد القيمة `pricePerNight`.
  double get _pricePerNight =>
      (widget.bookingData['pricePerNight'] ?? 0.0) as double;

  /// العربية: يعيد القيمة `servicesTotal`.
  double get _servicesTotal {
    final services =
        widget.bookingData['selectedServices'] as List<Map<String, dynamic>>;
    return services.fold<double>(
      0,
      (sum, service) => sum + (service['price'] as num).toDouble(),
    );
  }

  /// العربية: يعيد القيمة `total`.
  double get _total => (_nights * _pricePerNight) + _servicesTotal;

  /// العربية: يعيد القيمة `serverTotal`.
  double? get _serverTotal {
    final value = (widget.bookingData['totalAmount'] as num?)?.toDouble();
    if (value == null || value <= 0) return null;
    return value;
  }

  /// العربية: يعيد القيمة `payableTotal`.
  double get _payableTotal => _serverTotal ?? _total;

  /// العربية: يعيد القيمة `hasServerTotalMismatch`.
  bool get _hasServerTotalMismatch =>
      _serverTotal != null && (_serverTotal! - _total).abs() > 0.01;

  /// العربية: يهيئ الحالة الخاصة بهذا العنصر.
  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = PaymentMethod.jaibWallet;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_holdNoticeShown) {
        _holdNoticeShown = true;
        _showHoldNoticeDialog();
      }
    });
  }

  /// العربية: يحرر الموارد المستخدمة بواسطة هذا الكائن.
  @override
  void dispose() {
    _controller.dispose();
    _walletCodeController.dispose();
    super.dispose();
  }

  /// العربية: يبني شجرة العناصر الخاصة بهذا المكوّن.
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_returnToPrevious) {
          context.pop(false);
          return false;
        }
        return true;
      },
      child: BlocListener<PaymentBloc, PaymentState>(
        listener: _handlePaymentState,
        child: Scaffold(
          backgroundColor: AppTheme.darkBackground,
          body: BlocConsumer<BookingBloc, BookingState>(
            listener: _handleBookingState,
            builder: (context, state) {
              final isLoading = state is BookingLoading ||
                  context.watch<PaymentBloc>().state is PaymentProcessing;

              if (isLoading) {
                return _buildLoadingState();
              }

              return _buildMainContent();
            },
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // المحتوى الرئيسي
  // ═══════════════════════════════════════════════════════════════
  /// العربية: يبني main content.
  Widget _buildMainContent() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildSliverAppBar(),
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _controller,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _controller,
                curve: Curves.easeOutCubic,
              )),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBookingSummaryCard(),
                    const SizedBox(height: 28),
                    _buildPaymentSection(),
                    const SizedBox(height: 28),
                    _buildTermsCard(),
                    const SizedBox(height: 32),
                    _buildPayButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // AppBar
  // ═══════════════════════════════════════════════════════════════
  /// العربية: يبني sliver app bar.
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: AppTheme.darkBackground,
      elevation: 0,
      pinned: true,
      expandedHeight: 110,
      leading: _buildBackButton(),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(right: 56, bottom: 14),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إتمام الدفع',
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textWhite,
              ),
            ),
            Text(
              'خطوة أخيرة لتأكيد حجزك',
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.darkGradient,
          ),
        ),
      ),
    );
  }

  /// العربية: يبني back button.
  Widget _buildBackButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.glassLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.3),
        ),
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        color: AppTheme.textWhite,
        onPressed: () {
          HapticFeedback.lightImpact();
          if (_returnToPrevious) {
            context.pop(false);
            return;
          }

          final bookingId = widget.bookingData['bookingId'];
          context.pop(
            bookingId != null && bookingId.toString().isNotEmpty
                ? {'bookingId': bookingId}
                : null,
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // بطاقة ملخص الحجز
  // ═══════════════════════════════════════════════════════════════
  /// العربية: يبني booking summary card.
  Widget _buildBookingSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowDark,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.darkBorder.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryBlue.withOpacity(0.2),
                        AppTheme.primaryBlue.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: AppTheme.primaryBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'ملخص الحجز',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.nights_stay_rounded,
                        size: 12,
                        color: AppTheme.primaryPurple,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_nights ليالي',
                        style: AppTextStyles.caption.copyWith(
                          color: AppTheme.primaryPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Price Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildPriceItem(
                  icon: Icons.hotel_rounded,
                  label: 'الإقامة',
                  sublabel:
                      '$_nights ليالي × ${_pricePerNight.toStringAsFixed(0)}',
                  amount: _nights * _pricePerNight,
                  color: AppTheme.primaryBlue,
                ),
                if (_servicesTotal > 0) ...[
                  const SizedBox(height: 12),
                  _buildPriceItem(
                    icon: Icons.room_service_rounded,
                    label: 'الخدمات الإضافية',
                    amount: _servicesTotal,
                    color: AppTheme.success,
                  ),
                ],

                const SizedBox(height: 16),

                // Divider
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppTheme.darkBorder.withOpacity(0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الإجمالي',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        '${_payableTotal.toStringAsFixed(0)} ريال',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_hasServerTotalMismatch) ...[
                  const SizedBox(height: 8),
                  Text(
                    'تم تحديث المبلغ النهائي حسب التسعير اليومي الحالي.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.warning,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// العربية: يبني price item.
  Widget _buildPriceItem({
    required IconData icon,
    required String label,
    String? sublabel,
    required double amount,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textWhite.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (sublabel != null)
                Text(
                  sublabel,
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
            ],
          ),
        ),
        Text(
          '${amount.toStringAsFixed(0)} ريال',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // قسم طرق الدفع
  // ═══════════════════════════════════════════════════════════════
  /// العربية: يبني payment section.
  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.success.withOpacity(0.2),
                    AppTheme.success.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.payment_rounded,
                color: AppTheme.success,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'طريقة الدفع',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'اختر الطريقة المناسبة لك',
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        PaymentMethodsWidget(
          selectedMethod: _selectedPaymentMethod,
          onMethodSelected: (method) {
            HapticFeedback.lightImpact();
            setState(() => _selectedPaymentMethod = method);
          },
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // بطاقة الشروط والأحكام
  // ═══════════════════════════════════════════════════════════════
  /// العربية: يبني terms card.
  Widget _buildTermsCard() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _acceptTerms = !_acceptTerms);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: _acceptTerms
              ? LinearGradient(
                  colors: [
                    AppTheme.success.withOpacity(0.1),
                    AppTheme.success.withOpacity(0.05),
                  ],
                )
              : null,
          color: _acceptTerms ? null : AppTheme.darkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _acceptTerms
                ? AppTheme.success.withOpacity(0.3)
                : AppTheme.darkBorder.withOpacity(0.3),
            width: _acceptTerms ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                gradient: _acceptTerms
                    ? LinearGradient(
                        colors: [
                          AppTheme.success,
                          AppTheme.success.withOpacity(0.8),
                        ],
                      )
                    : null,
                color: _acceptTerms ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _acceptTerms
                      ? Colors.transparent
                      : AppTheme.darkBorder.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: _acceptTerms
                    ? [
                        BoxShadow(
                          color: AppTheme.success.withOpacity(0.4),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: _acceptTerms
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أوافق على الشروط والأحكام',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 11,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'إلغاء مجاني قبل 24 ساعة من الوصول',
                        style: AppTextStyles.caption.copyWith(
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // زر الدفع
  // ═══════════════════════════════════════════════════════════════
  /// العربية: يبني pay button.
  Widget _buildPayButton() {
    final isValid = _selectedPaymentMethod != null && _acceptTerms;

    return GestureDetector(
      onTap: isValid ? _processPayment : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 52,
        decoration: BoxDecoration(
          gradient: isValid ? AppTheme.primaryGradient : null,
          color: isValid ? null : AppTheme.darkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isValid ? Colors.transparent : AppTheme.darkBorder,
          ),
          boxShadow: isValid
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_rounded,
              size: 18,
              color: isValid ? Colors.white : AppTheme.textMuted,
            ),
            const SizedBox(width: 10),
            Text(
              'تأكيد الدفع',
              style: AppTextStyles.buttonLarge.copyWith(
                color: isValid ? Colors.white : AppTheme.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${_payableTotal.toStringAsFixed(0)} ريال)',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isValid
                    ? Colors.white.withOpacity(0.85)
                    : AppTheme.textMuted.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // حالة التحميل
  // ═══════════════════════════════════════════════════════════════
  /// العربية: يبني loading state.
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withOpacity(0.2),
                  AppTheme.primaryBlue.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryBlue,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'جاري معالجة الدفع...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'يرجى الانتظار',
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // معالجة الدفع
  // ═══════════════════════════════════════════════════════════════
  /// العربية: يعالج `processPayment`.
  void _processPayment() {
    HapticFeedback.mediumImpact();

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      context.push('/login');
      return;
    }

    final paymentMethod = _selectedPaymentMethod ?? PaymentMethod.cash;

    if (paymentMethod == PaymentMethod.sabaCashWallet ||
        paymentMethod == PaymentMethod.floskWallet) {
      final phone = authState.user.phone.trim();
      if (phone.isEmpty) {
        _showPaymentErrorDialog(
          title: 'رقم الهاتف مطلوب',
          message:
              'لا يمكن إتمام الدفع عبر هذه المحفظة لأن رقم هاتفك غير محفوظ. يرجى إضافة رقم الهاتف في الملف الشخصي ثم إعادة المحاولة.',
        );
        return;
      }
    }

    void dispatchPayment(String? walletCode) {
      final currency = widget.bookingData['currency']?.toString() ?? 'YER';

      context.read<PaymentBloc>().add(
            ProcessPaymentEvent(
              bookingId: widget.bookingData['bookingId'] ?? '',
              userId: authState.user.userId,
              amount: _payableTotal,
              paymentMethod: paymentMethod,
              currency: currency,
              paymentDetails:
                  _getPaymentDetails(paymentMethod, walletCode: walletCode),
            ),
          );
    }

    if (paymentMethod == PaymentMethod.sabaCashWallet ||
        paymentMethod == PaymentMethod.floskWallet) {
      dispatchPayment(null);
    } else if (paymentMethod.isWallet) {
      _showWalletCodeDialog(
        method: paymentMethod,
        onConfirm: (code) => dispatchPayment(code),
      );
    } else {
      dispatchPayment(null);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Dialogs
  // ═══════════════════════════════════════════════════════════════
  /// العربية: يعرض wallet code dialog.
  void _showWalletCodeDialog({
    required PaymentMethod method,
    required void Function(String code) onConfirm,
  }) {
    final color = _getWalletColor(method);
    _walletCodeController.clear();
    HapticFeedback.mediumImpact();

    final isOtp = method == PaymentMethod.sabaCashWallet ||
        method == PaymentMethod.floskWallet;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: AppTheme.overlayDark,
      builder: (ctx) => _buildDialog(
        icon: Icons.dialpad_rounded,
        iconColor: color,
        title: _getWalletDialogTitle(method),
        message: _getWalletDialogDescription(method),
        content: TextField(
          controller: _walletCodeController,
          textAlign: TextAlign.center,
          style: AppTextStyles.h3.copyWith(
            color: AppTheme.textWhite,
            letterSpacing: 4,
          ),
          keyboardType: isOtp ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: _getWalletHintText(method),
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
              letterSpacing: 0,
            ),
            filled: true,
            fillColor: AppTheme.darkSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 1.5),
            ),
          ),
        ),
        primaryButtonText: 'تأكيد الدفع',
        primaryButtonColor: color,
        onPrimaryPressed: () {
          final code = _walletCodeController.text.trim();
          if (code.isEmpty) {
            _showSnackBar('يرجى إدخال الكود', isError: true);
            return;
          }
          Navigator.pop(ctx);
          onConfirm(code);
        },
        secondaryButtonText: 'إلغاء',
        onSecondaryPressed: () => Navigator.pop(ctx),
      ),
    );
  }

  /// العربية: يعرض payment success dialog.
  void _showPaymentSuccessDialog({required String bookingId}) {
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppTheme.overlayDark,
      builder: (ctx) => _buildDialog(
        icon: Icons.check_circle_rounded,
        iconColor: AppTheme.success,
        title: 'تم الدفع بنجاح! 🎉',
        message: 'تهانينا! تم تأكيد حجزك بنجاح.',
        primaryButtonText: 'عرض الحجز',
        primaryButtonColor: AppTheme.success,
        onPrimaryPressed: () {
          Navigator.pop(ctx);
          if (_returnToPrevious) {
            context.pop(true);
            return;
          }

          if (bookingId.isNotEmpty) {
            context.go('/main');
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                SwitchMainTabNotification(2).dispatch(context);
                Future.delayed(const Duration(milliseconds: 200), () {
                  if (mounted) {
                    context.push('/booking/$bookingId');
                  }
                });
              }
            });
          }
        },
        secondaryButtonText: 'إغلاق',
        onSecondaryPressed: () {
          Navigator.pop(ctx);
          if (_returnToPrevious) {
            Navigator.pop(context, true);
            return;
          }

          context.go('/main');
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              SwitchMainTabNotification(2).dispatch(context);
            }
          });
        },
      ),
    );
  }

  /// العربية: يعرض payment error dialog.
  void _showPaymentErrorDialog({
    required String title,
    required String message,
  }) {
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      barrierColor: AppTheme.overlayDark,
      builder: (ctx) => _buildDialog(
        icon: Icons.error_outline_rounded,
        iconColor: AppTheme.error,
        title: title,
        message: message,
        primaryButtonText: 'حسناً',
        primaryButtonColor: AppTheme.error,
        onPrimaryPressed: () => Navigator.pop(ctx),
      ),
    );
  }

  /// العربية: يعرض unit unavailable dialog.
  void _showUnitUnavailableDialog() {
    _showPaymentErrorDialog(
      title: 'غير متاح',
      message: 'عذراً، الوحدة غير متاحة في التواريخ المحددة.',
    );
  }

  /// العربية: يعرض hold notice dialog.
  void _showHoldNoticeDialog() {
    HapticFeedback.selectionClick();

    showDialog(
      context: context,
      barrierColor: AppTheme.overlayDark,
      builder: (ctx) => _buildDialog(
        icon: Icons.schedule_rounded,
        iconColor: AppTheme.warning,
        title: 'في انتظار الدفع',
        message: 'حجزك محفوظ مؤقتاً. أكمل الدفع لتأكيده قبل أن يحجزه شخص آخر.',
        primaryButtonText: 'فهمت',
        primaryButtonColor: AppTheme.warning,
        onPrimaryPressed: () => Navigator.pop(ctx),
      ),
    );
  }

  /// العربية: يبني dialog.
  Widget _buildDialog({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    Widget? content,
    required String primaryButtonText,
    required Color primaryButtonColor,
    required VoidCallback onPrimaryPressed,
    String? secondaryButtonText,
    VoidCallback? onSecondaryPressed,
  }) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: iconColor.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.15),
                blurRadius: 30,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          iconColor.withOpacity(0.2),
                          iconColor.withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 34),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    title,
                    style: AppTextStyles.h3.copyWith(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  // Message
                  Text(
                    message,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppTheme.textMuted,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Custom Content
                  if (content != null) ...[
                    const SizedBox(height: 20),
                    content,
                  ],

                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      if (secondaryButtonText != null) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onSecondaryPressed,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(
                                color: AppTheme.darkBorder,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              secondaryButtonText,
                              style: AppTextStyles.buttonMedium.copyWith(
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onPrimaryPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryButtonColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            primaryButtonText,
                            style: AppTextStyles.buttonMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Handlers & Helpers
  // ═══════════════════════════════════════════════════════════════
  /// العربية: يعالج payment state.
  void _handlePaymentState(BuildContext context, PaymentState state) {
    if (state is PaymentError) {
      final msg = state.message;
      if (state.showAsDialog) {
        _showPaymentErrorDialog(
          title: state.code ?? 'خطأ في الدفع',
          message: msg,
        );
        return;
      }
      if (msg.contains('غير متاحة')) {
        _showUnitUnavailableDialog();
      } else if (msg.contains('BOOKING_MISSED')) {
        _showPaymentErrorDialog(
          title: 'انتهى الوقت',
          message: 'لا يمكن إتمام الدفع لأن وقت الوصول قد انقضى.',
        );
      } else if (msg.contains('AMOUNT_MISMATCH')) {
        _showPaymentErrorDialog(
          title: 'خطأ في المبلغ',
          message: 'مبلغ الدفع لا يطابق مبلغ الحجز.',
        );
      } else if (msg.contains('ALREADY_PAID')) {
        _showPaymentErrorDialog(
          title: 'مدفوع مسبقاً',
          message: 'هذا الحجز مدفوع بالفعل.',
        );
      } else {
        _showSnackBar(msg, isError: true);
      }
    } else if (state is PaymentSuccess) {
      if (_selectedPaymentMethod == PaymentMethod.sabaCashWallet &&
          state.transaction.status == PaymentStatus.pending) {
        _showWalletCodeDialog(
          method: PaymentMethod.sabaCashWallet,
          onConfirm: (otp) => _dispatchSabaCashOtp(otp),
        );
      } else if (_selectedPaymentMethod == PaymentMethod.floskWallet &&
          state.transaction.status == PaymentStatus.pending) {
        _showWalletCodeDialog(
          method: PaymentMethod.floskWallet,
          onConfirm: (otp) => _dispatchFloskOtp(otp),
        );
      } else {
        final bookingId = widget.bookingData['bookingId']?.toString() ?? '';
        if (bookingId.isNotEmpty) {
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticated) {
            context.read<BookingBloc>().add(
                  GetBookingDetailsEvent(
                    bookingId: bookingId,
                    userId: authState.user.userId,
                  ),
                );
          }
        }
        _showPaymentSuccessDialog(bookingId: bookingId);
      }
    }
  }

  /// العربية: يعالج booking state.
  void _handleBookingState(BuildContext context, BookingState state) {
    if (state is BookingCreated) {
      context.push('/booking/confirmation', extra: state.booking);
    } else if (state is BookingError) {
      _showSnackBar(state.message, isError: true);
    }
  }

  /// العربية: يرسل saba cash otp.
  void _dispatchSabaCashOtp(String otp) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final currency = widget.bookingData['currency']?.toString() ?? 'YER';

    context.read<PaymentBloc>().add(
          ProcessPaymentEvent(
            bookingId: widget.bookingData['bookingId'] ?? '',
            userId: authState.user.userId,
            amount: _payableTotal,
            paymentMethod: PaymentMethod.sabaCashWallet,
            currency: currency,
            paymentDetails: {'otp': otp},
          ),
        );
  }

  /// العربية: يرسل flosk otp.
  void _dispatchFloskOtp(String otp) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final currency = widget.bookingData['currency']?.toString() ?? 'YER';

    context.read<PaymentBloc>().add(
          ProcessPaymentEvent(
            bookingId: widget.bookingData['bookingId'] ?? '',
            userId: authState.user.userId,
            amount: _payableTotal,
            paymentMethod: PaymentMethod.floskWallet,
            currency: currency,
            paymentDetails: {'otp': otp},
          ),
        );
  }

  /// العربية: يعيد payment details.
  Map<String, dynamic>? _getPaymentDetails(PaymentMethod method,
      {String? walletCode}) {
    if (method == PaymentMethod.creditCard) {
      return {
        'cardDetails': {
          'cardNumber': '4111111111111111',
          'cardHolderName': 'John Doe',
          'expiryDate': '12/25',
          'cvv': '123',
        },
      };
    } else if (method == PaymentMethod.sabaCashWallet && walletCode != null) {
      return {'otp': walletCode};
    } else if (method == PaymentMethod.floskWallet && walletCode != null) {
      return {'otp': walletCode};
    } else if (method.isWallet && walletCode != null) {
      return {
        if (method == PaymentMethod.jwaliWallet) 'voucher': walletCode,
        if (method != PaymentMethod.jwaliWallet) 'walletId': walletCode,
      };
    }
    return null;
  }

  /// العربية: يعيد wallet color.
  Color _getWalletColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.jaibWallet:
        return AppTheme.error;
      case PaymentMethod.jwaliWallet:
        return AppTheme.primaryPurple;
      case PaymentMethod.cashWallet:
        return AppTheme.success;
      case PaymentMethod.oneCashWallet:
        return AppTheme.warning;
      case PaymentMethod.floskWallet:
        return AppTheme.neonPurple;
      case PaymentMethod.sabaCashWallet:
        return AppTheme.info;
      default:
        return AppTheme.primaryBlue;
    }
  }

  /// العربية: يعيد wallet dialog title.
  String _getWalletDialogTitle(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.jaibWallet:
        return 'إدخال كود شراء جيب';
      case PaymentMethod.jwaliWallet:
        return 'إدخال كود شراء جوالي';
      case PaymentMethod.cashWallet:
        return 'إدخال كود شراء كاش';
      case PaymentMethod.oneCashWallet:
        return 'إدخال كود محفظة ون كاش';
      case PaymentMethod.floskWallet:
        return 'إدخال رمز التحقق (OTP) لمحفظة فلوسك';
      case PaymentMethod.sabaCashWallet:
        return 'إدخال رمز التحقق (OTP) لمحفظة سبأ كاش';
      default:
        return 'إدخال كود المحفظة';
    }
  }

  /// العربية: يعيد wallet dialog description.
  String _getWalletDialogDescription(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.jaibWallet:
        return 'قم بإدخال كود الشراء المنشأ في تطبيق جيب (من شراء أونلاين ثم كود) في محفظة جيب.';
      case PaymentMethod.jwaliWallet:
        return 'يرجى إدخال كود الشراء الذي تم توليده من تطبيق جوالي.';
      case PaymentMethod.cashWallet:
        return 'يرجى إدخال كود شراء أونلاين (يمكنك الحصول عليه من تطبيق كاش).';
      case PaymentMethod.oneCashWallet:
        return 'يرجى إدخال كود الشراء الذي تم توليده من تطبيق ون كاش.';
      case PaymentMethod.floskWallet:
        return 'تم إرسال رمز تحقق (OTP) إلى رقم هاتفك المرتبط بمحفظة فلوسك. يرجى إدخال الرمز المكون من 6 أرقام لتأكيد العملية.';
      case PaymentMethod.sabaCashWallet:
        return 'تم إرسال رمز تحقق (OTP) إلى رقم هاتفك المرتبط بمحفظة سبأ كاش. يرجى إدخال الرمز المكون من 4 أرقام لتأكيد العملية.';
      default:
        return 'يرجى إدخال كود الشراء المرتبط بهذه المحفظة.';
    }
  }

  /// العربية: يعيد wallet hint text.
  String _getWalletHintText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.jaibWallet:
        return 'أدخل كود شراء جيب';
      case PaymentMethod.jwaliWallet:
        return 'أدخل كود شراء جوالي';
      case PaymentMethod.cashWallet:
        return 'أدخل كود شراء أونلاين من كاش';
      case PaymentMethod.oneCashWallet:
        return 'أدخل كود ون كاش';
      case PaymentMethod.floskWallet:
        return 'أدخل رمز التحقق المكون من 6 أرقام';
      case PaymentMethod.sabaCashWallet:
        return 'أدخل رمز التحقق المكون من 4 أرقام';
      default:
        return 'أدخل كود المحفظة';
    }
  }

  /// العربية: يعرض snack bar.
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        ),
        backgroundColor: isError ? AppTheme.error : AppTheme.darkCard,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
