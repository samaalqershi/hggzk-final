using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YemenBooking.Core.Entities;

namespace YemenBooking.Infrastructure.Data.Configurations;

/// <summary>
/// Configures the Favorite entity mapping.
/// يهيئ ربط كيان المفضلة بقاعدة البيانات. / Configures the Favorite entity mapping.
/// </summary>
public class FavoriteConfiguration : IEntityTypeConfiguration<Favorite>
{
    /// <summary>
    /// Applies the Favorite mapping rules.
    /// يطبق قواعد ربط كيان المفضلة. / Applies the Favorite mapping rules.
    /// </summary>
    public void Configure(EntityTypeBuilder<Favorite> builder)
    {
        builder.ToTable("Favorites");

        builder.HasKey(f => f.Id);

        builder.Property(f => f.Id)
            .IsRequired();

        builder.Property(f => f.UserId)
            .IsRequired()
            .HasComment("User identifier / معرف المستخدم");

        builder.Property(f => f.PropertyId)
            .IsRequired()
            .HasComment("Property identifier / معرف العقار");

        builder.Property(f => f.DateAdded)
            .IsRequired()
            .HasColumnType("timestamp with time zone")
            .HasComment("Added to favorites timestamp / تاريخ الإضافة إلى المفضلة");

        // Re-apply BaseEntity fields explicitly for the schema. / إعادة تطبيق حقول BaseEntity بشكل صريح في المخطط.
        builder.Property(f => f.CreatedAt)
            .HasColumnType("timestamp with time zone");

        builder.Property(f => f.UpdatedAt)
            .HasColumnType("timestamp with time zone");

        builder.Property(f => f.IsDeleted)
            .HasDefaultValue(false);

        // Configure relationships without back-collections. / تهيئة العلاقات دون مجموعات عكسية.
        builder.HasOne(f => f.User)
            .WithMany()
            .HasForeignKey(f => f.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(f => f.Property)
            .WithMany()
            .HasForeignKey(f => f.PropertyId)
            .OnDelete(DeleteBehavior.Cascade);

        // Unique constraint per user-property pair. / قيد فريد لكل زوج مستخدم/عقار.
        builder.HasIndex(f => new { f.UserId, f.PropertyId })
            .IsUnique()
            .HasDatabaseName("IX_Favorites_User_Property");

        builder.HasIndex(f => f.UserId)
            .HasDatabaseName("IX_Favorites_UserId");

        builder.HasIndex(f => f.PropertyId)
            .HasDatabaseName("IX_Favorites_PropertyId");

        // Apply the soft-delete query filter. / تطبيق مرشح الحذف الناعم.
        builder.HasQueryFilter(f => !f.IsDeleted);
    }
}
