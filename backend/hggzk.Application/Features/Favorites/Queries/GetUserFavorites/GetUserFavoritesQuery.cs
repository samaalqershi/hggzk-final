using MediatR;
using YemenBooking.Application.Common.Models;
using YemenBooking.Application.Features.Users;
using YemenBooking.Application.Features.Users.DTOs;
using YemenBooking.Application.Features;

namespace YemenBooking.Application.Features.Favorites.Queries.GetUserFavorites;

    /// <summary>
    /// يمثل استعلامًا ضمن نطاق النطاق الحالي.
    /// Represents a current feature area query.
    /// </summary>
public class GetUserFavoritesQuery : IRequest<ResultDto<UserFavoritesResponse>>
{
    /// <summary>
    /// معرّف المستخدم.
    /// User identifier.
    /// </summary>
    public Guid UserId { get; set; }
    
    /// <summary>
    /// رقم الصفحة المطلوبة.
    /// Requested page number.
    /// </summary>
    public int PageNumber { get; set; } = 1;
    
    /// <summary>
    /// عدد العناصر في الصفحة.
    /// Number of items per page.
    /// </summary>
    public int PageSize { get; set; } = 10;
}