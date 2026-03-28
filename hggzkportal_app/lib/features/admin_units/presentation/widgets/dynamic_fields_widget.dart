// lib/features/admin_units/presentation/widgets/dynamic_fields_widget.dart

import 'package:hggzkportal/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:hggzkportal/core/theme/app_text_styles.dart';
import '../../domain/entities/unit_type.dart';
import 'package:intl/intl.dart';

/// يمثل هذا الكلاس DynamicFieldsWidget البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for DynamicFieldsWidget in the admin unit workflow.
class DynamicFieldsWidget extends StatefulWidget {
  /// This field keeps the fields value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة fields التي يعتمد عليها مسار إدارة الوحدات.
  final List<UnitTypeField> fields;

  /// يحتفظ هذا الحقل بقيمة values التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the values value used by the admin unit workflow.
  final Map<String, dynamic> values;

  /// ينفذ هذا الأسلوب عملية Function ضمن مسار إدارة الوحدات.
  /// This method performs the Function operation in the admin unit workflow.
  final Function(Map<String, dynamic>) onChanged;

  /// يحتفظ هذا الحقل بقيمة isReadOnly التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the isReadOnly value used by the admin unit workflow.
  final bool isReadOnly;

  /// ينشئ هذا المُنشئ مثيلاً من DynamicFieldsWidget.
  /// This constructor creates an instance of DynamicFieldsWidget.
  const DynamicFieldsWidget({
    super.key,
    required this.fields,
    required this.values,
    required this.onChanged,
    this.isReadOnly = false,
  });

  /// ينشئ هذا الأسلوب كائن الحالة الخاص بهذه الصفحة.
  /// This method performs the createState operation in the admin unit workflow.
  @override
  State<DynamicFieldsWidget> createState() => _DynamicFieldsWidgetState();
}

/// يمثل هذا الكلاس _DynamicFieldsWidgetState البيانات والسلوك المستخدمين في إدارة الوحدات.
/// This class models the data and behavior for _DynamicFieldsWidgetState in the admin unit workflow.
class _DynamicFieldsWidgetState extends State<DynamicFieldsWidget> {
  /// This field keeps the textControllers value used by the admin unit workflow.
  /// يحتفظ هذا الحقل بقيمة textControllers التي يعتمد عليها مسار إدارة الوحدات.
  late Map<String, TextEditingController> _textControllers;

  /// يحتفظ هذا الحقل بقيمة _currentValues التي يعتمد عليها مسار إدارة الوحدات.
  /// This field keeps the _currentValues value used by the admin unit workflow.
  late Map<String, dynamic> _currentValues;

  // Safely coerce dynamic values into a boolean
  /// ينفذ هذا الأسلوب عملية _asBool ضمن مسار إدارة الوحدات.
  /// This method performs the _asBool operation in the admin unit workflow.
  bool _asBool(dynamic v) {
    if (v is bool) return v;
    if (v is String) {
      final s = v.toLowerCase().trim();
      return s == 'true' || s == '1' || s == 'yes' || s == 'y';
    }
    if (v is num) return v != 0;
    return false;
  }

  /// ينفذ هذا الأسلوب عملية initState ضمن مسار إدارة الوحدات.
  /// This method performs the initState operation in the admin unit workflow.
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _currentValues = Map<String, dynamic>.from(widget.values);

    // Ensure sensible defaults (especially booleans -> false)
    bool changed = false;
    for (final field in widget.fields) {
      if (field.fieldTypeId == 'boolean' &&
          _currentValues[field.fieldId] == null) {
        _currentValues[field.fieldId] = false;
        changed = true;
      }
    }

