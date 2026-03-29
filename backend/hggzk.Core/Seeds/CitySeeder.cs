using System.Collections.Generic;
using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Seeds
{
    /// <summary>
    /// فئة CitySeeder.
    /// CitySeeder class.
    /// </summary>
    public class CitySeeder : ISeeder<City>
    {
        /// <summary>
        /// دالة SeedData.
        /// SeedData method.
        /// </summary>
        public IEnumerable<City> SeedData()
        {
            var cities = new List<City>
            {
                new City { Name = "صنعاء", Country = "اليمن", ImagesJson = "[]" },
                new City { Name = "عدن", Country = "اليمن", ImagesJson = "[]" },
                new City { Name = "تعز", Country = "اليمن", ImagesJson = "[]" },
                new City { Name = "الحديدة", Country = "اليمن", ImagesJson = "[]" },
                new City { Name = "إب", Country = "اليمن", ImagesJson = "[]" },
                new City { Name = "ذمار", Country = "اليمن", ImagesJson = "[]" },
                new City { Name = "المكلا", Country = "اليمن", ImagesJson = "[]" },
                new City { Name = "سيئون", Country = "اليمن", ImagesJson = "[]" },
                new City { Name = "المهرة", Country = "اليمن", ImagesJson = "[]" },
                new City { Name = "شبوة", Country = "اليمن", ImagesJson = "[]" }
            };

            foreach (var city in cities)
            {
                SeedLocalizationHelper.ApplyCityEnglish(city);
            }

            return cities;
        }
    }
}
