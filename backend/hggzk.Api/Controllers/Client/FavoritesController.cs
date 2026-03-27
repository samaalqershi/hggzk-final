using MediatR;
using Microsoft.AspNetCore.Mvc;
using YemenBooking.Application.Features.Favorites.Commands.ToFavorites;
using YemenBooking.Application.Features.Favorites.Commands.FromFavorites;
using YemenBooking.Application.Features.Favorites.Queries.GetUserFavorites;
using YemenBooking.Application.Features.Users.DTOs;
using YemenBooking.Application.Common.Models;

namespace YemenBooking.Api.Controllers.Client
{
    /// <summary>
    /// متحكم إدارة المفضلات الخاصة بالعميل.
    /// Client favorites controller.
    /// </summary>
    public class FavoritesController : BaseClientController
    {
        /// <summary>
        /// يهيئ نسخة جديدة من [FavoritesController].
        /// Initializes a new instance of [FavoritesController].
        /// </summary>
        /// <param name="mediator">وسيط MediatR المستخدم لمعالجة الطلبات. MediatR mediator used to process requests.</param>
        public FavoritesController(IMediator mediator) : base(mediator)
        {
        }

        /// <summary>
        /// يضيف عقارًا إلى قائمة المفضلات.
        /// Adds a property to the favorites list.
        /// </summary>
        /// <param name="command">بيانات الإضافة إلى المفضلات. Favorite item details.</param>
        /// <returns>نتيجة الإضافة. Add result.</returns>
        [HttpPost]
        public async Task<ActionResult<ResultDto<AddToFavoritesResponse>>> AddToFavorites([FromBody] AddToFavoritesCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يزيل عقارًا من قائمة المفضلات.
        /// Removes a property from the favorites list.
        /// </summary>
        /// <param name="command">بيانات الإزالة من المفضلات. Removal details.</param>
        /// <returns>نتيجة الإزالة. Remove result.</returns>
        [HttpDelete]
        public async Task<ActionResult<ResultDto<RemoveFromFavoritesResponse>>> RemoveFromFavorites([FromBody] RemoveFromFavoritesCommand command)
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }

        /// <summary>
        /// يعيد قائمة المفضلات الخاصة بالمستخدم.
        /// Returns the user's favorites list.
        /// </summary>
        /// <param name="query">معايير البحث. Query parameters.</param>
        /// <returns>قائمة المفضلات. Favorites list.</returns>
        [HttpGet]
        public async Task<ActionResult<ResultDto<UserFavoritesResponse>>> GetUserFavorites([FromQuery] GetUserFavoritesQuery query)
        {
            var result = await _mediator.Send(query);
            return Ok(result);
        }
    }
}
