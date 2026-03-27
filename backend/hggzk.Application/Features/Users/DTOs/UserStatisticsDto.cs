using System;

namespace YemenBooking.Application.Features.Users.DTOs;

/// <summary>
/// Represents summary statistics for a user account.
/// يمثل ملخصًا إحصائيًا لحساب المستخدم.
/// </summary>
public class UserStatisticsDto
{
    /// <summary>
    /// Gets or sets the user identifier.
    /// يحصل أو يعيّن معرف المستخدم.
    /// </summary>
    public Guid UserId { get; set; }

    /// <summary>
    /// Gets or sets the account membership start date.
    /// يحصل أو يعيّن تاريخ بداية العضوية للحساب.
    /// </summary>
    public DateTime MemberSince
    {
        get => RegistrationDate;
        set => RegistrationDate = value;
    }

    /// <summary>
    /// Gets or sets the total bookings count.
    /// يحصل أو يعيّن إجمالي عدد الحجوزات.
    /// </summary>
    public int TotalBookings { get; set; }

    /// <summary>
    /// Gets or sets the completed bookings count.
    /// يحصل أو يعيّن عدد الحجوزات المكتملة.
    /// </summary>
    public int CompletedBookings { get; set; }

    /// <summary>
    /// Gets or sets the cancelled bookings count.
    /// يحصل أو يعيّن عدد الحجوزات الملغاة.
    /// </summary>
    public int CancelledBookings { get; set; }

    /// <summary>
    /// Gets or sets the active bookings count.
    /// يحصل أو يعيّن عدد الحجوزات النشطة.
    /// </summary>
    public int ActiveBookings { get; set; }

    /// <summary>
    /// Gets or sets the total reviews count.
    /// يحصل أو يعيّن إجمالي عدد المراجعات.
    /// </summary>
    public int TotalReviews { get; set; }

    /// <summary>
    /// Gets or sets the number of written reviews.
    /// يحصل أو يعيّن عدد المراجعات المكتوبة.
    /// </summary>
    public int ReviewsWritten { get; set; }

    /// <summary>
    /// Gets or sets the average user rating.
    /// يحصل أو يعيّن متوسط تقييم المستخدم.
    /// </summary>
    public decimal AverageRating { get; set; }

    /// <summary>
    /// Gets or sets the favorites count.
    /// يحصل أو يعيّن عدد العناصر المفضلة.
    /// </summary>
    public int FavoritesCount { get; set; }

    /// <summary>
    /// Gets or sets the favorite properties count.
    /// يحصل أو يعيّن عدد العقارات المفضلة.
    /// </summary>
    public int FavoritePropertiesCount
    {
        get => FavoritesCount;
        set => FavoritesCount = value;
    }

    /// <summary>
    /// Gets or sets the total amount spent.
    /// يحصل أو يعيّن إجمالي المبلغ المنفق.
    /// </summary>
    public decimal TotalAmountSpent { get; set; }

    /// <summary>
    /// Gets or sets the reporting currency.
    /// يحصل أو يعيّن عملة التقرير.
    /// </summary>
    public string Currency { get; set; } = "USD";

    /// <summary>
    /// Gets or sets the alias for the total spent amount.
    /// يحصل أو يعيّن الاسم البديل لإجمالي المبلغ المنفق.
    /// </summary>
    public decimal TotalSpent
    {
        get => TotalAmountSpent;
        set => TotalAmountSpent = value;
    }

    /// <summary>
    /// Gets or sets the total amount saved through discounts.
    /// يحصل أو يعيّن إجمالي المبلغ الموفَّر عبر الخصومات.
    /// </summary>
    public decimal TotalSaved { get; set; }

    /// <summary>
    /// Gets or sets the loyalty points.
    /// يحصل أو يعيّن نقاط الولاء.
    /// </summary>
    public int LoyaltyPoints { get; set; }

    /// <summary>
    /// Gets or sets the loyalty level.
    /// يحصل أو يعيّن مستوى الولاء.
    /// </summary>
    public string LoyaltyLevel { get; set; } = "Bronze";

    /// <summary>
    /// Gets or sets the referrals count.
    /// يحصل أو يعيّن عدد الإحالات.
    /// </summary>
    public int ReferralsCount { get; set; }

    /// <summary>
    /// Gets or sets the registration date.
    /// يحصل أو يعيّن تاريخ التسجيل.
    /// </summary>
    public DateTime RegistrationDate { get; set; }

    /// <summary>
    /// Gets or sets the last booking date.
    /// يحصل أو يعيّن تاريخ آخر حجز.
    /// </summary>
    public DateTime? LastBookingDate { get; set; }

    /// <summary>
    /// Gets or sets the number of membership days.
    /// يحصل أو يعيّن عدد أيام العضوية.
    /// </summary>
    public int MembershipDays { get; set; }

    /// <summary>
    /// Gets or sets the monthly booking rate.
    /// يحصل أو يعيّن معدل الحجوزات الشهرية.
    /// </summary>
    public decimal MonthlyBookingRate { get; set; }

    /// <summary>
    /// Gets or sets the number of visited cities.
    /// يحصل أو يعيّن عدد المدن التي زارها المستخدم.
    /// </summary>
    public int CitiesVisited { get; set; }

    /// <summary>
    /// Gets or sets the booking completion rate.
    /// يحصل أو يعيّن نسبة إكمال الحجوزات.
    /// </summary>
    public decimal BookingCompletionRate { get; set; }

    /// <summary>
    /// Gets or sets the booking cancellation rate.
    /// يحصل أو يعيّن نسبة إلغاء الحجوزات.
    /// </summary>
    public decimal BookingCancellationRate { get; set; }

    /// <summary>
    /// Gets or sets the average booking value.
    /// يحصل أو يعيّن متوسط قيمة الحجز.
    /// </summary>
    public decimal AverageBookingValue { get; set; }

    /// <summary>
    /// Gets or sets the most frequently booked property type.
    /// يحصل أو يعيّن أكثر نوع عقار تم حجزه.
    /// </summary>
    public string? MostBookedPropertyType { get; set; }

    /// <summary>
    /// Gets or sets the most frequently booked city.
    /// يحصل أو يعيّن أكثر مدينة تم الحجز فيها.
    /// </summary>
    public string? MostBookedCity { get; set; }
}
