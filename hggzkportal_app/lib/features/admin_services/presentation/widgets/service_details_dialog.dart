import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/service.dart';
import '../utils/service_icons.dart';

/// 📋 Service Details Dialog
class ServiceDetailsDialog extends StatelessWidget {
  /// العربية: يخزن القيمة `service`.
  final Service service;
  const ServiceDetailsDialog({
    super.key,
    required this.service,
  });
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.darkCard.withValues(alpha: 0.95),
              AppTheme.darkCard.withValues(alpha: 0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                _buildContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withValues(alpha: 0.1),
            AppTheme.primaryPurple.withValues(alpha: 0.05),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.darkBorder.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              ServiceIcons.getIconByName(service.icon),
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: AppTextStyles.heading2.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_normalizedSecondary(service.nameEn, service.name) != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _normalizedSecondary(service.nameEn, service.name)!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  'Icons.${service.icon}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppTheme.textMuted,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            color: AppTheme.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.business_rounded,
            label: 'العقار',
            value: service.propertyName,
            secondaryValue: _normalizedSecondary(
                service.propertyNameEn, service.propertyName),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.fingerprint_rounded,
            label: 'معرف الخدمة',
            value: service.id,
            isMonospace: true,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.description_rounded,
            label: 'الوصف',
            value: service.description?.trim().isNotEmpty == true
                ? service.description!
                : '-',
            secondaryValue: _normalizedSecondary(
              service.descriptionEn,
              service.description ?? '',
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.attach_money_rounded,
            label: 'السعر',
            value: '${service.price.amount} ${service.price.currency}',
            valueColor: AppTheme.success,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.category_rounded,
            label: 'نموذج التسعير',
            value: service.pricingModel.label,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    String? secondaryValue,
    bool isMonospace = false,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryBlue,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: valueColor ?? AppTheme.textWhite,
                  fontFamily: isMonospace ? 'monospace' : null,
                ),
              ),
              if (secondaryValue != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    secondaryValue,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
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
}
