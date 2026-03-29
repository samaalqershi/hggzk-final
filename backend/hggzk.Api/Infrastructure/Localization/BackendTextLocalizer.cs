using System.Globalization;
using System.Resources;
using System.Text.RegularExpressions;

namespace YemenBooking.Api.Infrastructure.Localization;

/// <summary>
/// Resource-backed translator for user-facing backend messages.
/// مترجم معتمد على الموارد للرسائل الظاهرة للمستخدم في الباك اند.
/// </summary>
public sealed class BackendTextLocalizer : IBackendTextLocalizer
{
    private static readonly ResourceManager ResourceManager =
        new("hggzk.Api.Resources.BackendMessages", typeof(BackendTextLocalizer).Assembly);

    private static readonly Regex ArabicRegex = new(@"[\u0600-\u06FF]", RegexOptions.Compiled);
    private static readonly Dictionary<string, string> ArabicTermsToEnglish = new(StringComparer.OrdinalIgnoreCase)
    {
        ["المستخدم"] = "User",
        ["المستخدم الآخر"] = "Other user",
        ["الحجز"] = "Booking",
        ["الحجوزات"] = "Bookings",
        ["الوحدة"] = "Unit",
        ["العقار"] = "Property",
        ["الكيان"] = "Property",
        ["الخدمة"] = "Service",
        ["الخدمات"] = "Services",
        ["المدينة"] = "City",
        ["الاسم"] = "Name",
        ["الكمية"] = "Quantity",
        ["الصفحة"] = "Page",
        ["حجم الصفحة"] = "Page size",
        ["خط العرض"] = "Latitude",
        ["خط الطول"] = "Longitude",
        ["نصف القطر"] = "Radius",
        ["العدد الأقصى للنتائج"] = "Maximum results count",
        ["عدد الضيوف"] = "Guest count",
        ["تاريخ الوصول"] = "Check-in date",
        ["تاريخ المغادرة"] = "Check-out date",
        ["الدور"] = "Role",
        ["الصلاحيات"] = "Permissions",
        ["المرفق"] = "Amenity",
        ["المرفقات"] = "Attachments",
        ["السياسة"] = "Policy",
        ["قواعد السياسة"] = "Policy rules",
        ["اللغة"] = "Language",
        ["العملة"] = "Currency",
        ["الملف"] = "File",
        ["اسم الملف"] = "File name",
        ["امتداد الملف"] = "File extension",
        ["الصورة"] = "Image",
        ["ملف الصورة"] = "Image file",
        ["رابط الصورة"] = "Image URL",
        ["البريد الإلكتروني"] = "Email",
        ["رقم الهاتف"] = "Phone number",
        ["كلمة المرور"] = "Password",
        ["الرسالة"] = "Message",
        ["محتوى الإشعار"] = "Notification content",
        ["عنوان الإشعار"] = "Notification title",
        ["الإشعار"] = "Notification",
        ["التقييم"] = "Review",
        ["التقييم المرتبط بهذا الرد"] = "The related review",
        ["الرد"] = "Response",
        ["البلاغ"] = "Report",
        ["تفاصيل البلاغ"] = "Report details",
        ["سبب البلاغ"] = "Report reason",
        ["الموظف"] = "Staff member",
        ["المالك"] = "Owner",
        ["المستلم"] = "Recipient",
        ["نوع الكيان"] = "Property type",
        ["نوع الوحدة"] = "Unit type",
        ["اسم الكيان"] = "Property name",
        ["اسم الوحدة"] = "Unit name",
        ["اسم نوع الكيان"] = "Property type name",
        ["اسم نوع الوحدة"] = "Unit type name",
        ["اسم المدينة"] = "City name",
        ["اسم الخدمة"] = "Service name",
        ["اسم الدور"] = "Role name",
        ["معرف المستخدم"] = "User",
        ["معرف الحجز"] = "Booking",
        ["معرف الوحدة"] = "Unit",
        ["معرف الكيان"] = "Property",
        ["معرف المالك"] = "Owner",
        ["معرف المبلغ"] = "Reporter",
        ["معرف المستلم"] = "Recipient",
        ["معرف نوع الكيان"] = "Property type",
        ["معرف نوع الوحدة"] = "Unit type",
        ["معرّف التقييم"] = "Review",
        ["معرّف الحجز"] = "Booking"
    };

