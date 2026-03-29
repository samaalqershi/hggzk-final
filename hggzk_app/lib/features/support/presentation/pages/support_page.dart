import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hggzk/app/dependency_injection/injection_container.dart';
import 'package:hggzk/core/theme/app_theme.dart';
import 'package:hggzk/core/localization/app_localizations.dart';
import 'package:hggzk/features/support/presentation/cubit/support_cubit.dart';
import 'package:hggzk/features/support/presentation/cubit/support_state.dart';
import 'package:url_launcher/url_launcher.dart';

/// Support screen that combines a contact form, helpful escalation channels,
/// and device-aware submission feedback.
///
/// شاشة الدعم التي تجمع بين نموذج التواصل وقنوات التصعيد المفيدة وتغذية
/// راجعة تراعي بيانات الجهاز.
class SupportPage extends StatefulWidget {
  /// Creates the entry page for the support workflow.
  ///
  /// ينشئ صفحة الدخول لمسار الدعم.
  const SupportPage({super.key});

  /// Creates the animation-driven state for the support form.
  ///
  /// ينشئ الحالة المعتمدة على الحركة لنموذج الدعم.
  @override
  State<SupportPage> createState() => _SupportPageState();
}

/// Owns the support form controls, the decorative background motion, and the
/// success/error feedback shown after submission.
///
/// يدير متحكمات النموذج وحركة الخلفية الزخرفية ورسائل النجاح أو الخطأ بعد
/// الإرسال.
class _SupportPageState extends State<SupportPage>
    with SingleTickerProviderStateMixin {
  static const List<String> _clientSupportNumbers = <String>[
    '785050951',
    '785050952',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  /// Drives the background motion and the first entrance of the page content.
  ///
  /// يدير حركة الخلفية والدخول الأول لعناصر الصفحة.
  late AnimationController _animationController;

  /// Fades the content from transparent to fully visible.
  ///
  /// يحول المحتوى من الشفافية إلى الظهور الكامل.
  late Animation<double> _fadeAnimation;

  /// Adds a gentle upward offset to the content as it appears.
  ///
  /// يضيف إزاحة صاعدة خفيفة أثناء الظهور.
  late Animation<double> _slideAnimation;

  /// Prepares the motion timeline before the page is first rendered.
  ///
  /// يجهز الخط الزمني للحركة قبل أول عرض للصفحة.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  /// Releases every controller used by the support screen.
  ///
  /// يحرر كل متحكمات شاشة الدعم.
  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  /// Builds the support experience with validation, device-aware metadata, and
  /// clear post-submit feedback.
  ///
  /// يبني تجربة الدعم مع التحقق وبيانات الجهاز وتغذية راجعة واضحة بعد الإرسال.
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return BlocProvider(
      create: (context) => sl<SupportCubit>(),
      child: BlocConsumer<SupportCubit, SupportState>(
        listener: (context, state) {
          if (state is SupportSuccess) {
            _showSuccessDialog(context, localizations, state.referenceNumber);
            _clearForm();
          } else if (state is SupportError) {
            _showErrorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppTheme.darkBackground,
            body: Stack(
              children: [
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _SupportBackgroundPainter(
                        animationValue: _animationController.value,
                      ),
                      size: Size.infinite,
                    );
                  },
                ),
                CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      pinned: true,
                      expandedHeight: 120,
                      leading: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.darkCard.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.primaryBlue.withOpacity(0.3),
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: AppTheme.textWhite,
                            size: 18,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        title: Text(
                          context.tr('support.title'),
                          style: TextStyle(
                            color: AppTheme.textWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        background: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppTheme.primaryBlue.withOpacity(0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: Transform.translate(
                              offset: Offset(0, _slideAnimation.value),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildHeaderCard(localizations),
                                    const SizedBox(height: 24),
                                    _buildContactFormCard(
                                        context, state, localizations),
                                    const SizedBox(height: 24),
                                    _buildContactInfoCard(localizations),
                                    const SizedBox(height: 40),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds the intro card that explains where users should go when they need
  /// help.
  ///
  /// يبني بطاقة المقدمة التي تشرح للمستخدم إلى أين يتجه عندما يحتاج إلى
  /// المساعدة.
  Widget _buildHeaderCard(AppLocalizations? localizations) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryBlue.withOpacity(0.15),
                AppTheme.darkCard.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryBlue.withOpacity(0.3),
                      AppTheme.primaryBlue.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.support_agent,
                  color: AppTheme.primaryBlue,
                  size: 40,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('support.need_help'),
                      style: TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('support.support_description'),
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the form card that collects the user's issue and the context
  /// support needs to respond.
  ///
  /// يبني بطاقة النموذج التي تجمع مشكلة المستخدم والسياق الذي يحتاجه فريق
  /// الدعم للرد.
  Widget _buildContactFormCard(BuildContext context, SupportState state,
      AppLocalizations? localizations) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.darkCard.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.mail_outline,
                        color: AppTheme.primaryBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      context.tr('support.send_message'),
                      style: TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _nameController,
                  label: context.tr('support.your_name'),
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return localizations?.get('support.name_required') ??
                          'Name is required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: context.tr('support.contact.email'),
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return localizations?.get('support.email_required') ??
                          'Email is required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _subjectController,
                  label: context.tr('support.subject'),
                  icon: Icons.subject,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return localizations?.get('support.subject_required') ??
                          'Subject is required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _messageController,
                  label: context.tr('support.your_message'),
                  icon: Icons.message_outlined,
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return localizations?.get('support.message_required') ??
                          'Message is required';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: state is SupportLoading
                        ? null
                        : () => _submitForm(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryBlue,
                            AppTheme.primaryPurple
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: state is SupportLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send, color: AppTheme.textWhite),
                                  const SizedBox(width: 8),
                                  Text(
                                    context.tr('support.send'),
                                    style: TextStyle(
                                      color: AppTheme.textWhite,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
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

  /// Builds a themed text field with the app's support styling and validation
  /// hooks.
  ///
  /// يبني حقلاً منسقًا يتماشى مع هوية التطبيق البصرية ويستقبل التحقق من
  /// الإدخال.
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(color: AppTheme.textWhite),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppTheme.textMuted),
        prefixIcon: maxLines == 1
            ? Icon(icon, color: AppTheme.primaryBlue.withOpacity(0.7))
            : null,
        filled: true,
        fillColor: AppTheme.darkSurface.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.darkBorder.withOpacity(0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  /// Builds the escalation card that shows email, phone, WhatsApp, and
  /// operating hours.
  ///
  /// يبني بطاقة التصعيد التي تعرض البريد والهاتف وWhatsApp وساعات العمل.
  Widget _buildContactInfoCard(AppLocalizations? localizations) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.darkCard.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.contact_support_outlined,
                      color: AppTheme.primaryPurple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    localizations?.get('support.contact_info') ??
                        'Contact Information',
                    style: TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildContactItem(
                icon: Icons.email_outlined,
                title: context.tr('support.contact.email'),
                value: 'support@hggzk.com',
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(height: 16),
              ..._clientSupportNumbers.expand((number) => <Widget>[
                    _buildContactItem(
                      icon: Icons.call_outlined,
                      title: context.tr('support.client_direct_call'),
                      value: _formatPhoneForDisplay(number),
                      color: AppTheme.primaryPurple,
                      onTap: () => _launchDirectCall(number),
                    ),
                    const SizedBox(height: 12),
                    _buildContactItem(
                      icon: Icons.chat_rounded,
                      title: context.tr('support.client_whatsapp'),
                      value: _formatPhoneForDisplay(number),
                      color: const Color(0xFF25D366),
                      onTap: () => _launchWhatsApp(number),
                    ),
                    const SizedBox(height: 16),
                  ]),
              const SizedBox(height: 16),
              _buildContactItem(
                icon: Icons.access_time,
                title: context.tr('support.working_hours'),
                value: context.tr('support.working_hours_value'),
                color: AppTheme.neonGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds one contact row and optionally makes it tappable for direct
  /// actions.
  ///
  /// يبني صف اتصال واحدًا ويمكن أن يجعله قابلًا للنقر لتنفيذ إجراء مباشر.
  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    final child = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return child;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: child,
      ),
    );
  }

  /// Launches the phone dialer with a Yemen-friendly international number.
  ///
  /// يفتح تطبيق الاتصال باستخدام رقم دولي مناسب لليمن.
  Future<void> _launchDirectCall(String phoneNumber) async {
    final intlNumber = _toInternationalYemenNumber(phoneNumber);
    await _launchExternalLink(Uri.parse('tel:+$intlNumber'));
  }

  /// Opens WhatsApp with the same phone number so the user can continue the
  /// conversation in chat.
  ///
  /// يفتح WhatsApp بنفس الرقم حتى يستطيع المستخدم متابعة التواصل في الدردشة.
  Future<void> _launchWhatsApp(String phoneNumber) async {
    final intlNumber = _toInternationalYemenNumber(phoneNumber);
    await _launchExternalLink(Uri.parse('https://wa.me/$intlNumber'));
  }

  /// Sends the user to an external app and falls back to an error message if
  /// the device cannot open it.
  ///
  /// يرسل المستخدم إلى تطبيق خارجي ويعرض رسالة خطأ إذا تعذر فتحه.
  Future<void> _launchExternalLink(Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      _showErrorSnackBar(
        context,
        context.tr('support.link_open_failed'),
      );
    }
  }

  /// Normalizes a local Yemeni number into the international format required
  /// by phone and WhatsApp links.
  ///
  /// يطبع رقمًا محليًا يمنيًا إلى الصيغة الدولية المطلوبة لروابط الاتصال
  /// وWhatsApp.
  String _toInternationalYemenNumber(String phoneNumber) {
    final normalized = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalized.startsWith('967')) {
      return normalized;
    }
    if (normalized.startsWith('0') && normalized.length > 1) {
      return '967${normalized.substring(1)}';
    }
    return '967$normalized';
  }

  /// Formats a phone number for readable display inside the contact card.
  ///
  /// ينسق رقم الهاتف ليظهر بشكل مقروء داخل بطاقة التواصل.
  String _formatPhoneForDisplay(String phoneNumber) {
    final normalized = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalized.length == 9) {
      return '+967 ${normalized.substring(0, 3)} ${normalized.substring(3, 6)} ${normalized.substring(6)}';
    }
    return '+$normalized';
  }

  /// Validates the form and forwards the message to the cubit for submission.
  ///
  /// يتحقق من صحة النموذج ثم يمرر الرسالة إلى الـ cubit لإرسالها.
  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<SupportCubit>().sendSupportMessage(
            userName: _nameController.text,
            userEmail: _emailController.text,
            subject: _subjectController.text,
            message: _messageController.text,
          );
    }
  }

  /// Clears the text controllers after a successful submission.
  ///
  /// يمسح متحكمات النص بعد نجاح الإرسال.
  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _subjectController.clear();
    _messageController.clear();
  }

  /// Shows the confirmation dialog and surfaces the tracking number so the
  /// user can reference the request later.
  ///
  /// يعرض نافذة التأكيد ويظهر رقم التتبع حتى يستطيع المستخدم الرجوع إلى
  /// الطلب لاحقًا.
  void _showSuccessDialog(BuildContext context, AppLocalizations? localizations,
      String referenceNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.darkCard.withOpacity(0.95),
                    AppTheme.darkSurface.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.neonGreen.withOpacity(0.2),
                          AppTheme.neonGreen.withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppTheme.neonGreen.withOpacity(0.3)),
                    ),
                    child: Icon(
                      Icons.check_circle_outline,
                      color: AppTheme.neonGreen,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    localizations?.get('support.message_sent') ??
                        'Message Sent!',
                    style: TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppTheme.primaryBlue.withOpacity(0.3)),
                    ),
                    child: Text(
                      '${localizations?.get('support.reference') ?? 'Reference'}: $referenceNumber',
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations?.get('support.support_success_message') ??
                        'Thank you for contacting us.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryBlue,
                              AppTheme.primaryPurple
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            localizations?.get('common.ok') ?? 'OK',
                            style: TextStyle(
                              color: AppTheme.textWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Surfaces submission failures in a compact toast-style message.
  ///
  /// يعرض فشل الإرسال في رسالة صغيرة من نوع snackbar.
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

/// Paints the soft motion backdrop behind the support form so the page feels
/// alive without distracting from the fields.
///
/// يرسم الخلفية الحركية الناعمة خلف نموذج الدعم حتى تبدو الصفحة حية من دون
/// أن تشتت الانتباه عن الحقول.
class _SupportBackgroundPainter extends CustomPainter {
  /// Normalized animation progress used to shift the glow positions.
  ///
  /// تقدّم الحركة المطبّع المستخدم لتحريك مواقع التوهج.
  final double animationValue;

  /// Creates the painter with the current animation progress.
  ///
  /// ينشئ الـ painter بقيمة التقدم الحالية للحركة.
  _SupportBackgroundPainter({required this.animationValue});

  /// Draws the blurred glow circles that give the support page its animated
  /// atmosphere.
  ///
  /// يرسم دوائر التوهج الضبابية التي تمنح صفحة الدعم جوها المتحرك.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);

    paint.color = AppTheme.primaryBlue.withOpacity(0.08);
    canvas.drawCircle(
      Offset(
        size.width * 0.8 + math.sin(animationValue * math.pi * 2) * 20,
        size.height * 0.2 + math.cos(animationValue * math.pi * 2) * 20,
      ),
      size.width * 0.4,
      paint,
    );

    paint.color = AppTheme.primaryPurple.withOpacity(0.06);
    canvas.drawCircle(
      Offset(
        size.width * 0.2 + math.cos(animationValue * math.pi * 2) * 15,
        size.height * 0.7 + math.sin(animationValue * math.pi * 2) * 15,
      ),
      size.width * 0.35,
      paint,
    );

    paint.color = AppTheme.neonBlue.withOpacity(0.04);
    canvas.drawCircle(
      Offset(
        size.width * 0.5,
        size.height * 0.5 + math.sin(animationValue * math.pi) * 30,
      ),
      size.width * 0.3,
      paint,
    );
  }

  /// Repaints whenever the animation progress changes so the background motion
  /// stays in sync.
  ///
  /// يعيد الرسم كلما تغيرت قيمة الحركة حتى تبقى الخلفية متزامنة معها.
  @override
  bool shouldRepaint(covariant _SupportBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
