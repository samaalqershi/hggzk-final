using System;
using System.Globalization;

namespace YemenBooking.Application.Common.Helpers;

/// <summary>
/// مساعد خفيف لاختيار النص المناسب حسب اللغة الحالية أو لغة محددة صراحة.
/// Lightweight helper for selecting the correct text based on the current or explicit language.
/// </summary>
public static class LocalizedText
{
    /// <summary>
    /// يحدد ما إذا كانت اللغة المستهدفة عربية.
    /// Determines whether the target language is Arabic.
    /// </summary>
    public static bool IsArabic(string? language = null)
    {
        if (!string.IsNullOrWhiteSpace(language))
        {
            return language.StartsWith("ar", StringComparison.OrdinalIgnoreCase);
        }

        return string.Equals(
            CultureInfo.CurrentUICulture.TwoLetterISOLanguageName,
            "ar",
            StringComparison.OrdinalIgnoreCase);
    }

    /// <summary>
    /// يعيد النص العربي أو الإنجليزي حسب اللغة الحالية.
    /// Returns the Arabic or English text depending on the current language.
    /// </summary>
    public static string Choose(string arabic, string english, string? language = null)
        => IsArabic(language) ? arabic : english;
}
