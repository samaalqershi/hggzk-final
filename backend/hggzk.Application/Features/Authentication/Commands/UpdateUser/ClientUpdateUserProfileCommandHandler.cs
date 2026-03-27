using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.Authentication;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using System.Text.RegularExpressions;

namespace YemenBooking.Application.Features.Authentication.Commands.UpdateUser;

/// <summary>
/// معالج تحديث ملف العميل الشخصي.
/// client profile update handler.
/// </summary>
public class ClientUpdateUserProfileCommandHandler : IRequestHandler<ClientUpdateUserProfileCommand, ResultDto<ClientUserProfileResponse>>
{
    private readonly IUserRepository _userRepository;
    private readonly IFileUploadService _fileUploadService;
    private readonly ILogger<ClientUpdateUserProfileCommandHandler> _logger;

    /// <summary>
    /// يهيئ هذا المكوّن بالاعتماديات المطلوبة.
    /// Initializes this component with the required dependencies.
    /// </summary>
    /// <param name="userRepository">User repository.</param>
    /// <param name="fileUploadService">File upload service.</param>
    /// <param name="logger">Logger instance.</param>
    public ClientUpdateUserProfileCommandHandler(
        IUserRepository userRepository,
        IFileUploadService fileUploadService,
        ILogger<ClientUpdateUserProfileCommandHandler> logger)
    {
        _userRepository = userRepository;
        _fileUploadService = fileUploadService;
        _logger = logger;
    }

