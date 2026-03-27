using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Favorites.Commands.ToFavorites;

    /// <summary>
    /// يمثل طلب إضافة عقار إلى المفضلة.
    /// Represents a request to add a property to favorites.
    /// </summary>
public class AddToFavoritesCommand : IRequest<ResultDto<AddToFavoritesResponse>>
{
    /// <summary>
    /// معرّف المستخدم صاحب المفضلة.
    /// Identifies the user who owns the favorites list.
    /// </summary>
    public Guid UserId { get; set; }
    /// <summary>
    /// معرّف العقار المراد إضافته إلى المفضلة.
    /// Identifies the property to add to favorites.
    /// </summary>
    public Guid PropertyId { get; set; }
}

    /// <summary>
    /// يمثل نتيجة تنفيذ إضافة العقار إلى المفضلة.
    /// Represents the result of adding a property to favorites.
    /// </summary>
public class AddToFavoritesResponse
{
    /// <summary>
    /// يحدد ما إذا كانت العملية قد نجحت.
    /// Indicates whether the operation completed successfully.
    /// </summary>
    public bool Success { get; set; }
    /// <summary>
    /// رسالة توضح نتيجة العملية.
    /// A message describing the operation outcome.
    /// </summary>
    public string Message { get; set; } = string.Empty;
}
