using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YemenBooking.Core.Entities;

namespace YemenBooking.Infrastructure.Data.Configurations;

/// <summary>
/// Configures the FieldGroupField entity mapping.
/// يهيئ ربط كيان الحقل بالمجموعة بقاعدة البيانات. / Configures the FieldGroupField entity mapping.
/// </summary>
public class FieldGroupFieldConfiguration : IEntityTypeConfiguration<FieldGroupField>
{
    /// <summary>
    /// Applies the FieldGroupField mapping rules.
    /// يطبق قواعد ربط كيان الحقل بالمجموعة. / Applies the FieldGroupField mapping rules.
    /// </summary>
    public void Configure(EntityTypeBuilder<FieldGroupField> builder)
    {
        builder.ToTable("FieldGroupFields");

        builder.Property(fgf => fgf.FieldId)
            .IsRequired();

        builder.Property(fgf => fgf.GroupId)
            .IsRequired();

        builder.Property(fgf => fgf.SortOrder)
            .HasDefaultValue(0);

        builder.Property(fgf => fgf.IsDeleted)
            .HasDefaultValue(false);

        builder.Property(fgf => fgf.DeletedAt)
            .HasColumnType("timestamp with time zone");

        // Configure the composite primary key. / تهيئة المفتاح الأساسي المركب.
        builder.HasKey(fgf => new { fgf.FieldId, fgf.GroupId });

        builder.HasOne(fgf => fgf.UnitTypeField)
            .WithMany(ptf => ptf.FieldGroupFields)
            .HasForeignKey(fgf => fgf.FieldId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(fgf => fgf.FieldGroup)
            .WithMany(fg => fg.FieldGroupFields)
            .HasForeignKey(fgf => fgf.GroupId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasIndex(fgf => fgf.FieldId)
            .HasDatabaseName("IX_FieldGroupFields_FieldId");

        builder.HasIndex(fgf => fgf.GroupId)
            .HasDatabaseName("IX_FieldGroupFields_GroupId");

        builder.HasQueryFilter(fgf => !fgf.IsDeleted);
    }
} 
