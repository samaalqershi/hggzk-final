namespace YemenBooking.Application.Contracts.Services.Exports;

/// <summary>
/// خيارات سلوك التصدير وإخراج الملف.
/// Options controlling export behavior and file output.
/// </summary>
public class ExportOptions
{
    /// <summary>
    /// يحدد ما إذا كان يجب تضمين رؤوس الأعمدة.
    /// Indicates whether column headers should be included.
    /// </summary>
    public bool IncludeHeaders { get; set; } = true;

    /// <summary>
    /// الأعمدة التي يجب تضمينها صراحةً.
    /// Columns that should be explicitly included.
    /// </summary>
    public string[]? ColumnsToInclude { get; set; }

    /// <summary>
    /// الأعمدة التي يجب استبعادها من التصدير.
    /// Columns that should be excluded from export.
    /// </summary>
    public string[]? ColumnsToExclude { get; set; }

    /// <summary>
    /// عنوان اختياري للملف أو التقرير.
    /// Optional title for the exported file or report.
    /// </summary>
    public string? Title { get; set; }

    /// <summary>
    /// وصف اختياري يرافق الملف المصدر.
    /// Optional description stored with the exported file.
    /// </summary>
    public string? Description { get; set; }

    /// <summary>
    /// اسم المؤلف أو الجهة المنتجة للتصدير.
    /// Author or producer name for the export.
    /// </summary>
    public string? Author { get; set; }

    /// <summary>
    /// خصائص مخصصة إضافية لعملية التصدير.
    /// Additional custom properties for the export operation.
    /// </summary>
    public Dictionary<string, object>? CustomProperties { get; set; }

    /// <summary>
    /// يحدد ما إذا كان يجب ضغط المخرجات النهائية.
    /// Indicates whether the final output should be compressed.
    /// </summary>
    public bool CompressOutput { get; set; }

    /// <summary>
    /// مسار قالب التصدير إن تم استخدام قالب مخصص.
    /// Export template path when a custom template is used.
    /// </summary>
    public string? TemplateFile { get; set; }
}
