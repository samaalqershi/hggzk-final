// lib/features/admin_amenities/presentation/pages/edit_amenity_page.dart

import 'dart:math' as math;
import 'package:hggzkportal/core/theme/app_text_styles.dart';
import 'package:hggzkportal/core/theme/app_theme.dart';
import 'package:hggzkportal/features/admin_amenities/presentation/widgets/amenity_icon_picker.dart';
import 'package:hggzkportal/features/admin_amenities/domain/entities/amenity.dart'
    as am_entity;
import 'package:hggzkportal/features/admin_amenities/presentation/bloc/amenities_bloc.dart';
import 'package:hggzkportal/features/admin_amenities/presentation/bloc/amenities_event.dart';
import 'package:hggzkportal/features/admin_amenities/presentation/bloc/amenities_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hggzkportal/features/property_types/presentation/bloc/property_types/property_types_bloc.dart'
    as pt_bloc;
import 'package:hggzkportal/features/property_types/presentation/bloc/property_types/property_types_event.dart'
    as pt_event;
import 'package:hggzkportal/features/property_types/presentation/bloc/property_types/property_types_state.dart'
    as pt_state;

/// Arabic: صفحة تعديل مرفق موجود مع مقارنة التغييرات واسترجاع القيم الأصلية عند الحاجة.
/// English: Page for editing an existing amenity with change tracking and optional rollback to the original values.
class EditAmenityPage extends StatefulWidget {
  /// Arabic: معرّف المرفق الذي سيتم تعديله داخل هذه الصفحة.
  /// English: Identifier of the amenity being edited on this page.
  final String amenityId;

  /// Arabic: نسخة أولية اختيارية من المرفق لتسريع تعبئة النموذج.
  /// English: Optional initial amenity snapshot used to prefill the form quickly.
  final am_entity.Amenity? initialAmenity;

  /// Arabic: ينشئ صفحة التعديل مع معرّف المرفق والنسخة الأولية الاختيارية.
  /// English: Creates the edit page with the amenity identifier and an optional initial snapshot.
  const EditAmenityPage({
    super.key,
    required this.amenityId,
    this.initialAmenity,
  });

  /// Arabic: ينشئ الحالة التي تدير مقارنة القيم وحفظ تعديلات المرفق.
  /// English: Creates the state object that manages value comparison and amenity edit persistence.
  @override
  State<EditAmenityPage> createState() => _EditAmenityPageState();
}

