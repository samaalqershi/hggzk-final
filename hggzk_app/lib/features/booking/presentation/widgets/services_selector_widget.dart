import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hggzk/features/property/domain/entities/property_detail.dart';
import 'dart:ui';
import 'package:hggzk/core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// العربية: يمثل العنصر `ServicesSelectorWidget`.
class ServicesSelectorWidget extends StatefulWidget {
  /// العربية: يخزن القيمة `propertyId`.
  final String propertyId;

  /// العربية: يخزن القيمة `services`.
  final List<PropertyService>? services;

  /// العربية: يعالج `Function`.
  final Function(List<Map<String, dynamic>>) onServicesChanged;

  /// العربية: يخزن القيمة `initialSelected`.
  final List<Map<String, dynamic>>? initialSelected;

  /// العربية: ينشئ مثيلًا جديدًا من `ServicesSelectorWidget`.
  const ServicesSelectorWidget({
    super.key,
    required this.propertyId,
    this.services,
    required this.onServicesChanged,
    this.initialSelected,
  });

  /// العربية: ينشئ كائن الحالة الخاص بهذا العنصر.
  @override
  State<ServicesSelectorWidget> createState() => _ServicesSelectorWidgetState();
}

/// العربية: يمثل الحالة الخاصة بـ `ServicesSelectorWidgetState`.
class _ServicesSelectorWidgetState extends State<ServicesSelectorWidget>
    with TickerProviderStateMixin {
  /// العربية: يخزن القيمة `services`.
  late final List<Map<String, dynamic>> _services;

  static final List<Color> _serviceColors = [
    AppTheme.primaryBlue,
    AppTheme.warning,
    AppTheme.primaryPurple,
    AppTheme.success,
    AppTheme.info,
  ];

  /// العربية: يخزن القيمة `selectedServices`.
  final Map<String, bool> _selectedServices = {};

  /// العربية: يخزن القيمة `serviceQuantities`.
  final Map<String, int> _serviceQuantities = {};

  /// العربية: يخزن القيمة `animationControllers`.
  final Map<String, AnimationController> _animationControllers = {};

  /// العربية: يخزن القيمة `expandController`.
  late AnimationController _expandController;

  /// العربية: يحدد ما إذا كانت القيمة `isExpanded` مفعلة.
  bool _isExpanded = false;

  /// العربية: يهيئ الحالة الخاصة بهذا العنصر.
  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    if (widget.services != null && widget.services!.isNotEmpty) {
      int index = 0;
      _services = widget.services!.map((s) {
        final color = _serviceColors[index % _serviceColors.length];
        index++;
        return {
          'id': s.id,
          'name': s.name,
          'price': s.price,
          'currency': s.currency,
          'description': s.description ?? '',
          'icon': Icons.room_service,
          'color': color,
        };
      }).toList();
    } else {
      _services = [];
    }

    for (var service in _services) {
      _selectedServices[service['id']] = false;
      _serviceQuantities[service['id']] = 1;
      _animationControllers[service['id']] = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
    }

    // Apply initial selections if provided
    if (widget.initialSelected != null && widget.initialSelected!.isNotEmpty) {
      for (final item in widget.initialSelected!) {
        try {
          final id = item['id']?.toString();
          if (id != null && _selectedServices.containsKey(id)) {
            _selectedServices[id] = true;
            final q = (item['quantity'] is int)
                ? (item['quantity'] as int)
                : int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
            _serviceQuantities[id] = q > 0 ? q : 1;
          }
        } catch (_) {}
      }
      // Notify parent with initial state
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _updateSelectedServices());
    }
  }

  /// العربية: يحرر الموارد المستخدمة بواسطة هذا الكائن.
  @override
  void dispose() {
    _expandController.dispose();
    _animationControllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  /// العربية: يبني شجرة العناصر الخاصة بهذا المكوّن.
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withOpacity(0.8),
            AppTheme.darkCard.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryCyan.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              if (_isExpanded)
                ..._services.map((service) => _buildServiceItem(service)),
            ],
          ),
        ),
      ),
    );
  }

  /// العربية: يبني header.
  Widget _buildHeader() {
    final selectedCount =
        _selectedServices.values.where((selected) => selected).length;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _isExpanded = !_isExpanded;
          if (_isExpanded) {
            _expandController.forward();
          } else {
            _expandController.reverse();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryCyan.withOpacity(0.1),
              AppTheme.primaryCyan.withOpacity(0.05),
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.room_service,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(
                      'booking.services.title',
                    ),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textWhite,
                    ),
                  ),
                  Text(
                    selectedCount > 0
                        ? context.tr(
                            'booking.services.selectedCount',
                            params: {'count': selectedCount},
                          )
                        : context.tr(
                            'booking.services.selectOptional',
                          ),
                    style: AppTextStyles.caption.copyWith(
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.expand_more,
                color: AppTheme.primaryCyan,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// العربية: يبني service item.
  Widget _buildServiceItem(Map<String, dynamic> service) {
    final isSelected = _selectedServices[service['id']] ?? false;
    final quantity = _serviceQuantities[service['id']] ?? 1;
    final animationController = _animationControllers[service['id']]!;

    if (isSelected && !animationController.isCompleted) {
      animationController.forward();
    } else if (!isSelected && animationController.isCompleted) {
      animationController.reverse();
    }

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isSelected
                  ? [
                      service['color'].withOpacity(0.2),
                      service['color'].withOpacity(0.1),
                    ]
                  : [
                      AppTheme.darkCard.withOpacity(0.5),
                      AppTheme.darkCard.withOpacity(0.3),
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? service['color'].withOpacity(0.5)
                  : AppTheme.darkBorder.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: service['color'].withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedServices[service['id']] = !isSelected;
                  _updateSelectedServices();
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildCheckbox(isSelected, service['color']),
                        const SizedBox(width: 12),
                        _buildServiceIcon(service),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service['name'],
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? AppTheme.textWhite
                                      : AppTheme.textWhite.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                service['description'],
                                style: AppTextStyles.caption.copyWith(
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  service['color'],
                                  service['color'].withOpacity(0.7),
                                ],
                              ).createShader(bounds),
                              child: Text(
                                context.tr(
                                  'booking.services.priceSuffix',
                                  params: {
                                    'price':
                                        service['price'].toStringAsFixed(0),
                                    'currency':
                                        service['currency']?.toString() ?? '',
                                  },
                                ),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (isSelected)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: animationController.value * 50,
                        child: animationController.value > 0.5
                            ? _buildQuantitySelector(service, quantity)
                            : const SizedBox.shrink(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// العربية: يبني checkbox.
  Widget _buildCheckbox(bool isSelected, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [color, color.withOpacity(0.7)],
              )
            : null,
        color: !isSelected ? Colors.transparent : null,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected ? Colors.transparent : AppTheme.darkBorder,
          width: 2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: isSelected
          ? const Icon(
              Icons.check,
              size: 16,
              color: Colors.white,
            )
          : null,
    );
  }

  /// العربية: يبني service icon.
  Widget _buildServiceIcon(Map<String, dynamic> service) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            service['color'].withOpacity(0.3),
            service['color'].withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        service['icon'],
        color: service['color'],
        size: 20,
      ),
    );
  }

  /// العربية: يبني quantity selector.
  Widget _buildQuantitySelector(Map<String, dynamic> service, int quantity) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            context.tr(
              'booking.services.quantity',
            ),
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.darkCard.withOpacity(0.8),
                  AppTheme.darkCard.withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: service['color'].withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildQuantityButton(
                  icon: Icons.remove,
                  onTap: quantity > 1
                      ? () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _serviceQuantities[service['id']] = quantity - 1;
                            _updateSelectedServices();
                          });
                        }
                      : null,
                  color: service['color'],
                ),
                Container(
                  constraints: const BoxConstraints(minWidth: 40),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    quantity.toString(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: service['color'],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                _buildQuantityButton(
                  icon: Icons.add,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _serviceQuantities[service['id']] = quantity + 1;
                      _updateSelectedServices();
                    });
                  },
                  color: service['color'],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// العربية: يبني quantity button.
  Widget _buildQuantityButton({
    required IconData icon,
    VoidCallback? onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 16,
            color: onTap != null ? color : AppTheme.darkBorder,
          ),
        ),
      ),
    );
  }

  /// العربية: يحدّث selected services.
  void _updateSelectedServices() {
    final selectedList = <Map<String, dynamic>>[];

    _selectedServices.forEach((id, isSelected) {
      if (isSelected) {
        final service = _services.firstWhere((s) => s['id'] == id);
        selectedList.add({
          'id': id,
          'name': service['name'],
          'price': service['price'] * (_serviceQuantities[id] ?? 1),
          'quantity': _serviceQuantities[id] ?? 1,
        });
      }
    });

    widget.onServicesChanged(selectedList);
  }
}
