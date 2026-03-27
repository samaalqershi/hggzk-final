// Create new DTO for search result
using YemenBooking.Application.Common.Models;
namespace YemenBooking.Application.Features.Chat.DTOs {
    using System;
    using System.Collections.Generic;

    /// <summary>
    /// نتيجة البحث في المحادثات والرسائل
    /// Search result DTO for chats and messages
    /// </summary>
    public class SearchChatsResultDto
    {
        /// <summary>
        /// خاصية Messages.
        /// Messages property.
        /// </summary>
        public IEnumerable<ChatMessageDto> Messages { get; set; } = new List<ChatMessageDto>();
        /// <summary>
        /// خاصية Conversations.
        /// Conversations property.
        /// </summary>
        public IEnumerable<ChatConversationDto> Conversations { get; set; } = new List<ChatConversationDto>();
        /// <summary>
        /// خاصية TotalCount.
        /// TotalCount property.
        /// </summary>
        public int TotalCount { get; set; }
        /// <summary>
        /// خاصية HasMore.
        /// HasMore property.
        /// </summary>
        public bool HasMore { get; set; }
        /// <summary>
        /// خاصية NextPageNumber.
        /// NextPageNumber property.
        /// </summary>
        public int? NextPageNumber { get; set; }
    }
} 