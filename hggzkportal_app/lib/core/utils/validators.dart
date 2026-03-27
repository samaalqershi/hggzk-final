class Validators {
  Validators._();

  /// Normalizes Yemen phone input to backend-expected local format: 9 digits starting with 7.
  /// Accepts inputs like: +9677xxxxxxx, 009677xxxxxxx, 9677xxxxxxx, 07xxxxxxx, or with spaces.
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

  static bool isValidEmail(String email) {
    // Simple email regex pattern
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  static bool isValidPassword(String password, {int minLength = 8}) {
    if (password.length < minLength) {
      return false;
    }
    // Add more password complexity rules if needed (e.g., uppercase, number, special char)
    // final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    // return passwordRegex.hasMatch(password);
    return true;
  }

  static bool isValidPhoneNumber(String phoneNumber) {
    // YEMEN phone number format: 9 digits starting with 7
    final phoneRegex = RegExp(r'^7[0-9]{8}$');
    return phoneRegex.hasMatch(normalizeYemenPhone(phoneNumber));
  }

  static bool isValidName(String name) {
    // [ISSUE 1008] اصلاح مشكلة عدم قبول اسم مستخدم باللغة الانجليزية عند انشاء او تعديل مستخدم  في تطبيق لوحة التحكم
    // تم تعطيل كود الإصلاح أدناه لإرجاع السلوك القديم (رفض الأسماء الإنجليزية أثناء إنشاء/تعديل المستخدم)
    // final nameRegex = RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$');
    final nameRegex = RegExp(r'^[\u0600-\u06FF\s]+$');
    return nameRegex.hasMatch(name);
  }

  static bool isNotEmpty(String? value) {
    return value != null && value.isNotEmpty;
  }

  static bool isAmountValid(String amount) {
    final amountRegex = RegExp(
        r'^\d+(\.\d{1,2})?$'); // Allows integers or decimals with 1 or 2 places
    return amountRegex.hasMatch(amount);
  }

  // Add other validation methods as needed

  // Form field validators (to be used directly as TextFormField.validator)
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