/// Arabic: تدير هذه الحالة تحميل القيم الأصلية، تعديلها، وإبراز الفروقات قبل الحفظ.
/// English: Manages loading original values, editing them, and highlighting differences before saving.
class _EditAmenityPageState extends State<EditAmenityPage>
    with TickerProviderStateMixin {
  /// Arabic: يتحكم في ظهور محتوى الصفحة وحركته الافتتاحية.
  /// English: Controls the page entrance and main content animation.
  late AnimationController _animationController;

  /// Arabic: يدير نبض الخلفية المتوهجة أثناء التحرير.
  /// English: Drives the glowing background pulse while editing.
  late AnimationController _glowController;

  /// Arabic: يدير مؤشر الدوران أثناء حالات الانتظار أو التحميل.
  /// English: Drives the loading spinner rotation during wait states.
  late AnimationController _loadingAnimationController;

  /// Arabic: يتحكم في شفافية ظهور المحتوى الرئيسي.
  /// English: Controls the fade-in of the primary content.
  late Animation<double> _fadeAnimation;

  /// Arabic: يتحكم في انزلاق المحتوى الرئيسي إلى موضعه النهائي.
  /// English: Controls the slide-in motion for the main content.
  late Animation<Offset> _slideAnimation;

  /// Arabic: يدير الدوران البصري المستخدم في مؤشرات التحميل.
  /// English: Controls the rotation animation used by loading indicators.
  late Animation<double> _loadingRotation;

  /// Arabic: مفتاح النموذج المستخدم للتحقق من الحقول قبل حفظ التعديلات.
  /// English: Form key used to validate fields before saving edits.
  final _formKey = GlobalKey<FormState>();

  /// Arabic: يتحكم في اسم المرفق المعروض داخل النموذج.
  /// English: Controls the amenity name shown in the form.
  final TextEditingController _nameController = TextEditingController();

  /// Arabic: يتحكم في وصف المرفق القابل للتعديل.
  /// English: Controls the editable amenity description.
  final TextEditingController _descriptionController = TextEditingController();

  /// Arabic: الأيقونة المختارة حاليًا للمرفق بعد التعديل.
  /// English: Currently selected icon for the amenity after editing.
  String _selectedIcon = 'star_rounded';

  /// Arabic: معرّف نوع العقار المرتبط بالمرفق إن وُجد.
  /// English: Property type identifier linked to the amenity, if any.
  String? _selectedPropertyTypeId;

  /// Arabic: يحدد ما إذا كان هذا المرفق افتراضيًا لنوع العقار المختار.
  /// English: Indicates whether the amenity is the default for the selected property type.
  bool _isDefaultForType = false;

  /// Arabic: رقم الخطوة الحالية في رحلة التعديل متعددة المراحل.
  /// English: Current step number in the multi-step edit flow.
  int _currentStep = 0;

  /// Arabic: النسخة الأصلية من المرفق لمقارنة التغييرات وإبرازها.
  /// English: Original amenity snapshot used to compare and highlight changes.
  am_entity.Amenity? _originalAmenity;

  /// Arabic: يحدد ما إذا كانت البيانات الأساسية قد تم تجهيزها للعرض.
  /// English: Indicates whether the initial data has been prepared for display.
  bool _isDataLoaded = false;

  /// Arabic: يحدد وجود تغييرات فعلية مقارنة بالنسخة الأصلية.
  /// English: Indicates whether there are real edits compared to the original snapshot.
  bool _hasChanges = false;

  /// Arabic: يجهز أنيميشنات الصفحة ويبدأ تعبئة البيانات الأولية.
  /// English: Prepares the page animations and starts loading or pre-filling data.
  @override
  void initState() {
    super.initState();

    _initializeAnimations();

    _prefillData();
  }

  /// Arabic: يجهز أنيميشن الظهور والتوهج والدوران قبل عرض الصفحة.
  /// English: Prepares the fade, glow, and rotation animations before the page is shown.
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _loadingAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));

    _loadingRotation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _loadingAnimationController,
      curve: Curves.linear,
    ));
  }

  /// Arabic: يملأ النموذج بالبيانات الأولية مباشرة أو يطلب تحميلها من الـ bloc.
  /// English: Prefills the form with initial data or requests it from the bloc.
  void _prefillData() {
    final initial = widget.initialAmenity;
    if (initial != null) {
      _populateFormWithAmenityData(initial);
    } else {
      // Load amenity data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AmenitiesBloc>().add(
              const LoadAmenitiesEvent(pageNumber: 1, pageSize: 1000),
            );
      });
    }
  }

  /// Arabic: ينسخ بيانات المرفق إلى الحقول ويثبتها كنسخة أصلية للمقارنة لاحقًا.
  /// English: Copies amenity data into the fields and stores it as the original comparison snapshot.
  void _populateFormWithAmenityData(am_entity.Amenity amenity) {
    if (_isDataLoaded) return;

    setState(() {
      _originalAmenity = amenity;
      _isDataLoaded = true;

      // Populate controllers
      _nameController.text = amenity.name;
      _descriptionController.text = amenity.description;
      _selectedIcon = amenity.icon;
      // Note: propertyTypeId is not directly available in Amenity entity
      // You might need to load this from a separate relationship
    });

    // Start animation after data is loaded
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  /// Arabic: يحرر كل المتحكمات حتى لا تتسرب الموارد عند مغادرة الصفحة.
  /// English: Disposes all controllers so resources are released when leaving the page.
  @override
  void dispose() {
    _animationController.dispose();
    _glowController.dispose();
    _loadingAnimationController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Arabic: يبني صفحة التعديل مع حظر الرجوع المباشر والاستماع لنتائج الـ bloc.
  /// English: Builds the edit page while guarding back navigation and listening for bloc results.
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && await _onWillPop() && mounted) {
          context.pop();
        }
      },
      child: BlocListener<AmenitiesBloc, AmenitiesState>(
        listener: (context, state) {
          if (state is AmenityOperationSuccess) {
            _showSuccessMessage('تم تحديث المرفق بنجاح');
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                context.pop({'refresh': true});
              }
            });
          } else if (state is AmenitiesError) {
            _showErrorMessage(state.message);
          } else if (state is AmenitiesLoaded &&
              widget.initialAmenity == null) {
            _tryPrefillFromState(state);
          }
        },
        child: Scaffold(
          backgroundColor: AppTheme.darkBackground,
          body: Stack(
            children: [
              // Animated Background
              _buildAnimatedBackground(),

              // Main Content or Loading
              SafeArea(
                child: !_isDataLoaded
                    ? _buildLoadingState()
                    : Column(
                        children: [
                          // Header
                          _buildHeader(),

                          // Progress Indicator
                          _buildProgressIndicator(),

                          // Form Content
                          Expanded(
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: _buildFormContent(),
                              ),
                            ),
                          ),

                          // Action Buttons
                          _buildActionButtons(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Arabic: يحاول استكمال تعبئة النموذج من البيانات المحمّلة عندما لا تأتي نسخة أولية مباشرة.
  /// English: Tries to finish form prefill from loaded data when no initial snapshot was supplied.
  void _tryPrefillFromState(AmenitiesLoaded state) {
    try {
      final found =
          state.amenities.items.firstWhere((a) => a.id == widget.amenityId);
      _populateFormWithAmenityData(found);
    } catch (_) {
      // Not found
      _showErrorMessage('لم يتم العثور على المرفق');
    }
  }

  /// Arabic: يبني الخلفية المتحركة متعددة الطبقات خلف شاشة التعديل.
  /// English: Builds the layered animated background behind the edit screen.
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
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
          ),
          child: CustomPaint(
            painter: _EditAmenityBackgroundPainter(
              glowIntensity: _glowController.value,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  /// Arabic: يبني شاشة انتظار مختصرة مع مؤشر دوران أثناء تحميل بيانات المرفق.
  /// English: Builds a compact waiting state with a spinning indicator while amenity data loads.
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _loadingRotation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _loadingRotation.value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryBlue.withValues(alpha: 0.3),
                        AppTheme.primaryPurple.withValues(alpha: 0.2),
                        AppTheme.primaryViolet.withValues(alpha: 0.1),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.darkBackground,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.star_rounded,
                          color: AppTheme.primaryBlue,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.primaryGradient.createShader(bounds),
            child: Text(
              'جاري تحميل بيانات المرفق...',
              style: AppTextStyles.heading3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'الرجاء الانتظار',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  /// Arabic: يبني شريط الرأس الذي يضم الرجوع والعنوان وحالة التعديل.
  /// English: Builds the header with back navigation, title, and edit-state status.
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.7),
            AppTheme.darkCard.withValues(alpha: 0.3),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: _handleBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.darkSurface.withValues(alpha: 0.5),
                    AppTheme.darkSurface.withValues(alpha: 0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.darkBorder.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppTheme.textWhite,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppTheme.primaryGradient.createShader(bounds),
                      child: Text(
                        'تعديل المرفق',
                        style: AppTextStyles.heading2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_hasChanges)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.warning.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'محرر',
                          style: AppTextStyles.caption.copyWith(
                            color: AppTheme.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _originalAmenity?.name ?? 'قم بتحديث بيانات المرفق',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Reset Button
          if (_hasChanges)
            GestureDetector(
              onTap: _resetChanges,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.error.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  color: AppTheme.error,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Arabic: يبني مؤشر الخطوات مع إبراز الخطوات المعدلة بخلاف الحالة الأصلية.
  /// English: Builds the step indicator and highlights steps that differ from the original data.
  Widget _buildProgressIndicator() {
    final steps = ['المعلومات الأساسية', 'الإعدادات', 'المراجعة'];

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          final isModified = _hasChangesInStep(index);

          return Expanded(
            child: Row(
              children: [
                // Step Indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: isActive ? AppTheme.primaryGradient : null,
                    color: !isActive
                        ? AppTheme.darkSurface.withValues(alpha: 0.5)
                        : null,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isModified
                          ? AppTheme.warning.withValues(alpha: 0.5)
                          : isActive
                              ? AppTheme.primaryBlue.withValues(alpha: 0.5)
                              : AppTheme.darkBorder.withValues(alpha: 0.3),
                      width: isModified ? 2 : 1,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: isModified
                                  ? AppTheme.warning.withValues(alpha: 0.3)
                                  : AppTheme.primaryBlue.withValues(alpha: 0.3),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(
                            isModified
                                ? Icons.edit_rounded
                                : Icons.check_rounded,
                            size: 16,
                            color: Colors.white,
                          )
                        : Text(
                            '${index + 1}',
                            style: AppTextStyles.caption.copyWith(
                              color:
                                  isActive ? Colors.white : AppTheme.textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                // Line
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        gradient: isCompleted
                            ? isModified
                                ? LinearGradient(colors: [
                                    AppTheme.warning,
                                    AppTheme.warning.withValues(alpha: 0.5)
                                  ])
                                : AppTheme.primaryGradient
                            : null,
                        color: !isCompleted
                            ? AppTheme.darkBorder.withValues(alpha: 0.2)
                            : null,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// Arabic: يجمع خطوات التحرير داخل نموذج واحد كي تتشارك التحقق وتتبع التغييرات.
  /// English: Wraps the edit steps in a single form so validation and change tracking are shared.
  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      onChanged: () {
        setState(() {
          _hasChanges = _checkForChanges();
        });
      },
      child: IndexedStack(
        index: _currentStep,
        children: [
          _buildBasicInfoStep(),
          _buildSettingsStep(),
          _buildReviewStep(),
        ],
      ),
    );
  }

  /// Arabic: يبني خطوة المعلومات الأساسية مع مؤشرات للقيم المعدلة مقارنة بالأصل.
  /// English: Builds the basic info step and shows indicators for values changed from the original.
  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Change Indicator
          if (_originalAmenity != null)
            _buildOriginalValueIndicator(
              'اسم المرفق الأصلي',
              _originalAmenity!.name,
              _nameController.text != _originalAmenity!.name,
            ),

          // Name Field
          _buildInputField(
            controller: _nameController,
            label: 'اسم المرفق',
            hint: 'أدخل اسم المرفق',
            icon: Icons.label_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال اسم المرفق';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Description
          if (_originalAmenity != null &&
              _descriptionController.text != _originalAmenity!.description)
            _buildOriginalValueIndicator(
              'الوصف الأصلي',
              _originalAmenity!.description.isEmpty
                  ? 'لا يوجد'
                  : _originalAmenity!.description,
              true,
            ),

          _buildInputField(
            controller: _descriptionController,
            label: 'الوصف',
            hint: 'وصف مختصر للمرفق (اختياري)',
            icon: Icons.description_rounded,
            maxLines: 5,
          ),

          const SizedBox(height: 20),

          // Icon Selector
          _buildIconSelector(),
        ],
      ),
    );
  }

  /// Arabic: يبني خطوة الإعدادات التي تربط المرفق بنوع عقار وتبين ما إذا كانت هناك تغييرات.
  /// English: Builds the settings step that links the amenity to a property type and flags changes.
  Widget _buildSettingsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property Type Assignment
          Text(
            'ربط المرفق',
            style: AppTextStyles.heading3.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _buildPropertyTypeSelector(),

          const SizedBox(height: 16),

          // Default for Type Setting
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _selectedPropertyTypeId == null ? 0.4 : 1.0,
            child: IgnorePointer(
              ignoring: _selectedPropertyTypeId == null,
              child: _buildSettingItem(
                title: 'تعيين كافتراضي',
                subtitle: 'تعيينه كمرفق افتراضي لنوع العقار المختار',
                icon: Icons.star_rounded,
                hasChanged: false, // Since this is optional assignment
                trailing: Switch(
                  value: _isDefaultForType,
                  onChanged: (value) {
                    setState(() {
                      _isDefaultForType = value;
                      _hasChanges = _checkForChanges();
                    });
                    HapticFeedback.lightImpact();
                  },
                  activeThumbColor: AppTheme.success,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Arabic: يبني خطوة المراجعة النهائية مع ملخص تغييرات واضح قبل الحفظ.
  /// English: Builds the final review step with a clear change summary before saving.
  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'مراجعة التغييرات',
                style: AppTextStyles.heading2.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              if (_hasChanges)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.warning,
                        AppTheme.warning.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'يوجد تغييرات',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Changes Summary
          if (_hasChanges) _buildChangesSummary(),

          const SizedBox(height: 20),

          _buildReviewCard(
            title: 'المعلومات الأساسية',
            items: [
              {
                'label': 'الاسم',
                'value': _nameController.text,
                'changed': _nameController.text != _originalAmenity?.name
              },
              {
                'label': 'الوصف',
                'value': _descriptionController.text.isEmpty
                    ? 'لا يوجد'
                    : _descriptionController.text,
                'changed':
                    _descriptionController.text != _originalAmenity?.description
              },
              {
                'label': 'الأيقونة',
                'value': 'Icons.$_selectedIcon',
                'changed': _selectedIcon != _originalAmenity?.icon
              },
            ],
          ),

          const SizedBox(height: 16),

          _buildReviewCard(
            title: 'الإعدادات',
            items: [
              {
                'label': 'نوع العقار',
                'value': _getPropertyTypeName(),
                'changed': false // Since this is optional
              },
              {
                'label': 'مرفق افتراضي',
                'value': _isDefaultForType ? 'نعم' : 'لا',
                'changed': false // Since this is optional
              },
            ],
          ),
        ],
      ),
    );
  }

  /// Arabic: يفتح منتقي الأيقونات ويحدث حالة التغيير عند اختيار رمز جديد.
  /// English: Opens the icon picker and updates change state when a new icon is selected.
  Widget _buildIconSelector() {
    return GestureDetector(
      onTap: _showIconPicker,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withValues(alpha: 0.5),
              AppTheme.darkCard.withValues(alpha: 0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedIcon != _originalAmenity?.icon
                ? AppTheme.warning.withValues(alpha: 0.3)
                : AppTheme.darkBorder.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _selectedIcon != _originalAmenity?.icon
                      ? [
                          AppTheme.warning.withValues(alpha: 0.2),
                          AppTheme.warning.withValues(alpha: 0.1),
                        ]
                      : [
                          AppTheme.primaryBlue.withValues(alpha: 0.2),
                          AppTheme.primaryPurple.withValues(alpha: 0.1),
                        ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getIconFromString(_selectedIcon),
                color: _selectedIcon != _originalAmenity?.icon
                    ? AppTheme.warning
                    : AppTheme.primaryBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أيقونة المرفق',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppTheme.textWhite,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Icons.$_selectedIcon',
                        style: AppTextStyles.caption.copyWith(
                          color: AppTheme.textMuted,
                          fontFamily: 'monospace',
                        ),
                      ),
                      if (_selectedIcon != _originalAmenity?.icon) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.warning.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'معدّل',
                            style: AppTextStyles.caption.copyWith(
                              color: AppTheme.warning,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppTheme.textMuted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  /// Arabic: يبني واجهة اختيار نوع العقار المرتبط بالمرفق مع حالات التحميل والخطأ.
  /// English: Builds the property type selector with loading and error states.
  Widget _buildPropertyTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ربط بنوع عقار (اختياري)',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        BlocBuilder<pt_bloc.PropertyTypesBloc, pt_state.PropertyTypesState>(
          builder: (context, state) {
            if (state is pt_state.PropertyTypesInitial) {
              context
                  .read<pt_bloc.PropertyTypesBloc>()
                  .add(const pt_event.LoadPropertyTypesEvent(pageSize: 1000));
            }
            if (state is pt_state.PropertyTypesLoading ||
                state is pt_state.PropertyTypesInitial) {
              return _buildLoadingDropdown();
            }
            if (state is pt_state.PropertyTypesError) {
              return _buildErrorDropdown(state.message);
            }
            if (state is pt_state.PropertyTypesLoaded) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppTheme.darkCard.withValues(alpha: 0.5),
                    AppTheme.darkCard.withValues(alpha: 0.3),
                  ]),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.darkBorder.withValues(alpha: 0.3),
                      width: 1),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _selectedPropertyTypeId,
                    isExpanded: true,
                    dropdownColor: AppTheme.darkCard,
                    icon: Icon(Icons.arrow_drop_down_rounded,
                        color: AppTheme.primaryBlue.withValues(alpha: 0.7)),
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppTheme.textWhite),
                    hint: Text('اختر نوع العقار لربطه بالمرفق',
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: AppTheme.textMuted.withValues(alpha: 0.5))),
                    items: [
                      const DropdownMenuItem<String?>(
                          value: null, child: Text('بدون')),
                      ...state.propertyTypes.map((t) =>
                          DropdownMenuItem<String?>(
                              value: t.id, child: Text(t.name)))
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPropertyTypeId = value;
                        if (_selectedPropertyTypeId == null)
                          _isDefaultForType = false;
                        _hasChanges = _checkForChanges();
                      });
                    },
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  /// Arabic: يبني صف إعداد واحد مع تمييز بصري إذا كان هذا الحقل قد تغيّر.
  /// English: Builds a single settings row and visually highlights it when the value has changed.
  Widget _buildSettingItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget trailing,
    bool hasChanged = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasChanged
              ? [
                  AppTheme.warning.withValues(alpha: 0.1),
                  AppTheme.warning.withValues(alpha: 0.05),
                ]
              : [
                  AppTheme.darkCard.withValues(alpha: 0.5),
                  AppTheme.darkCard.withValues(alpha: 0.3),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasChanged
              ? AppTheme.warning.withValues(alpha: 0.3)
              : AppTheme.darkBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: hasChanged
                  ? LinearGradient(colors: [
                      AppTheme.warning.withValues(alpha: 0.2),
                      AppTheme.warning.withValues(alpha: 0.1),
                    ])
                  : LinearGradient(colors: [
                      AppTheme.primaryBlue.withValues(alpha: 0.2),
                      AppTheme.primaryPurple.withValues(alpha: 0.1),
                    ]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: hasChanged ? AppTheme.warning : AppTheme.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (hasChanged) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'معدّل',
                          style: AppTextStyles.caption.copyWith(
                            color: AppTheme.warning,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  /// Arabic: يعرض القيمة الأصلية عندما يختلف الحقل الحالي عنها.
  /// English: Shows the original value whenever the current field differs from it.
  Widget _buildOriginalValueIndicator(
      String label, String value, bool isChanged) {
    if (!isChanged) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.warning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: AppTheme.warning,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.warning.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Arabic: يلخص جميع الحقول المعدلة في بطاقة واحدة قبل الحفظ.
  /// English: Summarizes every modified field in one card before saving.
  Widget _buildChangesSummary() {
    final changes = _getChangedFields();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.warning.withValues(alpha: 0.1),
            AppTheme.warning.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.warning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.track_changes_rounded,
                color: AppTheme.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'ملخص التغييرات (${changes.length})',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...changes.map((change) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            change['field']!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppTheme.textWhite,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'من: ${change['oldValue']}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppTheme.textMuted,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 12,
                                color: AppTheme.warning,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'إلى: ${change['newValue']}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppTheme.success,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// Arabic: يبني بطاقة مراجعة تعرض القيم مع وسم يوضح إن كانت قد تغيرت.
  /// English: Builds a review card that shows values and marks the ones that changed.
  Widget _buildReviewCard({
    required String title,
    required List<Map<String, dynamic>> items,
  }) {
    final hasChanges = items.any((item) => item['changed'] == true);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasChanges
              ? [
                  AppTheme.warning.withValues(alpha: 0.05),
                  AppTheme.darkCard.withValues(alpha: 0.4),
                ]
              : [
                  AppTheme.darkCard.withValues(alpha: 0.5),
                  AppTheme.darkCard.withValues(alpha: 0.3),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasChanges
              ? AppTheme.warning.withValues(alpha: 0.3)
              : AppTheme.darkBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: hasChanges ? AppTheme.warning : AppTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (hasChanges) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'معدّل',
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.warning,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (item['changed'] == true)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.warning,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Text(
                          item['label']!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: item['changed'] == true
                                ? AppTheme.warning
                                : AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Text(
                        item['value']!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppTheme.textWhite,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.end,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// Arabic: يبني حقل إدخال قابل للتحقق مع دعم إبراز الحالة المعدلة.
  /// English: Builds a validated input field with support for highlighting the edited state.
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.darkCard.withValues(alpha: 0.5),
                AppTheme.darkCard.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.darkBorder.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted.withValues(alpha: 0.5),
              ),
              prefixIcon: maxLines == 1
                  ? Icon(
                      icon,
                      color: AppTheme.primaryBlue.withValues(alpha: 0.7),
                      size: 20,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  /// Arabic: يبني حالة التحميل أثناء جلب أنواع العقار من الخلفية.
  /// English: Builds the loading state while property types are fetched.
  Widget _buildLoadingDropdown() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.5),
            AppTheme.darkCard.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'جاري تحميل أنواع العقار...',
              style: AppTextStyles.caption.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Arabic: يبني حالة الخطأ عندما يتعذر تحميل أنواع العقار.
  /// English: Builds the error state when property types cannot be loaded.
  Widget _buildErrorDropdown(String message) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.5),
            AppTheme.darkCard.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 18,
              color: AppTheme.error,
            ),
            const SizedBox(width: 8),
            Text(
              'خطأ في تحميل أنواع العقار',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Arabic: يبني أزرار التنقل والحفظ مع مراعاة حالة التغيير الحالية.
  /// English: Builds the navigation and save buttons while respecting the current change state.
  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.7),
            AppTheme.darkCard.withValues(alpha: 0.5),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: AppTheme.darkBorder.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Previous Button
          if (_currentStep > 0)
            Expanded(
              child: GestureDetector(
                onTap: _previousStep,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.darkSurface.withValues(alpha: 0.5),
                        AppTheme.darkSurface.withValues(alpha: 0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.darkBorder.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'السابق',
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: AppTheme.textWhite,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          if (_currentStep > 0) const SizedBox(width: 12),

          // Next/Submit Button
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: GestureDetector(
              onTap: _currentStep < 2 ? _nextStep : _submitForm,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: _hasChanges
                      ? LinearGradient(colors: [
                          AppTheme.warning,
                          AppTheme.warning.withValues(alpha: 0.8)
                        ])
                      : AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _hasChanges
                          ? AppTheme.warning.withValues(alpha: 0.3)
                          : AppTheme.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: BlocBuilder<AmenitiesBloc, AmenitiesState>(
                    builder: (context, state) {
                      if (state is AmenityOperationInProgress) {
                        return const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        );
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_currentStep == 2 && _hasChanges)
                            const Icon(
                              Icons.save_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          if (_currentStep == 2 && _hasChanges)
                            const SizedBox(width: 8),
                          Text(
                            _currentStep < 2
                                ? 'التالي'
                                : _hasChanges
                                    ? 'حفظ التغييرات'
                                    : 'لا توجد تغييرات',
                            style: AppTextStyles.buttonMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Arabic: يحدد ما إذا كانت هناك فروق فعلية بين النموذج الحالي والنسخة الأصلية.
  /// English: Determines whether the current form differs from the original snapshot.
  bool _checkForChanges() {
    if (_originalAmenity == null) return false;

    return _nameController.text != _originalAmenity!.name ||
        _descriptionController.text != _originalAmenity!.description ||
        _selectedIcon != _originalAmenity!.icon;
  }

  /// Arabic: يحدد الخطوات التي تحتوي على تغييرات فعلية لعرضها في المؤشر.
  /// English: Determines which steps contain actual changes so the stepper can highlight them.
  bool _hasChangesInStep(int step) {
    if (_originalAmenity == null) return false;

    switch (step) {
      case 0: // Basic Info
        return _nameController.text != _originalAmenity!.name ||
            _descriptionController.text != _originalAmenity!.description ||
            _selectedIcon != _originalAmenity!.icon;
      case 1: // Settings
        return false; // Settings are optional assignments
      default:
        return false;
    }
  }

  /// Arabic: يجمع قائمة الحقول التي تغيرت مع قيمها القديمة والجديدة.
  /// English: Collects the fields that changed along with their old and new values.
  List<Map<String, String>> _getChangedFields() {
    final changes = <Map<String, String>>[];
    if (_originalAmenity == null) return changes;

    if (_nameController.text != _originalAmenity!.name) {
      changes.add({
        'field': 'اسم المرفق',
        'oldValue': _originalAmenity!.name,
        'newValue': _nameController.text,
      });
    }

    if (_descriptionController.text != _originalAmenity!.description) {
      changes.add({
        'field': 'الوصف',
        'oldValue': _originalAmenity!.description.isEmpty
            ? 'لا يوجد'
            : _originalAmenity!.description,
        'newValue': _descriptionController.text.isEmpty
            ? 'لا يوجد'
            : _descriptionController.text,
      });
    }

    if (_selectedIcon != _originalAmenity!.icon) {
      changes.add({
        'field': 'الأيقونة',
        'oldValue': 'Icons.${_originalAmenity!.icon}',
        'newValue': 'Icons.$_selectedIcon',
      });
    }

    return changes;
  }

  /// Arabic: يفتح حوارًا يعيد النموذج إلى القيم الأصلية بعد التأكيد.
  /// English: Opens a confirmation dialog that restores the original values after approval.
  void _resetChanges() {
    if (_originalAmenity == null) return;

    showDialog(
      context: context,
      builder: (context) => _ResetConfirmationDialog(
        onConfirm: () {
          Navigator.pop(context);

          setState(() {
            _nameController.text = _originalAmenity!.name;
            _descriptionController.text = _originalAmenity!.description;
            _selectedIcon = _originalAmenity!.icon;
            _hasChanges = false;
          });

          _showSuccessMessage('تم استرجاع البيانات الأصلية');
        },
      ),
    );
  }

  /// Arabic: يقرر ما إذا كان الرجوع مسموحًا أو يحتاج لتأكيد بسبب التغييرات غير المحفوظة.
  /// English: Decides whether back navigation can proceed or needs confirmation because of unsaved changes.
  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _UnsavedChangesDialog(),
    );

    return result ?? false;
  }

  /// Arabic: يعيد اسم نوع العقار المختار ليظهر في المراجعة.
  /// English: Returns the selected property type name for display in the review step.
  String _getPropertyTypeName() {
    if (_selectedPropertyTypeId == null) return 'بدون';

    final state = context.read<pt_bloc.PropertyTypesBloc>().state;
    if (state is pt_state.PropertyTypesLoaded) {
      try {
        final propertyType = state.propertyTypes
            .firstWhere((t) => t.id == _selectedPropertyTypeId);
        return propertyType.name;
      } catch (_) {
        return 'غير محدد';
      }
    }
    return 'غير محدد';
  }

  /// Arabic: يحول اسم الأيقونة النصي إلى `IconData` المستخدم في الواجهة.
  /// English: Converts the string icon name into the `IconData` used by the interface.
  IconData _getIconFromString(String icon) {
    switch (icon) {
      case 'star_rounded':
        return Icons.star_rounded;
      case 'wifi':
        return Icons.wifi;
      case 'pool':
        return Icons.pool;
      case 'local_parking':
        return Icons.local_parking;
      case 'fitness_center':
        return Icons.fitness_center;
      default:
        return Icons.star_rounded;
    }
  }

  /// Arabic: يتعامل مع زر الرجوع بما يحافظ على التغييرات أو يرجع خطوة للخلف.
  /// English: Handles back navigation by preserving edits or moving one step backward.
  void _handleBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      if (_hasChanges) {
        _onWillPop().then((canPop) {
          if (canPop) {
            context.pop();
          }
        });
      } else {
        context.pop();
      }
    }
  }

  /// Arabic: يعيد المستخدم إلى الخطوة السابقة في نموذج التعديل.
  /// English: Moves the user back to the previous step in the edit flow.
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  /// Arabic: ينتقل إلى الخطوة التالية بعد التحقق من صحة البيانات الأساسية.
  /// English: Advances to the next step after validating the basic information.
  void _nextStep() {
    if (_currentStep < 2) {
      bool isValid = true;

      if (_currentStep == 0) {
        isValid = _validateBasicInfo();
      }

      if (isValid) {
        setState(() {
          _currentStep++;
        });
      }
    }
  }

  /// Arabic: يتحقق من الحد الأدنى من البيانات الأساسية قبل السماح بالتقدم.
  /// English: Validates the minimum basic data before allowing the user to continue.
  bool _validateBasicInfo() {
    if (_nameController.text.isEmpty) {
      _showErrorMessage('الرجاء إدخال اسم المرفق');
      return false;
    }
    return true;
  }

  /// Arabic: يرسل التحديث أو الإسناد إلى طبقة الـ bloc بعد التحقق من وجود تغييرات.
  /// English: Sends the update or assignment events to the bloc after confirming there are changes.
  void _submitForm() {
    if (!_hasChanges) {
      _showInfoMessage('لا توجد تغييرات للحفظ');
      return;
    }

    if (_formKey.currentState!.validate()) {
      context.read<AmenitiesBloc>().add(
            UpdateAmenityEvent(
              amenityId: widget.amenityId,
              name: _nameController.text,
              description: _descriptionController.text,
              icon: _selectedIcon,
            ),
          );

      // If user selected a property type, trigger assignment
      if (_selectedPropertyTypeId != null) {
        context.read<AmenitiesBloc>().add(
              AssignAmenityToPropertyTypeEvent(
                amenityId: widget.amenityId,
                propertyTypeId: _selectedPropertyTypeId!,
                isDefault: _isDefaultForType,
              ),
            );
      }
    }
  }

  /// Arabic: يفتح منتقي الأيقونات ويعيد احتساب حالة التغيير عند الاختيار.
  /// English: Opens the icon picker and recalculates change state when a new icon is chosen.
  void _showIconPicker() {
    showDialog(
      context: context,
      builder: (context) => AmenityIconPicker(
        selectedIcon: _selectedIcon,
        onIconSelected: (icon) {
          setState(() {
            _selectedIcon = icon;
            _hasChanges = _checkForChanges();
          });
        },
      ),
    );
  }

  /// Arabic: يعرض رسالة نجاح قصيرة بعد حفظ التعديل أو الاسترجاع.
  /// English: Shows a short success message after saving edits or restoring data.
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Arabic: يعرض رسالة خطأ واضحة عندما تفشل عملية الحفظ أو التحميل.
  /// English: Shows a clear error message when saving or loading fails.
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Arabic: يعرض رسالة معلومات عندما لا توجد تغييرات جاهزة للحفظ.
  /// English: Shows an informational message when there are no changes to save.
  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Arabic: حوار تأكيد يعرض خيار استرجاع القيم الأصلية قبل تنفيذ ذلك.
/// English: Confirmation dialog that offers to restore the original values before applying the reset.
class _ResetConfirmationDialog extends StatelessWidget {
  /// Arabic: الإجراء الذي يُنفذ عند تأكيد الاسترجاع من قبل المستخدم.
  /// English: Callback executed when the user confirms the reset.
  final VoidCallback onConfirm;

  /// Arabic: ينشئ حوار التأكيد مع الإجراء الذي يعيد القيم الأصلية.
  /// English: Creates the confirmation dialog with the callback that restores the original values.
  const _ResetConfirmationDialog({required this.onConfirm});

  @override

  /// Arabic: يبني واجهة تأكيد الاسترجاع وما تحتويه من أزرار وتنبيه.
  /// English: Builds the reset confirmation UI, including its warning text and actions.
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withValues(alpha: 0.95),
              AppTheme.darkCard.withValues(alpha: 0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.warning.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.warning.withValues(alpha: 0.2),
                    AppTheme.warning.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.refresh_rounded,
                color: AppTheme.warning,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'استرجاع البيانات الأصلية',
              style: AppTextStyles.heading3.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'سيتم التراجع عن جميع التغييرات\nواسترجاع البيانات الأصلية',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      onConfirm();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.warning,
                            AppTheme.warning.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'استرجاع',
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

/// Arabic: حوار يحذر المستخدم من مغادرة الصفحة مع بقاء تغييرات غير محفوظة.
/// English: Dialog that warns the user before leaving with unsaved changes.
class _UnsavedChangesDialog extends StatelessWidget {
  @override

  /// Arabic: يبني واجهة التحذير الخاصة بالتغييرات غير المحفوظة.
  /// English: Builds the warning UI for unsaved edits.
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.darkCard.withValues(alpha: 0.95),
              AppTheme.darkCard.withValues(alpha: 0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.error.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.error.withValues(alpha: 0.2),
                    AppTheme.error.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_rounded,
                color: AppTheme.error,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'تغييرات غير محفوظة',
              style: AppTextStyles.heading3.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لديك تغييرات غير محفوظة.\nهل تريد الخروج بدون حفظ؟',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'البقاء',
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context, true);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.error.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'خروج بدون حفظ',
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: AppTheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

/// Arabic: يرسم الخلفية المتحركة الخاصة بوضع التعديل مع وهج تحذيري دافئ.
/// English: Paints the edit-mode animated background with a warm warning glow.
class _EditAmenityBackgroundPainter extends CustomPainter {
  /// Arabic: شدة الوهج الحالية التي يستخدمها الرسام لتحديد قوة الإضاءة الخلفية.
  /// English: Current glow intensity used by the painter to scale the background light.
  final double glowIntensity;

  /// Arabic: ينشئ الرسام مع شدة الوهج القادمة من الأنيميشن.
  /// English: Creates the painter with the glow intensity supplied by the animation.
  _EditAmenityBackgroundPainter({required this.glowIntensity});

  @override

  /// Arabic: يرسم الدوائر الضوئية المتحركة التي تميز شاشة التعديل.
  /// English: Draws the animated glowing circles that define the edit screen atmosphere.
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw glowing orbs with edit theme
    paint.shader = RadialGradient(
      colors: [
        AppTheme.warning.withValues(alpha: 0.1 * glowIntensity),
        AppTheme.warning.withValues(alpha: 0.05 * glowIntensity),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(
      center: Offset(size.width * 0.8, size.height * 0.2),
      radius: 150,
    ));

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      150,
      paint,
    );

    paint.shader = RadialGradient(
      colors: [
        AppTheme.primaryPurple.withValues(alpha: 0.1 * glowIntensity),
        AppTheme.primaryPurple.withValues(alpha: 0.05 * glowIntensity),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(
      center: Offset(size.width * 0.2, size.height * 0.7),
      radius: 100,
    ));

    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.7),
      100,
      paint,
    );
  }

  @override

  /// Arabic: يعيد الرسم عند تغير الوهج لأن الخلفية مرتبطة بحركة زمنية مستمرة.
  /// English: Repaints when the glow changes because the background is tied to continuous motion.
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
