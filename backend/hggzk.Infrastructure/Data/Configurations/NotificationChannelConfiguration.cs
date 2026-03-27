using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YemenBooking.Core.Entities;

namespace YemenBooking.Infrastructure.Data.Configurations;

/// <summary>
/// Configuration for notification channels.
/// تكوين جدول قنوات الإشعارات.
/// </summary>
public class NotificationChannelConfiguration : IEntityTypeConfiguration<NotificationChannel>
{
    /// <summary>
    /// Applies the notification channel mapping rules.
    /// يطبق قواعد ربط قناة الإشعارات.
    /// </summary>
    public void Configure(EntityTypeBuilder<NotificationChannel> builder)
    {
        // Configure the table.
        // تكوين الجدول.
        builder.ToTable("NotificationChannels");
        
        // Configure the primary key.
        // تكوين المفتاح الأساسي.
        builder.HasKey(nc => nc.Id);
        
        // Configure the properties.
        // تكوين الخصائص.
        builder.Property(nc => nc.Name)
            .IsRequired()
            .HasMaxLength(100);
            
        builder.Property(nc => nc.Identifier)
            .IsRequired()
            .HasMaxLength(50);
            
        // Create a unique index on the identifier.
        // إنشاء فهرس فريد على المعرف.
        builder.HasIndex(nc => nc.Identifier)
            .IsUnique()
            .HasDatabaseName("IX_NotificationChannels_Identifier");
            
        builder.Property(nc => nc.Description)
            .HasMaxLength(500);
            
        builder.Property(nc => nc.Icon)
            .HasMaxLength(50);
            
        builder.Property(nc => nc.Color)
            .HasMaxLength(20);
            
        builder.Property(nc => nc.Type)
            .IsRequired()
            .HasMaxLength(20)
            .HasDefaultValue("CUSTOM");
            
        builder.Property(nc => nc.IsActive)
            .HasDefaultValue(true);
            
        builder.Property(nc => nc.IsPrivate)
            .HasDefaultValue(false);
            
        builder.Property(nc => nc.IsDeletable)
            .HasDefaultValue(true);
            
        builder.Property(nc => nc.Settings)
            .HasColumnType("text");
            
        // Configure JSON-like lists.
        // تكوين القوائم الشبيهة بـ JSON.
        builder.Property(nc => nc.AllowedRoles)
            .HasConversion(
                v => string.Join(',', v),
                v => v.Split(',', StringSplitOptions.RemoveEmptyEntries).ToList()
            )
            .HasMaxLength(500);
            
        // Indexes.
        // الفهارس.
        builder.HasIndex(nc => nc.Type)
            .HasDatabaseName("IX_NotificationChannels_Type");
            
        builder.HasIndex(nc => nc.IsActive)
            .HasDatabaseName("IX_NotificationChannels_IsActive");
            
        builder.HasIndex(nc => new { nc.CreatedBy, nc.IsActive })
            .HasDatabaseName("IX_NotificationChannels_CreatedBy_IsActive");
            
        // Relationships.
        // العلاقات.
        builder.HasOne(nc => nc.Creator)
            .WithMany()
            .HasForeignKey(nc => nc.CreatedBy)
            .OnDelete(DeleteBehavior.SetNull);
            
        builder.HasMany(nc => nc.UserChannels)
            .WithOne(uc => uc.Channel)
            .HasForeignKey(uc => uc.ChannelId)
            .OnDelete(DeleteBehavior.Cascade);
            
        builder.HasMany(nc => nc.NotificationHistories)
            .WithOne(nh => nh.Channel)
            .HasForeignKey(nh => nh.ChannelId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}

/// <summary>
/// Configuration for user channel subscriptions.
/// تكوين جدول اشتراكات المستخدمين في القنوات.
/// </summary>
public class UserChannelConfiguration : IEntityTypeConfiguration<UserChannel>
{
    /// <summary>
    /// Applies the user channel subscription mapping rules.
    /// يطبق قواعد ربط اشتراك المستخدم في القناة.
    /// </summary>
    public void Configure(EntityTypeBuilder<UserChannel> builder)
    {
        // Configure the table.
        // تكوين الجدول.
        builder.ToTable("UserChannels");
        
        // Configure the primary key.
        // تكوين المفتاح الأساسي.
        builder.HasKey(uc => uc.Id);
        
        // Configure the properties.
        // تكوين الخصائص.
        builder.Property(uc => uc.IsActive)
            .HasDefaultValue(true);
            
        builder.Property(uc => uc.IsMuted)
            .HasDefaultValue(false);
            
        builder.Property(uc => uc.SubscribedAt)
            .HasDefaultValueSql("NOW()");
            
        builder.Property(uc => uc.Notes)
            .HasMaxLength(500);
            
        // Indexes.
        // الفهارس.
        builder.HasIndex(uc => new { uc.UserId, uc.ChannelId })
            .IsUnique()
            .HasDatabaseName("IX_UserChannels_UserId_ChannelId");
            
        builder.HasIndex(uc => new { uc.ChannelId, uc.IsActive })
            .HasDatabaseName("IX_UserChannels_ChannelId_IsActive");
            
        builder.HasIndex(uc => uc.IsActive)
            .HasDatabaseName("IX_UserChannels_IsActive");
            
        // Relationships.
        // العلاقات.
        builder.HasOne(uc => uc.User)
            .WithMany()
            .HasForeignKey(uc => uc.UserId)
            .OnDelete(DeleteBehavior.Cascade);
            
        builder.HasOne(uc => uc.Channel)
            .WithMany(c => c.UserChannels)
            .HasForeignKey(uc => uc.ChannelId)
            .OnDelete(DeleteBehavior.Cascade);

        // Global query filter.
        // مرشح الاستعلام العام.
        builder.HasQueryFilter(uc => !uc.IsDeleted);
    }
}

/// <summary>
/// Configuration for notification channel history.
/// تكوين جدول سجل إشعارات القنوات.
/// </summary>
public class NotificationChannelHistoryConfiguration : IEntityTypeConfiguration<NotificationChannelHistory>
{
    /// <summary>
    /// Applies the notification channel history mapping rules.
    /// يطبق قواعد ربط سجل إشعارات القنوات.
    /// </summary>
    public void Configure(EntityTypeBuilder<NotificationChannelHistory> builder)
    {
        // Configure the table.
        // تكوين الجدول.
        builder.ToTable("NotificationChannelHistories");
        
        // Configure the primary key.
        // تكوين المفتاح الأساسي.
        builder.HasKey(nh => nh.Id);
        
        // Configure the properties.
        // تكوين الخصائص.
        builder.Property(nh => nh.Title)
            .IsRequired()
            .HasMaxLength(200);
            
        builder.Property(nh => nh.Content)
            .IsRequired()
            .HasMaxLength(1000);
            
        builder.Property(nh => nh.Type)
            .IsRequired()
            .HasMaxLength(20)
            .HasDefaultValue("INFO");
            
        builder.Property(nh => nh.SentAt)
            .HasDefaultValueSql("NOW()");
            
        // Indexes.
        // الفهارس.
        builder.HasIndex(nh => nh.ChannelId)
            .HasDatabaseName("IX_NotificationChannelHistories_ChannelId");
            
        builder.HasIndex(nh => nh.SentAt)
            .HasDatabaseName("IX_NotificationChannelHistories_SentAt");
            
        builder.HasIndex(nh => new { nh.ChannelId, nh.SentAt })
            .HasDatabaseName("IX_NotificationChannelHistories_ChannelId_SentAt");
            
        // Relationships.
        // العلاقات.
        builder.HasOne(nh => nh.Channel)
            .WithMany(c => c.NotificationHistories)
            .HasForeignKey(nh => nh.ChannelId)
            .OnDelete(DeleteBehavior.Cascade);
            
        builder.HasOne(nh => nh.Sender)
            .WithMany()
            .HasForeignKey(nh => nh.SenderId)
            .OnDelete(DeleteBehavior.SetNull);
    }
}
