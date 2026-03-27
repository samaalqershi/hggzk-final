using System;
using System.Collections.Generic;
using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Seeds
{
    /// <summary>
    /// مولد البيانات الأولية لكائن PropertyType
    /// </summary>
    public class PropertyTypeSeeder : ISeeder<PropertyType>
    {
        // معرف نوع العقار الافتراضي (يُستخدم في PropertySeeder)
        /// <summary>
        /// حقل DefaultPropertyTypeId.
        /// DefaultPropertyTypeId field.
        /// </summary>
        public static readonly Guid DefaultPropertyTypeId = Guid.Parse("30000000-0000-0000-0000-000000000001");
        
        // Fixed: Use static GUIDs instead of Guid.NewGuid() for PostgreSQL compatibility
        /// <summary>
        /// حقل ChaletTypeId.
        /// ChaletTypeId field.
        /// </summary>
        private static readonly Guid ChaletTypeId = Guid.Parse("30000000-0000-0000-0000-000000000002");
        /// <summary>
        /// حقل RestTypeId.
        /// RestTypeId field.
        /// </summary>
        private static readonly Guid RestTypeId = Guid.Parse("30000000-0000-0000-0000-000000000003");
        /// <summary>
        /// حقل VillaTypeId.
        /// VillaTypeId field.
        /// </summary>
        private static readonly Guid VillaTypeId = Guid.Parse("30000000-0000-0000-0000-000000000004");
        /// <summary>
        /// حقل ApartmentTypeId.
        /// ApartmentTypeId field.
        /// </summary>
        private static readonly Guid ApartmentTypeId = Guid.Parse("30000000-0000-0000-0000-000000000005");
        
        /// <summary>
        /// دالة SeedData.
        /// SeedData method.
        /// </summary>
        public IEnumerable<PropertyType> SeedData()
        {
            // Fixed: Use static date instead of DateTime.UtcNow for PostgreSQL compatibility
            var seedDate = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc);
            
            return new List<PropertyType>
            {
                new PropertyType
                {
                    Id = DefaultPropertyTypeId,
                    Name = "فندق",
                    Description = "منشأة فندقية تقدم خدمات الإقامة",
                    DefaultAmenities = "[]",
                    CreatedAt = seedDate,
                    IsActive = true,
                    IsDeleted = false
                },
                new PropertyType
                {
                    Id = ChaletTypeId,
                    Name = "شاليه",
                    Description = "شاليه أو منتجع",
                    DefaultAmenities = "[]",
                    CreatedAt = seedDate,
                    IsActive = true,
                    IsDeleted = false
                },
                new PropertyType
                {
                    Id = RestTypeId,
                    Name = "استراحة",
                    Description = "استراحة عائلية",
                    DefaultAmenities = "[]",
                    CreatedAt = seedDate,
                    IsActive = true,
                    IsDeleted = false
                },
                new PropertyType
                {
                    Id = VillaTypeId,
                    Name = "فيلا",
                    Description = "فيلا أو منزل مستقل",
                    DefaultAmenities = "[]",
                    CreatedAt = seedDate,
                    IsActive = true,
                    IsDeleted = false
                },
                new PropertyType
                {
                    Id = ApartmentTypeId,
                    Name = "شقة",
                    Description = "شقة مفروشة",
                    DefaultAmenities = "[]",
                    CreatedAt = seedDate,
                    IsActive = true,
                    IsDeleted = false
                }
            };
        }
    }
} 