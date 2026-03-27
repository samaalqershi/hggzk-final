using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YemenBooking.Core.Entities;

namespace YemenBooking.Infrastructure.Data.Configurations;

/// <summary>
/// Configuration for the review response entity.
/// تكوين كيان ردود التقييمات.
/// </summary>
public class ReviewResponseConfiguration : IEntityTypeConfiguration<ReviewResponse>
{
    /// <summary>
    /// Applies the review response mapping rules.
    /// يطبق قواعد ربط ردود التقييمات.
    /// </summary>
    public void Configure(EntityTypeBuilder<ReviewResponse> builder)
    {
        builder.ToTable("ReviewResponses");

        builder.HasKey(r => r.Id);

        builder.Property(r => r.Text)
            .IsRequired()
            .IsUnicode(true)
            .HasColumnType("text")
            .HasComment("نص الرد على التقييم");

        builder.Property(r => r.RespondedAt)
            .HasColumnType("timestamp with time zone")
            .IsRequired()
            .HasComment("تاريخ إنشاء الرد");

        builder.Property(r => r.RespondedBy)
            .IsRequired()
            .HasComment("المستخدم الذي قام بالرد");

        builder.Property(r => r.RespondedByName)
            .IsUnicode(true)
            .HasMaxLength(200)
            .HasComment("اسم المجيب (منسوخ)");

        builder.Property(r => r.IsDeleted)
            .IsRequired()
            .HasDefaultValue(false);

        builder.HasIndex(r => r.ReviewId)
            .HasDatabaseName("IX_ReviewResponses_ReviewId");

        builder.HasOne(r => r.Review)
            .WithMany(rv => rv.Responses)
            .HasForeignKey(r => r.ReviewId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasQueryFilter(r => !r.IsDeleted);
    }
}
