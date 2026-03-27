namespace YemenBooking.Core.Entities;

using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

/// <summary>
/// كيان العملة
/// Represents a currency definition used across the system.
/// </summary>
[Display(Name = "كيان العملة")]
public class Currency
{
    /// <summary>
    /// رمز العملة.
    /// Currency code used as the primary key.
    /// </summary>
    [Key]
    [Display(Name = "رمز العملة")]
    public string Code { get; set; }

    /// <summary>
    /// الرمز باللغة العربية.
    /// Arabic currency code.
    /// </summary>
    public string ArabicCode { get; set; }

    /// <summary>
    /// اسم العملة.
    /// Currency name.
    /// </summary>
    public string Name { get; set; }

    /// <summary>
    /// اسم العملة بالعربية.
    /// Arabic currency name.
    /// </summary>
    public string ArabicName { get; set; }

    /// <summary>
    /// يحدد ما إذا كانت هذه هي العملة الافتراضية.
    /// Indicates whether this is the default currency.
    /// </summary>
    public bool IsDefault { get; set; }

    /// <summary>
    /// سعر الصرف بالنسبة للعملة الافتراضية.
    /// Exchange rate relative to the default currency; null for the default currency.
    /// </summary>
    public decimal? ExchangeRate { get; set; }

    /// <summary>
    /// تاريخ آخر تحديث لسعر الصرف.
    /// Timestamp of the last exchange rate update.
    /// </summary>
    public DateTime? LastUpdated { get; set; }

    /// <summary>
    /// العقارات التي تستخدم هذه العملة.
    /// Properties that use this currency through reverse navigation.
    /// </summary>
    public virtual ICollection<Property> Properties { get; set; } = new List<Property>();
}
