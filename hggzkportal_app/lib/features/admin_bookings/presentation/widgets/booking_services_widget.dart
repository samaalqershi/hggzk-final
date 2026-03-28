// lib/features/admin_bookings/presentation/widgets/booking_services_widget.dart

import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/booking_details.dart';

/// تعرض الخدمات الإضافية المرتبطة بالحجز مع الإجمالي والتقسيم حسب الفئة.
/// Shows extra booking services with totals and category breakdown.
class BookingServicesWidget extends StatelessWidget {
  /// قائمة الخدمات المرتبطة بالحجز الحالي.
  /// Services attached to the current booking.
  final List<Service> services;

  /// يستدعى عند طلب إضافة خدمة جديدة إلى الحجز.
  /// Called when the user wants to add a new service.
  final VoidCallback? onAddService;

  /// يستدعى عند إزالة خدمة بواسطة معرّفها.
  /// Called when a service should be removed by its identifier.
  final Function(String)? onRemoveService;

  /// يستدعى عند تعديل خدمة موجودة.
  /// Called when an existing service needs editing.
  final VoidCallback? onEditService;

  /// يستدعى لفتح تفاصيل الخدمة المختارة.
  /// Called to open the selected service details.
  final VoidCallback? onShowServiceDetails;

  /// ينشئ ويدجت الخدمات مع ردود الأفعال الاختيارية.
  /// Creates the services widget with optional action callbacks.
  const BookingServicesWidget({
    super.key,
    required this.services,
    this.onAddService,
    this.onRemoveService,
    this.onEditService,
    this.onShowServiceDetails,
  });

