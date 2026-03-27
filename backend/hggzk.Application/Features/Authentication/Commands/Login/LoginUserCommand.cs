using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Authentication.Commands.Login;

/// <summary>
/// طلب تسجيل دخول العميل.
/// client login request.
/// </summary>
public class ClientLoginUserCommand : IRequest<ResultDto<ClientLoginUserResponse>>
{
    /// <summary>
    /// البريد الإلكتروني أو رقم الهاتف
    /// email address or phone number
    /// </summary>
    public string EmailOrPhone { get; set; } = string.Empty;
    
    /// <summary>
    /// كلمة المرور
    /// password
    /// </summary>
    public string Password { get; set; } = string.Empty;
    
    /// <summary>
    /// تذكرني
    /// remember me
    /// </summary>
    public bool RememberMe { get; set; }
}

/// <summary>
/// نتيجة تسجيل دخول العميل.
/// client login response.
/// </summary>
public class ClientLoginUserResponse
{
    /// <summary>
    /// معرّف المستخدم
    /// user ID
    /// </summary>
    public Guid UserId { get; set; }
    
    /// <summary>
    /// الاسم
    /// name
    /// </summary>
    public string Name { get; set; } = string.Empty;
    
    /// <summary>
    /// البريد الإلكتروني
    /// email address
    /// </summary>
    public string Email { get; set; } = string.Empty;
    
    /// <summary>
    /// رقم الهاتف
    /// phone number
    /// </summary>
    public string Phone { get; set; } = string.Empty;
    
    /// <summary>
    /// رمز الوصول
    /// access token
    /// </summary>
    public string AccessToken { get; set; } = string.Empty;
    
    /// <summary>
    /// رمز التحديث
    /// refresh token
    /// </summary>
    public string RefreshToken { get; set; } = string.Empty;
    
    /// <summary>
    /// الأدوار
    /// roles
    /// </summary>
    public List<string> Roles { get; set; } = new();
}