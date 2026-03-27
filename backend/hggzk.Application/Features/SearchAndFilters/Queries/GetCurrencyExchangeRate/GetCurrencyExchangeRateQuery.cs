using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Common;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.SearchAndFilters.Queries.GetCurrencyExchangeRate;

/// <summary>
/// استعلام جلب currency exchange rate.
/// Get Currency Exchange Rate query.
/// </summary>
public class GetCurrencyExchangeRateQuery : IRequest<ResultDto<CurrencyExchangeRateDto>>
{
    /// <summary>
    /// القيمة الخاصة بـ from currency.
    /// From Currency value.
    /// </summary>
    public string FromCurrency { get; set; } = "YER";
    
    /// <summary>
    /// القيمة الخاصة بـ to currency.
    /// To Currency value.
    /// </summary>
    public string ToCurrency { get; set; } = "USD";
    
    /// <summary>
    /// القيمة الخاصة بـ amount.
    /// Amount value.
    /// </summary>
    public decimal? Amount { get; set; }
}

/// <summary>
/// استعلام جلب currency exchange rate.
/// Get Currency Exchange Rate query.
/// </summary>
public class CurrencyExchangeRateDto
{
    /// <summary>
    /// القيمة الخاصة بـ from currency.
    /// From Currency value.
    /// </summary>
    public string FromCurrency { get; set; } = string.Empty;
    
    /// <summary>
    /// القيمة الخاصة بـ to currency.
    /// To Currency value.
    /// </summary>
    public string ToCurrency { get; set; } = string.Empty;
    
    /// <summary>
    /// القيمة الخاصة بـ exchange rate.
    /// Exchange Rate value.
    /// </summary>
    public decimal ExchangeRate { get; set; }
    
    /// <summary>
    /// القيمة الخاصة بـ converted amount.
    /// Converted Amount value.
    /// </summary>
    public decimal? ConvertedAmount { get; set; }
    
    /// <summary>
    /// القيمة الخاصة بـ last التحديث.
    /// Last Updated value.
    /// </summary>
    public DateTime LastUpdated { get; set; }
}