  /// يبني الحاوية الأساسية مع الرأس والملخص والقائمة والتذييل.
  /// Builds the main container with header, summary, list, and footer.
  @override
  Widget build(BuildContext context) {
    final totalAmount = _calculateTotalAmount();
    final hasServices = services.isNotEmpty;
    final categorizedServices = _categorizeServices();
    final currency =
        services.isNotEmpty ? services.first.price.currency : 'YER';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowDark.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.darkCard.withValues(alpha: 0.8),
                  AppTheme.darkCard.withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: hasServices
                    ? AppTheme.primaryBlue.withValues(alpha: 0.3)
                    : AppTheme.darkBorder.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                _buildHeader(hasServices),
                if (hasServices)
                  _buildSummary(totalAmount, categorizedServices, currency),
                if (hasServices) _buildServicesList() else _buildEmptyState(),
                _buildFooter(hasServices, totalAmount),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// يبني رأس القسم مع حالة وجود الخدمات وعددها.
  /// Builds the section header with service presence and count.
  Widget _buildHeader(bool hasServices) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasServices
              ? [
                  AppTheme.primaryBlue.withValues(alpha: 0.15),
                  AppTheme.primaryBlue.withValues(alpha: 0.05),
                ]
              : [
                  AppTheme.darkCard.withValues(alpha: 0.15),
                  AppTheme.darkCard.withValues(alpha: 0.05),
                ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.darkBorder.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: hasServices
                    ? [
                        AppTheme.primaryBlue,
                        AppTheme.primaryBlue.withValues(alpha: 0.7)
                      ]
                    : [
                        AppTheme.textMuted,
                        AppTheme.textMuted.withValues(alpha: 0.7)
                      ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              hasServices
                  ? CupertinoIcons.sparkles
                  : CupertinoIcons.square_stack,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الخدمات الإضافية',
                style: AppTextStyles.heading3.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: hasServices
                      ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                      : AppTheme.textMuted.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hasServices
                      ? '${services.length} خدمة نشطة'
                      : 'لا توجد خدمات',
                  style: AppTextStyles.caption.copyWith(
                    color:
                        hasServices ? AppTheme.primaryBlue : AppTheme.textMuted,
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

  /// يبني ملخصًا مختصرًا للإجمالي وعدد الفئات والمبلغ النهائي.
  /// Builds a compact summary for totals, category count, and final amount.
  Widget _buildSummary(double totalAmount,
      Map<String, List<Service>> categorized, String currency) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildSummaryRow(
            label: 'إجمالي الخدمات',
            value: '${services.length} خدمة',
            icon: CupertinoIcons.square_stack_fill,
            color: AppTheme.textWhite,
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            label: 'عدد الفئات',
            value: '${categorized.keys.length} فئة',
            icon: CupertinoIcons.square_grid_2x2_fill,
            color: AppTheme.primaryPurple,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withValues(alpha: 0.15),
                  AppTheme.primaryBlue.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryBlue.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.tag_circle_fill,
                  color: AppTheme.primaryBlue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'المبلغ الإجمالي',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    Formatters.formatCurrency(totalAmount, currency),
                    style: AppTextStyles.heading2.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
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

  /// يبني سطرًا واحدًا داخل الملخص يعرض تسمية وقيمة وأيقونة.
  /// Builds one summary row with label, value, and icon.
  Widget _buildSummaryRow({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: color.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// يعرض قائمة الخدمات الفعلية مع تأثيرات دخول متدرجة.
  /// Renders the actual services list with staggered entry animation.
  Widget _buildServicesList() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفاصيل الخدمات',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          AnimationLimiter(
            child: Column(
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 20,
                  child: FadeInAnimation(child: widget),
                ),
                children: services
                    .map((service) => _buildServiceItem(service))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// يبني بطاقة خدمة واحدة مع السعر والحالة والأزرار السياقية.
  /// Builds one service card with price, status, and contextual actions.
  Widget _buildServiceItem(Service service) {
    final activeColor = AppTheme.primaryBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            activeColor.withValues(alpha: 0.05),
            AppTheme.darkBackground.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: activeColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: activeColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onShowServiceDetails,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Service Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        activeColor.withValues(alpha: 0.2),
                        activeColor.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getServiceIcon(service.category),
                    color: activeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Service Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              service.name,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppTheme.textWhite,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'نشط',
                              style: AppTextStyles.caption.copyWith(
                                color: AppTheme.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.cube_box,
                            size: 12,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'الكمية: ${service.quantity}',
                              style: AppTextStyles.caption.copyWith(
                                color: AppTheme.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            CupertinoIcons.tag,
                            size: 12,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              service.category ?? 'عام',
                              style: AppTextStyles.caption.copyWith(
                                color: AppTheme.textMuted,
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

                // Price and Actions
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      service.totalPrice.formattedAmount,
                      style: AppTextStyles.heading3.copyWith(
                        color: activeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onEditService != null)
                          InkWell(
                            onTap: onEditService,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.primaryBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                CupertinoIcons.pencil,
                                size: 14,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ),
                        if (onRemoveService != null) ...[
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => onRemoveService!(service.id),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                CupertinoIcons.trash,
                                size: 14,
                                color: AppTheme.error,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// يعرض حالة فارغة عندما لا توجد خدمات مرتبطة بالحجز.
  /// Shows the empty state when no services are attached to the booking.
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(60),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.darkCard.withValues(alpha: 0.5),
                    AppTheme.darkBackground.withValues(alpha: 0.3),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.square_stack,
                size: 40,
                color: AppTheme.textMuted.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'لا توجد خدمات إضافية',
              style: AppTextStyles.heading3.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'يمكنك إضافة خدمات للحجز من خلال الزر أدناه',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// يبني التذييل الذي يوضح الإجراءات والإجمالي أو دعوة الإضافة.
  /// Builds the footer with actions and total, or an add-services prompt.
  Widget _buildFooter(bool hasServices, double totalAmount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground.withValues(alpha: 0.3),
        border: Border(
          top: BorderSide(
            color: AppTheme.darkBorder.withValues(alpha: 0.1),
          ),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          if (onAddService != null) ...[
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withValues(alpha: 0.8),
                      AppTheme.primaryBlue,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onAddService,
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.plus_circle_fill,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'إضافة خدمة',
                            style: AppTextStyles.buttonMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          if (hasServices)
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.darkCard.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.darkBorder.withValues(alpha: 0.3),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onShowServiceDetails,
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.doc_text,
                            color: AppTheme.textMuted,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'تقرير الخدمات',
                            style: AppTextStyles.buttonMedium.copyWith(
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
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

  /// يجمع قيم الخدمات كلها لإظهار المبلغ الإجمالي.
  /// Sums all services to produce the total amount.
  double _calculateTotalAmount() {
    return services.fold<double>(
      0,
      (sum, service) => sum + service.totalPrice.amount,
    );
  }

  /// يجمع الخدمات في خريطة حسب الفئة لإظهار التوزيع المنظم.
  /// Groups services by category for a structured breakdown.
  Map<String, List<Service>> _categorizeServices() {
    final Map<String, List<Service>> categorized = {};
    for (final service in services) {
      final category = service.category ?? 'عام';
      if (categorized.containsKey(category)) {
        categorized[category]!.add(service);
      } else {
        categorized[category] = [service];
      }
    }
    return categorized;
  }

  /// يختار أيقونة مناسبة بحسب فئة الخدمة أو نوعها.
  /// Chooses an appropriate icon based on the service category or type.
  IconData _getServiceIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'food':
      case 'طعام':
        return CupertinoIcons.bag_fill;
      case 'transport':
      case 'نقل':
        return CupertinoIcons.car_fill;
      case 'cleaning':
      case 'تنظيف':
        return CupertinoIcons.sparkles;
      case 'entertainment':
      case 'ترفيه':
        return CupertinoIcons.tv_fill;
      case 'laundry':
      case 'غسيل':
        return CupertinoIcons.drop_fill;
      case 'spa':
      case 'سبا':
        return CupertinoIcons.heart_fill;
      case 'maintenance':
      case 'صيانة':
        return CupertinoIcons.wrench_fill;
      default:
        return CupertinoIcons.square_grid_2x2_fill;
    }
  }
}
