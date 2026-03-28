/// مجموعة تحققات قابلة لإعادة الاستخدام داخل النماذج وواجهات الإدخال.
/// Reusable validation helpers for forms and input fields.
class Validators {
  /// يمنع إنشاء مثيل لأن الوظائف كلها ساكنة.
  /// Prevents instantiation because the helpers are static only.
  Validators._();

  /// يوحد أرقام اليمن إلى الشكل المحلي الذي يتوقعه الخادم.
  /// Normalizes Yemen phone numbers into the local format expected by the backend.
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

  /// يتحقق من أن النص يبدو كبريد إلكتروني صالح.
  /// Checks whether the string looks like a valid email address.
  static bool isValidEmail(String email) {
    // Simple email regex pattern
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// يتحقق فقط من الحد الأدنى للطول، ويترك تعقيد كلمة المرور للسياسة الأوسع.
  /// Checks only the minimum length and leaves complexity rules to higher-level policy.
  static bool isValidPassword(String password, {int minLength = 8}) {
    if (password.length < minLength) {
      return false;
    }
    // Add more password complexity rules if needed (e.g., uppercase, number, special char)
    // final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    // return passwordRegex.hasMatch(password);
    return true;
  }

  /// يتأكد من أن الرقم اليمني المحلي يطابق النمط المطلوب.
  /// Verifies that the normalized Yemen phone number matches the expected pattern.
  static bool isValidPhoneNumber(String phoneNumber) {
    // YEMEN phone number format: 9 digits starting with 7
    final phoneRegex = RegExp(r'^7[0-9]{8}$');
    return phoneRegex.hasMatch(normalizeYemenPhone(phoneNumber));
  }

  /// يقبل الأحرف اللاتينية والعربية والمسافات فقط.
  /// Allows Latin letters, Arabic letters, and spaces only.
  static bool isValidName(String name) {
    // Allows letters, spaces, and Arabic characters
    final nameRegex = RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$');
    return nameRegex.hasMatch(name);
  }

  /// يتحقق من أن القيمة موجودة وليست سلسلة فارغة.
  /// Checks that a value is present and not an empty string.
  static bool isNotEmpty(String? value) {
    return value != null && value.isNotEmpty;
  }

  /// يتحقق من الأرقام الصحيحة أو الكسور المكونة من منزلتين.
  /// Checks for whole numbers or decimals with up to two places.
  static bool isAmountValid(String amount) {
    final amountRegex = RegExp(
        r'^\d+(\.\d{1,2})?$'); // Allows integers or decimals with 1 or 2 places
    return amountRegex.hasMatch(amount);
  }

  /// يتحقق من تنسيق GUID/UUID الشائع مع السماح بالأقواس أو بدونها.
  /// Validates standard GUID/UUID formats with or without braces/parentheses.
  static bool isValidGuid(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }

    // GUID/UUID regex pattern
    final guidRegex = RegExp(
      r'^[{(]?[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}[)}]?$',
      caseSensitive: false,
    );

    return guidRegex.hasMatch(value);
  }

  /// يتحقق من أن كل العناصر في القائمة معرفات GUID صحيحة.
  /// Ensures every item in the list is a valid GUID.
  static bool areValidGuids(List<String>? values) {
    if (values == null || values.isEmpty) {
      return true; // Empty list is valid
    }

    return values.every((value) => isValidGuid(value));
  }

  /// يزيل الأقواس ويحول المعرف إلى حروف صغيرة لتوحيد التخزين.
  /// Removes wrappers and lowercases the GUID for consistent storage.
  static String? normalizeGuid(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    // Remove braces and parentheses, convert to lowercase
    return value.replaceAll(RegExp(r'[{}()]'), '').toLowerCase();
  }

  /// يتحقق من أن النص يمكن قراءته كعدد.
  /// Checks whether the string can be parsed as a number.
  static bool isNumeric(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }

    return double.tryParse(value) != null;
  }

  /// يتحقق من أن القيمة تقع داخل المجال المسموح.
  /// Checks that the value falls within the allowed numeric range.
  static bool isInRange(double? value, double min, double max) {
    if (value == null) {
      return false;
    }

    return value >= min && value <= max;
  }

  // Add other validation methods as needed
}