    private static readonly Dictionary<string, string> EnglishTermsToArabic = new(StringComparer.OrdinalIgnoreCase)
    {
        ["user"] = "المستخدم",
        ["other user"] = "المستخدم الآخر",
        ["booking"] = "الحجز",
        ["bookings"] = "الحجوزات",
        ["unit"] = "الوحدة",
        ["property"] = "الكيان",
        ["service"] = "الخدمة",
        ["services"] = "الخدمات",
        ["city"] = "المدينة",
        ["name"] = "الاسم",
        ["quantity"] = "الكمية",
        ["page"] = "الصفحة",
        ["page size"] = "حجم الصفحة",
        ["latitude"] = "خط العرض",
        ["longitude"] = "خط الطول",
        ["radius"] = "نصف القطر",
        ["maximum results count"] = "العدد الأقصى للنتائج",
        ["guest count"] = "عدد الضيوف",
        ["check-in date"] = "تاريخ الوصول",
        ["check-out date"] = "تاريخ المغادرة",
        ["role"] = "الدور",
        ["permissions"] = "الصلاحيات",
        ["amenity"] = "المرفق",
        ["policy"] = "السياسة",
        ["policy rules"] = "قواعد السياسة",
        ["language"] = "اللغة",
        ["currency"] = "العملة",
        ["file"] = "الملف",
        ["file name"] = "اسم الملف",
        ["file extension"] = "امتداد الملف",
        ["image"] = "الصورة",
        ["image file"] = "ملف الصورة",
        ["image url"] = "رابط الصورة",
        ["email"] = "البريد الإلكتروني",
        ["phone"] = "الهاتف",
        ["phone number"] = "رقم الهاتف",
        ["password"] = "كلمة المرور",
        ["message"] = "الرسالة",
        ["notification"] = "الإشعار",
        ["notification content"] = "محتوى الإشعار",
        ["notification title"] = "عنوان الإشعار",
        ["review"] = "التقييم",
        ["response"] = "الرد",
        ["report"] = "البلاغ",
        ["report details"] = "تفاصيل البلاغ",
        ["report reason"] = "سبب البلاغ",
        ["staff member"] = "الموظف",
        ["owner"] = "المالك",
        ["recipient"] = "المستلم",
        ["property type"] = "نوع الكيان",
        ["unit type"] = "نوع الوحدة"
    };

    /// <inheritdoc />
    public string CurrentLanguage =>
        string.Equals(CultureInfo.CurrentUICulture.TwoLetterISOLanguageName, "en", StringComparison.OrdinalIgnoreCase)
            ? "en"
            : "ar";

    /// <inheritdoc />
    public string Translate(string? input)
    {
        if (string.IsNullOrWhiteSpace(input))
        {
            return string.Empty;
        }

        var text = input.Trim();

        if (TrySelectBilingualSegment(text, out var bilingualSegment))
        {
            return bilingualSegment;
        }

        var translated = ResourceManager.GetString(text, CultureInfo.CurrentUICulture);
        if (!string.IsNullOrWhiteSpace(translated))
        {
            return translated;
        }

        // Fallback to the neutral resource set so semantic keys continue to work
        // even when a localized value is not present for the current culture.
        translated = ResourceManager.GetString(text, CultureInfo.GetCultureInfo("ar"));
        if (!string.IsNullOrWhiteSpace(translated))
        {
            return translated;
        }

        if (TryTranslateByPattern(text, out translated))
        {
            return translated;
        }

        return text;
    }

