using YemenBooking.Application.Features.Users.DTOs;

namespace YemenBooking.Application.Features.Chat.DTOs {
    using System;
    using System.Collections.Generic;
    using YemenBooking.Application.Features.Users; // Added for UserDto
    using System.Text.Json.Serialization;

    /// <summary>
    /// DTO لتمثيل المحادثة بين المستخدمين
    /// DTO for ChatConversation entity
    /// </summary>
    public class ChatConversationDto
    {
        /// <summary>
        /// خاصية Id.
        /// Id property.
        /// </summary>
        [JsonPropertyName("id")]
        public Guid Id { get; set; }
        /// <summary>
        /// خاصية ConversationType.
        /// ConversationType property.
        /// </summary>
        [JsonPropertyName("conversationType")]
        public string ConversationType { get; set; } = string.Empty;
        /// <summary>
        /// خاصية Title.
        /// Title property.
        /// </summary>
        [JsonPropertyName("title")]
        public string? Title { get; set; }
        /// <summary>
        /// خاصية Description.
        /// Description property.
        /// </summary>
        [JsonPropertyName("description")]
        public string? Description { get; set; }
        /// <summary>
        /// خاصية Avatar.
        /// Avatar property.
        /// </summary>
        [JsonPropertyName("avatar")]
        public string? Avatar { get; set; }
        /// <summary>
        /// خاصية CreatedAt.
        /// CreatedAt property.
        /// </summary>
        [JsonPropertyName("createdAt")]
        public DateTime CreatedAt { get; set; }
        /// <summary>
        /// خاصية UpdatedAt.
        /// UpdatedAt property.
        /// </summary>
        [JsonPropertyName("updatedAt")]
        public DateTime UpdatedAt { get; set; }
        /// <summary>
        /// خاصية LastMessage.
        /// LastMessage property.
        /// </summary>
        [JsonPropertyName("lastMessage")]
        public ChatMessageDto? LastMessage { get; set; }
        /// <summary>
        /// خاصية LastMessageTime.
        /// LastMessageTime property.
        /// </summary>
        [JsonPropertyName("lastMessageTime")]
        public DateTime? LastMessageTime { get; set; }
        /// <summary>
        /// خاصية UnreadCount.
        /// UnreadCount property.
        /// </summary>
        [JsonPropertyName("unreadCount")]
        public int UnreadCount { get; set; }
        /// <summary>
        /// خاصية IsArchived.
        /// IsArchived property.
        /// </summary>
        [JsonPropertyName("isArchived")]
        public bool IsArchived { get; set; }
        /// <summary>
        /// خاصية IsMuted.
        /// IsMuted property.
        /// </summary>
        [JsonPropertyName("isMuted")]
        public bool IsMuted { get; set; }
       
        /// <summary>
        /// معرّف الفندق المرتبط بالمحادثة
        /// Property ID associated with the conversation
        /// </summary>
        [JsonPropertyName("propertyId")]
        public Guid? PropertyId { get; set; }

        /// <summary>
        /// خاصية Participants.
        /// Participants property.
        /// </summary>
        [JsonPropertyName("participants")]
        public IEnumerable<ChatUserDto> Participants { get; set; } = new List<ChatUserDto>();
    }
} 