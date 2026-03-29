// lib/features/admin_amenities/presentation/pages/create_amenity_page.dart

import 'package:hggzkportal/core/theme/app_text_styles.dart';
import 'package:hggzkportal/core/theme/app_theme.dart';
import 'package:hggzkportal/features/admin_amenities/presentation/widgets/amenity_icon_picker.dart';
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

/// Arabic: صفحة إنشاء مرفق جديد مع نموذج متعدد الخطوات وتغذية بصرية متدرجة.
/// English: Page for creating a new amenity using a multi-step form and animated visual feedback.
class CreateAmenityPage extends StatefulWidget {
  /// Arabic: ينشئ صفحة إنشاء المرفق دون معاملات لأن كل المدخلات تُجمع داخل النموذج نفسه.
  /// English: Creates the create-amenity page; the form itself gathers all required inputs.
  const CreateAmenityPage({super.key});

  /// Arabic: ينشئ الحالة التي تدير النموذج متعدد الخطوات وحركات الصفحة.
  /// English: Creates the state object that manages the multi-step form and page animations.
  @override
  State<CreateAmenityPage> createState() => _CreateAmenityPageState();
}

/// Arabic: تدير هذه الحالة إدخال بيانات المرفق الجديد والتحقق منها ثم إرسالها.
/// English: Manages entry, validation, and submission of the new amenity data.
class _CreateAmenityPageState extends State<CreateAmenityPage>
    with TickerProviderStateMixin {
  /// Arabic: يتحكم في ظهور النموذج وانتقالاته الرئيسية عند فتح الصفحة.
  /// English: Controls the main form entrance and transition animations.
  late AnimationController _animationController;

  /// Arabic: يدير نبض الخلفية المتوهجة التي تعطي الصفحة طابعًا حيًا.
  /// English: Drives the pulsing glow background that gives the page a lively feel.
  late AnimationController _glowController;

  /// Arabic: يحدد شفافية ظهور المحتوى الرئيسي عند التهيئة.
  /// English: Controls the fade-in of the main content during setup.
  late Animation<double> _fadeAnimation;

  /// Arabic: يحدد انزلاق المحتوى الرئيسي من الأسفل إلى موضعه النهائي.
  /// English: Controls the slide-in motion of the main content.
  late Animation<Offset> _slideAnimation;

  /// Arabic: مفتاح النموذج المستخدم للتحقق من صحة الحقول قبل الإرسال.
  /// English: Form key used to validate fields before submission.
  final _formKey = GlobalKey<FormState>();

  /// Arabic: يتحكم في قيمة حقل اسم المرفق.
  /// English: Controls the amenity name input value.
  final TextEditingController _nameController = TextEditingController();

  /// Arabic: يتحكم في قيمة حقل اسم المرفق بالإنجليزية.
  /// English: Controls the English amenity name input value.
  final TextEditingController _nameEnController = TextEditingController();

  /// Arabic: يتحكم في قيمة حقل الوصف.
  /// English: Controls the description input value.
  final TextEditingController _descriptionController = TextEditingController();

  /// Arabic: يتحكم في قيمة حقل الوصف الإنجليزي.
  /// English: Controls the English description input value.
  final TextEditingController _descriptionEnController =
      TextEditingController();

  /// Arabic: الأيقونة المختارة حاليًا للمرفق الجديد.
  /// English: Currently selected icon for the new amenity.
  String _selectedIcon = 'star_rounded';

  /// Arabic: معرّف نوع العقار المرتبط اختياريًا بالمرفق.
  /// English: Optional property type identifier linked to the amenity.
  String? _selectedPropertyTypeId;

  /// Arabic: يحدد ما إذا كان المرفق سيصبح افتراضيًا لهذا النوع من العقارات.
  /// English: Indicates whether this amenity should be the default for the selected property type.
  bool _isDefaultForType = false;

  /// Arabic: الخطوة الحالية ضمن النموذج متعدد المراحل.
  /// English: Current step in the multi-step form flow.
  int _currentStep = 0;

  /// Arabic: يجهز الأنيميشنات والبيانات الأولية فور إنشاء الحالة.
  /// English: Prepares animations and initial state as soon as the widget state is created.
  @override
  void initState() {
    super.initState();

    _initializeAnimations();
  }

  /// Arabic: يجهز أنيميشن الظهور والانزلاق والتوهج قبل عرض الصفحة.
  /// English: Prepares the fade, slide, and glow animations before the page is shown.
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _animationController.forward();
    });
  }

  /// Arabic: يحرر جميع المتحكمات حتى لا تبقى موارد الرسوم والحقول معلقة.
  /// English: Releases all controllers so animation and input resources are not leaked.
  @override
  void dispose() {
    _animationController.dispose();
    _glowController.dispose();
    _nameController.dispose();
    _nameEnController.dispose();
    _descriptionController.dispose();
    _descriptionEnController.dispose();
    super.dispose();
  }

  /// Arabic: يبني الصفحة الكاملة بما فيها الاستماع لحالات الـ bloc والنموذج متعدد الخطوات.
  /// English: Builds the full page, including bloc listening and the multi-step form layout.
  @override
  Widget build(BuildContext context) {
    return BlocListener<AmenitiesBloc, AmenitiesState>(
      listener: (context, state) {
        if (state is AmenityOperationSuccess) {
          _showSuccessMessage('تم إنشاء المرفق بنجاح');
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) context.pop({'refresh': true});
          });
        } else if (state is AmenitiesError) {
          _showErrorMessage(state.message);
        }
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
    );
  }

  /// Arabic: يبني الخلفية المتحركة متعددة الطبقات خلف النموذج.
  /// English: Builds the layered animated background behind the form.
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
            painter: _CreateAmenityBackgroundPainter(
              glowIntensity: _glowController.value,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  /// Arabic: يبني شريط الرأس الذي يحتوي على العنوان وزر الرجوع.
  /// English: Builds the header area containing the title and back button.
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
                    'إضافة مرفق جديد',
                    style: AppTextStyles.heading2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'قم بملء البيانات المطلوبة لإضافة المرفق',
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

  /// Arabic: يبني مؤشر الخطوات الذي يوضح تقدم المستخدم داخل النموذج.
  /// English: Builds the step indicator that shows progress through the form.
  Widget _buildProgressIndicator() {
    final steps = ['المعلومات الأساسية', 'الإعدادات', 'المراجعة'];

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

  /// Arabic: يجمع الخطوات داخل نموذج واحد حتى يتم التحقق والإرسال من مكان موحد.
  /// English: Wraps all steps in a single form so validation and submission happen from one place.
  Widget _buildFormContent() {
    return Form(
      key: _formKey,
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

  /// Arabic: يبني خطوة المعلومات الأساسية التي تجمع الاسم والوصف والأيقونة.
  /// English: Builds the basic info step that collects the name, description, and icon.
  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          _buildInputField(
            controller: _nameEnController,
            label: 'اسم المرفق بالإنجليزية',
            hint: 'Enter amenity name in English',
            icon: Icons.translate_rounded,
          ),

          const SizedBox(height: 20),

          // Description Field
          _buildInputField(
            controller: _descriptionController,
            label: 'الوصف',
            hint: 'وصف مختصر للمرفق (اختياري)',
            icon: Icons.description_rounded,
            maxLines: 5,
          ),

          const SizedBox(height: 20),

          _buildInputField(
            controller: _descriptionEnController,
            label: 'الوصف بالإنجليزية',
            hint: 'Short English description (optional)',
            icon: Icons.language_rounded,
            maxLines: 5,
          ),

          const SizedBox(height: 20),

          // Icon Selector
          _buildIconSelector(),
        ],
      ),
    );
  }

  /// Arabic: يبني خطوة الإعدادات التي تربط المرفق بنوع عقار وتحدد الإعدادات الافتراضية.
  /// English: Builds the settings step that links the amenity to a property type and default behavior.
  Widget _buildSettingsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property Type Selector
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

          // Default for Type Checkbox
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _selectedPropertyTypeId == null ? 0.4 : 1.0,
            child: IgnorePointer(
              ignoring: _selectedPropertyTypeId == null,
              child: _buildSettingItem(
                title: 'تعيين كافتراضي',
                subtitle: 'تعيينه كمرفق افتراضي لنوع العقار المختار',
                icon: Icons.star_rounded,
                trailing: Switch(
                  value: _isDefaultForType,
                  onChanged: (value) {
                    setState(() {
                      _isDefaultForType = value;
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

  /// Arabic: يبني خطوة المراجعة النهائية قبل إرسال إنشاء المرفق.
  /// English: Builds the final review step shown before creating the amenity.
  Widget _buildReviewStep() {
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
              {
                'label': 'الوصف',
                'value': _descriptionController.text.isEmpty
                    ? 'لا يوجد'
                    : _descriptionController.text
              },
              {'label': 'الأيقونة', 'value': 'Icons.$_selectedIcon'},
            ],
          ),
          const SizedBox(height: 16),
          _buildReviewCard(
            title: 'الإعدادات',
            items: [
              {'label': 'نوع العقار', 'value': _getPropertyTypeName()},
              {
                'label': 'مرفق افتراضي',
                'value': _isDefaultForType ? 'نعم' : 'لا'
              },
            ],
          ),
        ],
      ),
    );
  }

  /// Arabic: يفتح منتقي الأيقونات المخصص لاختيار رمز المرفق بصريًا.
  /// English: Opens the custom icon picker used to choose the amenity symbol visually.
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
            color: AppTheme.darkBorder.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withValues(alpha: 0.2),
                    AppTheme.primaryPurple.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getIconFromString(_selectedIcon),
                color: AppTheme.primaryBlue,
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
                  Text(
                    'Icons.$_selectedIcon',
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.textMuted,
                      fontFamily: 'monospace',
                    ),
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
          'نوع العقار (اختياري)',
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
                        if (_selectedPropertyTypeId == null) {
                          _isDefaultForType = false;
                        }
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

  /// Arabic: يبني صفًا واحدًا داخل قسم الإعدادات مع أيقونة ووصف وتحكم نهائي.
  /// English: Builds a single setting row with an icon, description, and trailing control.
  Widget _buildSettingItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget trailing,
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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppTheme.primaryBlue.withValues(alpha: 0.2),
                AppTheme.primaryPurple.withValues(alpha: 0.1),
              ]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
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
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
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

  /// Arabic: يبني بطاقة مراجعة موجزة تعرض مجموعة حقول قبل الإرسال.
  /// English: Builds a compact review card that lists a group of fields before submission.
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
          ...items.map((item) => Padding(
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
              )),
        ],
      ),
    );
  }

  /// Arabic: يبني حقل إدخال مزخرفًا يدعم التحقق وعدة أسطر حسب الحاجة.
  /// English: Builds a decorated input field that supports validation and multiple lines.
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

  /// Arabic: يبني حالة مؤقتة أثناء تحميل أنواع العقار من الخلفية.
  /// English: Builds the temporary loading state while property types are being fetched.
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

  /// Arabic: يبني حالة الخطأ عندما يفشل تحميل أنواع العقار.
  /// English: Builds the error state shown when loading property types fails.
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

  /// Arabic: يبني أزرار التنقل السفلية للانتقال بين الخطوات أو إرسال النموذج.
  /// English: Builds the bottom navigation buttons used to move between steps or submit the form.
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
                      return Text(
                        _currentStep < 2 ? 'التالي' : 'إضافة المرفق',
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

  /// Arabic: يعيد اسم نوع العقار المختار ليظهر في خطوة المراجعة.
  /// English: Returns the selected property type name for display in the review step.
  String _getPropertyTypeName() {
    if (_selectedPropertyTypeId == null) return 'بدون';

    // Try to get the name from the loaded property types
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

  /// Arabic: يحول اسم الأيقونة النصي إلى `IconData` المستخدم فعليًا في الواجهة.
  /// English: Converts the string icon name into the `IconData` used by the UI.
  IconData _getIconFromString(String icon) {
    // Map string to IconData
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

  /// Arabic: يتعامل مع الرجوع من الصفحة، إما خطوة للخلف أو خروجًا من الصفحة.
  /// English: Handles back navigation by moving a step backward or leaving the page.
  void _handleBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      context.pop();
    }
  }

  /// Arabic: يعيد المستخدم إلى الخطوة السابقة داخل النموذج.
  /// English: Moves the user to the previous step in the form flow.
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  /// Arabic: ينتقل إلى الخطوة التالية بعد التحقق من صحة المدخلات المطلوبة.
  /// English: Advances to the next step after validating the required inputs.
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

  /// Arabic: يتحقق من الحد الأدنى من البيانات الأساسية قبل متابعة الإضافة.
  /// English: Validates the minimum basic information before the user proceeds.
  bool _validateBasicInfo() {
    if (_nameController.text.isEmpty) {
      _showErrorMessage('الرجاء إدخال اسم المرفق');
      return false;
    }
    return true;
  }

  /// Arabic: يرسل حدث إنشاء المرفق إلى طبقة الـ bloc بعد نجاح التحقق.
  /// English: Sends the create-amenity event to the bloc after validation succeeds.
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<AmenitiesBloc>().add(
            CreateAmenityEvent(
              name: _nameController.text,
              nameEn: _nameEnController.text.trim().isEmpty
                  ? null
                  : _nameEnController.text.trim(),
              description: _descriptionController.text,
              descriptionEn: _descriptionEnController.text.trim().isEmpty
                  ? null
                  : _descriptionEnController.text.trim(),
              icon: _selectedIcon,
              propertyTypeId: _selectedPropertyTypeId,
              isDefaultForType: _isDefaultForType,
            ),
          );
    }
  }

  /// Arabic: يفتح نافذة اختيار الأيقونة ليغير المستخدم الرمز المخصص للمرفق.
  /// English: Opens the icon selection dialog so the user can change the amenity symbol.
  void _showIconPicker() {
    showDialog(
      context: context,
      builder: (context) => AmenityIconPicker(
        selectedIcon: _selectedIcon,
        onIconSelected: (icon) {
          setState(() => _selectedIcon = icon);
        },
      ),
    );
  }

  /// Arabic: يعرض رسالة نجاح قصيرة بعد اكتمال إنشاء المرفق.
  /// English: Shows a short success message after the amenity is created.
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

  /// Arabic: يعرض رسالة خطأ واضحة عندما تفشل عملية إنشاء المرفق.
  /// English: Shows a clear error message when amenity creation fails.
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
}

