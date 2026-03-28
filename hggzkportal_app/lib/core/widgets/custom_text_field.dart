// lib/core/widgets/custom_text_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// حقل إدخال موحّد يحافظ على نفس المظهر والسلوك في شاشات البورتال.
/// Consistent text field used to keep portal forms visually and behaviorally aligned.
class CustomTextField extends StatelessWidget {
  /// المتحكم في النص الحالي داخل الحقل.
  /// Controller for the current text value.
  final TextEditingController controller;

  /// تسمية الحقل التي تظهر أعلى منطقة الإدخال.
  /// Visible label shown above the input area.
  final String label;

  /// نص إرشادي يظهر داخل الحقل عندما يكون فارغًا.
  /// Hint text shown inside the field when it is empty.
  final String? hint;

  /// الأيقونة الظاهرة في بداية الحقل.
  /// Leading icon shown at the start of the field.
  final IconData? prefixIcon;

  /// الأيقونة الظاهرة في نهاية الحقل مثل إظهار/إخفاء النص.
  /// Trailing icon shown at the end of the field such as show/hide text.
  final IconData? suffixIcon;

  /// يجعل النص مخفيًا عادةً لحالات كلمات المرور.
  /// Hides the input text, typically for password fields.
  final bool obscureText;

  /// يحدد ما إذا كان الحقل للقراءة فقط.
  /// Marks the field as read-only.
  final bool readOnly;

  /// الحد الأقصى لعدد الأسطر المعروضة.
  /// Maximum number of visible lines.
  final int maxLines;

  /// نوع لوحة المفاتيح المطلوبة لهذا الإدخال.
  /// Keyboard type requested for this input.
  final TextInputType? keyboardType;

  /// فلاتر الإدخال التي تنظف أو تقيد ما يكتبه المستخدم.
  /// Input formatters that constrain or sanitize user input.
  final List<TextInputFormatter>? inputFormatters;

  /// دالة التحقق من صحة القيمة عند استخدام الحقل داخل Form.
  /// Validator used when the field is placed inside a Form.
  final String? Function(String?)? validator;

  /// استدعاء اختياري عند تغيير النص.
  /// Optional callback invoked when the text changes.
  final void Function(String)? onChanged;

  /// استدعاء اختياري عند الضغط على الأيقونة الجانبية.
  /// Optional callback when the suffix icon is pressed.
  final void Function()? onSuffixIconPressed;

  /// يفعّل التركيز التلقائي عند بناء الحقل.
  /// Requests autofocus when the field is built.
  final bool autofocus;

  /// ينشئ حقل إدخال قابلًا لإعادة الاستخدام مع نفس لغة التصميم في البورتال.
  /// Creates a reusable input field with the portal's shared visual language.
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSuffixIconPressed,
    this.autofocus = false,
  });

  /// يبني الحقل مع الحدود والأيقونات والتنبيهات المرئية المعتادة في التطبيق.
  /// Builds the field with the borders, icons, and visual cues used throughout the app.
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            readOnly: readOnly,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator,
            onChanged: onChanged,
            autofocus: autofocus,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      color: AppColors.primary,
                      size: 20,
                    )
                  : null,
              suffixIcon: suffixIcon != null
                  ? IconButton(
                      onPressed: onSuffixIconPressed,
                      icon: Icon(
                        suffixIcon,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
