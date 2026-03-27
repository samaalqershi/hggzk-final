using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using YemenBooking.Core.Entities;

namespace YemenBooking.Infrastructure.Data.Configurations
{
    /// <summary>
    /// Configures the Section entity mapping.
    /// يهيئ ربط كيان القسم بقاعدة البيانات.
    /// </summary>
	public class SectionConfiguration : IEntityTypeConfiguration<Section>
	{
        /// <summary>
        /// Applies Section entity mapping rules.
        /// يطبق قواعد ربط كيان القسم.
        /// </summary>
		public void Configure(EntityTypeBuilder<Section> builder)
		{
			builder.ToTable("Sections");
			builder.HasKey(s => s.Id);
			builder.Property(s => s.Type).IsRequired();
			builder.Property(s => s.ContentType).IsRequired();
			builder.Property(s => s.DisplayStyle).IsRequired();
			builder.Property(s => s.DisplayOrder).IsRequired();
			builder.Property(s => s.Target).IsRequired();
			builder.Property(s => s.Name).HasMaxLength(150);
			builder.Property(s => s.Title).HasMaxLength(200);
			builder.Property(s => s.Subtitle).HasMaxLength(300);
			builder.Property(s => s.Description).HasColumnType("text");
			builder.Property(s => s.ShortDescription).HasMaxLength(500);
			builder.Property(s => s.Icon).HasMaxLength(100);
			builder.Property(s => s.ColorTheme).HasMaxLength(50);
			builder.Property(s => s.BackgroundImage).HasMaxLength(500);
			builder.Property(s => s.BackgroundImageId).IsRequired(false);
			builder.Property(s => s.FilterCriteria).HasColumnType("text");
			builder.Property(s => s.SortCriteria).HasColumnType("text");
			builder.Property(s => s.CityName).HasMaxLength(100);
			builder.Property(s => s.MinPrice).HasColumnType("decimal(18,2)");
			builder.Property(s => s.MaxPrice).HasColumnType("decimal(18,2)");
			builder.Property(s => s.MinRating).HasColumnType("decimal(5,2)");
			builder.Property(s => s.Metadata).HasColumnType("text");
			builder.Property(s => s.CategoryClass).IsRequired(false);
			builder.Property(s => s.HomeItemsCount).IsRequired(false);

			builder.HasMany(s => s.PropertyItems)
				.WithOne(pi => pi.Section)
				.HasForeignKey(pi => pi.SectionId)
				.OnDelete(DeleteBehavior.Cascade);

			builder.HasMany(s => s.UnitItems)
				.WithOne(ui => ui.Section)
				.HasForeignKey(ui => ui.SectionId)
				.OnDelete(DeleteBehavior.Cascade);

            // Optional relationship to City by name.
            // علاقة اختيارية مع City باستخدام الاسم.
            builder.HasOne<City>()
                .WithMany()
                .HasForeignKey(s => s.CityName)
                .HasPrincipalKey(c => c.Name)
                .OnDelete(DeleteBehavior.SetNull);

            // Optional background image link through SectionImages.
            // ربط اختياري للصورة الخلفية عبر SectionImages.
            builder.HasOne<SectionImage>()
				.WithMany()
				.HasForeignKey(s => s.BackgroundImageId)
				.OnDelete(DeleteBehavior.SetNull);

            // Images collection is configured in SectionImageConfiguration.
            // مجموعة الصور مهيأة في SectionImageConfiguration.
		}
	}
}
