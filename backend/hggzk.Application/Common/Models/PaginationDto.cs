namespace YemenBooking.Application.Common.Models;

/// <summary>
/// معايير الترقيم والفرز الموحدة.
/// Shared pagination and sorting parameters.
/// </summary>
public class PaginationDto
{
    /// <summary>
    /// حقل _pageNumber.
    /// _pageNumber field.
    /// </summary>
    private int _pageNumber = 1;
    /// <summary>
    /// حقل _pageSize.
    /// _pageSize field.
    /// </summary>
    private int _pageSize = 10;

    /// <summary>
    /// رقم الصفحة الحالية ابتداءً من 1.
    /// Current page number starting from 1.
    /// </summary>
    public int PageNumber
    {
        get => _pageNumber;
        set => _pageNumber = value < 1 ? 1 : value;
    }

    /// <summary>
    /// عدد العناصر في الصفحة الواحدة.
    /// Number of items per page.
    /// </summary>
    public int PageSize
    {
        get => _pageSize;
        set => _pageSize = value switch
        {
            < 1 => 1,
            > 100 => 100,
            _ => value,
        };
    }

    /// <summary>
    /// اسم الحقل المستخدم للترتيب.
    /// Field name used for sorting.
    /// </summary>
    public string? SortBy { get; set; }

    /// <summary>
    /// اتجاه الترتيب.
    /// Sort direction.
    /// </summary>
    public bool Ascending { get; set; } = true;

    /// <summary>
    /// عدد العناصر التي يجب تخطيها قبل جلب الصفحة.
    /// Number of items to skip before loading the page.
    /// </summary>
    public int Skip => (PageNumber - 1) * PageSize;
}
