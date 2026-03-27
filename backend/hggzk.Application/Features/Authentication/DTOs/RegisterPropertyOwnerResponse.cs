using System;

namespace YemenBooking.Application.Features.Authentication.DTOs {
    /// <summary>
    /// استجابة تسجيل مالك عقار مع إنشاء العقار
    /// Response for registering property owner with created property
    /// </summary>
    public class RegisterPropertyOwnerResponse
    {
        /// <summary>
        /// خاصية UserId.
        /// UserId property.
        /// </summary>
        public Guid UserId { get; set; }
        /// <summary>
        /// خاصية PropertyId.
        /// PropertyId property.
        /// </summary>
        public Guid PropertyId { get; set; }
        /// <summary>
        /// خاصية UserName.
        /// UserName property.
        /// </summary>
        public string UserName { get; set; } = string.Empty;
        /// <summary>
        /// خاصية Email.
        /// Email property.
        /// </summary>
        public string Email { get; set; } = string.Empty;
        /// <summary>
        /// خاصية PropertyName.
        /// PropertyName property.
        /// </summary>
        public string PropertyName { get; set; } = string.Empty;
        /// <summary>
        /// خاصية AccountRole.
        /// AccountRole property.
        /// </summary>
        public string AccountRole { get; set; } = "Owner";
        /// <summary>
        /// خاصية Message.
        /// Message property.
        /// </summary>
        public string Message { get; set; } = string.Empty;

        // Tokens
        /// <summary>
        /// خاصية AccessToken.
        /// AccessToken property.
        /// </summary>
        public string AccessToken { get; set; } = string.Empty;
        /// <summary>
        /// خاصية RefreshToken.
        /// RefreshToken property.
        /// </summary>
        public string RefreshToken { get; set; } = string.Empty;
        /// <summary>
        /// خاصية AccessTokenExpiry.
        /// AccessTokenExpiry property.
        /// </summary>
        public DateTime AccessTokenExpiry { get; set; }

        // Optional property enrichments
        /// <summary>
        /// خاصية PropertyCurrency.
        /// PropertyCurrency property.
        /// </summary>
        public string? PropertyCurrency { get; set; }
    }
}