/// Arabic: يرسم خلفية الصفحة المتحركة عبر دوائر ضوئية متدرجة.
/// English: Paints the page background using animated glowing radial orbs.
class _CreateAmenityBackgroundPainter extends CustomPainter {
  /// Arabic: شدة الوهج الحالية التي يقرأها الرسام لتحديد قوة الدوائر الضوئية.
  /// English: Current glow intensity used by the painter to scale the light orbs.
  final double glowIntensity;

  /// Arabic: ينشئ الرسام مع شدة الوهج المطلوبة من الحركة.
  /// English: Creates the painter with the glow intensity provided by the animation.
  _CreateAmenityBackgroundPainter({required this.glowIntensity});

  @override

  /// Arabic: يرسم التوهج الخلفي في مواضع ثابتة مع شدة متغيرة.
  /// English: Draws the animated background glow in fixed positions with varying intensity.
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw glowing orbs
    paint.shader = RadialGradient(
      colors: [
        AppTheme.primaryBlue.withValues(alpha: 0.1 * glowIntensity),
        AppTheme.primaryBlue.withValues(alpha: 0.05 * glowIntensity),
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

  /// Arabic: يعيد الرسم عند تغير شدة الوهج لأن الحركة مرتبطة بقيمة آنية.
  /// English: Repaints whenever glow intensity changes because the animation is time-based.
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
