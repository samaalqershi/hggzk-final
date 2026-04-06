import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hggzkportal/core/theme/app_text_styles.dart';
import 'package:hggzkportal/core/theme/app_theme.dart';
import 'package:hggzkportal/features/admin_nearby_places/domain/entities/nearby_place.dart';

class NearbyPlaceFormPage extends StatefulWidget {
  final String propertyId;
  final String propertyName;
  final NearbyPlace? nearbyPlace;

  const NearbyPlaceFormPage({
    super.key,
    required this.propertyId,
    required this.propertyName,
    this.nearbyPlace,
  });

  @override
  State<NearbyPlaceFormPage> createState() => _NearbyPlaceFormPageState();
}

class _NearbyPlaceFormPageState extends State<NearbyPlaceFormPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _glowController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _nameEnController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _descriptionEnController;
  late final TextEditingController _categoryController;
  late final TextEditingController _iconController;
  late final TextEditingController _distanceController;
  late final TextEditingController _walkingController;
  late final TextEditingController _drivingController;
  late final TextEditingController _orderController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;

  int _currentStep = 0;
  late bool _isActive;

  bool get _isEditMode => widget.nearbyPlace != null;

  static const List<_NearbyPreset> _presets = [
    _NearbyPreset(
        'معلم تاريخي', 'historic_site', Icons.account_balance_rounded),
    _NearbyPreset('مطعم', 'restaurant', Icons.restaurant_rounded),
    _NearbyPreset('مستشفى', 'hospital', Icons.local_hospital_rounded),
    _NearbyPreset('سوق', 'market', Icons.shopping_bag_rounded),
    _NearbyPreset('مول', 'mall', Icons.storefront_rounded),
    _NearbyPreset('مسجد', 'mosque', Icons.mosque_rounded),
    _NearbyPreset('جامعة', 'university', Icons.school_rounded),
    _NearbyPreset('حديقة', 'park', Icons.park_rounded),
    _NearbyPreset('شاطئ', 'beach', Icons.waves_rounded),
    _NearbyPreset('كورنيش', 'corniche', Icons.landscape_rounded),
  ];

  @override
  void initState() {
    super.initState();
    final place = widget.nearbyPlace;
    _nameController = TextEditingController(text: place?.name ?? '');
    _nameEnController = TextEditingController(text: place?.nameEn ?? '');
    _descriptionController =
        TextEditingController(text: place?.description ?? '');
    _descriptionEnController =
        TextEditingController(text: place?.descriptionEn ?? '');
    _categoryController = TextEditingController(text: place?.category ?? '');
    _iconController = TextEditingController(text: place?.icon ?? '');
    _distanceController = TextEditingController(
      text: place == null ? '' : place.distanceInMeters.toString(),
    );
    _walkingController =
        TextEditingController(text: place?.walkingMinutes?.toString() ?? '');
    _drivingController =
        TextEditingController(text: place?.drivingMinutes?.toString() ?? '');
    _orderController = TextEditingController(
      text: place == null ? '1' : place.displayOrder.toString(),
    );
    _latController =
        TextEditingController(text: place?.latitude?.toString() ?? '');
    _lngController =
        TextEditingController(text: place?.longitude?.toString() ?? '');
    _isActive = place?.isActive ?? true;
    _initializeAnimations();
  }

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _glowController.dispose();
    _nameController.dispose();
    _nameEnController.dispose();
    _descriptionController.dispose();
    _descriptionEnController.dispose();
    _categoryController.dispose();
    _iconController.dispose();
    _distanceController.dispose();
    _walkingController.dispose();
    _drivingController.dispose();
    _orderController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: Stack(
          children: [
            _buildAnimatedBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildProgressIndicator(),
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildFormContent(),
                      ),
                    ),
                  ),
                  _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            painter: _NearbyPlaceBackgroundPainter(
              glowIntensity: _glowController.value,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.primaryGradient.createShader(bounds),
                  child: Text(
                    _isEditMode ? 'تعديل مكان قريب' : 'إضافة مكان قريب',
                    style: AppTextStyles.heading2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isEditMode
                      ? 'قم بتحديث بيانات المكان بنفس تجربة تعديل العقار والوحدة'
                      : 'قم بملء البيانات المطلوبة لإضافة مكان قريب جديد',
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

  Widget _buildProgressIndicator() {
    final steps = [
      'المعلومات الأساسية',
      'الموقع والزمن',
      'الإحداثيات والظهور',
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

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: IndexedStack(
        index: _currentStep,
        children: [
          _buildBasicInfoStep(),
          _buildLocationTimeStep(),
          _buildCoordinatesVisibilityStep(),
          _buildReviewStep(),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPropertyContextBanner(),
          const SizedBox(height: 24),
          _buildSectionTitle(
            'المعلومات الأساسية',
            'هذه البيانات تمثل الهوية الرئيسية للمكان القريب داخل البورتال وتطبيق العميل.',
          ),
          const SizedBox(height: 16),
          _buildStepCard(
            child: Column(
              children: [
                _buildInputField(
                  controller: _nameController,
                  label: 'اسم المكان',
                  hint: 'مثال: باب اليمن',
                  icon: Icons.place_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الرجاء إدخال اسم المكان';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  controller: _nameEnController,
                  label: 'الاسم بالإنجليزية',
                  hint: 'Example: Bab Al-Yemen',
                  icon: Icons.translate_rounded,
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  controller: _descriptionController,
                  label: 'الوصف',
                  hint: 'وصف مختصر يظهر في الملخص وصفحة العميل',
                  icon: Icons.description_rounded,
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  controller: _descriptionEnController,
                  label: 'الوصف بالإنجليزية',
                  hint: 'Short English description',
                  icon: Icons.language_rounded,
                  maxLines: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle(
            'النوع والهوية البصرية',
            'اختيار التصنيف والأيقونة بنفس نمط إدارات النظام يساعد على تنظيم العرض داخل الخرائط والقوائم.',
          ),
          const SizedBox(height: 16),
          _buildStepCard(
            child: Column(
              children: [
                _buildInputField(
                  controller: _categoryController,
                  label: 'التصنيف',
                  hint: 'مثال: معلم تاريخي',
                  icon: Icons.category_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الرجاء إدخال التصنيف';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  controller: _iconController,
                  label: 'مفتاح الأيقونة',
                  hint: 'historic_site أو restaurant',
                  icon: Icons.auto_awesome_mosaic_rounded,
                ),
                const SizedBox(height: 20),
                _buildPresetPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTimeStep() {
    final hasComputedMetrics = _distanceController.text.trim().isNotEmpty ||
        _walkingController.text.trim().isNotEmpty ||
        _drivingController.text.trim().isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            'المسافة والزمن',
            'سيقوم الباك اند باحتساب المسافة ومدة المشي والقيادة تلقائيًا من Google بعد الحفظ اعتمادًا على إحداثيات العقار والمكان.',
          ),
          const SizedBox(height: 16),
          _buildStepCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.route_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'احتساب تلقائي من Google',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppTheme.textWhite,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'لن تحتاج لإدخال المسافة أو الدقائق يدويًا. عند الحفظ سيقوم الخادم باحتسابها تلقائيًا من الإحداثيات.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppTheme.textMuted,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  controller: _orderController,
                  label: 'ترتيب العرض',
                  hint: '1',
                  icon: Icons.format_list_numbered_rounded,
                  keyboardType: TextInputType.number,
                ),
                if (hasComputedMetrics) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildReadonlyMetricCard(
                          title: 'المسافة الحالية',
                          value: _distanceController.text.trim().isEmpty
                              ? 'سيتم احتسابها'
                              : '${_distanceController.text.trim()} م',
                          icon: Icons.social_distance_rounded,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildReadonlyMetricCard(
                          title: 'المشي الحالي',
                          value: _walkingController.text.trim().isEmpty
                              ? 'غير متوفر'
                              : '${_walkingController.text.trim()} دقيقة',
                          icon: Icons.directions_walk_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildReadonlyMetricCard(
                          title: 'القيادة الحالية',
                          value: _drivingController.text.trim().isEmpty
                              ? 'غير متوفر'
                              : '${_drivingController.text.trim()} دقيقة',
                          icon: Icons.directions_car_rounded,
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildStepHints(
            items: const [
              'يجب إدخال إحداثيات المكان بدقة حتى يستطيع الخادم حساب المسافة والمدة من Google.',
              'إذا عدلت الإحداثيات لاحقًا فسيعاد احتساب القيم تلقائيًا.',
              'ترتيب العرض الأصغر يظهر أولًا داخل صفحة تفاصيل العقار.',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinatesVisibilityStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            'الإحداثيات والظهور',
            'هذه الخطوة تتحكم في ظهور المكان داخل الخريطة وفي حالة نشره داخل النظام.',
          ),
          const SizedBox(height: 16),
          _buildStepCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: _latController,
                        label: 'خط العرض',
                        hint: '15.3694',
                        icon: Icons.my_location_rounded,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }
                          final lat = double.tryParse(value.trim());
                          if (lat == null || lat < -90 || lat > 90) {
                            return 'خط العرض غير صحيح';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInputField(
                        controller: _lngController,
                        label: 'خط الطول',
                        hint: '44.1910',
                        icon: Icons.explore_rounded,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }
                          final lng = double.tryParse(value.trim());
                          if (lng == null || lng < -180 || lng > 180) {
                            return 'خط الطول غير صحيح';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildStatusCard(),
                const SizedBox(height: 20),
                _buildMiniSummaryCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            'مراجعة البيانات',
            'راجع ملخص المكان القريب قبل الحفظ النهائي تمامًا كما في شاشات إنشاء العقارات والوحدات.',
          ),
          const SizedBox(height: 16),
          _buildReviewHero(),
          const SizedBox(height: 20),
          _buildReviewCard(
            title: 'الهوية الأساسية',
            icon: Icons.place_rounded,
            items: [
              _ReviewItem(
                  'اسم المكان', _displayOrPlaceholder(_nameController.text)),
              _ReviewItem(
                'الاسم بالإنجليزية',
                _displayOrPlaceholder(_nameEnController.text),
              ),
              _ReviewItem(
                  'الوصف', _displayOrPlaceholder(_descriptionController.text)),
              _ReviewItem(
                'الوصف بالإنجليزية',
                _displayOrPlaceholder(_descriptionEnController.text),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildReviewCard(
            title: 'التصنيف والعرض',
            icon: _resolvePreviewIcon(
              _iconController.text,
              _categoryController.text,
            ),
            items: [
              _ReviewItem('العقار', widget.propertyName),
              _ReviewItem(
                  'التصنيف', _displayOrPlaceholder(_categoryController.text)),
              _ReviewItem(
                'مفتاح الأيقونة',
                _displayOrPlaceholder(
                  _iconController.text,
                  fallback: _categoryController.text.trim().isEmpty
                      ? 'سيُشتق من التصنيف'
                      : _categoryController.text.trim(),
                ),
              ),
              _ReviewItem(
                'الحالة',
                _isActive ? 'نشط ويظهر في النظام' : 'غير نشط ومخفي',
              ),
              _ReviewItem(
                'ترتيب العرض',
                _displayOrPlaceholder(_orderController.text, fallback: '0'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildReviewCard(
            title: 'القرب والإحداثيات',
            icon: Icons.route_rounded,
            items: [
              _ReviewItem(
                'المسافة',
                _distanceController.text.trim().isEmpty
                    ? 'غير محددة'
                    : '${_distanceController.text.trim()} م',
              ),
              _ReviewItem(
                'المشي',
                _displayOrPlaceholder(
                  _walkingController.text,
                  fallback: 'غير محدد',
                ),
              ),
              _ReviewItem(
                'القيادة',
                _displayOrPlaceholder(
                  _drivingController.text,
                  fallback: 'غير محدد',
                ),
              ),
              _ReviewItem(
                'الإحداثيات',
                _latController.text.trim().isNotEmpty &&
                        _lngController.text.trim().isNotEmpty
                    ? '${_latController.text.trim()}, ${_lngController.text.trim()}'
                    : 'غير مضافة',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyContextBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withValues(alpha: 0.18),
            AppTheme.primaryPurple.withValues(alpha: 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.apartment_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.propertyName,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isEditMode
                      ? 'أنت الآن في وضع تعديل مكان قريب تابع لهذا العقار'
                      : 'سيتم ربط المكان القريب مباشرة بهذا العقار بعد الحفظ',
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

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading3.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildStepCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.72),
            AppTheme.darkCard.withValues(alpha: 0.48),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: child,
    );
  }

  Widget _buildStepHints({required List<String> items}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.24),
        ),
      ),
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.visibility_rounded, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الحالة والظهور',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'عند التفعيل سيظهر المكان في الإدارة وتطبيق العميل وعلامات الخريطة.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isActive,
            onChanged: (value) => setState(() => _isActive = value),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniSummaryCard() {
    final hasCoordinates = _latController.text.trim().isNotEmpty &&
        _lngController.text.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withValues(alpha: 0.1),
            AppTheme.darkCard.withValues(alpha: 0.42),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasCoordinates
                ? Icons.location_on_rounded
                : Icons.location_off_rounded,
            color: AppTheme.primaryBlue,
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              hasCoordinates
                  ? 'تمت إضافة الإحداثيات وسيظهر المكان داخل الخريطة عند توفر العرض في تطبيق العميل.'
                  : 'لم تتم إضافة الإحداثيات بعد، وسيبقى المكان ظاهرًا كبيانات نصية فقط دون نقطة على الخريطة.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textWhite,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withValues(alpha: 0.16),
            AppTheme.primaryPurple.withValues(alpha: 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              _resolvePreviewIcon(
                  _iconController.text, _categoryController.text),
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayOrPlaceholder(
                    _nameController.text,
                    fallback: 'اسم المكان غير مدخل بعد',
                  ),
                  style: AppTextStyles.heading3.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_displayOrPlaceholder(_categoryController.text, fallback: 'بدون تصنيف')} • ${widget.propertyName}',
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: (_) => setState(() {}),
      validator: validator,
      style: AppTextStyles.bodyMedium.copyWith(color: AppTheme.textWhite),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primaryBlue),
        filled: true,
        fillColor: AppTheme.darkCard.withValues(alpha: 0.7),
        labelStyle: AppTextStyles.bodySmall.copyWith(color: AppTheme.textMuted),
        hintStyle: AppTextStyles.bodySmall.copyWith(
          color: AppTheme.textMuted.withValues(alpha: 0.7),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: AppTheme.darkBorder.withValues(alpha: 0.25),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: AppTheme.darkBorder.withValues(alpha: 0.25),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: AppTheme.primaryBlue.withValues(alpha: 0.9),
            width: 1.2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: AppTheme.error.withValues(alpha: 0.9),
          ),
        ),
      ),
    );
  }

  Widget _buildReadonlyMetricCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'قوالب سريعة',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اختر تصنيفًا جاهزًا لتسريع الإدخال وتوحيد شكل البيانات.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _presets.map((preset) {
              final isSelected =
                  _categoryController.text.trim() == preset.category &&
                      _iconController.text.trim() == preset.iconKey;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _categoryController.text = preset.category;
                    _iconController.text = preset.iconKey;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppTheme.primaryGradient : null,
                    color: !isSelected
                        ? AppTheme.darkSurface.withValues(alpha: 0.45)
                        : null,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryBlue.withValues(alpha: 0.45)
                          : AppTheme.darkBorder.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        preset.icon,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        preset.category,
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard({
    required String title,
    required IconData icon,
    required List<_ReviewItem> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.75),
            AppTheme.darkCard.withValues(alpha: 0.55),
          ],
        ),
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
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 130,
                    child: Text(
                      item.label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.value,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.w600,
                      ),
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
          Expanded(
            child: GestureDetector(
              onTap: _currentStep < 3 ? _nextStep : _submit,
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
                  child: Text(
                    _currentStep < 3
                        ? 'التالي'
                        : _isEditMode
                            ? 'حفظ التعديلات'
                            : 'إضافة المكان',
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
    );
  }

  void _handleBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      return;
    }
    context.pop();
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _nextStep() {
    bool isValid = false;

    if (_currentStep == 0) {
      isValid = _validateBasicInfoStep();
    } else if (_currentStep == 1) {
      isValid = _validateLocationTimeStep();
    } else if (_currentStep == 2) {
      isValid = _validateCoordinatesStep();
    }

    if (isValid) {
      setState(() {
        _currentStep++;
      });
    }
  }

  bool _validateBasicInfoStep() {
    if (_nameController.text.trim().isEmpty ||
        _categoryController.text.trim().isEmpty) {
      _showMessage('الرجاء إدخال اسم المكان والتصنيف قبل المتابعة');
      return false;
    }
    return true;
  }

  bool _validateLocationTimeStep() {
    final orderText = _orderController.text.trim();

    if (orderText.isNotEmpty && int.tryParse(orderText) == null) {
      _showMessage('ترتيب العرض يجب أن يكون رقمًا صحيحًا');
      return false;
    }

    return true;
  }

  bool _validateCoordinatesStep() {
    if (!_validateCoordinatesPair()) {
      return false;
    }
    return true;
  }

  void _submit() {
    if (!_validateBasicInfoStep() ||
        !_validateLocationTimeStep() ||
        !_validateCoordinatesStep()) {
      return;
    }

    context.pop({
      if (_isEditMode) 'nearbyPlaceId': widget.nearbyPlace!.id,
      if (!_isEditMode) 'propertyId': widget.propertyId,
      'name': _nameController.text.trim(),
      'nameEn': _nullIfEmpty(_nameEnController.text),
      'description': _nullIfEmpty(_descriptionController.text),
      'descriptionEn': _nullIfEmpty(_descriptionEnController.text),
      'category': _categoryController.text.trim(),
      'icon': _iconController.text.trim().isEmpty
          ? _categoryController.text.trim()
          : _iconController.text.trim(),
      'displayOrder': int.tryParse(_orderController.text.trim()) ?? 0,
      'latitude': double.tryParse(_latController.text.trim()),
      'longitude': double.tryParse(_lngController.text.trim()),
      'isActive': _isActive,
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  bool _validateCoordinatesPair() {
    final latText = _latController.text.trim();
    final lngText = _lngController.text.trim();
    final hasLat = latText.isNotEmpty;
    final hasLng = lngText.isNotEmpty;

    if (hasLat != hasLng) {
      _showMessage('يجب إدخال خط العرض وخط الطول معًا أو تركهما فارغين');
      return false;
    }

    if (!hasLat && !hasLng) {
      return true;
    }

    final lat = double.tryParse(latText);
    if (lat == null || lat < -90 || lat > 90) {
      _showMessage('خط العرض غير صحيح');
      return false;
    }

    final lng = double.tryParse(lngText);
    if (lng == null || lng < -180 || lng > 180) {
      _showMessage('خط الطول غير صحيح');
      return false;
    }

    return true;
  }

  String? _nullIfEmpty(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _displayOrPlaceholder(String value, {String fallback = 'غير مدخل'}) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }

  IconData _resolvePreviewIcon(String iconKey, String category) {
    final key = '$iconKey $category'.toLowerCase();
    if (key.contains('hospital') ||
        key.contains('medical') ||
        key.contains('مستشفى')) {
      return Icons.local_hospital_rounded;
    }
    if (key.contains('restaurant') || key.contains('مطعم')) {
      return Icons.restaurant_rounded;
    }
    if (key.contains('market') || key.contains('mall') || key.contains('سوق')) {
      return Icons.shopping_bag_rounded;
    }
    if (key.contains('mosque') ||
        key.contains('جامع') ||
        key.contains('مسجد')) {
      return Icons.mosque_rounded;
    }
    if (key.contains('school') ||
        key.contains('university') ||
        key.contains('جامعة')) {
      return Icons.school_rounded;
    }
    if (key.contains('beach') ||
        key.contains('شاطئ') ||
        key.contains('corniche')) {
      return Icons.waves_rounded;
    }
    if (key.contains('park') || key.contains('حديقة')) {
      return Icons.park_rounded;
    }
    if (key.contains('historic') || key.contains('معلم')) {
      return Icons.account_balance_rounded;
    }
    return Icons.place_rounded;
  }
}

class _NearbyPreset {
  final String category;
  final String iconKey;
  final IconData icon;

  const _NearbyPreset(this.category, this.iconKey, this.icon);
}

class _ReviewItem {
  final String label;
  final String value;

  const _ReviewItem(this.label, this.value);
}

class _NearbyPlaceBackgroundPainter extends CustomPainter {
  final double glowIntensity;

  _NearbyPlaceBackgroundPainter({required this.glowIntensity});

  @override
  void paint(Canvas canvas, Size size) {
    final primaryPaint = Paint()
      ..color =
          AppTheme.primaryBlue.withValues(alpha: 0.08 + (glowIntensity * 0.08))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    final secondaryPaint = Paint()
      ..color = AppTheme.primaryPurple
          .withValues(alpha: 0.06 + (glowIntensity * 0.06))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);

    canvas.drawCircle(
      Offset(size.width * 0.88, size.height * 0.12),
      160 + (glowIntensity * 25),
      primaryPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.14, size.height * 0.76),
      190 + (glowIntensity * 30),
      secondaryPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _NearbyPlaceBackgroundPainter oldDelegate) {
    return oldDelegate.glowIntensity != glowIntensity;
  }
}
