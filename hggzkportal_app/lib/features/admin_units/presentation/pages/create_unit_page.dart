// lib/features/admin_units/presentation/pages/create_unit_page.dart

import 'package:hggzkportal/core/theme/app_theme.dart';
import 'package:hggzkportal/features/admin_units/domain/entities/pricing_method.dart';
import 'package:hggzkportal/features/admin_units/domain/entities/unit_type.dart';
import 'package:hggzkportal/features/admin_units/presentation/widgets/dynamic_fields_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hggzkportal/core/theme/app_text_styles.dart';
import '../bloc/unit_form/unit_form_bloc.dart';
import 'package:hggzkportal/features/admin_properties/domain/entities/property.dart';
import 'package:hggzkportal/features/admin_units/presentation/widgets/unit_image_gallery.dart';
import 'package:get_it/get_it.dart';
import 'package:hggzkportal/core/network/api_client.dart';
import 'package:hggzkportal/features/admin_daily_schedule/presentation/bloc/daily_schedule_barrel.dart';
import 'package:hggzkportal/features/admin_daily_schedule/presentation/pages/daily_schedule_page.dart';
import 'package:hggzkportal/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hggzkportal/features/auth/presentation/bloc/auth_state.dart';
import 'package:hggzkportal/features/auth/domain/entities/user.dart' as domain;
import 'package:hggzkportal/features/admin_properties/domain/usecases/properties/get_property_details_usecase.dart'
    as ap_uc_prop_details;

/// يمثل هذا الكلاس CreateUnitPage البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for CreateUnitPage in the admin unit workflow.
class CreateUnitPage extends StatefulWidget {
  /// This constructor creates a new CreateUnitPage instance.
  /// ينشئ مثيلًا جديدًا من CreateUnitPage.
  const CreateUnitPage({super.key});

  /// ينشئ هذا الأسلوب كائن الحالة الخاص بهذه الصفحة.
  /// This method performs the createState operation in the admin unit workflow.
  @override
  State<CreateUnitPage> createState() => _CreateUnitPageState();
}

