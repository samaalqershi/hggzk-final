using MediatR;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Application.Features.Favorites.Commands.FromFavorites;

    /// <summary>
    /// يمثل طلب إزالة عقار من المفضلة.
    /// Represents a request to remove a property from favorites.
    /// </summary>
public class RemoveFromFavoritesCommand : IRequest<ResultDto<RemoveFromFavoritesResponse>>
{
    /// <summary>
    /// معرّف المستخدم صاحب المفضلة.
    /// Identifies the user who owns the favorites list.
    /// </summary>
    public Guid UserId { get; set; }
    /// <summary>
    /// معرّف العقار المراد إزالته من المفضلة.
    /// Identifies the property to remove from favorites.
    /// </summary>
    public Guid PropertyId { get; set; }
}

    /// <summary>
    /// يمثل نتيجة تنفيذ إزالة العقار من المفضلة.
    /// Represents the result of removing a property from favorites.
    /// </summary>
public class RemoveFromFavoritesResponse
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