    /// <inheritdoc />
    public IReadOnlyList<string> TranslateMany(IEnumerable<string>? values)
    {
        if (values == null)
        {
            return Array.Empty<string>();
        }

        return values
            .Where(static value => !string.IsNullOrWhiteSpace(value))
            .Select(Translate)
            .ToArray();
    }

    private string SelectByLanguage(string first, string second)
    {
        var firstHasArabic = ArabicRegex.IsMatch(first);
        var secondHasArabic = ArabicRegex.IsMatch(second);

        if (firstHasArabic && !secondHasArabic)
        {
            return CurrentLanguage == "ar" ? first : second;
        }

        if (!firstHasArabic && secondHasArabic)
        {
            return CurrentLanguage == "ar" ? second : first;
        }

        return CurrentLanguage == "ar" ? first : second;
    }

    private bool TrySelectBilingualSegment(string text, out string translated)
    {
        translated = string.Empty;

        if (!text.Contains(" / ", StringComparison.Ordinal))
        {
            return false;
        }

        var parts = text.Split(" / ", 2, StringSplitOptions.TrimEntries);
        if (parts.Length != 2 || string.IsNullOrWhiteSpace(parts[0]) || string.IsNullOrWhiteSpace(parts[1]))
        {
            return false;
        }

        translated = SelectByLanguage(parts[0], parts[1]);
        return true;
    }

    private bool TryTranslateByPattern(string text, out string translated)
    {
        if (CurrentLanguage == "en" && ArabicRegex.IsMatch(text))
        {
            return TryTranslateArabicToEnglish(text, out translated);
        }

        if (CurrentLanguage == "ar" && !ArabicRegex.IsMatch(text))
        {
            return TryTranslateEnglishToArabic(text, out translated);
        }

        translated = string.Empty;
        return false;
    }

