using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YemenBooking.Core.Entities;

namespace YemenBooking.Infrastructure.Data.Configurations;

/// <summary>
/// Configuration for the audit log entity.
/// تكوين كيان سجل التدقيق.
/// </summary>
public class AuditLogConfiguration : IEntityTypeConfiguration<AuditLog>
{
    /// <summary>
    /// Applies the audit log mapping rules.
    /// يطبق قواعد ربط سجل التدقيق.
    /// </summary>
    public void Configure(EntityTypeBuilder<AuditLog> builder)
    {
        // Table name.
        // اسم الجدول.
        builder.ToTable("AuditLogs");

        // Primary key.
        // المفتاح الأساسي.
        builder.HasKey(a => a.Id);
        builder.Property(a => a.Id).HasColumnName("AuditLogId").IsRequired();

        // Base entity properties.
        // خصائص الكيان الأساسي.
        builder.Property(a => a.CreatedAt).HasColumnType("timestamp with time zone").IsRequired();
        builder.Property(a => a.UpdatedAt).HasColumnType("timestamp with time zone").IsRequired();
        builder.Property(a => a.IsActive).HasDefaultValue(true);
        builder.Property(a => a.IsDeleted).HasDefaultValue(false);
        builder.Property(a => a.DeletedAt).HasColumnType("timestamp with time zone");

        // Properties.
        // الخصائص.
        builder.Property(a => a.EntityType).IsRequired().IsUnicode(true).HasMaxLength(100);
        builder.Property(a => a.EntityId);
        builder.Property(a => a.Action).IsRequired();
        builder.Property(a => a.OldValues).IsUnicode(true).HasColumnType("text");
        builder.Property(a => a.NewValues).IsUnicode(true).HasColumnType("text");
        builder.Property(a => a.PerformedBy);
        builder.Property(a => a.Username).IsUnicode(true).HasMaxLength(100);
        builder.Property(a => a.IpAddress).IsUnicode(true).HasMaxLength(50);
        builder.Property(a => a.UserAgent).IsUnicode(true).HasMaxLength(255);
        builder.Property(a => a.Notes).IsUnicode(true).HasColumnType("text");
        builder.Property(a => a.Metadata).IsUnicode(true).HasColumnType("text");
        builder.Property(a => a.IsSuccessful).HasDefaultValue(true);
        builder.Property(a => a.ErrorMessage).HasMaxLength(500);
        builder.Property(a => a.DurationMs);
        builder.Property(a => a.SessionId).IsUnicode(true).HasMaxLength(100);
        builder.Property(a => a.RequestId).IsUnicode(true).HasMaxLength(100);
        builder.Property(a => a.Source).IsUnicode(true).HasMaxLength(100);

        // Relationships.
        // العلاقات.
        builder.HasOne(a => a.PerformedByUser)
            .WithMany()
            .HasForeignKey(a => a.PerformedBy)
            .OnDelete(DeleteBehavior.SetNull);

        // Global query filter.
        // مرشح الاستعلام العام.
        builder.HasQueryFilter(a => !a.IsDeleted);

        // Performance indexes for frequent queries.
        // فهارس أداء للاستعلامات المتكررة.
        builder.HasIndex(a => a.CreatedAt)
            .HasDatabaseName("IX_AuditLogs_CreatedAt");
        builder.HasIndex(a => new { a.EntityType, a.CreatedAt })
            .HasDatabaseName("IX_AuditLogs_EntityType_CreatedAt");
        builder.HasIndex(a => a.Action)
            .HasDatabaseName("IX_AuditLogs_Action");
        builder.HasIndex(a => a.PerformedBy)
            .HasDatabaseName("IX_AuditLogs_PerformedBy");
        builder.HasIndex(a => new { a.EntityType, a.EntityId })
            .HasDatabaseName("IX_AuditLogs_EntityType_EntityId");
    }
} 
