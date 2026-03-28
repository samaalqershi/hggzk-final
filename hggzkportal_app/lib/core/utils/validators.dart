/// مجموعة دوال تحقق مشتركة تستخدمها نماذج الإدخال وطبقات الحماية قبل الإرسال.
/// Shared validation helpers used by input forms and guard layers before submission.
class Validators {
  Validators._();

  /// يوحد أرقام اليمن إلى الصيغة المحلية التي يتوقعها الخادم: 9 أرقام تبدأ بـ 7.
  /// Normalizes Yemen phone input to the backend-expected local format: 9 digits starting with 7.
  static String normalizeYemenPhone(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';

    String d = digits;
    if (d.startsWith('00967')) d = d.substring(2);
    if (d.startsWith('967') && d.length >= 12) d = d.substring(3);
    if (d.startsWith('0') && d.length >= 10) d = d.substring(1);
    if (d.length > 9) d = d.substring(d.length - 9);
    return d;
  }

  /// يتحقق من أن البريد الإلكتروني يطابق نمطًا بسيطًا وعمليًا.
  /// Validates that the email follows a simple, practical pattern.
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// يتحقق من طول كلمة المرور الأدنى، ويترك قواعد التعقيد للسياسة الأعلى.
  /// Checks the minimum password length and leaves complexity rules to higher-level policy.
  static bool isValidPassword(String password, {int minLength = 8}) {
    if (password.length < minLength) {
      return false;
    }
    return true;
  }

  /// يتحقق من أن رقم الهاتف اليمني بعد التطبيع يطابق النمط الصحيح.
  /// Validates the normalized Yemen phone number against the expected pattern.
  static bool isValidPhoneNumber(String phoneNumber) {
    final phoneRegex = RegExp(r'^7[0-9]{8}$');
    return phoneRegex.hasMatch(normalizeYemenPhone(phoneNumber));
  }

  /// يتحقق من أن الاسم مكتوب بالأحرف العربية والمسافات فقط.
  /// Validates that the name uses Arabic letters and spaces only.
  static bool isValidName(String name) {
    final nameRegex = RegExp(r'^[\u0600-\u06FF\s]+$');
    return nameRegex.hasMatch(name);
  }

  /// يتحقق من أن القيمة موجودة وغير فارغة.
  /// Validates that the value exists and is not empty.
  static bool isNotEmpty(String? value) {
    return value != null && value.isNotEmpty;
  }

  /// يتحقق من أن المبلغ رقمي ويحتوي على منزلتين عشريتين كحد أقصى.
  /// Validates that the amount is numeric with at most two decimal places.
  static bool isAmountValid(String amount) {
    final amountRegex = RegExp(r'^\d+(\.\d{1,2})?$');
    return amountRegex.hasMatch(amount);
  }

  /// مدققات جاهزة للاستخدام المباشر داخل `TextFormField.validator`.
  /// Ready-made validators for direct use in `TextFormField.validator`.
  static String? Function(String?) get validateName => (String? value) {
        final trimmed = value?.trim() ?? '';
        if (trimmed.isEmpty) {
          return 'مطلوب';
        }
        if (!isValidName(trimmed)) {
          return 'اسم غير صحيح';
        }
        return null;
      };
  static String? Function(String?) get validateEmail => (String? value) {
        final trimmed = value?.trim() ?? '';
        if (trimmed.isEmpty) {
          return 'مطلوب';
        }
        if (!isValidEmail(trimmed)) {
          return 'بريد غير صحيح';
        }
        return null;
      };
  static String? Function(String?) get validatePassword => (String? value) {
        final raw = value ?? '';
        if (raw.isEmpty) {
          return 'مطلوب';
        }
        if (!isValidPassword(raw, minLength: 8)) {
          return '8 أحرف على الأقل';
        }
        return null;
      };
  static String? Function(String?) get validatePhone => (String? value) {
        final trimmed = value?.trim() ?? '';
        if (trimmed.isEmpty) {
          return 'مطلوب';
        }
        if (!isValidPhoneNumber(trimmed)) {
          return 'رقم الهاتف يجب أن يبدأ بـ 7 ويتكون من 9 أرقام';
        }
        return null;
      };
}