    private bool TryTranslateArabicToEnglish(string text, out string translated)
    {
        translated = string.Empty;
        string? candidate = null;

        if (TryMatch(text, @"^معرف\s+(.+?)\s+مطلوب$", match =>
        {
            candidate = $"{TranslateArabicTerm(match.Groups[1].Value)} ID is required";
        }))
        {
            translated = candidate ?? string.Empty;
            return true;
        }

        if (TryMatch(text, @"^(.+?)\s+غير موجود(?:ة)?(?:\s+أو\s+غير نشط)?$", match =>
        {
            var subject = match.Groups[1].Value.Trim();
            var suffix = text.Contains("غير نشط", StringComparison.Ordinal) ? " not found or inactive" : " not found";
            candidate = $"{TranslateArabicTerm(subject)}{suffix}";
        }))
        {
            translated = candidate ?? string.Empty;
            return true;
        }

        if (TryMatch(text, @"^(.+?)\s+مطلوب(?:ة)?$", match =>
        {
            candidate = $"{TranslateArabicTerm(match.Groups[1].Value)} is required";
        }))
        {
            translated = candidate ?? string.Empty;
            return true;
        }

        if (TryMatch(text, @"^(.+?)\s+غير صالح(?:ة)?$", match =>
        {
            candidate = $"{TranslateArabicTerm(match.Groups[1].Value)} is invalid";
        }))
        {
            translated = candidate ?? string.Empty;
            return true;
        }

        if (TryMatch(text, @"^(.+?)\s+يجب أن يكون أكبر من صفر$", match =>
        {
            candidate = $"{TranslateArabicTerm(match.Groups[1].Value)} must be greater than zero";
        }))
        {
            translated = candidate ?? string.Empty;
            return true;
        }

        if (TryMatch(text, @"^(.+?)\s+يجب أن يكون بين\s+(.+?)\s+و\s+(.+)$", match =>
        {
            candidate = $"{TranslateArabicTerm(match.Groups[1].Value)} must be between {match.Groups[2].Value.Trim()} and {match.Groups[3].Value.Trim()}";
        }))
        {
            translated = candidate ?? string.Empty;
            return true;
        }

        if (TryMatch(text, @"^تم العثور على\s+(\d+)\s+طريقة دفع متاحة$", match =>
        {
            candidate = $"Found {match.Groups[1].Value} available payment methods";
        }))
        {
            translated = candidate ?? string.Empty;
            return true;
        }

        if (TryMatch(text, @"^لا توجد وحدات تتسع لـ\s+(.+?)\s+ضيف$", match =>
        {
            candidate = $"No units can accommodate {match.Groups[1].Value.Trim()} guest(s)";
        }))
        {
            translated = candidate ?? string.Empty;
            return true;
        }

        if (text.StartsWith("غير مصرح لك", StringComparison.Ordinal)
            || text.StartsWith("ليس لديك صلاحية", StringComparison.Ordinal))
        {
            translated = "You are not allowed to perform this action";
            return true;
        }

        if (text.StartsWith("حدث خطأ أثناء", StringComparison.Ordinal))
        {
            translated = "An error occurred while processing the request";
            return true;
        }

        if (text.StartsWith("حدث خطأ في", StringComparison.Ordinal))
        {
            translated = "An error occurred while processing the request";
            return true;
        }

        if (text.Equals("البيانات صحيحة", StringComparison.Ordinal))
        {
            translated = "The data is valid";
            return true;
        }

        if (text.Equals("تطابق دقيق", StringComparison.Ordinal))
        {
            translated = "Exact Match";
            return true;
        }

        if (text.Equals("تخفيف بسيط", StringComparison.Ordinal))
        {
            translated = "Minor Relaxation";
            return true;
        }

        if (text.Equals("تخفيف متوسط", StringComparison.Ordinal))
        {
            translated = "Moderate Relaxation";
            return true;
        }

        if (text.Equals("تخفيف كبير", StringComparison.Ordinal))
        {
            translated = "Major Relaxation";
            return true;
        }

        if (text.Equals("اقتراحات بديلة", StringComparison.Ordinal))
        {
            translated = "Alternative Suggestions";
            return true;
        }

        if (text.Equals("افتراضي", StringComparison.Ordinal))
        {
            translated = "Default";
            return true;
        }

        if (text.Equals("الكمية غير صحيحة", StringComparison.Ordinal))
        {
            translated = "Invalid quantity";
            return true;
        }

        if (text.Equals("العقار غير متاح حالياً", StringComparison.Ordinal))
        {
            translated = "The property is currently unavailable";
            return true;
        }

        if (text.Equals("لا توجد وحدات في هذا العقار", StringComparison.Ordinal))
        {
            translated = "There are no units in this property";
            return true;
        }

        if (text.Equals("تمت إضافة الخدمة بنجاح", StringComparison.Ordinal))
        {
            translated = "Service added successfully";
            return true;
        }

        if (text.Equals("تم تسجيل الوصول بنجاح", StringComparison.Ordinal))
        {
            translated = "Check-in completed successfully";
            return true;
        }

        if (text.Equals("تم تسجيل المغادرة بنجاح", StringComparison.Ordinal))
        {
            translated = "Check-out completed successfully";
            return true;
        }

        if (text.Equals("فشل في إنشاء معاملة التحويل", StringComparison.Ordinal))
        {
            translated = "Failed to create the transfer transaction";
            return true;
        }

        if (text.Equals("تم إنشاء حساب ذمم مدينة للعميل", StringComparison.Ordinal))
        {
            translated = "The customer receivables account has been created";
            return true;
        }

        if (text.Equals("تم إنشاء الحسابات الناقصة للمالك", StringComparison.Ordinal))
        {
            translated = "The missing owner accounts have been created";
            return true;
        }

        if (text.Equals("يتطلب تشغيل ChartOfAccountSeeder", StringComparison.Ordinal))
        {
            translated = "Running ChartOfAccountSeeder is required";
            return true;
        }

        if (text.Equals("تم إكمال الدفع بنجاح (وضع المحاكاة)", StringComparison.Ordinal))
        {
            translated = "Payment completed successfully (simulation mode)";
            return true;
        }

        if (text.StartsWith("طريقة الدفع هذه غير مفعّلة حالياً.", StringComparison.Ordinal))
        {
            translated = "This payment method is currently disabled. Please use one of the available payment methods.";
            return true;
        }

        if (text.StartsWith("فشل", StringComparison.Ordinal) || text.StartsWith("فشلت", StringComparison.Ordinal))
        {
            translated = "The operation failed";
            return true;
        }

        if (text.StartsWith("لا يمكن", StringComparison.Ordinal))
        {
            translated = "This action cannot be completed";
            return true;
        }

        if (text.StartsWith("تم ", StringComparison.Ordinal) || text.StartsWith("تمت ", StringComparison.Ordinal))
        {
            translated = "Operation completed successfully";
            return true;
        }

        if (text.StartsWith("انتهت صلاحية", StringComparison.Ordinal))
        {
            translated = "The operation has expired. Please try again.";
            return true;
        }

        if (text.StartsWith("يرجى", StringComparison.Ordinal))
        {
            translated = "Please review the input and try again.";
            return true;
        }

        if (text.Contains("غير متاح", StringComparison.Ordinal))
        {
            translated = "Currently unavailable";
            return true;
        }

        if (text.Contains("غير مدعوم", StringComparison.Ordinal))
        {
            translated = "Unsupported value";
            return true;
        }

        if (text.Contains("يجب", StringComparison.Ordinal) || text.Contains("لا يجوز", StringComparison.Ordinal))
        {
            translated = "Invalid input";
            return true;
        }

        if (text.StartsWith("لا توجد", StringComparison.Ordinal))
        {
            translated = "No data is currently available";
            return true;
        }

        return false;
    }

