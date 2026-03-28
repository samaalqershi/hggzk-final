import 'dart:convert';

import 'package:hggzkportal/features/admin_sections/domain/entities/section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/enums/section_type.dart';
import '../../../../core/enums/section_content_type.dart';
import '../../../../core/enums/section_display_style.dart';
import '../../../../core/enums/section_target.dart';
import '../bloc/section_form/section_form_bloc.dart';
import '../bloc/section_form/section_form_event.dart';
import '../bloc/section_form/section_form_state.dart';
import 'section_content_type_toggle.dart';
import 'section_metadata_editor.dart';
import 'section_schedule_picker.dart';
import 'section_preview_widget.dart';
import 'section_ui_type_picker.dart';

/// العربية: يجمع إعدادات إنشاء القسم أو تعديله في نموذج واحد يغطي نوع
/// المحتوى، الترتيب، الظهور، والجدولة.
/// content type, ordering, visibility, and scheduling.
class SectionFormWidget extends StatefulWidget {
  /// العربية: يحدد ما إذا كانت الشاشة تعمل في وضع التعديل بدل الإنشاء.
  final bool isEditing;

  /// العربية: معرف القسم الجاري تحريره عند التعديل.
  final String? sectionId;

  /// العربية: يبني نموذج القسم مع دعم وضع الإنشاء أو التعديل.
  const SectionFormWidget({
    super.key,
    required this.isEditing,
    this.sectionId,
  });

  /// العربية: ينشئ حالة النموذج التي تدير التبويبات والحقول وطلبات الحفظ.
  /// requests.
  @override
  State<SectionFormWidget> createState() => _SectionFormWidgetState();
}

