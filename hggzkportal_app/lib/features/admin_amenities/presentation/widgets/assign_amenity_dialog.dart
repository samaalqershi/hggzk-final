import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/amenity.dart';

/// حوار إسناد المرفق إلى عقار مع التوفر والتكلفة والملاحظات.
/// Full-screen amenity assignment dialog with availability, cost, and notes controls.
class AssignAmenityDialog extends StatefulWidget {
  /// المرفق الذي سيُربط بالعقار.
  /// Amenity that will be linked to a property.
  final Amenity amenity;

  /// معرف العقار الذي يُفضل تحديده عند فتح الحوار.
  /// Property ID that should be preselected when the dialog opens.
  final String? preSelectedPropertyId;

  /// دالة تنفيذ الإسناد الفعلية التي تحفظ الربط بين الكيانين.
  /// Callback that performs the actual assignment between the two entities.
  final Function({
    required String amenityId,
    required String propertyId,
    required bool isAvailable,
    double? extraCost,
    String? description,
  })? onAssign;

  /// يستدعى بعد النجاح لتحديث الحالة أو الواجهة المحيطة.
  /// Called after success to refresh the surrounding UI or state.
  final VoidCallback? onSuccess;

  /// يستدعى عند الفشل لتمرير رسالة الخطأ إلى الطبقة الأعلى.
  /// Called on failure so the error message can be forwarded upward.
  final Function(String message)? onError;

  /// ينشئ الحوار مع القيم والردود الممررة من الطبقة المستدعية.
  /// Creates the dialog with the values and callbacks supplied by the caller.
  const AssignAmenityDialog({
    super.key,
    required this.amenity,
    this.preSelectedPropertyId,
    this.onAssign,
    this.onSuccess,
    this.onError,
  });

  /// يفتح الحوار كنافذة كاملة الشاشة وغير قابلة للإغلاق بالنقر الخارجي.
  /// Opens the dialog as a fullscreen modal that cannot be dismissed by outside taps.
  static Future<void> show({
    required BuildContext context,
    required Amenity amenity,
    String? preSelectedPropertyId,
    required Function({
      required String amenityId,
      required String propertyId,
      required bool isAvailable,
      double? extraCost,
      String? description,
    }) onAssign,
    VoidCallback? onSuccess,
    Function(String message)? onError,
  }) {
    return showDialog(
      fullscreenDialog: true,
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (dialogContext) => AssignAmenityDialog(
        amenity: amenity,
        preSelectedPropertyId: preSelectedPropertyId,
        onAssign: onAssign,
        onSuccess: onSuccess,
        onError: onError,
      ),
    );
  }

  /// ينشئ الحالة المسؤولة عن الحركة والتحقق وتنفيذ الإسناد.
  /// Creates the state that manages motion, validation, and assignment flow.
  @override
  State<AssignAmenityDialog> createState() => _AssignAmenityDialogState();
}

