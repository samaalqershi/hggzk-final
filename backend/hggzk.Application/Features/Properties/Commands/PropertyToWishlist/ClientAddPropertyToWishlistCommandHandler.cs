using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Properties;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Core.Enums;
using System.Text.Json;
using YemenBooking.Application.Common.Interfaces;
using YemenBooking.Application.Features.AuditLog.Services;
using YemenBooking.Core.Entities;

namespace YemenBooking.Application.Features.Properties.Commands.PropertyToWishlist;

/// <summary>
/// يعالج إضافة العقار إلى قائمة الأمنيات ويضمن اتساق السجل.
/// Handles adding a property to the wishlist while keeping the record consistent.
/// </summary>
public class ClientAddPropertyToWishlistCommandHandler : IRequestHandler<ClientAddPropertyToWishlistCommand, ResultDto<bool>>
{
    private readonly IPropertyRepository _propertyRepository;
    private readonly IUnitRepository _unitRepository;
    private readonly IBookingRepository _bookingRepository;
    private readonly IUserRepository _userRepository;
    private readonly IAuditService _auditService;
    private readonly ICurrentUserService _currentUserService;

    /// <summary>
    /// يهيّئ مثيلاً جديداً من [ClientAddPropertyToWishlistCommandHandler].
    /// Initializes a new instance of [ClientAddPropertyToWishlistCommandHandler].
    /// </summary>
    public ClientAddPropertyToWishlistCommandHandler(
        IPropertyRepository propertyRepository,
        IUnitRepository unitRepository,
        IBookingRepository bookingRepository,
        IUserRepository userRepository,
        IAuditService auditService,
        ICurrentUserService currentUserService)
    {
        _propertyRepository = propertyRepository;
        _unitRepository = unitRepository;
        _bookingRepository = bookingRepository;
        _userRepository = userRepository;
        _auditService = auditService;
        _currentUserService = currentUserService;
    }
    /// <summary>
    /// يعالج إضافة العقار إلى قائمة الأمنيات ويسجل العملية.
    /// Handles adding a property to the wishlist and records the action.
    /// </summary>
    public async Task<ResultDto<bool>> Handle(ClientAddPropertyToWishlistCommand request, CancellationToken cancellationToken)
    {
        try
        {
            // التحقق من وجود العقار
            // Check if property exists
            var property = await _propertyRepository.GetPropertyByIdAsync(request.PropertyId, cancellationToken);

            if (property == null)
            {
                return ResultDto<bool>.Failed("العقار غير موجود", "PROPERTY_NOT_FOUND");
            }

            // التحقق من وجود المستخدم
            // Check if user exists
            var user = await _userRepository.GetUserByIdAsync(request.UserId, cancellationToken);

            if (user == null)
            {
                return ResultDto<bool>.Failed("المستخدم غير موجود", "USER_NOT_FOUND");
            }

            // البحث عن أول وحدة في العقار للاستخدام كرمز للمفضلة
            // Find first unit in property to use as wishlist identifier
            var units = await _unitRepository.GetUnitsByPropertyAsync(request.PropertyId, cancellationToken);
            var firstUnit = units.FirstOrDefault(u => u.PropertyId == request.PropertyId);

            if (firstUnit == null)
            {
                return ResultDto<bool>.Failed("العقار لا يحتوي على وحدات متاحة", "NO_UNITS_AVAILABLE");
            }

            // التحقق من عدم وجود العقار مسبقاً في المفضلة
            // Check if property is not already in favorites
            var bookings = await _bookingRepository.GetBookingsByUserAsync(request.UserId, cancellationToken);
            var existingFavorite = bookings.FirstOrDefault(b => 
                b.UserId == request.UserId && 
                b.UnitId == firstUnit.Id && 
                b.BookingSource == "Wishlist");

            if (existingFavorite != null)
            {
                return ResultDto<bool>.Failed("العقار موجود بالفعل في قائمة الأمنيات", "ALREADY_IN_WISHLIST");
            }

            // إنشاء سجل جديد في المفضلة (استخدام جدول BookingDto مع BookingSource خاص)
            // Create new favorite record (using BookingDto table with special BookingSource)
            var wishlistItem = new Core.Entities.Booking
            {
                Id = Guid.NewGuid(),
                UserId = request.UserId,
                UnitId = firstUnit.Id,
                Status = BookingStatus.Pending,
                BookingSource = "Wishlist",
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
                CheckIn = request.DesiredVisitDate.HasValue ? await _currentUserService.ConvertFromUserLocalToUtcAsync(request.DesiredVisitDate.Value) : DateTime.UtcNow.AddDays(30),
                CheckOut = request.DesiredVisitDate.HasValue ? await _currentUserService.ConvertFromUserLocalToUtcAsync(request.DesiredVisitDate.Value.AddDays(1)) : DateTime.UtcNow.AddDays(31),
                TotalPrice = new Core.ValueObjects.Money(request.ExpectedBudget ?? 0, request.Currency ?? "YER"),
                GuestsCount = 1,
                BookedAt = DateTime.UtcNow
            };

            await _bookingRepository.CreateBookingAsync(wishlistItem, cancellationToken);

            // تدقيق يدوي: إضافة إلى الأمنيات
            var performerName = _currentUserService.Username;
            var performerId = _currentUserService.UserId;
            var notes = $"تمت إضافة العقار {request.PropertyId} إلى قائمة الأمنيات بواسطة {performerName} (ID={performerId})";
            await _auditService.LogAuditAsync(
                entityType: "Wishlist",
                entityId: wishlistItem.Id,
                action: YemenBooking.Core.Entities.AuditAction.CREATE,
                oldValues: null,
                newValues: JsonSerializer.Serialize(new { wishlistItem.Id, request.PropertyId, request.UserId }),
                performedBy: performerId,
                notes: notes,
                cancellationToken: cancellationToken);

            return ResultDto<bool>.Ok(true, "تم إضافة العقار لقائمة الأمنيات بنجاح");
        }
        catch (Exception ex)
        {
            return ResultDto<bool>.Failed($"حدث خطأ أثناء إضافة العقار لقائمة الأمنيات: {ex.Message}", "ADD_TO_WISHLIST_ERROR");
        }
    }
}