/// يمثل هذا الكلاس _CreateUnitPageState البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for _CreateUnitPageState in the admin unit workflow.
class _CreateUnitPageState extends State<CreateUnitPage>
    with TickerProviderStateMixin {
  // Controllers
  /// يحتفظ هذا الحقل بقيمة _animationController التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _animationController value used by the admin unit workflow.
  late AnimationController _animationController;

  /// يحتفظ هذا الحقل بقيمة _glowController التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _glowController value used by the admin unit workflow.
  late AnimationController _glowController;

  /// يحتفظ هذا الحقل بقيمة _fadeAnimation التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _fadeAnimation value used by the admin unit workflow.
  late Animation<double> _fadeAnimation;

  /// يحتفظ هذا الحقل بقيمة _slideAnimation التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _slideAnimation value used by the admin unit workflow.
  late Animation<Offset> _slideAnimation;

  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _featuresController = TextEditingController();

  // State
  /// يحتفظ هذا الحقل بقيمة _selectedPropertyId التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _selectedPropertyId value used by the admin unit workflow.
  String? _selectedPropertyId;

  /// يحتفظ هذا الحقل بقيمة _selectedUnitTypeId التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _selectedUnitTypeId value used by the admin unit workflow.
  String? _selectedUnitTypeId;

  /// يحتفظ هذا الحقل بقيمة _isHasAdults التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _isHasAdults value used by the admin unit workflow.
  bool _isHasAdults = false;

  /// يحتفظ هذا الحقل بقيمة _isHasChildren التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _isHasChildren value used by the admin unit workflow.
  bool _isHasChildren = false;

  /// يحتفظ هذا الحقل بقيمة _currentStep التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _currentStep value used by the admin unit workflow.
  int _currentStep = 0;

  /// يحتفظ هذا الحقل بقيمة _adultCapacity التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _adultCapacity value used by the admin unit workflow.
  int _adultCapacity = 0;

  /// يحتفظ هذا الحقل بقيمة _childrenCapacity التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _childrenCapacity value used by the admin unit workflow.
  int _childrenCapacity = 0;

  /// يحتفظ هذا الحقل بقيمة _pricingMethod التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _pricingMethod value used by the admin unit workflow.
  String _pricingMethod = 'per_night';

  /// يحتفظ هذا الحقل بقيمة _dynamicFieldValues التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _dynamicFieldValues value used by the admin unit workflow.
  Map<String, dynamic> _dynamicFieldValues = {};

  /// يحتفظ هذا الحقل بقيمة _selectedPropertyName التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _selectedPropertyName value used by the admin unit workflow.
  String? _selectedPropertyName;
  final GlobalKey<UnitImageGalleryState> _galleryKey = GlobalKey();

  /// يحتفظ هذا الحقل بقيمة _selectedLocalImages التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _selectedLocalImages value used by the admin unit workflow.
  List<String> _selectedLocalImages = [];

  /// يحتفظ هذا الحقل بقيمة _tempKey التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _tempKey value used by the admin unit workflow.
  String? _tempKey;

  /// يحتفظ هذا الحقل بقيمة _allowsCancellation التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _allowsCancellation value used by the admin unit workflow.
  bool _allowsCancellation = true;
  final _cancellationDaysController = TextEditingController();

  /// يحتفظ هذا الحقل بقيمة _isOwner التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _isOwner value used by the admin unit workflow.
  bool _isOwner = false;

  /// ينفذ هذا الأسلوب عملية initState ضمن مسار إدارة الوحدات.
  /// This method performs the initState operation in the admin unit workflow.
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadInitialData();
    // Generate a temp key to allow pre-save image uploads
    _tempKey = DateTime.now().millisecondsSinceEpoch.toString();
    // Re-initialize form with tempKey
    context.read<UnitFormBloc>().add(InitializeFormEvent(tempKey: _tempKey));
    // Apply owner context (auto select property) if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyOwnerContextIfAny();
    });
  }

  /// ينفذ هذا الأسلوب عملية _initializeAnimations ضمن مسار إدارة الوحدات.
  /// This method performs the _initializeAnimations operation in the admin unit workflow.
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuart,
      ),
    );

    // Start animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  /// ينفذ هذا الأسلوب عملية _loadInitialData ضمن مسار إدارة الوحدات.
  /// This method performs the _loadInitialData operation in the admin unit workflow.
  void _loadInitialData() {
    // Initialize form without unitId for create mode
    context.read<UnitFormBloc>().add(const InitializeFormEvent());
  }

  /// ينفذ هذا الأسلوب عملية _applyOwnerContextIfAny ضمن مسار إدارة الوحدات.
  /// This method performs the _applyOwnerContextIfAny operation in the admin unit workflow.
  Future<void> _applyOwnerContextIfAny() async {
    final authState = context.read<AuthBloc>().state;
    domain.User? user;
    if (authState is AuthAuthenticated) user = authState.user;
    if (authState is AuthLoginSuccess) user = authState.user;
    if (authState is AuthProfileUpdateSuccess) user = authState.user;

    if (user == null) return;
    final isOwner = user.isOwner;
    final ownerPropId = user.propertyId;
    if (!isOwner || ownerPropId == null || ownerPropId.isEmpty) return;
    final u = user;
    setState(() {
      _isOwner = true;
      _selectedPropertyId = ownerPropId;
      _selectedPropertyName = u.propertyName;
    });

    try {
      // Load property details to get property type id for unit types
      final getDetails =
          GetIt.instance<ap_uc_prop_details.GetPropertyDetailsUseCase>();
      final res = await getDetails(
        ap_uc_prop_details.GetPropertyDetailsParams(
          propertyId: ownerPropId,
          includeUnits: false,
        ),
      );
      res.fold((_) {}, (prop) {
        context.read<UnitFormBloc>().add(
              PropertySelectedEvent(
                propertyId: ownerPropId,
                propertyTypeId: prop.typeId,
              ),
            );
      });
    } catch (_) {}
  }

  /// ينفذ هذا الأسلوب عملية dispose ضمن مسار إدارة الوحدات.
  /// This method performs the dispose operation in the admin unit workflow.
  @override
  void dispose() {
    // Purge temp images if user leaves without saving
    if (_tempKey != null) {
      try {
        GetIt.instance<ApiClient>().delete(
          '/api/images/purge-temp',
          queryParameters: {'tempKey': _tempKey},
        );
      } catch (_) {}
    }
    _animationController.dispose();
    _glowController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _featuresController.dispose();
    _cancellationDaysController.dispose();
    super.dispose();
  }

  /// ينفذ هذا الأسلوب عملية build ضمن مسار إدارة الوحدات.
  /// This method performs the build operation in the admin unit workflow.
  @override
  Widget build(BuildContext context) {
    return BlocListener<UnitFormBloc, UnitFormState>(
      listener: (context, state) async {
        if (state is UnitFormSubmitted) {
          // If we have local images and unitId, trigger upload then pop
          final unitId = state.unitId;
          if (unitId != null && _selectedLocalImages.isNotEmpty) {
            try {
              // Use gallery helper to upload queued images
              _galleryKey.currentState?.uploadLocalImages(unitId);
            } catch (_) {}
          }
          // clear tempKey since entity is saved
          _tempKey = null;
          await _handleCreatedUnit(unitId);
        } else if (state is UnitFormError) {
          _showErrorMessage(state.message);
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _handleSystemBack();
        },
        child: Scaffold(
          backgroundColor: AppTheme.darkBackground,
          body: Stack(
            children: [
              // Animated Background
              _buildAnimatedBackground(),

              // Main Content
              SafeArea(
                child: Column(
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

  /// ينفذ هذا الأسلوب عملية _buildAnimatedBackground ضمن مسار إدارة الوحدات.
  /// This method performs the _buildAnimatedBackground operation in the admin unit workflow.
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
            painter: _CreateUnitBackgroundPainter(
              glowIntensity: _glowController.value,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildHeader ضمن مسار إدارة الوحدات.
  /// This method performs the _buildHeader operation in the admin unit workflow.
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
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.primaryGradient.createShader(bounds),
                  child: Text(
                    'إضافة وحدة جديدة',
                    style: AppTextStyles.heading2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'قم بملء البيانات المطلوبة لإضافة الوحدة',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildProgressIndicator ضمن مسار إدارة الوحدات.
  /// This method performs the _buildProgressIndicator operation in the admin unit workflow.
  Widget _buildProgressIndicator() {
    final steps = [
      'المعلومات الأساسية',
      'السعة والتسعير',
      'الصور والحقول الإضافية',
      'المراجعة',
    ];

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;

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
                      color: isActive
                          ? AppTheme.primaryBlue.withValues(alpha: 0.5)
                          : AppTheme.darkBorder.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color:
                                  AppTheme.primaryBlue.withValues(alpha: 0.3),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(
                            Icons.check_rounded,
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
                        gradient: isCompleted ? AppTheme.primaryGradient : null,
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

  /// ينفذ هذا الأسلوب عملية _buildFormContent ضمن مسار إدارة الوحدات.
  /// This method performs the _buildFormContent operation in the admin unit workflow.
  Widget _buildFormContent() {
    return BlocBuilder<UnitFormBloc, UnitFormState>(
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: IndexedStack(
            index: _currentStep,
            children: [
              _buildBasicInfoStep(state),
              _buildCapacityPricingStep(state),
              _buildFeaturesStep(state),
              _buildReviewStep(state),
            ],
          ),
        );
      },
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildBasicInfoStep ضمن مسار إدارة الوحدات.
  /// This method performs the _buildBasicInfoStep operation in the admin unit workflow.
  Widget _buildBasicInfoStep(UnitFormState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unit Name
          _buildInputField(
            controller: _nameController,
            label: 'اسم الوحدة',
            hint: 'أدخل اسم الوحدة',
            icon: Icons.home_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال اسم الوحدة';
              }
              return null;
            },
            onChanged: (value) => _updateUnitName(), // أضف هذا
          ),

          const SizedBox(height: 20),

          // Property Selector (hidden for owners)
          if (!_isOwner) _buildPropertySelector(state),

          const SizedBox(height: 20),

          // Unit Type Selector
          _buildUnitTypeSelector(state),

          const SizedBox(height: 20),

          // Description
          _buildInputField(
            controller: _descriptionController,
            label: 'الوصف',
            hint: 'أدخل وصف الوحدة',
            icon: Icons.description_rounded,
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال وصف الوحدة';
              }
              return null;
            },
            onChanged: (value) => _updateDescription(), // أضف هذا
          ),
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildCapacityPricingStep ضمن مسار إدارة الوحدات.
  /// This method performs the _buildCapacityPricingStep operation in the admin unit workflow.
  Widget _buildCapacityPricingStep(UnitFormState state) {
    final selectedUnitType =
        state is UnitFormReady ? state.selectedUnitType : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isHasAdults || _isHasChildren) ...[
            // Capacity Section
            Text(
              'السعة الاستيعابية',
              style: AppTextStyles.heading3.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                if (_isHasAdults) ...[
                  Expanded(
                    child: _buildCapacityCounter(
                      label: 'البالغين',
                      value: _adultCapacity,
                      icon: Icons.person,
                      onIncrement: () {
                        setState(() => _adultCapacity++);
                        _updateCapacity();
                      },
                      onDecrement: () {
                        if (_adultCapacity > 1) {
                          setState(() => _adultCapacity--);
                          _updateCapacity();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                if (_isHasChildren) ...[
                  Expanded(
                    child: _buildCapacityCounter(
                      label: 'الأطفال',
                      value: _childrenCapacity,
                      icon: Icons.child_care,
                      onIncrement: () {
                        setState(() => _childrenCapacity++);
                        _updateCapacity();
                      },
                      onDecrement: () {
                        if (_childrenCapacity > 0) {
                          setState(() => _childrenCapacity--);
                          _updateCapacity();
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 30),

            if (selectedUnitType != null) ...[
              _buildCapacityReferenceCard(selectedUnitType),
              const SizedBox(height: 24),
            ],
          ],
          // Pricing Section
          Text(
            'التسعير',
            style: AppTextStyles.heading3.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Pricing Method Selector
          _buildPricingMethodSelector(),

          const SizedBox(height: 24),
          // Cancellation Policy
          Text(
            'سياسة الإلغاء',
            style: AppTextStyles.heading3.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Switch(
                activeThumbColor: AppTheme.success,
                value: _allowsCancellation,
                onChanged: (v) {
                  setState(() {
                    _allowsCancellation = v;
                    if (!v) _cancellationDaysController.text = '';
                  });
                  _updateCancellationPolicy();
                },
              ),
              const SizedBox(width: 8),
              Text(
                'السماح بإلغاء الحجز',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _allowsCancellation ? 1 : 0.4,
            child: IgnorePointer(
              ignoring: !_allowsCancellation,
              child: _buildInputField(
                controller: _cancellationDaysController,
                label: 'أيام نافذة الإلغاء قبل الوصول',
                hint: 'مثال: 2',
                icon: Icons.event_busy,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (!_allowsCancellation) return null;
                  if (value == null || value.isEmpty) return null; // optional
                  final v = int.tryParse(value);
                  if (v == null || v < 0) return 'أدخل رقم صالح (0 أو أكثر)';
                  return null;
                },
                onChanged: (_) => _updateCancellationPolicy(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildFeaturesStep ضمن مسار إدارة الوحدات.
  /// This method performs the _buildFeaturesStep operation in the admin unit workflow.
  Widget _buildFeaturesStep(UnitFormState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الصور والحقول الإضافية',
            style: AppTextStyles.heading3.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'صور الوحدة',
            style: AppTextStyles.heading3.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          UnitImageGallery(
            key: _galleryKey,
            unitId: null,
            tempKey: _tempKey,
            maxImages: 10,
            onLocalImagesChanged: (paths) {
              setState(() {
                _selectedLocalImages = paths;
                _updateUnitImage();
              });
            },
          ),

          // Dynamic Fields Section - استخدام الويدجت المحدثة
          if (state is UnitFormReady && state.unitTypeFields.isNotEmpty) ...[
            const SizedBox(height: 30),
            DynamicFieldsWidget(
              fields: state.unitTypeFields,
              values: _dynamicFieldValues,
              onChanged: (values) {
                setState(() {
                  _dynamicFieldValues = values;
                });
                _updateDynamicFields();
              },
              isReadOnly: false,
            ),
          ],
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildReviewStep ضمن مسار إدارة الوحدات.
  /// This method performs the _buildReviewStep operation in the admin unit workflow.
  Widget _buildReviewStep(UnitFormState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مراجعة البيانات',
            style: AppTextStyles.heading2.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          _buildReviewCard(
            title: 'المعلومات الأساسية',
            items: [
              {'label': 'الاسم', 'value': _nameController.text},
              {'label': 'العقار', 'value': _getPropertyName(state)},
              {'label': 'النوع', 'value': _getUnitTypeName(state)},
            ],
          ),

          const SizedBox(height: 16),

          if (_isHasAdults || _isHasChildren) ...[
            _buildReviewCard(
              title: 'السعة والتسعير',
              items: [
                if (_isHasAdults)
                  {'label': 'البالغين', 'value': '$_adultCapacity'},
                if (_isHasChildren)
                  {'label': 'الأطفال', 'value': '$_childrenCapacity'},
                {'label': 'طريقة التسعير', 'value': _getPricingMethodText()},
              ],
            ),
          ] else ...[
            _buildReviewCard(
              title: 'التسعير',
              items: [
                {'label': 'طريقة التسعير', 'value': _getPricingMethodText()},
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Cancellation policy review
          _buildReviewCard(
            title: 'سياسة الإلغاء',
            items: [
              {
                'label': 'السماح بإلغاء الحجز',
                'value': _allowsCancellation ? 'نعم' : 'لا',
              },
              {
                'label': 'نافذة الإلغاء (أيام)',
                'value': _allowsCancellation
                    ? (_cancellationDaysController.text.isEmpty
                        ? 'غير محدد'
                        : _cancellationDaysController.text)
                    : 'غير متاح',
              },
            ],
          ),

          const SizedBox(height: 16),

          _buildReviewCard(
            title: 'الوصف',
            items: [
              {'label': 'الوصف', 'value': _descriptionController.text},
            ],
          ),

          // عرض الصور إذا وجدت
          if (_selectedLocalImages.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildImagesReviewCard(),
          ],

          // عرض الحقول الديناميكية
          if (state is UnitFormReady &&
              state.unitTypeFields.isNotEmpty &&
              _dynamicFieldValues.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDynamicFieldsReviewCard(state.unitTypeFields),
          ],
        ],
      ),
    );
  }

  // إضافة دالة جديدة لعرض الحقول الديناميكية في المراجعة
  /// ينفذ هذا الأسلوب عملية _buildDynamicFieldsReviewCard ضمن مسار إدارة الوحدات.
  /// This method performs the _buildDynamicFieldsReviewCard operation in the admin unit workflow.
  Widget _buildDynamicFieldsReviewCard(List<UnitTypeField> fields) {
    // فلترة الحقول التي لها قيم فقط
    final fieldsWithValues = fields.where((field) {
      final value = _dynamicFieldValues[field.fieldId];
      return value != null && value.toString().isNotEmpty;
    }).toList();

    if (fieldsWithValues.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
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
          color: AppTheme.darkBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.dynamic_form_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'معلومات إضافية',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...fieldsWithValues.map((field) {
            final value = _dynamicFieldValues[field.fieldId];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Icon(
                          _getFieldIcon(field.fieldTypeId),
                          size: 14,
                          color: AppTheme.textMuted.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            field.displayName,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      _formatFieldValue(field, value),
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
            );
          }),
        ],
      ),
    );
  }

  // إضافة دالة لعرض الصور في المراجعة
  /// ينفذ هذا الأسلوب عملية _buildImagesReviewCard ضمن مسار إدارة الوحدات.
  /// This method performs the _buildImagesReviewCard operation in the admin unit workflow.
  Widget _buildImagesReviewCard() {
    return Container(
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
          color: AppTheme.darkBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.info,
                      AppTheme.info.withValues(alpha: 0.7)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.image_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'الصور',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.info,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.photo_library_rounded,
                size: 14,
                color: AppTheme.textMuted.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                'عدد الصور',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.info.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_selectedLocalImages.length}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.info,
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

  // دالة مساعدة للحصول على أيقونة الحقل
  /// ينفذ هذا الأسلوب عملية _getFieldIcon ضمن مسار إدارة الوحدات.
  /// This method performs the _getFieldIcon operation in the admin unit workflow.
  IconData _getFieldIcon(String fieldType) {
    switch (fieldType) {
      case 'text':
        return Icons.text_fields_rounded;
      case 'textarea':
        return Icons.subject_rounded;
      case 'number':
        return Icons.numbers_rounded;
      case 'currency':
        return Icons.attach_money_rounded;
      case 'boolean':
        return Icons.toggle_on_rounded;
      case 'select':
        return Icons.arrow_drop_down_circle_rounded;
      case 'multiselect':
        return Icons.checklist_rounded;
      case 'date':
        return Icons.calendar_today_rounded;
      case 'email':
        return Icons.email_rounded;
      case 'phone':
        return Icons.phone_rounded;
      case 'file':
        return Icons.attach_file_rounded;
      case 'image':
        return Icons.image_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  // دالة مساعدة لتنسيق قيمة الحقل للعرض
  /// ينفذ هذا الأسلوب عملية _formatFieldValue ضمن مسار إدارة الوحدات.
  /// This method performs the _formatFieldValue operation in the admin unit workflow.
  String _formatFieldValue(UnitTypeField field, dynamic value) {
    if (value == null) return 'غير محدد';

    switch (field.fieldTypeId) {
      case 'boolean':
        return value == true ? 'نعم' : 'لا';

      case 'currency':
        if (value is num) {
          return '${value.toStringAsFixed(2)} ريال';
        }
        return '$value ريال';

      case 'date':
        if (value is String) {
          try {
            final date = DateTime.parse(value);
            return '${date.day}/${date.month}/${date.year}';
          } catch (_) {
            return value;
          }
        } else if (value is DateTime) {
          return '${value.day}/${value.month}/${value.year}';
        }
        return value.toString();

      case 'multiselect':
        if (value is List) {
          return value.join('، ');
        }
        return value.toString();

      case 'select':
        return value.toString();

      case 'number':
        return value.toString();

      case 'phone':
        final phone = value.toString();
        if (phone.length == 10) {
          return '${phone.substring(0, 4)} ${phone.substring(4, 7)} ${phone.substring(7)}';
        }
        return phone;

      case 'email':
        return value.toString().toLowerCase();

      case 'file':
      case 'image':
        if (value is String && value.isNotEmpty) {
          final fileName = value.split('/').last;
          return fileName.length > 20
              ? '...${fileName.substring(fileName.length - 20)}'
              : fileName;
        }
        return 'ملف مرفق';

      default:
        return value.toString();
    }
  }

  /// ينفذ هذا الأسلوب عملية _buildPropertySelector ضمن مسار إدارة الوحدات.
  /// This method performs the _buildPropertySelector operation in the admin unit workflow.
  Widget _buildPropertySelector(UnitFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'العقار',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            context.push(
              '/helpers/search/properties',
              extra: {
                'allowMultiSelect': false,
                'onPropertySelected': (Property property) {
                  setState(() {
                    _selectedPropertyId = property.id;
                    _selectedPropertyName = property.name;
                    _selectedUnitTypeId = null;
                  });
                  context.read<UnitFormBloc>().add(
                        PropertySelectedEvent(
                          propertyId: property.id,
                          propertyTypeId: property.typeId,
                        ),
                      );
                },
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            child: Row(
              children: [
                Icon(
                  Icons.home_work_outlined,
                  color: AppTheme.primaryBlue.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedPropertyName ?? 'اختر العقار',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _selectedPropertyName == null
                          ? AppTheme.textMuted.withValues(alpha: 0.5)
                          : AppTheme.textWhite,
                    ),
                  ),
                ),
                Icon(
                  Icons.search,
                  color: AppTheme.primaryBlue.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget _buildUnitTypeSelector(UnitFormState state) {
  //   List<DropdownMenuItem<String>> items = [];

  //   if (state is UnitFormReady && state.availableUnitTypes.isNotEmpty) {
  //     items = state.availableUnitTypes.map((unitType) {
  //       _isHasAdults = unitType.isHasAdults;
  //       _isHasChildren = unitType.isHasChildren;
  //       _adultCapacity = _isHasAdults ? 2 : 0;
  //       return DropdownMenuItem<String>(
  //         value: unitType.id,
  //         child: Text(unitType.name),
  //       );
  //     }).toList();
  //   }

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'نوع الوحدة',
  //         style: AppTextStyles.bodyMedium.copyWith(
  //           color: AppTheme.textWhite,
  //           fontWeight: FontWeight.w600,
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 16),
  //         decoration: BoxDecoration(
  //           gradient: LinearGradient(
  //             colors: [
  //               AppTheme.darkCard.withValues(alpha: 0.5),
  //               AppTheme.darkCard.withValues(alpha: 0.3),
  //             ],
  //           ),
  //           borderRadius: BorderRadius.circular(12),
  //           border: Border.all(
  //             color: AppTheme.darkBorder.withValues(alpha: 0.3),
  //             width: 1,
  //           ),
  //         ),
  //         child: DropdownButtonHideUnderline(
  //           child: DropdownButton<String>(
  //             value: _selectedUnitTypeId,
  //             isExpanded: true,
  //             dropdownColor: AppTheme.darkCard,
  //             icon: Icon(
  //               Icons.arrow_drop_down_rounded,
  //               color: AppTheme.primaryBlue.withValues(alpha: 0.7),
  //             ),
  //             style: AppTextStyles.bodyMedium.copyWith(
  //               color: AppTheme.textWhite,
  //             ),
  //             hint: Text(
  //               'اختر نوع الوحدة',
  //               style: AppTextStyles.bodyMedium.copyWith(
  //                 color: AppTheme.textMuted.withValues(alpha: 0.5),
  //               ),
  //             ),
  //             items: items,
  //             onChanged: _selectedPropertyId == null
  //                 ? null
  //                 : (value) {
  //                     setState(() {
  //                       _selectedUnitTypeId = value;
  //                     });
  //                     if (value != null) {
  //                       context.read<UnitFormBloc>().add(
  //                         UnitTypeSelectedEvent(unitTypeId: value),
  //                       );
  //                     }
  //                   },
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
  /// ينفذ هذا الأسلوب عملية _buildUnitTypeSelector ضمن مسار إدارة الوحدات.
  /// This method performs the _buildUnitTypeSelector operation in the admin unit workflow.
  Widget _buildUnitTypeSelector(UnitFormState state) {
    List<DropdownMenuItem<String>> items = [];
    bool isLoadingUnitTypes = false;

    if (state is UnitFormReady) {
      isLoadingUnitTypes = state.isLoadingUnitTypes;

      if (state.availableUnitTypes.isNotEmpty) {
        items = state.availableUnitTypes.map((unitType) {
          return DropdownMenuItem<String>(
            value: unitType.id,
            child: Text(unitType.name),
          );
        }).toList();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'نوع الوحدة',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isLoadingUnitTypes) ...[
              const SizedBox(width: 8),
              // Animated Loading Dots
              _buildLoadingDots(),
            ],
          ],
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.darkCard
                    .withValues(alpha: isLoadingUnitTypes ? 0.3 : 0.5),
                AppTheme.darkCard.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isLoadingUnitTypes
                  ? AppTheme.primaryBlue.withValues(alpha: 0.3)
                  : AppTheme.darkBorder.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedUnitTypeId,
                  isExpanded: true,
                  dropdownColor: AppTheme.darkCard,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isLoadingUnitTypes
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryBlue.withValues(alpha: 0.7),
                              ),
                            ),
                          )
                        : Icon(
                            Icons.arrow_drop_down_rounded,
                            key: const ValueKey('dropdown_icon'),
                            color: AppTheme.primaryBlue.withValues(alpha: 0.7),
                          ),
                  ),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textWhite,
                  ),
                  hint: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      isLoadingUnitTypes
                          ? 'جاري تحميل أنواع الوحدات...'
                          : 'اختر نوع الوحدة',
                      key: ValueKey(isLoadingUnitTypes),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppTheme.textMuted.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  items: items,
                  onChanged: (_selectedPropertyId == null || isLoadingUnitTypes)
                      ? null
                      : (value) {
                          UnitType? selectedUnitType;
                          if (value != null && state is UnitFormReady) {
                            for (final unitType in state.availableUnitTypes) {
                              if (unitType.id == value) {
                                selectedUnitType = unitType;
                                break;
                              }
                            }
                          }
                          setState(() {
                            _selectedUnitTypeId = value;
                            if (selectedUnitType != null) {
                              _isHasAdults = selectedUnitType.isHasAdults;
                              _isHasChildren = selectedUnitType.isHasChildren;
                              _applySelectedUnitTypeCapacityDefaults(
                                selectedUnitType,
                              );
                            } else {
                              _isHasAdults = false;
                              _isHasChildren = false;
                              _adultCapacity = 0;
                              _childrenCapacity = 0;
                            }
                          });
                          _updateCapacity();
                          if (value != null) {
                            context.read<UnitFormBloc>().add(
                                  UnitTypeSelectedEvent(unitTypeId: value),
                                );
                          }
                        },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // أضف هذه الدالة المساعدة بعد دالة _buildUnitTypeSelector
  /// ينفذ هذا الأسلوب عملية _buildLoadingDots ضمن مسار إدارة الوحدات.
  /// This method performs the _buildLoadingDots operation in the admin unit workflow.
  Widget _buildLoadingDots() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.3;
            final opacity = ((value - delay).clamp(0.0, 1.0) * 2 - 1).clamp(
              0.0,
              1.0,
            );

            return AnimatedOpacity(
              opacity: opacity,
              duration: const Duration(milliseconds: 300),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
      onEnd: () {},
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildPricingMethodSelector ضمن مسار إدارة الوحدات.
  /// This method performs the _buildPricingMethodSelector operation in the admin unit workflow.
  Widget _buildPricingMethodSelector() {
    final methods = [
      {'value': 'daily', 'label': 'لليلة الواحدة'},
      {'value': 'weekly', 'label': 'للأسبوع'},
      {'value': 'monthly', 'label': 'للشهر'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طريقة التسعير',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children: methods.map((method) {
            final isSelected = _pricingMethod == method['value'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _pricingMethod = method['value']!;
                });
                _updatePricing();
                HapticFeedback.lightImpact();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.primaryGradient : null,
                  color: isSelected
                      ? null
                      : AppTheme.darkCard.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryBlue.withValues(alpha: 0.5)
                        : AppTheme.darkBorder.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  method['label']!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected ? Colors.white : AppTheme.textMuted,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildInputField ضمن مسار إدارة الوحدات.
  /// This method performs the _buildInputField operation in the admin unit workflow.
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    Function(String)? onChanged,
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
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: AppTextStyles.bodyMedium.copyWith(color: AppTheme.textWhite),
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
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildCapacityCounter ضمن مسار إدارة الوحدات.
  /// This method performs the _buildCapacityCounter operation in the admin unit workflow.
  Widget _buildCapacityCounter({
    required String label,
    required int value,
    required IconData icon,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Container(
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
          color: AppTheme.darkBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onDecrement();
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.darkSurface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.darkBorder.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.remove,
                    color: AppTheme.textMuted,
                    size: 18,
                  ),
                ),
              ),
              Text(
                '$value',
                style: AppTextStyles.heading3.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onIncrement();
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildCapacityReferenceCard ضمن مسار إدارة الوحدات.
  /// This method performs the _buildCapacityReferenceCard operation in the admin unit workflow.
  Widget _buildCapacityReferenceCard(UnitType unitType) {
    final totalCapacity = _adultCapacity + _childrenCapacity;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص السعة',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'الإجمالي الحالي: $totalCapacity',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          if (unitType.maxCapacity > 0) ...[
            const SizedBox(height: 4),
            Text(
              'السعة المرجعية لنوع الوحدة: ${unitType.maxCapacity}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildReviewCard ضمن مسار إدارة الوحدات.
  /// This method performs the _buildReviewCard operation in the admin unit workflow.
  Widget _buildReviewCard({
    required String title,
    required List<Map<String, String>> items,
  }) {
    return Container(
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
          color: AppTheme.darkBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['label']!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppTheme.textMuted,
                    ),
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
            ),
          ),
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildActionButtons ضمن مسار إدارة الوحدات.
  /// This method performs the _buildActionButtons operation in the admin unit workflow.
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
              onTap: _currentStep < 3 ? _nextStep : _submitForm,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: BlocBuilder<UnitFormBloc, UnitFormState>(
                    builder: (context, state) {
                      if (state is UnitFormLoading) {
                        return const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        );
                      }
                      return Text(
                        _currentStep < 3 ? 'التالي' : 'إضافة الوحدة',
                        style: AppTextStyles.buttonMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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

  // Helper Methods
  /// ينفذ هذا الأسلوب عملية _updateCapacity ضمن مسار إدارة الوحدات.
  /// This method performs the _updateCapacity operation in the admin unit workflow.
  void _updateCapacity() {
    context.read<UnitFormBloc>().add(
          UpdateCapacityEvent(
            adultCapacity: _adultCapacity,
            childrenCapacity: _childrenCapacity,
          ),
        );
  }

  /// ينفذ هذا الأسلوب عملية _applySelectedUnitTypeCapacityDefaults ضمن مسار إدارة الوحدات.
  /// This method performs the _applySelectedUnitTypeCapacityDefaults operation in the admin unit workflow.
  void _applySelectedUnitTypeCapacityDefaults(UnitType unitType) {
    _adultCapacity = unitType.isHasAdults ? 1 : 0;
    _childrenCapacity = 0;
  }

  // Helper Methods
  /// ينفذ هذا الأسلوب عملية _updateUnitImage ضمن مسار إدارة الوحدات.
  /// This method performs the _updateUnitImage operation in the admin unit workflow.
  void _updateUnitImage() {
    context.read<UnitFormBloc>().add(
          UpdateUnitImageEvent(images: _selectedLocalImages),
        );
  }

  /// ينفذ هذا الأسلوب عملية _updatePricing ضمن مسار إدارة الوحدات.
  /// This method performs the _updatePricing operation in the admin unit workflow.
  void _updatePricing() {
    final pricingMethod = _getPricingMethodEnum();

    context.read<UnitFormBloc>().add(
          UpdatePricingEvent(pricingMethod: pricingMethod),
        );
  }

  /// ينفذ هذا الأسلوب عملية _updateFeatures ضمن مسار إدارة الوحدات.
  /// This method performs the _updateFeatures operation in the admin unit workflow.
  void _updateFeatures() {
    if (_featuresController.text.isNotEmpty) {
      context.read<UnitFormBloc>().add(
            UpdateFeaturesEvent(features: _featuresController.text),
          );
    }
  }

  /// ينفذ هذا الأسلوب عملية _updateUnitName ضمن مسار إدارة الوحدات.
  /// This method performs the _updateUnitName operation in the admin unit workflow.
  void _updateUnitName() {
    // if (_nameController.text.isNotEmpty) {
    context.read<UnitFormBloc>().add(
          UpdateUnitNameEvent(name: _nameController.text),
        );
    // }
  }

  /// ينفذ هذا الأسلوب عملية _updateDescription ضمن مسار إدارة الوحدات.
  /// This method performs the _updateDescription operation in the admin unit workflow.
  void _updateDescription() {
    // if (_descriptionController.text.isNotEmpty) {
    context.read<UnitFormBloc>().add(
          UpdateDescriptionEvent(description: _descriptionController.text),
        );
    // }
  }

  /// ينفذ هذا الأسلوب عملية _updateDynamicFields ضمن مسار إدارة الوحدات.
  /// This method performs the _updateDynamicFields operation in the admin unit workflow.
  void _updateDynamicFields() {
    context.read<UnitFormBloc>().add(
          UpdateDynamicFieldsEvent(values: _dynamicFieldValues),
        );
  }

  /// ينفذ هذا الأسلوب عملية _getPropertyName ضمن مسار إدارة الوحدات.
  /// This method performs the _getPropertyName operation in the admin unit workflow.
  String _getPropertyName(UnitFormState state) {
    if (_selectedPropertyName != null) {
      return _selectedPropertyName!;
    }
    return 'غير محدد';
  }

  /// ينفذ هذا الأسلوب عملية _getUnitTypeName ضمن مسار إدارة الوحدات.
  /// This method performs the _getUnitTypeName operation in the admin unit workflow.
  String _getUnitTypeName(UnitFormState state) {
    if (state is UnitFormReady && state.selectedUnitType != null) {
      return state.selectedUnitType!.name;
    }
    return 'غير محدد';
  }

  /// ينفذ هذا الأسلوب عملية _getPricingMethodText ضمن مسار إدارة الوحدات.
  /// This method performs the _getPricingMethodText operation in the admin unit workflow.
  String _getPricingMethodText() {
    switch (_pricingMethod) {
      case 'daily':
        return 'لليوم الواحد';
      case 'weekly':
        return 'للأسبوع';
      case 'monthly':
        return 'للشهر';
      default:
        return 'للساعة';
    }
  }

  /// ينفذ هذا الأسلوب عملية _handleSystemBack ضمن مسار إدارة الوحدات.
  /// This method performs the _handleSystemBack operation in the admin unit workflow.
  Future<void> _handleSystemBack() async {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.unfocus();
      return;
    }

    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      return;
    }

    if (mounted) {
      context.pop();
    }
  }

  /// ينفذ هذا الأسلوب عملية _getPricingMethodEnum ضمن مسار إدارة الوحدات.
  /// This method performs the _getPricingMethodEnum operation in the admin unit workflow.
  PricingMethod _getPricingMethodEnum() {
    switch (_pricingMethod) {
      case 'daily':
        return PricingMethod.daily;
      case 'weekly':
        return PricingMethod.weekly;
      case 'monthly':
        return PricingMethod.monthly;
      default:
        return PricingMethod.hourly;
    }
  }

  /// ينفذ هذا الأسلوب عملية _handleBack ضمن مسار إدارة الوحدات.
  /// This method performs the _handleBack operation in the admin unit workflow.
  void _handleBack() {
    _handleSystemBack();
  }

  /// ينفذ هذا الأسلوب عملية _previousStep ضمن مسار إدارة الوحدات.
  /// This method performs the _previousStep operation in the admin unit workflow.
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  /// ينفذ هذا الأسلوب عملية _nextStep ضمن مسار إدارة الوحدات.
  /// This method performs the _nextStep operation in the admin unit workflow.
  void _nextStep() {
    if (_currentStep < 3) {
      // Validate current step
      bool isValid = true;

      if (_currentStep == 0) {
        isValid = _validateBasicInfo();
      } else if (_currentStep == 1) {
        isValid = _validateCapacityPricing();
      } else if (_currentStep == 2) {
        isValid = _validateDynamicFields();
      }

      if (isValid) {
        setState(() {
          _currentStep++;
        });
      }
    }
  }

  /// ينفذ هذا الأسلوب عملية _validateBasicInfo ضمن مسار إدارة الوحدات.
  /// This method performs the _validateBasicInfo operation in the admin unit workflow.
  bool _validateBasicInfo() {
    if (_nameController.text.isEmpty ||
        _selectedPropertyId == null ||
        _selectedUnitTypeId == null ||
        _descriptionController.text.isEmpty) {
      _showErrorMessage('الرجاء ملء جميع الحقول المطلوبة');
      return false;
    }
    return true;
  }

  /// ينفذ هذا الأسلوب عملية _validateCapacityPricing ضمن مسار إدارة الوحدات.
  /// This method performs the _validateCapacityPricing operation in the admin unit workflow.
  bool _validateCapacityPricing() {
    return true;
  }

  /// ينفذ هذا الأسلوب عملية _validateDynamicFields ضمن مسار إدارة الوحدات.
  /// This method performs the _validateDynamicFields operation in the admin unit workflow.
  bool _validateDynamicFields() {
    final state = context.read<UnitFormBloc>().state;

    if (state is! UnitFormReady) {
      return true; // لا يمكن التحقق بدون بيانات النوع، لا نمنع التقدم هنا
    }

    final requiredFields =
        state.unitTypeFields.where((f) => f.isRequired).toList();

    if (requiredFields.isEmpty) {
      return true;
    }

    final missing = <String>[];

    for (final field in requiredFields) {
      final value = _dynamicFieldValues[field.fieldId];
      if (value == null || value.toString().trim().isEmpty) {
        missing.add(field.displayName);
      }
    }

    if (missing.isNotEmpty) {
      _showErrorMessage(
        'الرجاء تعبئة جميع الحقول الإضافية الإلزامية قبل المتابعة',
      );
      return false;
    }

    return true;
  }

  /// ينفذ هذا الأسلوب عملية _submitForm ضمن مسار إدارة الوحدات.
  /// This method performs the _submitForm operation in the admin unit workflow.
  void _submitForm() {
    if (_formKey.currentState!.validate() && _validateDynamicFields()) {
      // تأكد من تحديث جميع البيانات قبل الإرسال
      _updateUnitName();
      _updateDescription();
      _updatePricing();
      _updateFeatures();
      _updateCapacity();
      _updateUnitImage();
      _updateCancellationPolicy();

      // انتظر قليلاً للتأكد من تحديث البلوك
      final unitFormBloc = context.read<UnitFormBloc>();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) {
          return;
        }
        unitFormBloc.add(SubmitFormEvent());
      });
    }
  }

  /// ينفذ هذا الأسلوب عملية _updateCancellationPolicy ضمن مسار إدارة الوحدات.
  /// This method performs the _updateCancellationPolicy operation in the admin unit workflow.
  void _updateCancellationPolicy() {
    final daysText = _cancellationDaysController.text.trim();
    final days = daysText.isEmpty ? null : int.tryParse(daysText);
    context.read<UnitFormBloc>().add(
          UpdateCancellationPolicyEvent(
            allowsCancellation: _allowsCancellation,
            cancellationWindowDays: days,
          ),
        );
  }

  /// ينفذ هذا الأسلوب عملية _handleCreatedUnit ضمن مسار إدارة الوحدات.
  /// This method performs the _handleCreatedUnit operation in the admin unit workflow.
  Future<void> _handleCreatedUnit(String? unitId) async {
    final createdUnitId = unitId;
    final unitName = _nameController.text.trim();

    final shouldOpenSchedule = await _showAvailabilityPricingPrompt();
    if (!mounted) {
      return;
    }

    if (shouldOpenSchedule &&
        createdUnitId != null &&
        createdUnitId.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => GetIt.instance<DailyScheduleBloc>(),
            child: DailySchedulePage(
              initialUnitId: createdUnitId,
              initialUnitName: unitName.isEmpty ? null : unitName,
            ),
          ),
        ),
      );
      return;
    }

    context.pop();
  }

  /// ينفذ هذا الأسلوب عملية _showAvailabilityPricingPrompt ضمن مسار إدارة الوحدات.
  /// This method performs the _showAvailabilityPricingPrompt operation in the admin unit workflow.
  Future<bool> _showAvailabilityPricingPrompt() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.darkCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'تم إنشاء الوحدة',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'حتى تظهر الوحدة في تطبيق العميل عند البحث بالتواريخ، يلزم ضبط الإتاحة والتسعير اليومي لها الآن.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
              height: 1.6,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'لاحقاً',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.calendar_month_rounded, size: 18),
              label: const Text('إعداد الآن'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  /// ينفذ هذا الأسلوب عملية _showErrorMessage ضمن مسار إدارة الوحدات.
  /// This method performs the _showErrorMessage operation in the admin unit workflow.
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// يمثل هذا الكلاس _CreateUnitBackgroundPainter البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for _CreateUnitBackgroundPainter in the admin unit workflow.
class _CreateUnitBackgroundPainter extends CustomPainter {
  /// This field keeps the glowIntensity value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة glowIntensity التي يعتمد عليها مسار إدارة الوحدات.
  final double glowIntensity;

  /// ينشئ هذا المُنشئ مثيلاً من _CreateUnitBackgroundPainter.
  /// This constructor creates an instance of _CreateUnitBackgroundPainter.
  _CreateUnitBackgroundPainter({required this.glowIntensity});

  /// ينفذ هذا الأسلوب عملية paint ضمن مسار إدارة الوحدات.
  /// This method performs the paint operation in the admin unit workflow.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw glowing orbs
    paint.shader = RadialGradient(
      colors: [
        AppTheme.primaryBlue.withValues(alpha: 0.1 * glowIntensity),
        AppTheme.primaryBlue.withValues(alpha: 0.05 * glowIntensity),
        Colors.transparent,
      ],
    ).createShader(
      Rect.fromCircle(
        center: Offset(size.width * 0.8, size.height * 0.2),
        radius: 150,
      ),
    );

    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 150, paint);

    paint.shader = RadialGradient(
      colors: [
        AppTheme.primaryPurple.withValues(alpha: 0.1 * glowIntensity),
        AppTheme.primaryPurple.withValues(alpha: 0.05 * glowIntensity),
        Colors.transparent,
      ],
    ).createShader(
      Rect.fromCircle(
        center: Offset(size.width * 0.2, size.height * 0.7),
        radius: 100,
      ),
    );

    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.7), 100, paint);
  }

  /// ينفذ هذا الأسلوب عملية shouldRepaint ضمن مسار إدارة الوحدات.
  /// This method performs the shouldRepaint operation in the admin unit workflow.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
