using Microsoft.AspNetCore.Authorization;

namespace YemenBooking.Application.Common.Authorization;

/// <summary>
/// متطلب تفويض يستخدم للتحقق من ملكية العقار أو إمكانية الوصول إليه.
/// Authorization requirement used to validate property ownership or access eligibility.
/// </summary>
public class PropertyOwnershipRequirement : IAuthorizationRequirement
{
    /// <summary>
    /// يحدد ما إذا كان يسمح للمسؤول بالمرور مباشرة.
    /// Indicates whether administrators may pass the requirement directly.
    /// </summary>
    public bool AllowAdmin { get; }

    /// <summary>
    /// يحدد ما إذا كان يسمح لموظفي العقار بالمرور.
    /// Indicates whether property staff members may satisfy the requirement.
    /// </summary>
    public bool AllowStaff { get; }

    /// <summary>
    /// ينشئ متطلب التفويض لملكية العقار مع خيارات الوصول المطلوبة.
    /// Creates the property-ownership authorization requirement with the desired access options.
    /// </summary>
    /// <param name="allowAdmin">ما إذا كان يسمح للمسؤولين. Whether administrators are allowed.</param>
    /// <param name="allowStaff">ما إذا كان يسمح لموظفي العقار. Whether property staff members are allowed.</param>
    public PropertyOwnershipRequirement(bool allowAdmin = true, bool allowStaff = false)
    {
        AllowAdmin = allowAdmin;
        AllowStaff = allowStaff;
    }
}
