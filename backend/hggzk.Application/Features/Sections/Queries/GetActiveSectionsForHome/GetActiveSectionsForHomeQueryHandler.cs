using MediatR;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Sections.DTOs;

namespace YemenBooking.Application.Features.Sections.Queries.GetActiveSectionsForHome
{
    /// <summary>
    /// يعالج جلب النشاط الأقسام for الرئيسية ويعيد النتيجة المطلوبة.
    /// Processes the Get Active Sections For Home request and returns the requested result.
    /// </summary>
    public class GetActiveSectionsForHomeQueryHandler : IRequestHandler<GetActiveSectionsForHomeQuery, IEnumerable<SectionDto>>
    {
        private readonly ISectionRepository _repository;

        /// <summary>
        /// ينشئ مثيلاً جديداً من GetActiveSectionsForHomeQueryHandler.
        /// Initializes a new instance of GetActiveSectionsForHomeQueryHandler.
        /// </summary>
        /// <param name="repository">مستودع هذا العنصر / this member repository.</param>
        public GetActiveSectionsForHomeQueryHandler(ISectionRepository repository)
        {
            _repository = repository;
        }

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
        public async Task<IEnumerable<SectionDto>> Handle(GetActiveSectionsForHomeQuery request, CancellationToken cancellationToken)
        {
            var items = await _repository.FindAsync(s => s.IsActive, cancellationToken);
            if (!string.IsNullOrWhiteSpace(request.CityName))
            {
                var city = request.CityName!.Trim();
                items = items.Where(s => string.IsNullOrWhiteSpace(s.CityName) || s.CityName!.Trim().Equals(city, StringComparison.OrdinalIgnoreCase));
            }
            return items
                .OrderBy(s => s.DisplayOrder)
                .Select(s => new SectionDto
                {
                    Id = s.Id,
                    Type = s.Type,
                    ContentType = s.ContentType,
                    DisplayStyle = s.DisplayStyle,
                    Name = s.Name,
                    Title = s.Title,
                    Subtitle = s.Subtitle,
                    Description = s.Description,
                    ShortDescription = s.ShortDescription,
                    DisplayOrder = s.DisplayOrder,
                    Target = s.Target,
                    IsActive = s.IsActive,
                    ColumnsCount = s.ColumnsCount,
                    ItemsToShow = s.ItemsToShow,
                    Icon = s.Icon,
                    ColorTheme = s.ColorTheme,
                    BackgroundImage = s.BackgroundImage,
                    FilterCriteria = s.FilterCriteria,
                    SortCriteria = s.SortCriteria,
                    CityName = s.CityName,
                    PropertyTypeId = s.PropertyTypeId,
                    UnitTypeId = s.UnitTypeId,
                    MinPrice = s.MinPrice,
                    MaxPrice = s.MaxPrice,
                    MinRating = s.MinRating,
                    IsVisibleToGuests = s.IsVisibleToGuests,
                    IsVisibleToRegistered = s.IsVisibleToRegistered,
                    RequiresPermission = s.RequiresPermission,
                    StartDate = s.StartDate,
                    EndDate = s.EndDate,
                    Metadata = s.Metadata,
                    CategoryClass = s.CategoryClass,
                    HomeItemsCount = s.HomeItemsCount
                });
        }
    }
}

