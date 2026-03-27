namespace YemenBooking.Application.Contracts.Services.Scheduling;

using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using YemenBooking.Core.Entities;

/// <summary>
/// واجهة خدمة الجدول اليومي الموحد للوحدات. Daily unit schedule service interface.
/// </summary>
public interface IDailyUnitScheduleService
{
    /// <summary>
    /// تعيين أسعار لفترة زمنية - يتم تحويلها إلى سجلات يومية. Set pricing for a period - converts to daily records.
    /// </summary>
    /// <param name="unitId">معرف الوحدة. Unit identifier.</param>
    /// <param name="startDate">تاريخ البداية. Start date.</param>
    /// <param name="endDate">تاريخ النهاية. End date.</param>
    /// <param name="priceAmount">مبلغ السعر. Price amount.</param>
    /// <param name="currency">العملة. Currency.</param>
    /// <param name="priceType">نوع السعر. Price type.</param>
    /// <param name="pricingTier">فئة التسعير. Pricing tier.</param>
    /// <param name="percentageChange">نسبة التغيير (اختياري). Percentage change (optional).</param>
    /// <param name="minPrice">الحد الأدنى للسعر (اختياري). Minimum price (optional).</param>
    /// <param name="maxPrice">الحد الأقصى للسعر (اختياري). Maximum price (optional).</param>
    /// <param name="overwriteExisting">استبدال الأسعار الموجودة. Overwrite existing prices.</param>
    /// <param name="createdBy">المستخدم الذي أنشأ السجل. User who created the record.</param>
    /// <returns>عدد السجلات المنشأة/المحدثة. Number of created or updated records.</returns>
    Task<int> SetPricingForPeriodAsync(
        Guid unitId,
        DateTime startDate,
        DateTime endDate,
        decimal priceAmount,
        string currency,
        string? priceType = null,
        string? pricingTier = null,
        decimal? percentageChange = null,
        decimal? minPrice = null,
        decimal? maxPrice = null,
        bool overwriteExisting = false,
        string? createdBy = null);

    /// <summary>
    /// تعيين حالة الإتاحة لفترة زمنية - يتم تحويلها إلى سجلات يومية. Set availability status for a period - converts to daily records.
    /// </summary>
    /// <param name="unitId">معرف الوحدة. Unit identifier.</param>
    /// <param name="startDate">تاريخ البداية. Start date.</param>
    /// <param name="endDate">تاريخ النهاية. End date.</param>
    /// <param name="status">حالة الإتاحة. Availability status.</param>
    /// <param name="reason">السبب (اختياري). Reason (optional).</param>
    /// <param name="notes">ملاحظات (اختياري). Notes (optional).</param>
    /// <param name="bookingId">معرف الحجز (اختياري). Booking identifier (optional).</param>
    /// <param name="overwriteExisting">استبدال السجلات الموجودة. Overwrite existing records.</param>
    /// <param name="createdBy">المستخدم الذي أنشأ السجل. User who created the record.</param>
    /// <returns>عدد السجلات المنشأة/المحدثة. Number of created or updated records.</returns>
    Task<int> SetAvailabilityForPeriodAsync(
        Guid unitId,
        DateTime startDate,
        DateTime endDate,
        string status,
        string? reason = null,
        string? notes = null,
        Guid? bookingId = null,
        bool overwriteExisting = false,
        string? createdBy = null);

    /// <summary>
    /// الحصول على الجدول اليومي لوحدة في فترة زمنية. Get daily schedule for a unit in a period.
    /// </summary>
    /// <param name="unitId">معرف الوحدة. Unit identifier.</param>
    /// <param name="startDate">تاريخ البداية. Start date.</param>
    /// <param name="endDate">تاريخ النهاية. End date.</param>
    /// <param name="includeUnit">تضمين بيانات الوحدة. Include unit data.</param>
    /// <param name="includeBooking">تضمين بيانات الحجز. Include booking data.</param>
    /// <returns>قائمة الجداول اليومية. Daily schedule list.</returns>
    Task<IEnumerable<DailyUnitSchedule>> GetScheduleForPeriodAsync(
        Guid unitId,
        DateTime startDate,
        DateTime endDate,
        bool includeUnit = false,
        bool includeBooking = false);

