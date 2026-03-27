using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Payments.Queries.GetPaymentMethods;

/// <summary>
/// يمثل استعلامًا ضمن نطاق المدفوعات.
/// Represents a payment-related query.
/// </summary>
public class ClientGetPaymentMethodsQuery : IRequest<ResultDto<List<ClientPaymentMethodDto>>>
{
    /// <summary>
    /// معرّف المستخدم عند توفره لتخصيص النتائج.
    /// User identifier, when available, to personalize the results.
    /// </summary>
    public Guid? UserId { get; set; }

    /// <summary>
    /// رمز الدولة أو البلد.
    /// Country code or country name.
    /// </summary>
    public string? Country { get; set; }

    /// <summary>
    /// رمز العملة المطلوب تقييم طرق الدفع عليه.
    /// Currency code used to evaluate the payment methods.
    /// </summary>
    public string Currency { get; set; } = "YER";

    /// <summary>
    /// المبلغ المطلوب استخدامه في التصفية أو التوصية.
    /// Amount used for filtering or recommendation.
    /// </summary>
    public decimal? Amount { get; set; }
}

/// <summary>
/// يمثل نموذج بيانات مرتبطًا بنطاق المدفوعات.
/// Represents a data model for the payment-related feature area.
/// </summary>
public class ClientPaymentMethodDto
{
    /// <summary>
    /// معرّف طريقة الدفع.
    /// Payment method identifier.
    /// </summary>
    public string Id { get; set; } = string.Empty;

    /// <summary>
    /// اسم طريقة الدفع.
    /// Payment method name.
    /// </summary>
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// الوصف المختصر لطريقة الدفع.
    /// Short description of the payment method.
    /// </summary>
    public string Description { get; set; } = string.Empty;

    /// <summary>
    /// رابط أيقونة طريقة الدفع.
    /// Icon URL for the payment method.
    /// </summary>
    public string IconUrl { get; set; } = string.Empty;

    /// <summary>
    /// رابط شعار طريقة الدفع.
    /// Logo URL for the payment method.
    /// </summary>
    public string LogoUrl { get; set; } = string.Empty;

    /// <summary>
    /// يحدد ما إذا كانت طريقة الدفع متاحة.
    /// Indicates whether the payment method is available.
    /// </summary>
    public bool IsAvailable { get; set; }

    /// <summary>
    /// رسوم العملية الثابتة.
    /// Fixed transaction fee.
    /// </summary>
    public decimal TransactionFee { get; set; }

    /// <summary>
    /// نسبة الرسوم.
    /// Fee percentage.
    /// </summary>
    public decimal FeePercentage { get; set; }

    /// <summary>
    /// الحد الأدنى للمبلغ المقبول.
    /// Minimum acceptable amount.
    /// </summary>
    public decimal MinAmount { get; set; }

    /// <summary>
    /// الحد الأقصى للمبلغ المقبول.
    /// Maximum acceptable amount.
    /// </summary>
    public decimal MaxAmount { get; set; }

    /// <summary>
    /// العملات المدعومة.
    /// Supported currencies.
    /// </summary>
    public List<string> SupportedCurrencies { get; set; } = new();

    /// <summary>
    /// البلدان المدعومة.
    /// Supported countries.
    /// </summary>
    public List<string> SupportedCountries { get; set; } = new();

    /// <summary>
    /// زمن المعالجة المتوقع.
    /// Expected processing time.
    /// </summary>
    public string ProcessingTime { get; set; } = string.Empty;

    /// <summary>
    /// نوع طريقة الدفع.
    /// Payment method type.
    /// </summary>
    public string Type { get; set; } = string.Empty;

    /// <summary>
    /// يحدد ما إذا كانت الطريقة تتطلب تحققًا إضافيًا.
    /// Indicates whether the method requires additional verification.
    /// </summary>
    public bool RequiresVerification { get; set; }

    /// <summary>
    /// يحدد ما إذا كانت الطريقة تدعم الاسترداد.
    /// Indicates whether the method supports refunds.
    /// </summary>
    public bool SupportsRefunds { get; set; }

    /// <summary>
    /// ترتيب الظهور.
    /// Display order.
    /// </summary>
    public int DisplayOrder { get; set; }

    /// <summary>
    /// يحدد ما إذا كانت الطريقة موصى بها.
    /// Indicates whether the method is recommended.
    /// </summary>
    public bool IsRecommended { get; set; }

    /// <summary>
    /// رسالة تحذيرية مرتبطة بطريقة الدفع.
    /// Warning message associated with the payment method.
    /// </summary>
    public string? WarningMessage { get; set; }
}
