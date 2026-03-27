using MediatR;
using YemenBooking.Application.Features.Units;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Contracts.Services.Scheduling;
using YemenBooking.Core.Interfaces.Repositories;

namespace YemenBooking.Application.Features.Units.Commands.BulkOperations;


/// <summary>
/// يعالج معالجة مجمعة لـ تحديث التوفر ويعيد النتيجة المطلوبة.
/// Processes the Bulk Update Availability request and returns the requested result.
/// </summary>
public class BulkUpdateAvailabilityCommandHandler : IRequestHandler<BulkUpdateAvailabilityCommand, ResultDto>
{
    private readonly IAvailabilityService _availabilityService;
    private readonly ICurrentUserService _currentUserService;
    private readonly IUnitRepository _unitRepository;
    private readonly IPropertyRepository _propertyRepository;

    /// <summary>
    /// ينشئ مثيلاً جديداً من BulkUpdateAvailabilityCommandHandler.
    /// Initializes a new instance of BulkUpdateAvailabilityCommandHandler.
    /// </summary>
    /// <param name="availabilityService">خدمة التوفر / availability service.</param>
    /// <param name="currentUserService">خدمة المستخدم الحالي / Current user service.</param>
    /// <param name="unitRepository">مستودع الوحدة / unit repository.</param>
    /// <param name="propertyRepository">مستودع البيانات العقارية / Real-estate repository.</param>
    public BulkUpdateAvailabilityCommandHandler(
        IAvailabilityService availabilityService, 
        ICurrentUserService currentUserService,
        IUnitRepository unitRepository,
        IPropertyRepository propertyRepository)
    {
        _availabilityService = availabilityService;
        _currentUserService = currentUserService;
        _unitRepository = unitRepository;
        _propertyRepository = propertyRepository;
    }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
    public async Task<ResultDto> Handle(BulkUpdateAvailabilityCommand request, CancellationToken cancellationToken)
    {
        try
        {
            // التحقق من وجود الوحدة
            var unit = await _unitRepository.GetUnitByIdAsync(request.UnitId, cancellationToken);
            if (unit == null)
                return ResultDto.Failure("الوحدة غير موجودة");

            // التحقق من الصلاحيات - Admin/Owner/Staff
            var authResult = await ValidateAuthorizationAsync(unit.PropertyId, cancellationToken);
            if (!authResult.IsSuccess)
                return authResult;

            // Normalize all incoming periods to local-day bounds then convert to UTC
            var normalized = new List<AvailabilityPeriodDto>(request.Periods.Count);
            foreach (var p in request.Periods)
            {
                var localStart = new DateTime(p.StartDate.Year, p.StartDate.Month, p.StartDate.Day, 12, 0, 0);
                var localEnd = new DateTime(p.EndDate.Year, p.EndDate.Month, p.EndDate.Day, 23, 59, 59, 999);
                var startUtc = await _currentUserService.ConvertFromUserLocalToUtcAsync(localStart);
                var endUtc = await _currentUserService.ConvertFromUserLocalToUtcAsync(localEnd);
                normalized.Add(new AvailabilityPeriodDto
                {
                    StartDate = startUtc,
                    EndDate = endUtc,
                    Status = p.Status,
                    Reason = p.Reason,
                    Notes = p.Notes,
                    OverwriteExisting = p.OverwriteExisting
                });
            }
            await _availabilityService.ApplyBulkAvailabilityAsync(request.UnitId, normalized);
            return ResultDto.Ok();
        }
        catch (Exception ex)
        {
            return ResultDto.Failure($"حدث خطأ: {ex.Message}");
        }
    }

    private async Task<ResultDto> ValidateAuthorizationAsync(Guid propertyId, CancellationToken cancellationToken)
    {
        // Admin: صلاحية كاملة
        var isAdmin = string.Equals(_currentUserService.Role, "Admin", StringComparison.OrdinalIgnoreCase)
            || string.Equals(_currentUserService.AccountRole, "Admin", StringComparison.OrdinalIgnoreCase)
            || (_currentUserService.UserRoles?.Any(r => string.Equals(r, "Admin", StringComparison.OrdinalIgnoreCase)) ?? false);
        
        if (isAdmin)
        {
            return ResultDto.Ok();
        }

        // Owner: يجب أن يكون مالك العقار
        var property = await _propertyRepository.GetPropertyByIdAsync(propertyId, cancellationToken);
        if (property == null)
        {
            return ResultDto.Failure("العقار غير موجود");
        }

        if (string.Equals(_currentUserService.Role, "Owner", StringComparison.OrdinalIgnoreCase))
        {
            if (property.OwnerId != _currentUserService.UserId)
            {
                return ResultDto.Failure("ليس لديك الصلاحية لتحديث إتاحة وحدات هذا العقار - أنت لست مالك العقار");
            }
            return ResultDto.Ok();
        }

        // Staff: يجب أن يكون موظفًا في نفس العقار
        if (string.Equals(_currentUserService.Role, "Staff", StringComparison.OrdinalIgnoreCase))
        {
            if (!_currentUserService.IsStaffInProperty(propertyId))
            {
                return ResultDto.Failure("لست موظفًا في هذا العقار");
            }
            return ResultDto.Ok();
        }

        return ResultDto.Failure("ليس لديك الصلاحية لتحديث إتاحة هذه الوحدة");
    }
}
