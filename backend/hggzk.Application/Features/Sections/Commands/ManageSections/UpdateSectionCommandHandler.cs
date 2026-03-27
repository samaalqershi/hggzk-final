using MediatR;
using YemenBooking.Application.Features.Sections;
using YemenBooking.Application.Common.Models;
using YemenBooking.Core.Interfaces.Repositories;
using YemenBooking.Application.Features.Sections.DTOs;

namespace YemenBooking.Application.Features.Sections.Commands.ManageSections
{
	/// <summary>
	/// يعالج تحديث القسم ويعيد النتيجة المطلوبة.
	/// Processes the Update Section request and returns the requested result.
	/// </summary>
	public class UpdateSectionCommandHandler : IRequestHandler<UpdateSectionCommand, ResultDto<SectionDto>>
	{
		private readonly ISectionRepository _repository;

		/// <summary>
		/// ينشئ مثيلاً جديداً من UpdateSectionCommandHandler.
		/// Initializes a new instance of UpdateSectionCommandHandler.
		/// </summary>
		/// <param name="repository">مستودع هذا العنصر / this member repository.</param>
		public UpdateSectionCommandHandler(ISectionRepository repository)
		{
			_repository = repository;
		}

    /// <summary>
    /// يعالج الطلب الحالي ويعيد النتيجة المطلوبة.
    /// Processes the current request and returns the requested result.
    /// </summary>
    /// <param name="request">الطلب الحالي / Current request.</param>
    /// <param name="cancellationToken">رمز إلغاء العملية / Cancellation token.</param>
		public async Task<ResultDto<SectionDto>> Handle(UpdateSectionCommand request, CancellationToken cancellationToken)
		{
			var entity = await _repository.GetByIdAsync(request.SectionId, cancellationToken);
			if (entity == null) return ResultDto<SectionDto>.Failure("Section not found");
			// منع تعديل Target/ContentType إذا كان لدى القسم عناصر معيّنة مسبقاً
			var hasAssignedItems = (await _repository.GetPropertyItemsAsync(request.SectionId, cancellationToken)).Any()
				|| (await _repository.GetUnitItemsAsync(request.SectionId, cancellationToken)).Any();
			if (hasAssignedItems && (request.Target != entity.Target || request.ContentType != entity.ContentType))
			{
				return ResultDto<SectionDto>.Failure("لا يمكن تغيير الهدف أو نوع المحتوى بعد تعيين عناصر للقسم");
			}
			entity.Type = request.Type;
			entity.ContentType = request.ContentType;
			entity.DisplayStyle = request.DisplayStyle;
			entity.Name = request.Name;
			entity.Title = request.Title;
			entity.Subtitle = request.Subtitle;
			entity.Description = request.Description;
			entity.ShortDescription = request.ShortDescription;
			entity.DisplayOrder = request.DisplayOrder;
			entity.Target = request.Target;
			entity.IsActive = request.IsActive;
			entity.ColumnsCount = request.ColumnsCount;
			entity.ItemsToShow = request.ItemsToShow;
			entity.Icon = request.Icon;
			entity.ColorTheme = request.ColorTheme;
			entity.BackgroundImage = request.BackgroundImage;
			entity.FilterCriteria = request.FilterCriteria;
			entity.SortCriteria = request.SortCriteria;
			entity.CityName = request.CityName;
			entity.PropertyTypeId = request.PropertyTypeId;
			entity.UnitTypeId = request.UnitTypeId;
			entity.MinPrice = request.MinPrice;
			entity.MaxPrice = request.MaxPrice;
			entity.MinRating = request.MinRating;
			entity.IsVisibleToGuests = request.IsVisibleToGuests;
			entity.IsVisibleToRegistered = request.IsVisibleToRegistered;
			entity.RequiresPermission = request.RequiresPermission;
			entity.StartDate = request.StartDate;
			entity.EndDate = request.EndDate;
			entity.Metadata = request.Metadata;
			entity.CategoryClass = request.CategoryClass;
			entity.HomeItemsCount = request.HomeItemsCount;
			await _repository.UpdateAsync(entity, cancellationToken);
            await _repository.SaveChangesAsync(cancellationToken);
			var dto = new SectionDto
			{
				Id = entity.Id,
				Type = entity.Type,
				ContentType = entity.ContentType,
				DisplayStyle = entity.DisplayStyle,
				Name = entity.Name,
				Title = entity.Title,
				Subtitle = entity.Subtitle,
				Description = entity.Description,
				ShortDescription = entity.ShortDescription,
				DisplayOrder = entity.DisplayOrder,
				Target = entity.Target,
				IsActive = entity.IsActive,
				ColumnsCount = entity.ColumnsCount,
				ItemsToShow = entity.ItemsToShow,
				Icon = entity.Icon,
				ColorTheme = entity.ColorTheme,
				BackgroundImage = entity.BackgroundImage,
				FilterCriteria = entity.FilterCriteria,
				SortCriteria = entity.SortCriteria,
				CityName = entity.CityName,
				PropertyTypeId = entity.PropertyTypeId,
				UnitTypeId = entity.UnitTypeId,
				MinPrice = entity.MinPrice,
				MaxPrice = entity.MaxPrice,
				MinRating = entity.MinRating,
				IsVisibleToGuests = entity.IsVisibleToGuests,
				IsVisibleToRegistered = entity.IsVisibleToRegistered,
				RequiresPermission = entity.RequiresPermission,
				StartDate = entity.StartDate,
				EndDate = entity.EndDate,
				Metadata = entity.Metadata,
				CategoryClass = entity.CategoryClass,
				HomeItemsCount = entity.HomeItemsCount
			};
			return ResultDto<SectionDto>.Ok(dto);
		}
	}
}