    private bool TryTranslateEnglishToArabic(string text, out string translated)
    {
        translated = string.Empty;
        var normalized = text.Trim().TrimEnd('.');
        string? candidate = null;

        if (TryMatch(normalized, @"^(.+?)\s+id is required$", match =>
        {
            candidate = $"معرف {TranslateEnglishTerm(match.Groups[1].Value)} مطلوب";
        }, RegexOptions.IgnoreCase))
        {
            translated = candidate ?? string.Empty;
            return true;
        }

        if (TryMatch(normalized, @"^(.+?)\s+is required$", match =>
        {
            var term = TranslateEnglishTerm(match.Groups[1].Value);
            candidate = term == "هذا الحقل" ? "هذا الحقل مطلوب" : $"{term} مطلوب";
        }, RegexOptions.IgnoreCase))
        {
            translated = candidate ?? string.Empty;
            return true;
        }

        if (TryMatch(normalized, @"^(.+?)\s+not found(?:\s+or inactive)?$", match =>
        {
            var term = TranslateEnglishTerm(match.Groups[1].Value);
            candidate = normalized.EndsWith("or inactive", StringComparison.OrdinalIgnoreCase)
                ? $"{term} غير موجود أو غير نشط"
                : $"{term} غير موجود";
        }, RegexOptions.IgnoreCase))
        {
            translated = candidate ?? string.Empty;
            return true;
        }

        if (TryMatch(normalized, @"^(.+?)\s+is invalid$", match =>
        {
            candidate = $"{TranslateEnglishTerm(match.Groups[1].Value)} غير صالح";
        }, RegexOptions.IgnoreCase))
        {
            translated = candidate ?? string.Empty;
            return true;
        }

        if (TryMatch(normalized, @"^(.+?)\s+must be greater than zero$", match =>
        {
            candidate = $"{TranslateEnglishTerm(match.Groups[1].Value)} يجب أن يكون أكبر من صفر";
        }, RegexOptions.IgnoreCase))
        {
            translated = candidate ?? string.Empty;
            return true;
        }

        if (TryMatch(normalized, @"^(.+?)\s+must be between\s+(.+?)\s+and\s+(.+)$", match =>
        {
            candidate = $"{TranslateEnglishTerm(match.Groups[1].Value)} يجب أن يكون بين {match.Groups[2].Value.Trim()} و {match.Groups[3].Value.Trim()}";
        }, RegexOptions.IgnoreCase))
        {
            translated = candidate ?? string.Empty;
            return true;
        }

        if (TryMatch(normalized, @"^found\s+(\d+)\s+available payment methods$", match =>
        {
            candidate = $"تم العثور على {match.Groups[1].Value} طريقة دفع متاحة";
        }, RegexOptions.IgnoreCase))
        {
            translated = candidate ?? string.Empty;
            return true;
        }

        if (TryMatch(normalized, @"^no units can accommodate\s+(.+?)\s+guest\(s\)$", match =>
        {
            candidate = $"لا توجد وحدات تتسع لـ {match.Groups[1].Value.Trim()} ضيف";
        }, RegexOptions.IgnoreCase))
        {
            translated = candidate ?? string.Empty;
            return true;
        }

        if (normalized.Contains("unauthorized", StringComparison.OrdinalIgnoreCase)
            || normalized.Contains("not allowed", StringComparison.OrdinalIgnoreCase))
        {
            translated = "غير مصرح لك بتنفيذ هذا الإجراء";
            return true;
        }

        if (normalized.Contains("permission", StringComparison.OrdinalIgnoreCase))
        {
            translated = "ليس لديك صلاحية";
            return true;
        }

        if (normalized.Contains("error", StringComparison.OrdinalIgnoreCase)
            || normalized.Contains("failed", StringComparison.OrdinalIgnoreCase))
        {
            translated = "تعذر إكمال العملية";
            return true;
        }

        if (normalized.StartsWith("an error occurred while", StringComparison.OrdinalIgnoreCase))
        {
            translated = "حدث خطأ أثناء معالجة الطلب";
            return true;
        }

        if (normalized.Contains("unavailable", StringComparison.OrdinalIgnoreCase))
        {
            translated = "غير متاح حالياً";
            return true;
        }

        if (normalized.Contains("not supported", StringComparison.OrdinalIgnoreCase)
            || normalized.Contains("unsupported", StringComparison.OrdinalIgnoreCase))
        {
            translated = "قيمة غير مدعومة";
            return true;
        }

        if (normalized.Contains("successfully", StringComparison.OrdinalIgnoreCase))
        {
            translated = "تمت العملية بنجاح";
            return true;
        }

        if (normalized.Equals("the data is valid", StringComparison.OrdinalIgnoreCase))
        {
            translated = "البيانات صحيحة";
            return true;
        }

        if (normalized.Equals("exact match", StringComparison.OrdinalIgnoreCase))
        {
            translated = "تطابق دقيق";
            return true;
        }

        if (normalized.Equals("minor relaxation", StringComparison.OrdinalIgnoreCase))
        {
            translated = "تخفيف بسيط";
            return true;
        }

        if (normalized.Equals("moderate relaxation", StringComparison.OrdinalIgnoreCase))
        {
            translated = "تخفيف متوسط";
            return true;
        }

        if (normalized.Equals("major relaxation", StringComparison.OrdinalIgnoreCase))
        {
            translated = "تخفيف كبير";
            return true;
        }

        if (normalized.Equals("alternative suggestions", StringComparison.OrdinalIgnoreCase))
        {
            translated = "اقتراحات بديلة";
            return true;
        }

        if (normalized.Equals("default", StringComparison.OrdinalIgnoreCase))
        {
            translated = "افتراضي";
            return true;
        }

        if (normalized.Equals("invalid quantity", StringComparison.OrdinalIgnoreCase))
        {
            translated = "الكمية غير صحيحة";
            return true;
        }

        if (normalized.Equals("the property is currently unavailable", StringComparison.OrdinalIgnoreCase))
        {
            translated = "العقار غير متاح حالياً";
            return true;
        }

        if (normalized.Equals("there are no units in this property", StringComparison.OrdinalIgnoreCase))
        {
            translated = "لا توجد وحدات في هذا العقار";
            return true;
        }

        if (normalized.Equals("service added successfully", StringComparison.OrdinalIgnoreCase))
        {
            translated = "تمت إضافة الخدمة بنجاح";
            return true;
        }

        if (normalized.Equals("check-in completed successfully", StringComparison.OrdinalIgnoreCase))
        {
            translated = "تم تسجيل الوصول بنجاح";
            return true;
        }

        if (normalized.Equals("check-out completed successfully", StringComparison.OrdinalIgnoreCase))
        {
            translated = "تم تسجيل المغادرة بنجاح";
            return true;
        }

        if (normalized.Equals("failed to create the transfer transaction", StringComparison.OrdinalIgnoreCase))
        {
            translated = "فشل في إنشاء معاملة التحويل";
            return true;
        }

        if (normalized.Equals("the customer receivables account has been created", StringComparison.OrdinalIgnoreCase))
        {
            translated = "تم إنشاء حساب ذمم مدينة للعميل";
            return true;
        }

        if (normalized.Equals("the missing owner accounts have been created", StringComparison.OrdinalIgnoreCase))
        {
            translated = "تم إنشاء الحسابات الناقصة للمالك";
            return true;
        }

        if (normalized.Equals("running chartofaccountseeder is required", StringComparison.OrdinalIgnoreCase))
        {
            translated = "يتطلب تشغيل ChartOfAccountSeeder";
            return true;
        }

        if (normalized.Equals("payment completed successfully (simulation mode)", StringComparison.OrdinalIgnoreCase))
        {
            translated = "تم إكمال الدفع بنجاح (وضع المحاكاة)";
            return true;
        }

        if (normalized.StartsWith("this payment method is currently disabled.", StringComparison.OrdinalIgnoreCase))
        {
            translated = "طريقة الدفع هذه غير مفعّلة حالياً. يرجى استخدام إحدى طرق الدفع المتاحة.";
            return true;
        }

        if (normalized.Contains("expired", StringComparison.OrdinalIgnoreCase))
        {
            translated = "انتهت صلاحية العملية. يرجى إعادة المحاولة";
            return true;
        }

        if (TryMatch(normalized, @"^payment\s+(.+)$", match =>
        {
            candidate = $"حالة الدفع: {match.Groups[1].Value.Trim()}";
        }, RegexOptions.IgnoreCase))
        {
            translated = candidate ?? string.Empty;
            return true;
        }

        if (normalized.Equals("internal server error", StringComparison.OrdinalIgnoreCase))
        {
            translated = "خطأ داخلي في الخادم";
            return true;
        }

        if (normalized.Equals("unknown app", StringComparison.OrdinalIgnoreCase))
        {
            translated = "تطبيق غير معروف";
            return true;
        }

        if (normalized.StartsWith("no ", StringComparison.OrdinalIgnoreCase))
        {
            translated = "لا توجد بيانات متاحة حالياً";
            return true;
        }

        return false;
    }

    private string TranslateArabicTerm(string value)
    {
        var normalized = value.Trim();
        return ArabicTermsToEnglish.TryGetValue(normalized, out var translated)
            ? translated
            : "This item";
    }

    private string TranslateEnglishTerm(string value)
    {
        var normalized = value.Trim().ToLowerInvariant();
        return EnglishTermsToArabic.TryGetValue(normalized, out var translated)
            ? translated
            : "هذا الحقل";
    }

    private static bool TryMatch(string input, string pattern, Action<Match> onSuccess, RegexOptions options = RegexOptions.None)
    {
        var match = Regex.Match(input, pattern, options | RegexOptions.Compiled);
        if (!match.Success)
        {
            return false;
        }

        onSuccess(match);
        return true;
    }
}
