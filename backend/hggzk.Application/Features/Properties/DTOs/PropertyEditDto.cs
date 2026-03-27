namespace YemenBooking.Application.Features.Properties.DTOs;

using System;
using System.Collections.Generic;

/// <summary>
/// بيانات نقل بيانات الكيان للتحرير
/// DTO for property edit form including dynamic values
/// </summary>
public class PropertyEditDto
{
    /// <summary>
    /// خاصية PropertyId.
    /// PropertyId property.
    /// </summary>
    public Guid PropertyId { get; set; }
    /// <summary>
    /// خاصية Name.
    /// Name property.
    /// </summary>
    public string Name { get; set; }
    /// <summary>
    /// خاصية Address.
    /// Address property.
    /// </summary>
    public string Address { get; set; }
    /// <summary>
    /// خاصية City.
    /// City property.
    /// </summary>
    public string City { get; set; }
    /// <summary>
    /// خاصية Latitude.
    /// Latitude property.
    /// </summary>
    public decimal? Latitude { get; set; }
    /// <summary>
    /// خاصية Longitude.
    /// Longitude property.
    /// </summary>
    public decimal? Longitude { get; set; }
    /// <summary>
    /// خاصية StarRating.
    /// StarRating property.
    /// </summary>
    public int? StarRating { get; set; }
    /// <summary>
    /// خاصية Description.
    /// Description property.
    /// </summary>
    public string Description { get; set; }
    /// <summary>
    /// خاصية PropertyTypeId.
    /// PropertyTypeId property.
    /// </summary>
    public Guid PropertyTypeId { get; set; }
    /// <summary>
    /// خاصية Currency.
    /// Currency property.
    /// </summary>
    public string? Currency { get; set; }
    /// <summary>
    /// خاصية IsFeatured.
    /// IsFeatured property.
    /// </summary>
    public bool IsFeatured { get; set; }
    /// <summary>
    /// خاصية SystemCommissionRate.
    /// SystemCommissionRate property.
    /// </summary>
    public decimal? SystemCommissionRate { get; set; }
}
