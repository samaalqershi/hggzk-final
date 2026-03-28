// lib/features/notification_channels/presentation/pages/create_channel_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/channels_bloc.dart';
import '../bloc/channels_event.dart';
import '../bloc/channels_state.dart';

class CreateChannelPage extends StatefulWidget {
  /// العربية: ينشئ مثيلًا جديدًا من `CreateChannelPage`.
  const CreateChannelPage({super.key});
  @override
  State<CreateChannelPage> createState() => _CreateChannelPageState();
}

class _CreateChannelPageState extends State<CreateChannelPage>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _animationController;
  late AnimationController _glowController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _webhookUrlController = TextEditingController();
  final TextEditingController _maxSubscribersController =
      TextEditingController();

  // State
  int _currentStep = 0;
  String _selectedType = 'CUSTOM';
  String _selectedIcon = '📢';
  String _selectedColor = '#1E88E5';
  bool _isPrivate = false;
  bool _allowNotifications = true;
  bool _allowSubscription = true;
  bool _requireApproval = false;
  bool _enableWebhook = false;
  final List<String> _selectedRoles = [];
  final Map<String, bool> _notificationTypes = {
    'email': true,
    'push': true,
    'sms': false,
    'inApp': true,
  };

  // Available Options
  final List<String> _availableTypes = [
    'CUSTOM',
    'ROLE_BASED',
    'EVENT_BASED',
    'BROADCAST',
    'PRIVATE',
  ];
  final List<String> _availableIcons = [
    '📢',
    '🔔',
    '📣',
    '📡',
    '📮',
    '📤',
    '💬',
    '📻',
    '🎯',
    '⚡',
    '🚀',
    '💎',
    '🎉',
    '🏆',
    '⭐',
    '🌟',
    '📨',
    '📧',
    '📩',
    '💌',
    '📝',
    '📄',
    '📃',
    '📋',
  ];
  final List<String> _availableColors = [
    '#1E88E5',
    '#43A047',
    '#E53935',
    '#FB8C00',
    '#8E24AA',
    '#00ACC1',
    '#D81B60',
    '#546E7A',
    '#6A1B9A',
    '#00897B',
    '#F4511E',
    '#3949AB',
    '#FF6F00',
    '#C0CA33',
    '#26A69A',
    '#AB47BC',
  ];
  final List<String> _availableRoles = [
    'Admin',
    'SuperAdmin',
    'PropertyManager',
    'User',
    'Guest',
    'Moderator',
    'Support',
  ];
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupIdentifierAutoGeneration();
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
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  void _setupIdentifierAutoGeneration() {
    _nameController.addListener(() {
      if (_nameController.text.isNotEmpty &&
          _identifierController.text.isEmpty) {
        final identifier = _nameController.text
            .toLowerCase()
            .replaceAll(RegExp(r'[^\w\s]'), '')
            .replaceAll(RegExp(r'\s+'), '_')
            .replaceAll(RegExp(r'_+'), '_');
        _identifierController.text = identifier;
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _glowController.dispose();
    _nameController.dispose();
    _identifierController.dispose();
    _descriptionController.dispose();
    _webhookUrlController.dispose();
    _maxSubscribersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && await _onWillPop() && mounted) {
          context.pop();
        }
      },
      child: BlocListener<ChannelsBloc, ChannelsState>(
        listener: (context, state) {
          if (state.successMessage != null &&
              state.successMessage!.contains('إنشاء')) {
            _showSuccessMessage(state.successMessage!);
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) {
                context.pop(true);
              }
            });
          } else if (state.error != null) {
            _showErrorMessage(state.error!);
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
            painter: _CreateChannelBackgroundPainter(
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
                    'إنشاء قناة جديدة',
                    style: AppTextStyles.heading2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'قم بإنشاء قناة إشعارات للتواصل مع المستخدمين',
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
      'المظهر والتصميم',
      'الإعدادات',
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
    return BlocBuilder<ChannelsBloc, ChannelsState>(
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: IndexedStack(
            index: _currentStep,
            children: [
              _buildBasicInfoStep(),
              _buildAppearanceStep(),
              _buildSettingsStep(),
              _buildReviewStep(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputField(
            controller: _nameController,
            label: 'اسم القناة',
            hint: 'أدخل اسم القناة',
            icon: Icons.label_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال اسم القناة';
              }
              if (value.length < 3) {
                return 'الاسم يجب أن يكون 3 أحرف على الأقل';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _identifierController,
            label: 'معرف القناة',
            hint: 'معرف فريد للقناة (تلقائي)',
            icon: Icons.fingerprint_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال معرف القناة';
              }
              if (!RegExp(r'^[a-z0-9_]+$').hasMatch(value)) {
                return 'المعرف يجب أن يحتوي على أحرف صغيرة وأرقام و _ فقط';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _descriptionController,
            label: 'وصف القناة',
            hint: 'وصف مختصر للقناة (اختياري)',
            icon: Icons.description_rounded,
            maxLines: 4,
          ),
          const SizedBox(height: 20),
          _buildTypeSelector(),
        ],
      ),
    );
  }

  Widget _buildAppearanceStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر أيقونة القناة',
            style: AppTextStyles.heading3.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildIconGrid(),
          const SizedBox(height: 30),
          Text(
            'اختر لون القناة',
            style: AppTextStyles.heading3.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildColorGrid(),
          const SizedBox(height: 30),
          _buildPreviewCard(),
        ],
      ),
    );
  }

  Widget _buildSettingsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPrivacySettings(),
          const SizedBox(height: 24),
          _buildNotificationSettings(),
          const SizedBox(height: 24),
          if (_selectedType == 'ROLE_BASED') _buildRoleSelector(),
          const SizedBox(height: 24),
          _buildAdvancedSettings(),
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
              {'label': 'المعرف', 'value': _identifierController.text},
              {'label': 'النوع', 'value': _getTypeLabel(_selectedType)},
              {
                'label': 'الوصف',
                'value': _descriptionController.text.isEmpty
                    ? 'لا يوجد'
                    : _descriptionController.text
              },
            ],
          ),
          const SizedBox(height: 16),
          _buildReviewCard(
            title: 'المظهر',
            items: [
              {'label': 'الأيقونة', 'value': _selectedIcon},
              {'label': 'اللون', 'value': _selectedColor},
            ],
          ),
          const SizedBox(height: 16),
          _buildReviewCard(
            title: 'الإعدادات',
            items: [
              {'label': 'الخصوصية', 'value': _isPrivate ? 'خاصة' : 'عامة'},
              {
                'label': 'السماح بالإشعارات',
                'value': _allowNotifications ? 'نعم' : 'لا'
              },
              {
                'label': 'السماح بالاشتراك',
                'value': _allowSubscription ? 'نعم' : 'لا'
              },
              {'label': 'طلب موافقة', 'value': _requireApproval ? 'نعم' : 'لا'},
            ],
          ),
          if (_selectedType == 'ROLE_BASED' && _selectedRoles.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildReviewCard(
              title: 'الأدوار المسموح لها',
              items: _selectedRoles
                  .map((role) => {'label': 'دور', 'value': _getRoleLabel(role)})
                  .toList(),
            ),
          ],
          if (_enableWebhook && _webhookUrlController.text.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildReviewCard(
              title: 'إعدادات متقدمة',
              items: [
                {'label': 'Webhook URL', 'value': _webhookUrlController.text},
                {
                  'label': 'الحد الأقصى للمشتركين',
                  'value': _maxSubscribersController.text.isEmpty
                      ? 'غير محدود'
                      : _maxSubscribersController.text
                },
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع القناة',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _availableTypes.map((type) {
            final isSelected = _selectedType == type;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedType = type;
                  if (type != 'ROLE_BASED') {
                    _selectedRoles.clear();
                  }
                });
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTypeIcon(type),
                      color: isSelected ? Colors.white : AppTheme.textMuted,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getTypeLabel(type),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSelected ? Colors.white : AppTheme.textMuted,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIconGrid() {
    return SizedBox(
      height: 200,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          childAspectRatio: 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _availableIcons.length,
        itemBuilder: (context, index) {
          final icon = _availableIcons[index];
          final isSelected = _selectedIcon == icon;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIcon = icon;
              });
              HapticFeedback.lightImpact();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryGradient : null,
                color: isSelected
                    ? null
                    : AppTheme.darkBackground.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : AppTheme.darkBorder.withValues(alpha: 0.3),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorGrid() {
    return SizedBox(
      height: 100,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _availableColors.length,
        itemBuilder: (context, index) {
          final color = _availableColors[index];
          final isSelected = _selectedColor == color;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedColor = color;
              });
              HapticFeedback.lightImpact();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Color(
                    int.parse(color.substring(1), radix: 16) + 0xFF000000),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.textWhite
                      : AppTheme.darkBorder.withValues(alpha: 0.3),
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Color(
                                  int.parse(color.substring(1), radix: 16) +
                                      0xFF000000)
                              .withValues(alpha: 0.5),
                          blurRadius: 12,
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.5),
            AppTheme.darkCard.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معاينة القناة',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Color(
                          int.parse(_selectedColor.substring(1), radix: 16) +
                              0xFF000000)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Color(
                            int.parse(_selectedColor.substring(1), radix: 16) +
                                0xFF000000)
                        .withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    _selectedIcon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameController.text.isEmpty
                          ? 'اسم القناة'
                          : _nameController.text,
                      style: AppTextStyles.heading3.copyWith(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _descriptionController.text.isEmpty
                          ? 'وصف القناة'
                          : _descriptionController.text,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppTheme.textMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.5),
            AppTheme.darkCard.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'إعدادات الخصوصية',
                style: AppTextStyles.heading3.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSwitchTile(
            title: 'قناة خاصة',
            subtitle: 'القناة الخاصة تحتاج إذن للانضمام',
            value: _isPrivate,
            onChanged: (value) => setState(() => _isPrivate = value),
          ),
          const SizedBox(height: 12),
          _buildSwitchTile(
            title: 'السماح بالاشتراك',
            subtitle: 'السماح للمستخدمين بالاشتراك في القناة',
            value: _allowSubscription,
            onChanged: (value) => setState(() => _allowSubscription = value),
          ),
          const SizedBox(height: 12),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _allowSubscription
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: _buildSwitchTile(
              title: 'طلب موافقة',
              subtitle: 'مراجعة طلبات الاشتراك قبل الموافقة',
              value: _requireApproval,
              onChanged: (value) => setState(() => _requireApproval = value),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.5),
            AppTheme.darkCard.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.info,
                      AppTheme.info.withValues(alpha: 0.7)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.notifications_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'إعدادات الإشعارات',
                style: AppTextStyles.heading3.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSwitchTile(
            title: 'السماح بالإشعارات',
            subtitle: 'تفعيل إرسال الإشعارات عبر هذه القناة',
            value: _allowNotifications,
            onChanged: (value) => setState(() => _allowNotifications = value),
          ),
          const SizedBox(height: 16),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _allowNotifications
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أنواع الإشعارات المسموحة',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ..._notificationTypes.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildCheckboxTile(
                      title: _getNotificationTypeLabel(entry.key),
                      value: entry.value,
                      onChanged: (value) {
                        setState(() {
                          _notificationTypes[entry.key] = value ?? false;
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.5),
            AppTheme.darkCard.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryPurple,
                      AppTheme.primaryPurple.withValues(alpha: 0.7)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.people_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'الأدوار المسموح لها',
                style: AppTextStyles.heading3.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _availableRoles.map((role) {
              final isSelected = _selectedRoles.contains(role);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedRoles.remove(role);
                    } else {
                      _selectedRoles.add(role);
                    }
                  });
                  HapticFeedback.lightImpact();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppTheme.primaryGradient : null,
                    color: isSelected
                        ? null
                        : AppTheme.darkBackground.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : AppTheme.darkBorder.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _getRoleLabel(role),
                    style: AppTextStyles.bodySmall.copyWith(
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
      ),
    );
  }

  Widget _buildAdvancedSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.5),
            AppTheme.darkCard.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.warning,
                      AppTheme.warning.withValues(alpha: 0.7)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.settings_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'إعدادات متقدمة',
                style: AppTextStyles.heading3.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSwitchTile(
            title: 'تفعيل Webhook',
            subtitle: 'إرسال الإشعارات إلى URL خارجي',
            value: _enableWebhook,
            onChanged: (value) => setState(() => _enableWebhook = value),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _enableWebhook
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              children: [
                const SizedBox(height: 16),
                _buildInputField(
                  controller: _webhookUrlController,
                  label: 'Webhook URL',
                  hint: 'https://example.com/webhook',
                  icon: Icons.link_rounded,
                  validator: _enableWebhook
                      ? (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال URL';
                          }
                          if (!Uri.tryParse(value)!.isAbsolute) {
                            return 'URL غير صحيح';
                          }
                          return null;
                        }
                      : null,
                ),
              ],
            ),
            secondChild: const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _maxSubscribersController,
            label: 'الحد الأقصى للمشتركين (اختياري)',
            hint: 'اتركه فارغاً لعدم وضع حد',
            icon: Icons.group_rounded,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
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
        CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppTheme.primaryBlue,
        ),
      ],
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              gradient: value ? AppTheme.primaryGradient : null,
              color:
                  value ? null : AppTheme.darkBackground.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: value
                    ? Colors.transparent
                    : AppTheme.darkBorder.withValues(alpha: 0.3),
              ),
            ),
            child: value
                ? const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.textWhite,
            ),
          ),
        ],
      ),
    );
  }

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
                  child: BlocBuilder<ChannelsBloc, ChannelsState>(
                    builder: (context, state) {
                      if (state.isLoading) {
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
                        _currentStep < 3 ? 'التالي' : 'إنشاء القناة',
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

  // Helper methods
  String _getTypeLabel(String type) {
    switch (type) {
      case 'CUSTOM':
        return 'قناة مخصصة';
      case 'ROLE_BASED':
        return 'حسب الدور';
      case 'EVENT_BASED':
        return 'حسب الحدث';
      case 'BROADCAST':
        return 'بث عام';
      case 'PRIVATE':
        return 'خاصة';
      default:
        return type;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'CUSTOM':
        return Icons.star_rounded;
      case 'ROLE_BASED':
        return Icons.people_rounded;
      case 'EVENT_BASED':
        return Icons.event_rounded;
      case 'BROADCAST':
        return Icons.campaign_rounded;
      case 'PRIVATE':
        return Icons.lock_rounded;
      default:
        return Icons.tag_rounded;
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'Admin':
        return 'مدير';
      case 'SuperAdmin':
        return 'مدير عام';
      case 'PropertyManager':
        return 'مدير عقار';
      case 'User':
        return 'مستخدم';
      case 'Guest':
        return 'ضيف';
      case 'Moderator':
        return 'مشرف';
      case 'Support':
        return 'دعم فني';
      default:
        return role;
    }
  }

  String _getNotificationTypeLabel(String type) {
    switch (type) {
      case 'email':
        return 'البريد الإلكتروني';
      case 'push':
        return 'الإشعارات الفورية';
      case 'sms':
        return 'رسائل SMS';
      case 'inApp':
        return 'داخل التطبيق';
      default:
        return type;
    }
  }

  void _handleBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      context.pop();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      bool isValid = true;

      if (_currentStep == 0) {
        isValid = _validateBasicInfo();
      } else if (_currentStep == 1) {
        isValid = _validateAppearance();
      } else if (_currentStep == 2) {
        isValid = _validateSettings();
      }

      if (isValid) {
        setState(() {
          _currentStep++;
        });
      }
    }
  }

  bool _validateBasicInfo() {
    if (_nameController.text.isEmpty || _identifierController.text.isEmpty) {
      _showErrorMessage('الرجاء ملء جميع الحقول المطلوبة');
      return false;
    }
    return true;
  }

  bool _validateAppearance() {
    // Appearance is always valid as we have defaults
    return true;
  }

  bool _validateSettings() {
    if (_selectedType == 'ROLE_BASED' && _selectedRoles.isEmpty) {
      _showErrorMessage('الرجاء اختيار دور واحد على الأقل');
      return false;
    }

    if (_enableWebhook && _webhookUrlController.text.isEmpty) {
      _showErrorMessage('الرجاء إدخال Webhook URL');
      return false;
    }

    return true;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();

      context.read<ChannelsBloc>().add(
            CreateChannelEvent(
              name: _nameController.text.trim(),
              identifier: _identifierController.text.trim(),
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              type: _selectedType,
              icon: _selectedIcon,
              color: _selectedColor,
            ),
          );
    }
  }

  Future<bool> _onWillPop() async {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      return false;
    }

    if (_hasUnsavedChanges()) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => _UnsavedChangesDialog(),
      );
      return result ?? false;
    }

    return true;
  }

  bool _hasUnsavedChanges() {
    return _nameController.text.isNotEmpty ||
        _identifierController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty ||
        _selectedType != 'CUSTOM' ||
        _selectedIcon != '📢' ||
        _selectedColor != '#1E88E5' ||
        _isPrivate ||
        _selectedRoles.isNotEmpty;
  }

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
            Expanded(
              child: Text(message),
            ),
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
            Expanded(
              child: Text(message),
            ),
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

// Background Painter
class _CreateChannelBackgroundPainter extends CustomPainter {
  /// العربية: يخزن القيمة `glowIntensity`.
  final double glowIntensity;
  _CreateChannelBackgroundPainter({required this.glowIntensity});
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Unsaved Changes Dialog
class _UnsavedChangesDialog extends StatelessWidget {
  @override
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
