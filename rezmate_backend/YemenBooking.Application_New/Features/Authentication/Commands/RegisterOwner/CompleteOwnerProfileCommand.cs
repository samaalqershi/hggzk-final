using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Accounting.Services;
using YemenBooking.Application.Features.Authentication.DTOs;
using YemenBooking.Application.Features.Authentication.Services;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Interfaces;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.Authentication.Commands.RegisterOwner;

public class CompleteOwnerProfileCommand : IRequest<ResultDto<AuthResultDto>>
{
    public string Name { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;

    public List<OwnerWalletAccountRequestDto>? WalletAccounts { get; set; }

    public Guid PropertyTypeId { get; set; }
    public string PropertyName { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public double? Latitude { get; set; }
    public double? Longitude { get; set; }
    public int StarRating { get; set; } = 3;
    public string? Description { get; set; }
    public string? Currency { get; set; }
}

public class CompleteOwnerProfileCommandHandler : IRequestHandler<CompleteOwnerProfileCommand, ResultDto<AuthResultDto>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IUserRepository _userRepository;
    private readonly IUserWalletAccountRepository _userWalletAccountRepository;
    private readonly IPropertyRepository _propertyRepository;
    private readonly IFinancialAccountingService _financialAccountingService;
    private readonly IAuthenticationService _authService;
    private readonly ICurrentUserService _currentUserService;
    private readonly ILogger<CompleteOwnerProfileCommandHandler> _logger;

    public CompleteOwnerProfileCommandHandler(
        IUnitOfWork unitOfWork,
        IUserRepository userRepository,
        IUserWalletAccountRepository userWalletAccountRepository,
        IPropertyRepository propertyRepository,
        IFinancialAccountingService financialAccountingService,
        IAuthenticationService authService,
        ICurrentUserService currentUserService,
        ILogger<CompleteOwnerProfileCommandHandler> logger)
    {
        _unitOfWork = unitOfWork;
        _userRepository = userRepository;
        _userWalletAccountRepository = userWalletAccountRepository;
        _propertyRepository = propertyRepository;
        _financialAccountingService = financialAccountingService;
        _authService = authService;
        _currentUserService = currentUserService;
        _logger = logger;
    }

    public async Task<ResultDto<AuthResultDto>> Handle(CompleteOwnerProfileCommand request, CancellationToken cancellationToken)
    {
        try
        {
            var userId = _currentUserService.UserId;
            if (userId == Guid.Empty)
            {
                return ResultDto<AuthResultDto>.Failed("غير مصرح", "UNAUTHORIZED");
            }

            if (request.PropertyTypeId == Guid.Empty)
                return ResultDto<AuthResultDto>.Failed("نوع الكيان مطلوب", "PROPERTY_TYPE_REQUIRED");
            if (string.IsNullOrWhiteSpace(request.PropertyName))
                return ResultDto<AuthResultDto>.Failed("اسم الكيان مطلوب", "PROPERTY_NAME_REQUIRED");
            if (string.IsNullOrWhiteSpace(request.Address))
                return ResultDto<AuthResultDto>.Failed("عنوان الكيان مطلوب", "PROPERTY_ADDRESS_REQUIRED");
            if (string.IsNullOrWhiteSpace(request.City))
                return ResultDto<AuthResultDto>.Failed("اسم المدينة مطلوب", "CITY_REQUIRED");
            if (string.IsNullOrWhiteSpace(request.Name))
                return ResultDto<AuthResultDto>.Failed("اسم المستخدم مطلوب", "NAME_REQUIRED");

            var user = await _userRepository.GetUserByIdAsync(userId, cancellationToken);
            if (user == null)
            {
                return ResultDto<AuthResultDto>.Failed("المستخدم غير موجود", "USER_NOT_FOUND");
            }

            var existingProps = await _propertyRepository.GetPropertiesByOwnerAsync(userId, cancellationToken);
            if (existingProps.Any())
            {
                return ResultDto<AuthResultDto>.Failed("تم استكمال بيانات المالك مسبقاً", "OWNER_PROFILE_ALREADY_COMPLETED");
            }

            await _unitOfWork.ExecuteInTransactionAsync(async () =>
            {
                user.Name = request.Name.Trim();
                if (!string.IsNullOrWhiteSpace(request.Phone))
                    user.Phone = request.Phone.Trim();

                user.City = request.City.Trim();
                user.UpdatedAt = DateTime.UtcNow;
                await _userRepository.UpdateUserAsync(user, cancellationToken);

                if (request.WalletAccounts != null)
                {
                    var normalized = request.WalletAccounts
                        .Where(a => a != null && !string.IsNullOrWhiteSpace(a.AccountNumber))
                        .ToList();

                    if (normalized.Count == 0)
                    {
                        await _userWalletAccountRepository.ReplaceForUserAsync(user.Id, new List<UserWalletAccount>(), cancellationToken);
                    }
                    else
                    {
                        var firstDefaultIndex = normalized.FindIndex(a => a.IsDefault);
                        for (int i = 0; i < normalized.Count; i++)
                        {
                            normalized[i].IsDefault = (firstDefaultIndex == -1) ? (i == 0) : (i == firstDefaultIndex);
                        }

                        var entities = normalized.Select(a => new UserWalletAccount
                        {
                            Id = Guid.NewGuid(),
                            UserId = user.Id,
                            WalletType = a.WalletType,
                            AccountNumber = a.AccountNumber.Trim(),
                            AccountName = string.IsNullOrWhiteSpace(a.AccountName) ? null : a.AccountName.Trim(),
                            IsDefault = a.IsDefault,
                            CreatedAt = DateTime.UtcNow,
                            UpdatedAt = DateTime.UtcNow,
                            IsActive = true,
                        }).ToList();

                        await _userWalletAccountRepository.ReplaceForUserAsync(user.Id, entities, cancellationToken);
                    }
                }

                var property = new Property
                {
                    Id = Guid.NewGuid(),
                    OwnerId = user.Id,
                    TypeId = request.PropertyTypeId,
                    Name = request.PropertyName.Trim(),
                    Address = request.Address.Trim(),
                    City = request.City.Trim(),
                    Latitude = (decimal)(request.Latitude ?? 0),
                    Longitude = (decimal)(request.Longitude ?? 0),
                    StarRating = request.StarRating,
                    Description = request.Description ?? string.Empty,
                    Currency = string.IsNullOrWhiteSpace(request.Currency) ? "YER" : request.Currency!.Trim().ToUpperInvariant(),
                    CreatedAt = DateTime.UtcNow,
                    CreatedBy = user.Id,
                    IsApproved = false,
                };

                await _propertyRepository.CreatePropertyAsync(property, cancellationToken);

                var ownerAccountsCreated = await _financialAccountingService.CreateOwnerFinancialAccountsAsync(
                    user.Id,
                    user.Name,
                    cancellationToken);

                if (!ownerAccountsCreated)
                    throw new InvalidOperationException("FAILED_TO_CREATE_OWNER_FINANCIAL_ACCOUNTS");

            }, cancellationToken);

            var tokens = await _authService.IssueTokensForUserAsync(userId, cancellationToken);

            var response = new AuthResultDto
            {
                AccessToken = tokens.AccessToken,
                RefreshToken = tokens.RefreshToken,
                ExpiresAt = tokens.ExpiresAt,
                UserId = tokens.UserId,
                UserName = tokens.UserName,
                Email = tokens.Email,
                Role = tokens.Role,
                AccountRole = tokens.AccountRole,
                ProfileImage = tokens.ProfileImage,
                PropertyId = tokens.PropertyId,
                PropertyName = tokens.PropertyName,
                StaffId = tokens.StaffId,
                PropertyCurrency = tokens.PropertyCurrency,
                SettingsJson = user.SettingsJson ?? "{}",
                FavoritesJson = user.FavoritesJson ?? "[]",
                RequiresProfileCompletion = false,
            };

            return ResultDto<AuthResultDto>.Ok(response, "تم استكمال بيانات المالك بنجاح");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Complete owner profile failed");
            return ResultDto<AuthResultDto>.Failed("حدث خطأ أثناء استكمال بيانات المالك", "COMPLETE_OWNER_PROFILE_ERROR");
        }
    }
}