    /// <summary>
    /// ينفذ منطق المعالجة لهذا الطلب.
    /// executes the handling logic for this request.
    /// </summary>
    public async Task<ResultDto<ClientUserProfileResponse>> Handle(ClientUpdateUserProfileCommand request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation("بدء عملية تحديث ملف المستخدم للعميل: {UserId}", request.UserId);

            var validationResult = ValidateRequest(request);
            if (!validationResult.IsSuccess)
            {
                return validationResult;
            }

            var user = await _userRepository.GetByIdAsync(request.UserId, cancellationToken);
            if (user == null)
            {
                _logger.LogWarning("لم يتم العثور على المستخدم: {UserId}", request.UserId);
                return ResultDto<ClientUserProfileResponse>.Failed("المستخدم غير موجود", "USER_NOT_FOUND");
            }

            await UpdateUserProfile(user, request, cancellationToken);

            user.UpdatedAt = DateTime.UtcNow;
            await _userRepository.UpdateUserAsync(user, cancellationToken);
            await _userRepository.SaveChangesAsync(cancellationToken);

            _logger.LogInformation("تم تحديث الملف الشخصي بنجاح للمستخدم: {UserId}", request.UserId);

            var response = CreateResponse(user);

            return ResultDto<ClientUserProfileResponse>.Ok(response, "تم تحديث الملف الشخصي بنجاح");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "خطأ أثناء تحديث الملف الشخصي للعميل: {UserId}", request.UserId);
            return ResultDto<ClientUserProfileResponse>.Failed($"حدث خطأ أثناء تحديث الملف الشخصي: {ex.Message}", "UPDATE_PROFILE_ERROR");
        }
    }

    private ResultDto<ClientUserProfileResponse> ValidateRequest(ClientUpdateUserProfileCommand request)
    {
        if (request.UserId == Guid.Empty)
        {
            _logger.LogWarning("محاولة تحديث ملف شخصي بمعرف مستخدم غير صالح");
            return ResultDto<ClientUserProfileResponse>.Failed("معرف المستخدم غير صالح", "INVALID_USER_ID");
        }

        if (string.IsNullOrWhiteSpace(request.FirstName))
        {
            return ResultDto<ClientUserProfileResponse>.Failed("الاسم الأول مطلوب", "FIRST_NAME_REQUIRED");
        }

        if (request.FirstName.Length < 2 || request.FirstName.Length > 50)
        {
            return ResultDto<ClientUserProfileResponse>.Failed("الاسم الأول يجب أن يكون بين 2 و 50 حرف", "INVALID_FIRST_NAME_LENGTH");
        }

        if (string.IsNullOrWhiteSpace(request.LastName))
        {
            return ResultDto<ClientUserProfileResponse>.Failed("الاسم الأخير مطلوب", "LAST_NAME_REQUIRED");
        }

        if (request.LastName.Length < 2 || request.LastName.Length > 50)
        {
            return ResultDto<ClientUserProfileResponse>.Failed("الاسم الأخير يجب أن يكون بين 2 و 50 حرف", "INVALID_LAST_NAME_LENGTH");
        }

        if (!string.IsNullOrWhiteSpace(request.PhoneNumber))
        {
            var phoneRegex = new Regex(@"^7\d{8}$");
            if (!phoneRegex.IsMatch(request.PhoneNumber))
            {
                return ResultDto<ClientUserProfileResponse>.Failed("رقم الهاتف يجب أن يبدأ بـ 7 ويتكون من 9 أرقام", "INVALID_PHONE_FORMAT");
            }
        }

        if (request.DateOfBirth.HasValue)
        {
            var age = DateTime.Now.Year - request.DateOfBirth.Value.Year;
            if (request.DateOfBirth.Value > DateTime.Now.AddYears(-age)) age--;

            if (age < 18 || age > 120)
            {
                return ResultDto<ClientUserProfileResponse>.Failed("العمر يجب أن يكون بين 18 و 120 سنة", "INVALID_AGE");
            }
        }

        if (!string.IsNullOrWhiteSpace(request.Gender))
        {
            var validGenders = new[] { "male", "female", "other", "ذكر", "أنثى", "آخر" };
            if (!validGenders.Contains(request.Gender.ToLower()))
            {
                return ResultDto<ClientUserProfileResponse>.Failed("قيمة الجنس غير صحيحة", "INVALID_GENDER");
            }
        }

        if (!string.IsNullOrWhiteSpace(request.PreferredLanguage))
        {
            var validLanguages = new[] { "ar", "en", "arabic", "english", "عربي", "إنجليزي" };
            if (!validLanguages.Contains(request.PreferredLanguage.ToLower()))
            {
                return ResultDto<ClientUserProfileResponse>.Failed("اللغة المفضلة غير مدعومة", "INVALID_LANGUAGE");
            }
        }

        if (!string.IsNullOrWhiteSpace(request.PreferredCurrency))
        {
            var validCurrencies = new[] { "YER", "USD", "SAR", "AED", "EUR" };
            if (!validCurrencies.Contains(request.PreferredCurrency.ToUpper()))
            {
                return ResultDto<ClientUserProfileResponse>.Failed("العملة المفضلة غير مدعومة", "INVALID_CURRENCY");
            }
        }

        return ResultDto<ClientUserProfileResponse>.Ok(null, "البيانات صحيحة");
    }

    private async Task UpdateUserProfile(dynamic user, ClientUpdateUserProfileCommand request, CancellationToken cancellationToken)
    {
        user.Name = $"{request.FirstName.Trim()} {request.LastName.Trim()}";

        if (!string.IsNullOrWhiteSpace(request.PhoneNumber))
        {
            user.PhoneNumber = request.PhoneNumber;
        }

        if (request.DateOfBirth.HasValue)
        {
            user.DateOfBirth = request.DateOfBirth.Value;
        }

        if (!string.IsNullOrWhiteSpace(request.Gender))
        {
            user.Gender = request.Gender;
        }

        if (!string.IsNullOrWhiteSpace(request.Country))
        {
            user.Country = request.Country;
        }

        if (!string.IsNullOrWhiteSpace(request.City))
        {
            user.City = request.City;
        }

        if (!string.IsNullOrWhiteSpace(request.Address))
        {
            user.Address = request.Address;
        }

        if (!string.IsNullOrWhiteSpace(request.ProfilePictureUrl))
        {
            user.ProfileImageUrl = request.ProfilePictureUrl;
        }

        if (!string.IsNullOrWhiteSpace(request.PreferredLanguage))
        {
            user.PreferredLanguage = request.PreferredLanguage;
        }

        if (!string.IsNullOrWhiteSpace(request.PreferredCurrency))
        {
            user.PreferredCurrency = request.PreferredCurrency;
        }

        user.ReceiveNotifications = request.ReceiveNotifications;
        user.ReceivePromotions = request.ReceivePromotions;

        _logger.LogInformation("تم تحديث بيانات المستخدم: {UserId}", request.UserId);
    }

    private ClientUserProfileResponse CreateResponse(dynamic user)
    {
        var completionPercentage = CalculateProfileCompletion(user);

        return new ClientUserProfileResponse
        {
            UserId = user.Id,
            FullName = user.Name,
            Email = user.Email,
            PhoneNumber = user.PhoneNumber,
            ProfilePictureUrl = user.ProfileImageUrl,
            UpdatedAt = user.UpdatedAt,
            IsProfileComplete = completionPercentage >= 80m,
            CompletionPercentage = completionPercentage
        };
    }

    private decimal CalculateProfileCompletion(dynamic user)
    {
        var fields = new[]
        {
            !string.IsNullOrWhiteSpace(user.Name),
                        !string.IsNullOrWhiteSpace(user.Email),
            !string.IsNullOrWhiteSpace(user.PhoneNumber),
            user.DateOfBirth != null,
            !string.IsNullOrWhiteSpace(user.Gender),
            !string.IsNullOrWhiteSpace(user.Country),
            !string.IsNullOrWhiteSpace(user.City),
            !string.IsNullOrWhiteSpace(user.ProfileImageUrl),
            user.IsEmailVerified
        };

        var completedFields = fields.Count(f => f);
        return Math.Round((decimal)completedFields / fields.Length * 100, 1);
    }
}