    /// <summary>
    /// التحقق من توفر وحدة لفترة زمنية. Check if unit is available for a period.
    /// </summary>
    /// <param name="unitId">معرف الوحدة. Unit identifier.</param>
    /// <param name="startDate">تاريخ البداية. Start date.</param>
    /// <param name="endDate">تاريخ النهاية. End date.</param>
    /// <param name="excludeBookingId">استثناء حجز معيّن من التحقق (يُعامل كتوفّر لنفس العميل). Exclude a specific booking from validation (treated as available for the same customer).</param>
    /// <returns>معلومات التوفر. Availability information.</returns>
    Task<AvailabilityCheckResult> CheckAvailabilityAsync(
        Guid unitId,
        DateTime startDate,
        DateTime endDate,
        Guid? excludeBookingId = null);

    /// <summary>
    /// حساب السعر الإجمالي لفترة زمنية. Calculate total price for a period.
    /// </summary>
    /// <param name="unitId">معرف الوحدة. Unit identifier.</param>
    /// <param name="startDate">تاريخ البداية. Start date.</param>
    /// <param name="endDate">تاريخ النهاية. End date.</param>
    /// <param name="basePriceAmount">السعر الأساسي للوحدة (للأيام بدون سعر محدد). Base price for the unit (for days without explicit pricing).</param>
    /// <param name="baseCurrency">العملة الأساسية. Base currency.</param>
    /// <returns>معلومات السعر الإجمالي. Total price information.</returns>
    Task<PricingCalculationResult> CalculatePriceForPeriodAsync(
        Guid unitId,
        DateTime startDate,
        DateTime endDate,
        decimal basePriceAmount,
        string baseCurrency);

    /// <summary>
    /// حذف جميع السجلات لوحدة في فترة زمنية. Delete all records for a unit in a period.
    /// </summary>
    /// <param name="unitId">معرف الوحدة. Unit identifier.</param>
    /// <param name="startDate">تاريخ البداية. Start date.</param>
    /// <param name="endDate">تاريخ النهاية. End date.</param>
    Task DeleteScheduleForPeriodAsync(
        Guid unitId,
        DateTime startDate,
        DateTime endDate);

    /// <summary>
    /// تحديث سجل يومي معين. Update a specific daily schedule.
    /// </summary>
    /// <param name="scheduleId">معرف السجل. Record identifier.</param>
    /// <param name="priceAmount">مبلغ السعر (اختياري). Price amount (optional).</param>
    /// <param name="status">حالة الإتاحة (اختياري). Availability status (optional).</param>
    /// <param name="reason">السبب (اختياري). Reason (optional).</param>
    /// <param name="notes">ملاحظات (اختياري). Notes (optional).</param>
    /// <param name="modifiedBy">المستخدم الذي عدّل السجل. User who modified the record.</param>
    Task<DailyUnitSchedule?> UpdateDailyScheduleAsync(
        Guid scheduleId,
        decimal? priceAmount = null,
        string? status = null,
        string? reason = null,
        string? notes = null,
        string? modifiedBy = null);

    /// <summary>
    /// إنشاء أو تحديث جدول يومي لتاريخ محدد. Create or update daily schedule for a specific date.
    /// </summary>
    /// <param name="unitId">معرف الوحدة. Unit identifier.</param>
    /// <param name="date">التاريخ. Date.</param>
    /// <param name="schedule">بيانات الجدول اليومي. Daily schedule data.</param>
    /// <returns>الجدول اليومي المحدث أو المنشأ. Updated or created daily schedule.</returns>
    Task<DailyUnitSchedule> UpsertDailyScheduleAsync(
        Guid unitId,
        DateTime date,
        DailyUnitSchedule schedule);
}