    // Propagate defaults to parent if anything changed
    if (changed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onChanged(_currentValues);
      });
    }
  }

  /// ينفذ هذا الأسلوب عملية _initializeControllers ضمن مسار إدارة الوحدات.
  /// This method performs the _initializeControllers operation in the admin unit workflow.
  void _initializeControllers() {
    _textControllers = {};
    for (final field in widget.fields) {
      if (_isTextBasedField(field.fieldTypeId)) {
        _textControllers[field.fieldId] = TextEditingController(
          text: widget.values[field.fieldId]?.toString() ?? '',
        );
      }
    }
  }

  /// ينفذ هذا الأسلوب عملية didUpdateWidget ضمن مسار إدارة الوحدات.
  /// This method performs the didUpdateWidget operation in the admin unit workflow.
  @override
  void didUpdateWidget(covariant DynamicFieldsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Rebuild controllers for text-based fields when fields/values change
    final Set<String> newTextFieldIds = {
      for (final f in widget.fields)
        if (_isTextBasedField(f.fieldTypeId)) f.fieldId
    };

    // Remove controllers for fields no longer present
    final idsToRemove = _textControllers.keys
        .where((id) => !newTextFieldIds.contains(id))
        .toList();
    for (final id in idsToRemove) {
      _textControllers[id]?.dispose();
      _textControllers.remove(id);
    }

    // Add controllers for new text fields and sync their text
    for (final field in widget.fields) {
      if (_isTextBasedField(field.fieldTypeId)) {
        _textControllers.putIfAbsent(
            field.fieldId, () => TextEditingController());
      }
    }

    // Build new values map and ensure boolean defaults
    final Map<String, dynamic> newValues =
        Map<String, dynamic>.from(widget.values);
    bool changed = false;
    for (final field in widget.fields) {
      if (field.fieldTypeId == 'boolean' && newValues[field.fieldId] == null) {
        newValues[field.fieldId] = false;
        changed = true;
      }
    }

    // Sync controller texts for text-based fields
    for (final id in newTextFieldIds) {
      final String text = newValues[id]?.toString() ?? '';
      final controller = _textControllers[id]!;
      if (controller.text != text) {
        controller.text = text;
      }
    }

    // Update local snapshot
    _currentValues = newValues;

    // Notify parent if defaults were injected (avoids missing required bool fields)
    if (changed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onChanged(_currentValues);
      });
    }
  }

  /// ينفذ هذا الأسلوب عملية _isTextBasedField ضمن مسار إدارة الوحدات.
  /// This method performs the _isTextBasedField operation in the admin unit workflow.
  bool _isTextBasedField(String fieldType) {
    return ['text', 'textarea', 'email', 'phone', 'number', 'currency']
        .contains(fieldType);
  }

  /// استخراج الخيارات من fieldOptions بشكل آمن
  /// Safely extract options from fieldOptions regardless of type
  /// ينفذ هذا الأسلوب عملية _extractOptions ضمن مسار إدارة الوحدات.
  /// This method performs the _extractOptions operation in the admin unit workflow.
  List<String> _extractOptions(Map<String, dynamic>? fieldOptions) {
    if (fieldOptions == null) return [];

    final optionsValue = fieldOptions['options'];

    // إذا كانت قائمة مباشرة
    if (optionsValue is List) {
      return optionsValue.map((e) => e.toString()).toList();
    }

    // إذا كانت Map (مفاتيح رقمية مثل {"0": "خيار1", "1": "خيار2"})
    if (optionsValue is Map) {
      // ترتيب المفاتيح إذا كانت رقمية
      final keys = optionsValue.keys.toList();
      final numericKeys = keys
          .whereType<String>()
          .where((k) => int.tryParse(k) != null)
          .toList();

      if (numericKeys.length == keys.length) {
        // جميع المفاتيح رقمية - رتبها
        numericKeys.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
        return numericKeys.map((k) => optionsValue[k].toString()).toList();
      }

      // مفاتيح غير رقمية - استخدم القيم مباشرة
      return optionsValue.values.map((v) => v.toString()).toList();
    }

    // إذا كانت سلسلة نصية مفصولة بفاصلة
    if (optionsValue is String && optionsValue.isNotEmpty) {
      return optionsValue
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return [];
  }

  /// ينفذ هذا الأسلوب عملية dispose ضمن مسار إدارة الوحدات.
  /// This method performs the dispose operation in the admin unit workflow.
  @override
  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// ينفذ هذا الأسلوب عملية build ضمن مسار إدارة الوحدات.
  /// This method performs the build operation in the admin unit workflow.
  @override
  Widget build(BuildContext context) {
    if (widget.fields.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.5),
            AppTheme.darkCard.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.dynamic_form_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'معلومات إضافية',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ...widget.fields.map((field) => _buildField(field)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildEmptyState ضمن مسار إدارة الوحدات.
  /// This method performs the _buildEmptyState operation in the admin unit workflow.
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard.withValues(alpha: 0.3),
            AppTheme.darkCard.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.darkBorder.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withValues(alpha: 0.2),
                    AppTheme.primaryPurple.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.dynamic_form_rounded,
                size: 30,
                color: AppTheme.primaryBlue.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد حقول إضافية',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildField ضمن مسار إدارة الوحدات.
  /// This method performs the _buildField operation in the admin unit workflow.
  Widget _buildField(UnitTypeField field) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel(field),
          const SizedBox(height: 8),
          _buildFieldInput(field),
          if (field.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            _buildFieldDescription(field.description),
          ],
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildFieldLabel ضمن مسار إدارة الوحدات.
  /// This method performs the _buildFieldLabel operation in the admin unit workflow.
  Widget _buildFieldLabel(UnitTypeField field) {
    return Row(
      children: [
        Text(
          field.displayName,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (field.isRequired)
          Text(
            ' *',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.error,
            ),
          ),
      ],
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildFieldDescription ضمن مسار إدارة الوحدات.
  /// This method performs the _buildFieldDescription operation in the admin unit workflow.
  Widget _buildFieldDescription(String description) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Text(
        description,
        style: AppTextStyles.caption.copyWith(
          color: AppTheme.textMuted.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildFieldInput ضمن مسار إدارة الوحدات.
  /// This method performs the _buildFieldInput operation in the admin unit workflow.
  Widget _buildFieldInput(UnitTypeField field) {
    switch (field.fieldTypeId) {
      case 'text':
        return _buildTextField(field);
      case 'textarea':
        return _buildTextArea(field);
      case 'number':
        return _buildNumberField(field);
      case 'currency':
        return _buildCurrencyField(field);
      case 'email':
        return _buildEmailField(field);
      case 'phone':
        return _buildPhoneField(field);
      case 'boolean':
        return _buildBooleanField(field);
      case 'select':
        return _buildSelectField(field);
      case 'multiselect':
        return _buildMultiSelectField(field);
      case 'date':
        return _buildDateField(field);
      case 'file':
        return _buildFileField(field);
      case 'image':
        return _buildImageField(field);
      default:
        return _buildTextField(field);
    }
  }

  /// ينفذ هذا الأسلوب عملية _buildTextField ضمن مسار إدارة الوحدات.
  /// This method performs the _buildTextField operation in the admin unit workflow.
  Widget _buildTextField(UnitTypeField field) {
    return Container(
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
      child: TextField(
        controller: _textControllers[field.fieldId],
        style: AppTextStyles.bodyMedium.copyWith(color: AppTheme.textWhite),
        readOnly: widget.isReadOnly,
        decoration: InputDecoration(
          hintText: 'أدخل ${field.displayName}',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textMuted.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Icon(
            Icons.text_fields_rounded,
            size: 20,
            color: AppTheme.primaryBlue.withValues(alpha: 0.7),
          ),
        ),
        onChanged: widget.isReadOnly
            ? null
            : (value) {
                _updateValue(field.fieldId, value);
              },
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildTextArea ضمن مسار إدارة الوحدات.
  /// This method performs the _buildTextArea operation in the admin unit workflow.
  Widget _buildTextArea(UnitTypeField field) {
    return Container(
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
      child: TextField(
        controller: _textControllers[field.fieldId],
        style: AppTextStyles.bodyMedium.copyWith(color: AppTheme.textWhite),
        readOnly: widget.isReadOnly,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'أدخل ${field.displayName}',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textMuted.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          alignLabelWithHint: true,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Icon(
              Icons.subject_rounded,
              size: 20,
              color: AppTheme.primaryPurple.withValues(alpha: 0.7),
            ),
          ),
        ),
        onChanged: widget.isReadOnly
            ? null
            : (value) {
                _updateValue(field.fieldId, value);
              },
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildNumberField ضمن مسار إدارة الوحدات.
  /// This method performs the _buildNumberField operation in the admin unit workflow.
  Widget _buildNumberField(UnitTypeField field) {
    return Container(
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
      child: TextField(
        controller: _textControllers[field.fieldId],
        style: AppTextStyles.bodyMedium.copyWith(color: AppTheme.textWhite),
        readOnly: widget.isReadOnly,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          hintText: 'أدخل ${field.displayName}',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textMuted.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Icon(
            Icons.numbers_rounded,
            size: 20,
            color: AppTheme.success.withValues(alpha: 0.7),
          ),
        ),
        onChanged: widget.isReadOnly
            ? null
            : (value) {
                final numValue = int.tryParse(value) ?? 0;
                _updateValue(field.fieldId, numValue);
              },
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildCurrencyField ضمن مسار إدارة الوحدات.
  /// This method performs the _buildCurrencyField operation in the admin unit workflow.
  Widget _buildCurrencyField(UnitTypeField field) {
    return Container(
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
      child: TextField(
        controller: _textControllers[field.fieldId],
        style: AppTextStyles.bodyMedium.copyWith(color: AppTheme.textWhite),
        readOnly: widget.isReadOnly,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        decoration: InputDecoration(
          hintText: 'أدخل ${field.displayName}',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textMuted.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Icon(
            Icons.attach_money_rounded,
            size: 20,
            color: AppTheme.warning.withValues(alpha: 0.7),
          ),
          suffixText: 'ريال',
          suffixStyle: AppTextStyles.bodySmall.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
        onChanged: widget.isReadOnly
            ? null
            : (value) {
                final numValue = double.tryParse(value) ?? 0.0;
                _updateValue(field.fieldId, numValue);
              },
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildEmailField ضمن مسار إدارة الوحدات.
  /// This method performs the _buildEmailField operation in the admin unit workflow.
  Widget _buildEmailField(UnitTypeField field) {
    return Container(
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
      child: TextField(
        controller: _textControllers[field.fieldId],
        style: AppTextStyles.bodyMedium.copyWith(color: AppTheme.textWhite),
        readOnly: widget.isReadOnly,
        keyboardType: TextInputType.emailAddress,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]')),
        ],
        decoration: InputDecoration(
          hintText: 'example@email.com',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textMuted.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Icon(
            Icons.email_rounded,
            size: 20,
            color: AppTheme.primaryBlue.withValues(alpha: 0.7),
          ),
        ),
        onChanged: widget.isReadOnly
            ? null
            : (value) {
                _updateValue(field.fieldId, value);
              },
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildPhoneField ضمن مسار إدارة الوحدات.
  /// This method performs the _buildPhoneField operation in the admin unit workflow.
  Widget _buildPhoneField(UnitTypeField field) {
    return Container(
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
      child: TextField(
        controller: _textControllers[field.fieldId],
        style: AppTextStyles.bodyMedium.copyWith(color: AppTheme.textWhite),
        readOnly: widget.isReadOnly,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        decoration: InputDecoration(
          hintText: '05XXXXXXXX',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textMuted.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Icon(
            Icons.phone_rounded,
            size: 20,
            color: AppTheme.success.withValues(alpha: 0.7),
          ),
        ),
        onChanged: widget.isReadOnly
            ? null
            : (value) {
                _updateValue(field.fieldId, value);
              },
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildBooleanField ضمن مسار إدارة الوحدات.
  /// This method performs the _buildBooleanField operation in the admin unit workflow.
  Widget _buildBooleanField(UnitTypeField field) {
    final bool value = _asBool(_currentValues[field.fieldId]);

    return GestureDetector(
      onTap: widget.isReadOnly
          ? null
          : () {
              HapticFeedback.lightImpact();
              _updateValue(field.fieldId, !value);
            },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: value
                ? [
                    AppTheme.primaryBlue.withValues(alpha: 0.2),
                    AppTheme.primaryPurple.withValues(alpha: 0.1),
                  ]
                : [
                    AppTheme.darkSurface.withValues(alpha: 0.5),
                    AppTheme.darkSurface.withValues(alpha: 0.3),
                  ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value
                ? AppTheme.primaryBlue.withValues(alpha: 0.5)
                : AppTheme.darkBorder.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                gradient: value ? AppTheme.primaryGradient : null,
                color: value ? null : AppTheme.darkCard,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value
                      ? AppTheme.primaryBlue
                      : AppTheme.darkBorder.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: value
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              value ? 'نعم' : 'لا',
              style: AppTextStyles.bodyMedium.copyWith(
                color: value ? AppTheme.primaryBlue : AppTheme.textMuted,
                fontWeight: value ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildSelectField ضمن مسار إدارة الوحدات.
  /// This method performs the _buildSelectField operation in the admin unit workflow.
  Widget _buildSelectField(UnitTypeField field) {
    final options = _extractOptions(field.fieldOptions);
    final value = _currentValues[field.fieldId];

    return Container(
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
      child: DropdownButtonFormField<String>(
        value: value?.toString(),
        dropdownColor: AppTheme.darkCard,
        style: AppTextStyles.bodyMedium.copyWith(color: AppTheme.textWhite),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          prefixIcon: Icon(
            Icons.arrow_drop_down_circle_rounded,
            color: AppTheme.neonPurple.withValues(alpha: 0.7),
            size: 20,
          ),
        ),
        hint: Text(
          'اختر ${field.displayName}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textMuted.withValues(alpha: 0.5),
          ),
        ),
        items: options.map((option) {
          return DropdownMenuItem<String>(
            value: option.toString(),
            child: Text(
              option.toString(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textWhite,
              ),
            ),
          );
        }).toList(),
        onChanged: widget.isReadOnly
            ? null
            : (newValue) {
                _updateValue(field.fieldId, newValue);
              },
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildMultiSelectField ضمن مسار إدارة الوحدات.
  /// This method performs the _buildMultiSelectField operation in the admin unit workflow.
  Widget _buildMultiSelectField(UnitTypeField field) {
    final options = _extractOptions(field.fieldOptions);
    final selectedValues =
        (_currentValues[field.fieldId] as List<dynamic>?) ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: options.map((option) {
              final isSelected = selectedValues.contains(option);

              return GestureDetector(
                onTap: widget.isReadOnly
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        final newSelected = List<dynamic>.from(selectedValues);

                        if (isSelected) {
                          newSelected.remove(option);
                        } else {
                          newSelected.add(option);
                        }

                        _updateValue(field.fieldId, newSelected);
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppTheme.primaryGradient : null,
                    color: isSelected ? null : AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryBlue
                          : AppTheme.darkBorder.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    option.toString(),
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

  /// ينفذ هذا الأسلوب عملية _buildDateField ضمن مسار إدارة الوحدات.
  /// This method performs the _buildDateField operation in the admin unit workflow.
  Widget _buildDateField(UnitTypeField field) {
    final value = _currentValues[field.fieldId];
    DateTime? selectedDate;
    if (value != null) {
      if (value is DateTime) {
        selectedDate = value;
      } else if (value is String) {
        selectedDate = DateTime.tryParse(value);
      }
    }

    return GestureDetector(
      onTap: widget.isReadOnly
          ? null
          : () async {
              HapticFeedback.lightImpact();
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.dark(
                        primary: AppTheme.primaryBlue,
                        onPrimary: Colors.white,
                        surface: AppTheme.darkCard,
                        onSurface: AppTheme.textWhite,
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (picked != null) {
                _updateValue(field.fieldId, picked.toIso8601String());
              }
            },
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 20,
              color: AppTheme.primaryPurple.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedDate != null
                    ? DateFormat('yyyy-MM-dd').format(selectedDate)
                    : 'اختر التاريخ',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: selectedDate != null
                      ? AppTheme.textWhite
                      : AppTheme.textMuted.withValues(alpha: 0.5),
                ),
              ),
            ),
            if (selectedDate != null && !widget.isReadOnly)
              GestureDetector(
                onTap: () {
                  _updateValue(field.fieldId, null);
                },
                child: Icon(
                  Icons.clear_rounded,
                  size: 18,
                  color: AppTheme.textMuted,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildFileField ضمن مسار إدارة الوحدات.
  /// This method performs the _buildFileField operation in the admin unit workflow.
  Widget _buildFileField(UnitTypeField field) {
    final fileName = _currentValues[field.fieldId];

    return GestureDetector(
      onTap: widget.isReadOnly
          ? null
          : () {
              HapticFeedback.lightImpact();
              // TODO: Implement file picker
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('اختيار الملف قيد التطوير')),
              );
            },
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Icon(
              Icons.attach_file_rounded,
              size: 20,
              color: AppTheme.warning.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                fileName ?? 'اختر ملف',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: fileName != null
                      ? AppTheme.textWhite
                      : AppTheme.textMuted.withValues(alpha: 0.5),
                ),
              ),
            ),
            if (!widget.isReadOnly)
              Icon(
                Icons.upload_rounded,
                size: 18,
                color: AppTheme.primaryBlue,
              ),
          ],
        ),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildImageField ضمن مسار إدارة الوحدات.
  /// This method performs the _buildImageField operation in the admin unit workflow.
  Widget _buildImageField(UnitTypeField field) {
    final imagePath = _currentValues[field.fieldId];

    return GestureDetector(
      onTap: widget.isReadOnly
          ? null
          : () {
              HapticFeedback.lightImpact();
              // TODO: Implement image picker
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('اختيار الصورة قيد التطوير')),
              );
            },
      child: Container(
        height: 120,
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
        child: imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImagePlaceholder();
                  },
                ),
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _buildImagePlaceholder ضمن مسار إدارة الوحدات.
  /// This method performs the _buildImagePlaceholder operation in the admin unit workflow.
  Widget _buildImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_rounded,
            size: 40,
            color: AppTheme.info.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'اختر صورة',
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.textMuted.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// ينفذ هذا الأسلوب عملية _updateValue ضمن مسار إدارة الوحدات.
  /// This method performs the _updateValue operation in the admin unit workflow.
  void _updateValue(String fieldId, dynamic value) {
    setState(() {
      _currentValues[fieldId] = value;
    });
    widget.onChanged(_currentValues);
  }
}
