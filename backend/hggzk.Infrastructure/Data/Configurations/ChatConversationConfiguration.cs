using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YemenBooking.Core.Entities;

namespace YemenBooking.Infrastructure.Data.Configurations
{
    /// <summary>
    /// Configuration for the chat conversation entity.
    /// تكوين كيان المحادثة.
    /// </summary>
    public class ChatConversationConfiguration : IEntityTypeConfiguration<ChatConversation>
    {
        /// <summary>
        /// Applies the chat conversation mapping rules.
        /// يطبق قواعد ربط المحادثة.
        /// </summary>
        public void Configure(EntityTypeBuilder<ChatConversation> builder)
        {
            builder.ToTable("ChatConversations");

            builder.HasKey(cc => cc.Id);

            builder.Property(cc => cc.ConversationType)
                .IsRequired()
                .HasMaxLength(20)
                .HasComment("نوع المحادثة: direct أو group");

            builder.Property(cc => cc.Title)
                .HasMaxLength(200)
                .HasComment("عنوان المحادثة للمجموعات");

            builder.Property(cc => cc.Description)
                .HasMaxLength(500)
                .HasComment("وصف المحادثة");

            builder.Property(cc => cc.Avatar)
                .HasMaxLength(500)
                .HasComment("مسار الصورة الرمزية");

            builder.Property(cc => cc.IsArchived)
                .HasDefaultValue(false)
                .HasComment("هل المحادثة مؤرشفة");

            builder.Property(cc => cc.IsMuted)
                .HasDefaultValue(false)
                .HasComment("هل المحادثة صامتة");

            // Configure the related property identifier.
            // تكوين معرف الكيان المرتبط.
            builder.Property(cc => cc.PropertyId)
                .HasComment("معرف الفندق المرتبط بالمحادثة");
            builder.HasIndex(cc => cc.PropertyId)
                .HasDatabaseName("IX_ChatConversations_PropertyId");
            builder.HasOne(cc => cc.Property)
                .WithMany()
                .HasForeignKey(cc => cc.PropertyId)
                .OnDelete(DeleteBehavior.SetNull);

            // Relationships.
            // العلاقات.
            builder.HasMany(cc => cc.Messages)
                .WithOne()
                .HasForeignKey(m => m.ConversationId)
                .OnDelete(DeleteBehavior.Cascade);

            builder.HasMany(cc => cc.Attachments)
                .WithOne()
                .HasForeignKey(a => a.ConversationId)
                .OnDelete(DeleteBehavior.Cascade);

            // Participant relationship: many-to-many with User.
            // علاقة المشاركين: many-to-many مع User.
            builder.HasMany(cc => cc.Participants)
                .WithMany()
                .UsingEntity<Dictionary<string, object>>(  
                    "ChatConversationParticipant",
                    j => j
                        .HasOne<User>()
                        .WithMany()
                        .HasForeignKey("UserId")
                        .OnDelete(DeleteBehavior.Cascade),
                    j => j
                        .HasOne<ChatConversation>()
                        .WithMany()
                        .HasForeignKey("ConversationId")
                        .OnDelete(DeleteBehavior.Cascade)
                );
        }
    }
} 