/// العربية: تدير هذه الحالة دورة حياة النموذج الكامل وتربط بين حقول الإدخال
/// والـ Bloc والملخص البصري للقسم.
/// visual preview together.
class _SectionFormWidgetState extends State<SectionFormWidget>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  /// العربية: يتحكم في التنقل بين تبويبات إعداد القسم.
  late TabController _tabController;

  /// العربية: يشغل الحركة الافتتاحية للتبويبات والمحتوى.
  late AnimationController _tabAnimationController;

  /// العربية: يحتفظ بمنحنيات الظهور المتدرجة لكل تبويب.
  late List<Animation<double>> _tabAnimations;

  // Controllers
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _shortDescriptionController = TextEditingController();
  final _displayOrderController = TextEditingController();
  final _columnsCountController = TextEditingController();
  final _itemsToShowController = TextEditingController();
  final _homeItemsCountController = TextEditingController();
  final _iconController = TextEditingController();
  final _colorThemeController = TextEditingController();
  final _backgroundImageController = TextEditingController();

  // State with default values
  /// العربية: نوع القسم المختار حاليًا.
  SectionTypeEnum _selectedType = SectionTypeEnum.grid;

  /// العربية: نوع المحتوى الذي سيعرضه القسم.
  SectionContentType _selectedContentType = SectionContentType.properties;

  /// العربية: نمط العرض المرئي للقسم.
  SectionDisplayStyle _selectedDisplayStyle = SectionDisplayStyle.grid;

  /// العربية: الوجهة التي يرتبط بها القسم.
  SectionTarget _selectedTarget = SectionTarget.properties;

  /// العربية: نوع الواجهة المستخدم لتجسيد القسم بصريًا.
  SectionTypeEnum? _selectedUIType;

  /// العربية: يحدد إن كان القسم مفعّلًا داخل الواجهة العامة.
  bool _isActive = true;

  /// العربية: يحدد ما إذا كان القسم ظاهرًا للزوار غير المسجلين.
  bool _isVisibleToGuests = true;

  /// العربية: يحدد ما إذا كان القسم ظاهرًا للمستخدمين المسجلين.
  bool _isVisibleToRegistered = true;

  /// العربية: اسم الصلاحية المطلوبة لعرض هذا القسم عند تقييده.
  /// restricted.
  String? _requiresPermission;

  /// العربية: بداية الفترة الزمنية التي يكون فيها القسم صالحًا.
  DateTime? _startDate;

  /// العربية: نهاية الفترة الزمنية التي يكون فيها القسم صالحًا.
  DateTime? _endDate;

  /// العربية: قواعد التصفية التي تحدد ما يدخل إلى هذا القسم.
  Map<String, dynamic> _filterCriteria = {};

  /// العربية: قواعد الترتيب التي تضبط ظهور العناصر داخل القسم.
  Map<String, dynamic> _sortCriteria = {};

  /// العربية: الحمولة الوصفية الإضافية التي قد ترافق القسم.
  String _metadata = '';

  /// العربية: يحدد ما إذا كانت المعاينة الحية معروضة داخل النموذج.
  bool _showPreview = false;

  /// العربية: يوضح ما إذا كانت هناك عناصر مرتبطة بالقسم بالفعل.
  bool _hasAssignedItems = false;

  /// العربية: يجهز الحقول والتبويبات والحالة الابتدائية للنموذج.
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _setupTabAnimations();
    _tabAnimationController.forward();

    // Set default values for required fields
    _displayOrderController.text = '0';
    _columnsCountController.text = '2';
    _itemsToShowController.text = '10';
    _homeItemsCountController.text = '';

    // Remove the initialization from here since it's done in CreateSectionPage
    // Only initialize if we're editing
    if (widget.isEditing && widget.sectionId != null) {
      context.read<SectionFormBloc>().add(
            InitializeSectionFormEvent(sectionId: widget.sectionId),
          );
      // تقدير وجود عناصر معينة مسبقاً بناءً على قيمة itemsToShow > 0 لا يكفي.
      // سنجمد الحقول فقط حين يعود الـ Bloc بحالة جاهزة تحمل مؤشر وجود عناصر، أو يمكننا الاعتماد على route extra.
    }
  }

  /// العربية: يبني حركات الظهور المتدرجة الخاصة بالتبويبات.
  void _setupTabAnimations() {
    _tabAnimations = List.generate(4, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _tabAnimationController,
          curve: Interval(
            index * 0.1,
            0.5 + index * 0.1,
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });
  }

  /// العربية: يحرر المتحكمات عند إزالة النموذج من الشجرة.
  @override
  void dispose() {
    _tabController.dispose();
    _tabAnimationController.dispose();
    _nameController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _shortDescriptionController.dispose();
    _displayOrderController.dispose();
    _columnsCountController.dispose();
    _itemsToShowController.dispose();
    _homeItemsCountController.dispose();
    _iconController.dispose();
    _colorThemeController.dispose();
    _backgroundImageController.dispose();
    super.dispose();
  }

  /// العربية: يبني واجهة النموذج ويعيدها بحسب حالات الـ Bloc أثناء التعديل
  /// أو الحفظ.
  /// flows.
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SectionFormBloc, SectionFormState>(
      listener: (context, state) {
        if (state is SectionFormReady &&
            widget.isEditing &&
            widget.sectionId != null) {
          _populateForm(state);
          // إذا كان هناك عناصر مُعيّنة، نجمد هدف القسم ونوع المحتوى
          // ملاحظة: نفترض استخدام itemsToShow كدلالة ضعيفة غير مؤكدة. يُفضل أن يمرر الـ Bloc معلومة أدق لاحقاً.
          setState(() {
            _hasAssignedItems = (state.itemsToShow ?? 0) > 0;
          });
        } else if (state is SectionFormSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.isEditing
                  ? 'تم تحديث القسم بنجاح'
                  : 'تم إضافة القسم بنجاح'),
              backgroundColor: AppTheme.success,
            ),
          );
          Navigator.of(context).pop(true);
        } else if (state is SectionFormError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ: ${state.message}'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is SectionFormLoading && widget.isEditing) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Stack(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildAnimatedTabs(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildBasicInfoTab(),
                        _buildConfigurationTab(),
                        _buildAppearanceTab(),
                        _buildAdvancedTab(),
                      ],
                    ),
                  ),
                  _buildActionButtons(state),
                ],
              ),
            ),
            if (_showPreview) _buildPreviewOverlay(),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedTabs() {
    final tabs = [
      'معلومات أساسية',
      'الإعدادات',
      'المظهر',
      'متقدم',
    ];

    final icons = [
      CupertinoIcons.info_circle_fill,
      CupertinoIcons.settings,
      CupertinoIcons.paintbrush_fill,
      CupertinoIcons.gear_alt_fill,
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.5),
            AppTheme.darkCard.withValues(alpha: 0.3),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.darkBorder.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AppTheme.primaryBlue,
        unselectedLabelColor: AppTheme.textMuted,
        indicatorColor: AppTheme.primaryBlue,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: List.generate(tabs.length, (index) {
          return AnimatedBuilder(
            animation: _tabAnimations[index],
            builder: (context, child) {
              final animationValue =
                  _tabAnimations[index].value.clamp(0.0, 1.0);
              final scaleValue = 0.9 + (animationValue * 0.1);

              return Transform.scale(
                scale: scaleValue,
                child: Opacity(
                  opacity: animationValue,
                  child: Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icons[index], size: 16),
                        const SizedBox(width: 8),
                        Text(tabs[index]),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildScrollableContent({required Widget child}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildBasicInfoTab() {
    return _buildScrollableContent(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
                'المعلومات الأساسية', CupertinoIcons.info_circle_fill),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _nameController,
              label: 'اسم القسم (داخلي)',
              hint: 'أدخل اسم القسم للاستخدام الداخلي',
              icon: Icons.label_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'اسم القسم مطلوب';
                }
                return null;
              },
              onChanged: (value) {
                context.read<SectionFormBloc>().add(
                      UpdateSectionBasicInfoEvent(name: value),
                    );
              },
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _titleController,
              label: 'العنوان',
              hint: 'أدخل عنوان القسم',
              icon: Icons.title,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'العنوان مطلوب';
                }
                return null;
              },
              onChanged: (value) {
                context.read<SectionFormBloc>().add(
                      UpdateSectionBasicInfoEvent(title: value),
                    );
              },
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _subtitleController,
              label: 'العنوان الفرعي',
              hint: 'أدخل عنوان فرعي (اختياري)',
              icon: Icons.subtitles_outlined,
              onChanged: (value) {
                context.read<SectionFormBloc>().add(
                      UpdateSectionBasicInfoEvent(subtitle: value),
                    );
              },
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _descriptionController,
              label: 'الوصف',
              hint: 'أدخل وصف القسم',
              icon: Icons.description_outlined,
              maxLines: 3,
              onChanged: (value) {
                context.read<SectionFormBloc>().add(
                      UpdateSectionBasicInfoEvent(description: value),
                    );
              },
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _shortDescriptionController,
              label: 'وصف مختصر',
              hint: 'أدخل وصف مختصر للعرض السريع',
              icon: Icons.short_text,
              onChanged: (value) {
                context.read<SectionFormBloc>().add(
                      UpdateSectionBasicInfoEvent(shortDescription: value),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigurationTab() {
    return _buildScrollableContent(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _buildSectionHeader('إعدادات القسم', CupertinoIcons.settings),
            // const SizedBox(height: 20),
            // AbsorbPointer(
            //   absorbing: _hasAssignedItems,
            //   child: Opacity(
            //     opacity: _hasAssignedItems ? 0.6 : 1,
            //     child: SectionTypeSelector(
            //       selectedType: _selectedType,
            //       onTypeSelected: (type) {
            //         setState(() => _selectedType = type);
            //         context.read<SectionFormBloc>().add(
            //               UpdateSectionConfigEvent(type: type),
            //             );
            //       },
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 20),
            // UI Type Selector (Optional)
            const SizedBox.shrink(),
            AbsorbPointer(
              absorbing: _hasAssignedItems,
              child: Opacity(
                opacity: _hasAssignedItems ? 0.6 : 1,
                child: SectionContentTypeToggle(
                  selectedType: _selectedContentType,
                  onTypeSelected: (type) {
                    setState(() => _selectedContentType = type);
                    context.read<SectionFormBloc>().add(
                          UpdateSectionConfigEvent(contentType: type),
                        );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedContentType != SectionContentType.none)
              SectionUITypePicker(
                selectedType: _selectedUIType ?? _selectedType,
                onTypeSelected: (type) {
                  setState(() {
                    _selectedUIType = type;
                    _selectedType = type;
                  });
                  // Update metadata with selected UI type
                  _updateUITypeInMetadata(type);
                  context.read<SectionFormBloc>().add(
                        UpdateSectionConfigEvent(type: type),
                      );
                },
              ),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            _buildActiveSwitch(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceTab() {
    return _buildScrollableContent(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
                'إعدادات المظهر', CupertinoIcons.paintbrush_fill),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _homeItemsCountController,
              label: 'عدد عناصر الصفحة الرئيسية',
              hint: 'اتركه فارغاً لاستخدام العدد الافتراضي',
              icon: Icons.home_outlined,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final v = int.tryParse(value);
                  if (v == null || v < 1) {
                    return 'أدخل رقم صحيح أكبر من 0 أو اتركه فارغاً';
                  }
                }
                return null;
              },
              onChanged: (value) {
                final v = (value.trim().isEmpty) ? null : int.tryParse(value);
                context.read<SectionFormBloc>().add(
                      UpdateSectionConfigEvent(homeItemsCount: v),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedTab() {
    return _buildScrollableContent(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('إعدادات متقدمة', CupertinoIcons.gear_alt_fill),
            const SizedBox(height: 20),
            SectionSchedulePicker(
              startDate: _startDate,
              endDate: _endDate,
              onScheduleChanged: (start, end) {
                setState(() {
                  _startDate = start;
                  _endDate = end;
                });
                context.read<SectionFormBloc>().add(
                      UpdateSectionVisibilityEvent(
                        startDate: start,
                        endDate: end,
                      ),
                    );
              },
            ),
            const SizedBox(height: 30),
            SectionMetadataEditor(
              initialMetadata: _metadata,
              onMetadataChanged: (metadata) {
                setState(() => _metadata = metadata);
                context.read<SectionFormBloc>().add(
                      UpdateSectionMetadataEvent(metadataJson: metadata),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewOverlay() {
    final section = _createSectionFromForm();

    return GestureDetector(
      onTap: () => setState(() => _showPreview = false),
      child: Container(
        color: AppTheme.darkBackground.withValues(alpha: 0.9),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.darkBorder.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'معاينة القسم',
                        style: AppTextStyles.heading2.copyWith(
                          color: AppTheme.textWhite,
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _showPreview = false),
                        icon: Icon(
                          CupertinoIcons.xmark_circle_fill,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: SectionPreviewWidget(
                        section: section,
                        isExpanded: true,
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTextStyles.heading3.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

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
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSwitch() {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'تفعيل القسم',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          CupertinoSwitch(
            value: _isActive,
            onChanged: (value) {
              setState(() => _isActive = value);
              context.read<SectionFormBloc>().add(
                    UpdateSectionConfigEvent(isActive: value),
                  );
            },
            activeTrackColor: AppTheme.success,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(SectionFormState state) {
    final isLoading = state is SectionFormLoading;

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
          GestureDetector(
            onTap: () => setState(() => _showPreview = true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryPurple.withValues(alpha: 0.3),
                    AppTheme.primaryViolet.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.eye_fill,
                    color: AppTheme.primaryPurple,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'معاينة',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: AppTheme.primaryPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
              child: Text(
                'إلغاء',
                style: AppTextStyles.buttonMedium.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: isLoading ? null : _submitForm,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: isLoading
                    ? LinearGradient(colors: [
                        AppTheme.primaryBlue.withValues(alpha: 0.5),
                        AppTheme.primaryBlue.withValues(alpha: 0.3),
                      ])
                    : AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      widget.isEditing ? 'تحديث' : 'إضافة',
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _populateForm(SectionFormReady state) {
    // تعبئة الحقول النصية
    if (state.name != null && state.name!.isNotEmpty) {
      _nameController.text = state.name!;
    }
    if (state.title != null && state.title!.isNotEmpty) {
      _titleController.text = state.title!;
    }
    if (state.subtitle != null && state.subtitle!.isNotEmpty) {
      _subtitleController.text = state.subtitle!;
    }
    if (state.description != null && state.description!.isNotEmpty) {
      _descriptionController.text = state.description!;
    }
    if (state.shortDescription != null && state.shortDescription!.isNotEmpty) {
      _shortDescriptionController.text = state.shortDescription!;
    }

    _displayOrderController.text = (state.displayOrder ?? 0).toString();
    _columnsCountController.text = (state.columnsCount ?? 2).toString();
    _itemsToShowController.text = (state.itemsToShow ?? 10).toString();
    if (state.homeItemsCount != null) {
      _homeItemsCountController.text = state.homeItemsCount.toString();
    }

    if (state.icon != null && state.icon!.isNotEmpty) {
      _iconController.text = state.icon!;
    }
    if (state.colorTheme != null && state.colorTheme!.isNotEmpty) {
      _colorThemeController.text = state.colorTheme!;
    }
    if (state.backgroundImage != null && state.backgroundImage!.isNotEmpty) {
      _backgroundImageController.text = state.backgroundImage!;
    }

    // تحديث الحالات
    setState(() {
      _selectedType = state.type ?? SectionTypeEnum.grid;
      _selectedContentType = state.contentType ?? SectionContentType.properties;
      _selectedDisplayStyle = state.displayStyle ?? SectionDisplayStyle.grid;
      _selectedTarget = state.target ?? SectionTarget.properties;
      _isActive = state.isActive ?? true;
      _isVisibleToGuests = state.isVisibleToGuests ?? true;
      _isVisibleToRegistered = state.isVisibleToRegistered ?? true;
      _requiresPermission = state.requiresPermission;
      _startDate = state.startDate;
      _endDate = state.endDate;

      if (state.filterCriteriaJson != null &&
          state.filterCriteriaJson!.isNotEmpty) {
        try {
          _filterCriteria = Map<String, dynamic>.from(
              state.filterCriteriaJson is String
                  ? jsonDecode(state.filterCriteriaJson!)
                  : state.filterCriteriaJson);
          // ignore: empty_catches
        } catch (e) {}
      }

      if (state.sortCriteriaJson != null &&
          state.sortCriteriaJson!.isNotEmpty) {
        try {
          _sortCriteria = Map<String, dynamic>.from(
              state.sortCriteriaJson is String
                  ? jsonDecode(state.sortCriteriaJson!)
                  : state.sortCriteriaJson);
          // ignore: empty_catches
        } catch (e) {}
      }

      _metadata = state.metadataJson ?? '';
    });
  }

  Section _createSectionFromForm() {
    return Section(
      id: widget.sectionId ?? '',
      type: _selectedType,
      contentType: _selectedContentType,
      displayStyle: _selectedDisplayStyle,
      name: _nameController.text.isEmpty
          ? _titleController.text
          : _nameController.text,
      title: _titleController.text,
      subtitle:
          _subtitleController.text.isEmpty ? null : _subtitleController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      shortDescription: _shortDescriptionController.text.isEmpty
          ? null
          : _shortDescriptionController.text,
      displayOrder: int.tryParse(_displayOrderController.text) ?? 0,
      target: _selectedTarget,
      isActive: _isActive,
      columnsCount: int.tryParse(_columnsCountController.text) ?? 2,
      itemsToShow: int.tryParse(_itemsToShowController.text) ?? 10,
      icon: _iconController.text.isEmpty ? null : _iconController.text,
      colorTheme: _colorThemeController.text.isEmpty
          ? null
          : _colorThemeController.text,
      backgroundImage: _backgroundImageController.text.isEmpty
          ? null
          : _backgroundImageController.text,
      filterCriteria:
          _filterCriteria.isNotEmpty ? _filterCriteria.toString() : null,
      sortCriteria: _sortCriteria.isNotEmpty ? _sortCriteria.toString() : null,
      cityName: _filterCriteria['cityName'],
      propertyTypeId: _filterCriteria['propertyTypeId'],
      unitTypeId: _filterCriteria['unitTypeId'],
      minPrice: _filterCriteria['minPrice'],
      maxPrice: _filterCriteria['maxPrice'],
      minRating: _filterCriteria['minRating'],
      isVisibleToGuests: _isVisibleToGuests,
      isVisibleToRegistered: _isVisibleToRegistered,
      requiresPermission: _requiresPermission,
      startDate: _startDate,
      endDate: _endDate,
      metadata: _metadata.isEmpty ? null : _metadata,
    );
  }

  void _updateUITypeInMetadata(SectionTypeEnum type) {
    try {
      Map<String, dynamic> metadataObj = {};
      if (_metadata.isNotEmpty) {
        final decoded = jsonDecode(_metadata);
        if (decoded is Map<String, dynamic>) {
          metadataObj = decoded;
        }
      }

      // Add or update uiType in metadata
      metadataObj['uiType'] = type.value;

      // Convert back to JSON string
      _metadata = jsonEncode(metadataObj);

      // Update the form state
      context.read<SectionFormBloc>().add(
            UpdateSectionMetadataEvent(metadataJson: _metadata),
          );
    } catch (e) {
      if (!mounted) return;
    }
  }

  void _submitForm() async {
    // التحقق من الـ form validation
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يرجى ملء جميع الحقول المطلوبة'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    // التحقق من الحقول المطلوبة
    if (_nameController.text.isEmpty) {
      _nameController.text = _titleController.text;
    }

    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('عنوان القسم مطلوب'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    try {
      // التحقق من وجود الـ Bloc
      final bloc = context.read<SectionFormBloc>();

      // تحديث البيانات الأساسية
      bloc.add(UpdateSectionBasicInfoEvent(
        name: _nameController.text,
        title: _titleController.text,
        subtitle:
            _subtitleController.text.isEmpty ? null : _subtitleController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        shortDescription: _shortDescriptionController.text.isEmpty
            ? null
            : _shortDescriptionController.text,
      ));

      await Future.delayed(const Duration(milliseconds: 100));

      // تحديث الإعدادات
      bloc.add(UpdateSectionConfigEvent(
        type: _selectedType,
        contentType: _selectedContentType,
        displayStyle: _selectedDisplayStyle,
        target: _selectedTarget,
        displayOrder: int.tryParse(_displayOrderController.text) ?? 0,
        itemsToShow: int.tryParse(_itemsToShowController.text) ?? 10,
        columnsCount: int.tryParse(_columnsCountController.text) ?? 2,
        isActive: _isActive,
      ));

      await Future.delayed(const Duration(milliseconds: 100));

      // إرسال الطلب النهائي
      bloc.add(SubmitSectionFormEvent());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: ${e.toString()}'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }
}
