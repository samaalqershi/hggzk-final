import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/enums/payment_method_enum.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_details.dart';
import '../bloc/register_payment/register_payment_bloc.dart';
import '../bloc/booking_details/booking_details_bloc.dart';
import '../bloc/booking_details/booking_details_state.dart';
import '../bloc/booking_details/booking_details_event.dart';
import '../widgets/booking_status_badge.dart';

/// Arabic: صفحة تسجيل دفعة جديدة مرتبطة بحجز محدد.
/// English: Page for registering a new payment against a specific booking.
class RegisterPaymentPage extends StatefulWidget {
  /// Arabic: معرّف الحجز الذي ستُسجل له الدفعة الجديدة.
  /// English: The booking identifier that will receive the new payment.
  final String bookingId;

  /// Arabic: ينشئ صفحة تسجيل الدفعة للحجز المحدد.
  /// English: Creates the payment registration page for the selected booking.
  const RegisterPaymentPage({
    super.key,
    required this.bookingId,
  });
  @override
  State<RegisterPaymentPage> createState() => _RegisterPaymentPageState();
}

/// Arabic: يدير نموذج تسجيل الدفعة، بما في ذلك تحميل بيانات الحجز والتحقق من المدخلات.
/// English: Manages the payment form, including booking data loading and input validation.
class _RegisterPaymentPageState extends State<RegisterPaymentPage>
    with TickerProviderStateMixin {
  /// Arabic: يتحكم في حركة الدخول الأولى لعناصر الصفحة.
  /// English: Drives the initial page entrance animation.
  late AnimationController _animationController;

  /// Arabic: المفتاح المسؤول عن التحقق من صحة النموذج قبل الإرسال.
  /// English: The form key used to validate the payment form before submission.
  final _formKey = GlobalKey<FormState>();

  /// Arabic: يتحكم في حقل مبلغ الدفعة.
  /// English: Controls the payment amount field.
  final _amountController = TextEditingController();

  /// Arabic: يتحكم في حقل رقم المعاملة الاختياري.
  /// English: Controls the optional transaction ID field.
  final _transactionIdController = TextEditingController();

  /// Arabic: يتحكم في حقل الملاحظات الإضافية.
  /// English: Controls the additional notes field.
  final _notesController = TextEditingController();

  /// Arabic: طريقة الدفع المختارة حاليًا.
  /// English: The currently selected payment method.
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;

  /// Arabic: تاريخ الدفعة الذي سيُرسل مع العملية.
  /// English: The payment date that will be submitted with the transaction.
  DateTime _selectedDate = DateTime.now();

  /// Arabic: العملة المستخدمة لعرض المبالغ وإرسالها.
  /// English: The currency code used to display and submit amounts.
  String _currency = 'YER';

  /// Arabic: بيانات الحجز المحملة لعرض الملخص والنطاق المتبقي.
  /// English: Loaded booking data used for the summary and remaining amount.
  Booking? _booking;

  /// Arabic: إجمالي قيمة الحجز قبل أي دفعات.
  /// English: The total booking amount before any payments.
  double _totalAmount = 0;

  /// Arabic: إجمالي الدفعات المسجلة حتى الآن.
  /// English: The sum of payments recorded so far.
  double _paidAmount = 0;

  /// Arabic: المبلغ الذي ما يزال مطلوبًا سداده.
  /// English: The amount still remaining to be paid.
  double _remainingAmount = 0;

  /// Arabic: يهيئ الحركة ثم يؤجل تحميل بيانات الحجز حتى يكتمل بناء الواجهة.
  /// English: Initializes the animation and defers booking loading until the first frame is ready.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
    // تأخير تحميل البيانات حتى يكتمل بناء الـ widget tree
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookingData();
    });
  }

  /// Arabic: يقرأ بيانات الحجز من الحالة الحالية ويضبط القيم الافتراضية للنموذج.
  /// English: Reads the booking data from the current state and primes the form defaults.
  void _loadBookingData() {
    if (!mounted) return;

    try {
      final bookingDetailsBloc = context.read<BookingDetailsBloc>();
      // إذا لم تكن البيانات محملة، قم بتحميلها أولاً
      if (bookingDetailsBloc.state is! BookingDetailsLoaded) {
        bookingDetailsBloc
            .add(LoadBookingDetailsEvent(bookingId: widget.bookingId));
        // انتظر قليلاً ثم حاول مرة أخرى
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _loadBookingData();
        });
        return;
      }

      final state = bookingDetailsBloc.state as BookingDetailsLoaded;

      // حساب المبلغ المدفوع - نستخدم كل من bookingDetails.payments و bookingDetails.totalPaid
      final payments = state.bookingDetails?.payments ?? [];
      final paidAmount = state.bookingDetails?.totalPaid.amount ??
          payments
              .where((p) => p.status == PaymentStatus.successful)
              .fold<double>(0.0, (sum, payment) => sum + payment.amount.amount);

      setState(() {
        _booking = state.booking;
        _totalAmount = state.booking.totalPrice.amount;
        _currency = state.booking.totalPrice.currency;
        _paidAmount = paidAmount;
        _remainingAmount = _totalAmount - _paidAmount;

        _amountController.text =
            _remainingAmount > 0 ? _remainingAmount.toStringAsFixed(2) : '0.00';
      });
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading booking data: $e');
      debugPrint('Stack trace: $stackTrace');
      // إذا فشل تحميل البيانات، قم بإغلاق الصفحة
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ في تحميل بيانات الحجز: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  /// Arabic: يحرر المتحكمات النصية والحركية قبل إزالة الصفحة.
  /// English: Disposes text and animation controllers before the page is removed.
  @override
  void dispose() {
    _animationController.dispose();
    _amountController.dispose();
    _transactionIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Arabic: يرسل الدفعة الجديدة بعد التأكد من صحة النموذج.
  /// English: Submits the new payment after validating the form.
  void _submitPayment() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.tryParse(_amountController.text) ?? 0;

      context.read<RegisterPaymentBloc>().add(
            RegisterNewPaymentEvent(
              bookingId: widget.bookingId,
              amount: amount,
              currency: _currency,
              paymentMethod: _selectedPaymentMethod,
              transactionId: _transactionIdController.text.isNotEmpty
                  ? _transactionIdController.text
                  : null,
              notes: _notesController.text.isNotEmpty
                  ? _notesController.text
                  : null,
              paymentDate: _selectedDate,
            ),
          );
    }
  }

  /// Arabic: يعرض رسالة نجاح واضحة مع خيار العودة بعد تسجيل الدفعة.
  /// English: Shows a success dialog with a clear return path after registering the payment.
  void _showSuccessDialog(Payment payment) {
    final navigator = Navigator.of(context);
    BookingDetailsBloc? detailsBloc;
    try {
      detailsBloc = context.read<BookingDetailsBloc>();
    } catch (_) {}

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.success.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.checkmark_circle_fill,
                  color: AppTheme.success,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'تم تسجيل الدفعة بنجاح',
                style: AppTextStyles.heading2.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'المبلغ: ${Formatters.formatCurrency(payment.amount.amount, payment.amount.currency)}',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        try {
                          detailsBloc?.add(const RefreshBookingDetailsEvent());
                        } catch (e) {
                          debugPrint('Error reloading booking details: $e');
                        }
                        navigator.pop();
                        navigator.pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'حسناً',
                        style: AppTextStyles.buttonMedium.copyWith(
                          color: Colors.white,
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
    );
  }

  /// Arabic: يعرض خطأً عابرًا أسفل الشاشة عندما تفشل عملية التسجيل.
  /// English: Shows a transient snackbar error when the registration fails.
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              CupertinoIcons.xmark_circle_fill,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Arabic: يفتح منتقي التاريخ لتعديل تاريخ تسجيل الدفعة.
  /// English: Opens the date picker to adjust the payment date.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              surface: AppTheme.darkCard,
              onSurface: AppTheme.textWhite,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Arabic: يختار الأيقونة الأنسب لتمثيل طريقة الدفع.
  /// English: Selects the icon that best represents the payment method.
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

  /// Arabic: ينشئ الخلفية المتدرجة الخاصة بصفحة التسجيل.
  /// English: Builds the page-specific gradient background.
  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkBackground,
            AppTheme.darkCard.withValues(alpha: 0.5),
            AppTheme.darkBackground,
          ],
        ),
      ),
    );
  }

  /// Arabic: يضيف طبقة حجب أثناء تنفيذ تسجيل الدفعة.
  /// English: Adds a blocking overlay while the payment is being submitted.
  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: AbsorbPointer(
        absorbing: true,
        child: Container(
          color: Colors.black54,
          child: const Center(
            child: LoadingWidget(
              type: LoadingType.futuristic,
              message: 'جاري تسجيل الدفعة...',
            ),
          ),
        ),
      ),
    );
  }

  /// Arabic: يبني الصفحة الكاملة مع نموذج الدفع وملخص الحجز.
  /// English: Builds the full page with the payment form and booking summary.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkCard,
        elevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.arrow_right, color: AppTheme.textWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'تسجيل دفعة جديدة',
          style: AppTextStyles.heading2.copyWith(color: AppTheme.textWhite),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<RegisterPaymentBloc, RegisterPaymentState>(
        listener: (context, state) {
          if (state is RegisterPaymentSuccess) {
            _showSuccessDialog(state.payment);
          } else if (state is RegisterPaymentError) {
            _showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              _buildBackground(),
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_booking != null) _buildBookingInfoCard(),
                      const SizedBox(height: 16),
                      _buildPaymentSummaryCard(),
                      const SizedBox(height: 16),
                      _buildPaymentForm(),
                      const SizedBox(height: 24),
                      _buildActionButtons(state is RegisterPaymentLoading),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
              if (state is RegisterPaymentLoading) _buildLoadingOverlay(),
            ],
          );
        },
      ),
    );
  }

  /// Arabic: يعرض ملخص معلومات الحجز المرتبط بالدفعة.
  /// English: Shows a summary of the booking tied to the payment.
  Widget _buildBookingInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.doc_text_fill, color: AppTheme.primaryBlue),
              const SizedBox(width: 12),
              Text(
                'معلومات الحجز',
                style:
                    AppTextStyles.heading3.copyWith(color: AppTheme.textWhite),
              ),
              const Spacer(),
              BookingStatusBadge(status: _booking!.status),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('الضيف', _booking!.userName),
          _buildInfoRow('الوحدة', _booking!.unitName),
          _buildInfoRow('الوصول', Formatters.formatDate(_booking!.checkIn)),
          _buildInfoRow('المغادرة', Formatters.formatDate(_booking!.checkOut)),
        ],
      ),
    );
  }

  /// Arabic: يلخص المبلغ الإجمالي والمدفوع والمتبقي.
  /// English: Summarizes the total, paid, and remaining amounts.
  Widget _buildPaymentSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.warning.withValues(alpha: 0.15),
            AppTheme.warning.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          _buildAmountRow('المبلغ الإجمالي', _totalAmount, AppTheme.textWhite),
          const SizedBox(height: 8),
          _buildAmountRow('المبلغ المدفوع', _paidAmount, AppTheme.success),
          const Divider(height: 24),
          _buildAmountRow('المبلغ المتبقي', _remainingAmount, AppTheme.warning),
        ],
      ),
    );
  }

  /// Arabic: يبني الحقول التي يحتاجها المستخدم قبل إرسال الدفعة.
  /// English: Builds the fields the user needs before submitting the payment.
  Widget _buildPaymentForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount Field
          Text(
            'المبلغ المدفوع',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: AppTheme.textWhite),
            decoration: InputDecoration(
              prefixIcon:
                  Icon(CupertinoIcons.money_dollar, color: AppTheme.warning),
              suffix:
                  Text(_currency, style: TextStyle(color: AppTheme.warning)),
              filled: true,
              fillColor: AppTheme.darkBackground.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'المبلغ مطلوب';
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) return 'المبلغ غير صحيح';
              if (amount > _remainingAmount) return 'المبلغ يتجاوز المتبقي';
              return null;
            },
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),
          const SizedBox(height: 20),

          // Payment Method
          Text(
            'طريقة الدفع',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.darkBackground.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonFormField<PaymentMethod>(
              initialValue: _selectedPaymentMethod,
              dropdownColor: AppTheme.darkCard,
              style: TextStyle(color: AppTheme.textWhite),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: PaymentMethod.values.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Row(
                    children: [
                      Icon(_getPaymentMethodIcon(method),
                          color: AppTheme.primaryBlue, size: 20),
                      const SizedBox(width: 8),
                      Text(method.displayNameAr),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null)
                  setState(() => _selectedPaymentMethod = value);
              },
            ),
          ),
          const SizedBox(height: 20),

          // Transaction ID
          Text(
            'رقم المعاملة (اختياري)',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _transactionIdController,
            style: TextStyle(color: AppTheme.textWhite),
            decoration: InputDecoration(
              prefixIcon:
                  Icon(CupertinoIcons.number, color: AppTheme.primaryBlue),
              filled: true,
              fillColor: AppTheme.darkBackground.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Date Picker
          Text(
            'تاريخ الدفع',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectDate(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.darkBackground.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(CupertinoIcons.calendar, color: AppTheme.primaryBlue),
                  const SizedBox(width: 12),
                  Text(
                    Formatters.formatDate(_selectedDate),
                    style: TextStyle(color: AppTheme.textWhite),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Arabic: يعرض أزرار الإرسال والإلغاء بحسب حالة التحميل.
  /// English: Shows the submit and cancel actions according to the loading state.
  Widget _buildActionButtons(bool isLoading) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : _submitPayment,
            icon: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(
                    CupertinoIcons.checkmark_circle_fill,
                    color: Colors.white,
                  ),
            label: Text(
              isLoading ? 'جاري التسجيل...' : 'تسجيل الدفعة',
              style: AppTextStyles.buttonMedium.copyWith(
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warning,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'إلغاء',
            style: TextStyle(color: AppTheme.textMuted),
          ),
        ),
      ],
    );
  }

  /// Arabic: يعرض سطرًا بسيطًا لعنصر معلومات واحد.
  /// English: Renders a simple row for one information item.
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: AppTheme.textMuted)),
          const Spacer(),
          Text(value, style: TextStyle(color: AppTheme.textWhite)),
        ],
      ),
    );
  }

  /// Arabic: يعرض سطر مبلغ بتنسيق مرئي يبرز القيمة المالية.
  /// English: Renders a formatted amount row that emphasizes the monetary value.
  Widget _buildAmountRow(String label, double amount, Color color) {
    return Row(
      children: [
        Text(label, style: TextStyle(color: AppTheme.textMuted)),
        const Spacer(),
        Text(
          Formatters.formatCurrency(amount, _currency),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
