namespace YemenBooking.Application.Features.DynamicFields.DTOs;

using System;
using System.Collections.Generic;

/// <summary>
/// بيانات نقل مجموعة الحقول مع قيمها للكيان
/// DTO for field group with its property field values
/// </summary>
public class FieldGroupWithValuesDto
{
    /// <summary>
    /// معرف المجموعة
    /// GroupId
    /// </summary>
    public Guid GroupId { get; set; }

    /// <summary>
    /// اسم المجموعة
    /// GroupName
    /// </summary>
    public string GroupName { get; set; }
    public string? GroupNameEn { get; set; }

    /// <summary>
    /// الاسم المعروض للمجموعة
    /// DisplayName
    /// </summary>
    public string DisplayName { get; set; }
    public string? DisplayNameEn { get; set; }

    /// <summary>
    /// وصف المجموعة
    /// Description
    /// </summary>
    public string Description { get; set; }
    public string? DescriptionEn { get; set; }

    /// <summary>
    /// قائمة قيم الحقول
    /// FieldValues
    /// </summary>
    public List<FieldWithValueDto> FieldValues { get; set; }
} 