/// تدير هذه الحالة الرسوم المتحركة، النموذج، ومسار الإسناد نفسه.
/// Manages the animations, form inputs, and the assignment workflow.
class _AssignAmenityDialogState extends State<AssignAmenityDialog>
    with TickerProviderStateMixin {
  /// متحكم التكبير التدريجي للحوار عند الظهور.
  /// Controls the dialog scale-in animation.
  late AnimationController _scaleController;

  /// متحكم التلاشي العام للحوار.
  /// Controls the dialog fade-in effect.
  late AnimationController _fadeController;

  /// متحكم انزلاق المحتوى من الأسفل إلى موضعه.
  /// Controls the content slide motion into place.
  late AnimationController _slideController;

  /// متحكم اللمعان المتكرر في الخلفية.
  /// Controls the repeating shimmer in the background.
  late AnimationController _shimmerController;

  /// متحكم النبض البصري للعناصر العلوية.
  /// Controls the subtle pulsing visual accents.
  late AnimationController _pulseController;

  /// قيمة التكبير الخاصة بدخول الحوار.
  /// Scale value used when the dialog enters.
  late Animation<double> _scaleAnimation;

  /// قيمة التلاشي الخاصة بظهور الحوار.
  /// Fade value used when the dialog appears.
  late Animation<double> _fadeAnimation;

  /// إزاحة الحركة المستخدمة لتحريك محتوى النموذج.
  /// Slide offset used to move the form content.
  late Animation<Offset> _slideAnimation;

  /// قيمة اللمعان المتكرر المستخدمة في الخلفية.
  /// Repeating shimmer value used across the background.
  late Animation<double> _shimmerAnimation;

  /// قيمة النبض البصري المستخدمة للأيقونة والزخارف.
  /// Pulse value used for the icon and decorative accents.
  late Animation<double> _pulseAnimation;

  /// مفتاح النموذج المستخدم للتحقق من صحة الحقول.
  /// Form key used to validate the input fields.
  final _formKey = GlobalKey<FormState>();

  /// يتحكم في حقل التكلفة الإضافية.
  /// Controls the extra-cost text field.
  final _costController = TextEditingController();

  /// يتحكم في حقل الملاحظات أو الوصف الإضافي.
  /// Controls the notes or extra description field.
  final _descriptionController = TextEditingController();

  /// معرف العقار المحدد حاليًا.
  /// ID of the currently selected property.
  String? _selectedPropertyId;

  /// اسم العقار المحدد لعرضه للمستخدم.
  /// Display name of the selected property.
  String? _selectedPropertyName;

  /// يحدد ما إذا كان المرفق سيبقى متاحًا بعد الإسناد.
  /// Indicates whether the amenity remains available after assignment.
  bool _isAvailable = true;

  /// يحدد ما إذا كان الإسناد قيد المعالجة الآن.
  /// Indicates whether the assignment is currently being processed.
  bool _isLoading = false;

  /// يحدد عرض أو إخفاء الخيارات المتقدمة.
  /// Toggles whether the advanced options are visible.
  bool _showAdvancedOptions = false;

  /// يهيئ الحركة والبيانات الافتراضية عند إنشاء الحالة.
  /// Initializes animations and defaults when the state is created.
  @override
  void initState() {
    super.initState();

    _initializeAnimations();

    _initializeData();
  }

  /// يجهز جميع الرسوم المتحركة المستخدمة داخل الحوار.
  /// Sets up all animations used inside the dialog.
  void _initializeAnimations() {
    // Scale Animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));

    // Fade Animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // Slide Animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Shimmer Animation
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(
      begin: -1,
      end: 2,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));

    // Pulse Animation
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _scaleController.forward();
    _fadeController.forward();
    _slideController.forward();
  }

  /// يملأ القيم الأولية مثل العقار المحدد والتكلفة الافتراضية.
  /// Populates initial values such as the selected property and default cost.
  void _initializeData() {
    _selectedPropertyId = widget.preSelectedPropertyId;
    // Set default cost if amenity has average cost
    if (widget.amenity.averageExtraCost != null &&
        widget.amenity.averageExtraCost! > 0) {
      _costController.text =
          widget.amenity.averageExtraCost!.toStringAsFixed(0);
    }
  }

  /// يحرر المتحكمات لتجنب التسريبات عند إغلاق الحوار.
  /// Disposes controllers to avoid leaks when the dialog is closed.
  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _costController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// يبني الحوار الكامل مع الخلفية والنموذج وأزرار الإجراءات.
  /// Builds the full dialog with the background, form, and action buttons.
  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: Container(
            width: 520,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.darkBackground,
                  AppTheme.darkBackground2.withValues(alpha: 0.8),
                  AppTheme.darkBackground3.withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(24), // زوايا حادة هادئة
              border: Border.all(
                color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                  blurRadius: 40,
                  spreadRadius: 10,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Stack(
                  children: [
                    // Background Pattern
                    _buildBackgroundPattern(),

                    // Main Content
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _buildHeader(),
                          _buildContent(),
                          _buildFooter(),
                        ],
                      ),
                    ),

                    // Loading Overlay
                    if (_isLoading) _buildLoadingOverlay(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// يرسم النمط الزخرفي المتحرك في الخلفية.
  /// Draws the animated decorative pattern in the background.
  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: _DialogPatternPainter(
              animation: _shimmerAnimation.value,
              color: AppTheme.primaryPurple.withValues(alpha: 0.03),
            ),
          );
        },
      ),
    );
  }

  /// يبني رأس الحوار الذي يوضح المهمة والمرفق الحالي.
  /// Builds the dialog header that presents the action and current amenity.
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkSurface.withValues(alpha: 0.8),
            AppTheme.darkSurface.withValues(alpha: 0.4),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryPurple.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Animated Icon
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryPurple,
                        AppTheme.primaryBlue,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryPurple.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.link_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 16),

          // Title Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      AppTheme.primaryPurple,
                      AppTheme.primaryBlue,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'إسناد المرفق للعقار',
                    style: AppTextStyles.heading2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            _getAmenityIcon(widget.amenity.icon),
                            size: 14,
                            color: AppTheme.primaryPurple,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.amenity.name,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppTheme.primaryPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (_normalizedSecondary(
                                      widget.amenity.nameEn,
                                      widget.amenity.name,
                                    ) !=
                                    null)
                                  Text(
                                    _normalizedSecondary(
                                      widget.amenity.nameEn,
                                      widget.amenity.name,
                                    )!,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppTheme.primaryPurple
                                          .withValues(alpha: 0.8),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Close Button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.darkSurface.withValues(alpha: 0.5),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.darkBorder.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.close_rounded,
                color: AppTheme.textMuted,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// يبني المحتوى الرئيسي الذي يحتوي على الحقول وخيارات الإسناد.
  /// Builds the main content area containing the fields and assignment options.
  Widget _buildContent() {
    return SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Property Selection
              _buildPropertySelection(),

              const SizedBox(height: 20),

              // Availability Toggle
              _buildAvailabilityToggle(),

              const SizedBox(height: 20),

              // Advanced Options Toggle
              _buildAdvancedOptionsToggle(),

              // Advanced Options Content
              if (_showAdvancedOptions) ...[
                const SizedBox(height: 20),
                _buildCostField(),
                const SizedBox(height: 20),
                _buildDescriptionField(),
              ],

              const SizedBox(height: 20),

              // Info Card
              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  /// يبني عنصر اختيار العقار ويعرض الهوية المختصرة للعقار بعد تحديده.
  /// Builds the property selector and shows a compact identity summary once a property is selected.
  Widget _buildPropertySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withValues(alpha: 0.2),
                    AppTheme.primaryBlue.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.business_rounded,
                size: 16,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'اختر العقار',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'مطلوب',
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _selectProperty,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _selectedPropertyId != null
                    ? [
                        AppTheme.primaryBlue.withValues(alpha: 0.1),
                        AppTheme.primaryBlue.withValues(alpha: 0.05),
                      ]
                    : [
                        AppTheme.darkSurface.withValues(alpha: 0.5),
                        AppTheme.darkSurface.withValues(alpha: 0.3),
                      ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _selectedPropertyId != null
                    ? AppTheme.primaryBlue.withValues(alpha: 0.3)
                    : AppTheme.darkBorder.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: _selectedPropertyId != null
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                if (_selectedPropertyId != null) ...[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryBlue.withValues(alpha: 0.2),
                          AppTheme.primaryBlue.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedPropertyName ?? 'عقار محدد',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppTheme.textWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ID: ${_selectedPropertyId?.substring(0, 8).toUpperCase()}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppTheme.primaryBlue,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.darkSurface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppTheme.darkBorder.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.add_business_rounded,
                      color: AppTheme.textMuted,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'اضغط لاختيار عقار',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'حدد العقار المراد إسناد المرفق إليه',
                          style: AppTextStyles.caption.copyWith(
                            color: AppTheme.textMuted.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: _selectedPropertyId != null
                      ? AppTheme.primaryBlue
                      : AppTheme.textMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// يبني مفتاح التوفر الذي يحدد قابلية استخدام المرفق بعد الإسناد.
  /// Builds the availability toggle that defines whether the amenity remains usable after assignment.
  Widget _buildAvailabilityToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkSurface.withValues(alpha: 0.4),
            AppTheme.darkSurface.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isAvailable
                    ? [
                        AppTheme.success.withValues(alpha: 0.2),
                        AppTheme.neonGreen.withValues(alpha: 0.1),
                      ]
                    : [
                        AppTheme.textMuted.withValues(alpha: 0.2),
                        AppTheme.textMuted.withValues(alpha: 0.1),
                      ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _isAvailable ? Icons.check_circle_rounded : Icons.cancel_rounded,
              size: 16,
              color: _isAvailable ? AppTheme.success : AppTheme.textMuted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حالة التوفر',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isAvailable ? 'المرفق متاح للحجز' : 'المرفق غير متاح حالياً',
                  style: AppTextStyles.caption.copyWith(
                    color: _isAvailable ? AppTheme.success : AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: _isAvailable,
              onChanged: (value) {
                HapticFeedback.lightImpact();
                setState(() => _isAvailable = value);
              },
              activeThumbColor: AppTheme.success,
              activeTrackColor: AppTheme.success.withValues(alpha: 0.3),
              inactiveThumbColor: AppTheme.textMuted,
              inactiveTrackColor: AppTheme.textMuted.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  /// يبني عنصر توسيع الخيارات المتقدمة مثل التكلفة والملاحظات.
  /// Builds the control that expands advanced options such as cost and notes.
  Widget _buildAdvancedOptionsToggle() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _showAdvancedOptions = !_showAdvancedOptions);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryPurple.withValues(alpha: 0.05),
              AppTheme.primaryBlue.withValues(alpha: 0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.primaryPurple.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.settings_rounded,
              size: 18,
              color: AppTheme.primaryPurple,
            ),
            const SizedBox(width: 8),
            Text(
              'خيارات متقدمة',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.primaryPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            AnimatedRotation(
              turns: _showAdvancedOptions ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.expand_more_rounded,
                size: 20,
                color: AppTheme.primaryPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// يبني حقل التكلفة الإضافية الاختياري الخاص بإسناد المرفق للعقار.
  /// Builds the optional extra-cost field for assigning the amenity to the property.
  Widget _buildCostField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.success.withValues(alpha: 0.2),
                    AppTheme.neonGreen.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.attach_money_rounded,
                size: 16,
                color: AppTheme.success,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'التكلفة الإضافية',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppTheme.textMuted.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'اختياري',
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _costController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
          ),
          decoration: InputDecoration(
            hintText: 'أدخل التكلفة الإضافية (بالدولار)',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted.withValues(alpha: 0.5),
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              child: Text(
                '\$',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppTheme.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            filled: true,
            fillColor: AppTheme.darkSurface.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.darkBorder.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.darkBorder.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.success.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.error.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final cost = double.tryParse(value);
              if (cost == null || cost < 0) {
                return 'الرجاء إدخال قيمة صحيحة';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  /// يبني حقل الملاحظات الإضافية لتخزين أي وصف خاص بعملية الإسناد.
  /// Builds the additional notes field used to store assignment-specific details.
  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withValues(alpha: 0.2),
                    AppTheme.primaryBlue.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.description_rounded,
                size: 16,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'ملاحظات إضافية',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
          ),
          decoration: InputDecoration(
            hintText: 'أضف أي ملاحظات أو تفاصيل خاصة بهذا المرفق...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: AppTheme.darkSurface.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.darkBorder.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.darkBorder.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.primaryBlue.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// يبني بطاقة معلومات سريعة تذكّر المستخدم بوصف المرفق الجاري إسناده.
  /// Builds a quick info card that reminds the user of the amenity being assigned.
  Widget _buildInfoCard() {
    final secondaryDescription = _normalizedSecondary(
      widget.amenity.descriptionEn,
      widget.amenity.description,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withValues(alpha: 0.05),
            AppTheme.primaryPurple.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withValues(alpha: 0.2),
                  AppTheme.primaryBlue.withValues(alpha: 0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline_rounded,
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
                  'معلومات المرفق',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.amenity.description,
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (secondaryDescription != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      secondaryDescription,
                      style: AppTextStyles.caption.copyWith(
                        color: AppTheme.textMuted.withValues(alpha: 0.78),
                      ),
                      maxLines: 2,
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

  String? _normalizedSecondary(String? secondary, String primary) {
    final normalized = secondary?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    if (normalized == primary.trim()) {
      return null;
    }

    return normalized;
  }

  /// يبني تذييل الحوار مع أزرار الإلغاء والتنفيذ وحالة التحميل المرتبطة بهما.
  /// Builds the dialog footer with cancel/confirm actions and their loading-aware state.
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkSurface.withValues(alpha: 0.6),
            AppTheme.darkSurface.withValues(alpha: 0.3),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: AppTheme.primaryPurple.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Cancel Button
          Expanded(
            child: GestureDetector(
              onTap: _isLoading
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.darkBorder.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    'إلغاء',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Assign Button
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _isLoading ? null : _handleAssign,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isLoading
                        ? [
                            AppTheme.textMuted.withValues(alpha: 0.3),
                            AppTheme.textMuted.withValues(alpha: 0.2),
                          ]
                        : [
                            AppTheme.primaryPurple,
                            AppTheme.primaryBlue,
                          ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !_isLoading
                      ? [
                          BoxShadow(
                            color:
                                AppTheme.primaryPurple.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isLoading) ...[
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.textWhite.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ] else ...[
                        const Icon(
                          Icons.link_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        _isLoading ? 'جاري الإسناد...' : 'إسناد المرفق',
                        style: AppTextStyles.buttonMedium.copyWith(
                          color: Colors.white,
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
    );
  }

  /// يبني طبقة حجب بصرية تمنع التفاعل أثناء تنفيذ الإسناد.
  /// Builds a visual blocking overlay that prevents interaction while assignment runs.
  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.darkCard.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryPurple,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'جاري إسناد المرفق...',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.bold,
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

  /// يفتح مساعد اختيار العقار ثم يحدّث العقار المختار عند عودة النتيجة.
  /// Opens the property-selection helper and updates the chosen property when the result returns.
  void _selectProperty() {
    HapticFeedback.lightImpact();
    context.push(
      '/helpers/search/properties',
      extra: {
        'allowMultiSelect': false,
        'onPropertySelected': (property) {
          setState(() {
            _selectedPropertyId = property.id;
            _selectedPropertyName = property.name;
          });
        },
      },
    );
  }

  /// يتحقق من الحقول ثم ينفذ إسناد المرفق باستخدام المدخلات الحالية.
  /// Validates the form and performs the amenity assignment using the current inputs.
  Future<void> _handleAssign() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedPropertyId == null) {
        _showError('الرجاء اختيار عقار');
        return;
      }

      setState(() => _isLoading = true);

      try {
        final cost = _costController.text.isNotEmpty
            ? double.tryParse(_costController.text)
            : null;

        // Call the callback function
        await widget.onAssign?.call(
          amenityId: widget.amenity.id,
          propertyId: _selectedPropertyId!,
          isAvailable: _isAvailable,
          extraCost: cost,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
        );

        // Simulate delay for better UX
        await Future.delayed(const Duration(milliseconds: 500));

        _handleSuccess();
      } catch (e) {
        _handleError(e.toString());
      }
    }
  }

  /// يعالج نجاح الإسناد بإغلاق الحوار وإظهار رسالة نجاح مناسبة.
  /// Handles successful assignment by closing the dialog and showing a fitting success message.
  void _handleSuccess() {
    HapticFeedback.heavyImpact();
    widget.onSuccess?.call();
    Navigator.pop(context);

    // Show success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: AppTheme.success,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'تم إسناد المرفق بنجاح',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.darkCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppTheme.success.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// يعالج الفشل بإيقاف التحميل وتمرير الرسالة وعرضها للمستخدم.
  /// Handles failure by stopping loading, forwarding the message, and surfacing it to the user.
  void _handleError(String message) {
    setState(() => _isLoading = false);
    widget.onError?.call(message);
    _showError(message);
  }

  /// يعرض رسالة خطأ عائمة متوافقة مع هوية الحوار البصرية.
  /// Displays a floating error message consistent with the dialog's visual language.
  void _showError(String message) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: AppTheme.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
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
        backgroundColor: AppTheme.darkCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppTheme.error.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// يحول اسم الأيقونة المخزن إلى رمز مرئي مناسب لعرض المرفق.
  /// Maps the stored icon name to the visual icon used to represent the amenity.
  IconData _getAmenityIcon(String iconName) {
    final iconMap = {
      'wifi': Icons.wifi_rounded,
      'parking': Icons.local_parking_rounded,
      'pool': Icons.pool_rounded,
      'gym': Icons.fitness_center_rounded,
      'restaurant': Icons.restaurant_rounded,
      'spa': Icons.spa_rounded,
      'laundry': Icons.local_laundry_service_rounded,
      'ac': Icons.ac_unit_rounded,
      'tv': Icons.tv_rounded,
      'kitchen': Icons.kitchen_rounded,
      'elevator': Icons.elevator_rounded,
      'safe': Icons.lock_rounded,
    };

    return iconMap[iconName] ?? Icons.star_rounded;
  }
}

/// يرسم شبكة زخرفية متحركة وخطوط زوايا خفيفة في خلفية الحوار.
/// Paints an animated grid with subtle corner lines in the dialog background.
class _DialogPatternPainter extends CustomPainter {
  /// قيمة الحركة التي تزحزح النمط الزخرفي مع الزمن.
  /// Animation progress used to shift the decorative pattern over time.
  final double animation;

  /// اللون الأساسي المستخدم لرسم الخطوط والزخارف.
  /// Base color used to draw the lines and accents.
  final Color color;

  /// ينشئ الرسام بالقيمة اللونية والحركية المطلوبة للخلفية.
  /// Creates the painter with the color and animation values required by the background.
  _DialogPatternPainter({
    required this.animation,
    required this.color,
  });

  /// يرسم الشبكة المائلة وزخارف الزوايا التي تعطي الحوار عمقه البصري.
  /// Paints the angled grid and corner accents that give the dialog visual depth.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Draw animated grid pattern
    const spacing = 40.0;
    final offset = animation * spacing;

    for (double x = -spacing + offset; x < size.width + spacing; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x - 20, size.height),
        paint,
      );
    }

    for (double y = -spacing + offset;
        y < size.height + spacing;
        y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y - 20),
        paint,
      );
    }

    // Draw corner decorations
    paint.strokeWidth = 1.5;
    paint.color = color.withValues(alpha: 0.5);

    // Top-left corner
    canvas.drawArc(
      const Rect.fromLTWH(0, 0, 60, 60),
      math.pi,
      math.pi / 2,
      false,
      paint,
    );

    // Bottom-right corner
    canvas.drawArc(
      Rect.fromLTWH(size.width - 60, size.height - 60, 60, 60),
      0,
      math.pi / 2,
      false,
      paint,
    );
  }

  /// يعيد الرسم باستمرار لأن النمط يعتمد على حركة متغيرة بين الإطارات.
  /// Repaints continuously because the pattern depends on animation values that change across frames.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
