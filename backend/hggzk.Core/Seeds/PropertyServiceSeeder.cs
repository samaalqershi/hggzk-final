using System;
using System.Collections.Generic;
using System.Linq;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Enums;
using YemenBooking.Core.ValueObjects;

namespace YemenBooking.Core.Seeds
{
    /// <summary>
    /// فئة PropertyServiceSeeder.
    /// PropertyServiceSeeder class.
    /// </summary>
    public class PropertyServiceSeeder : ISeeder<PropertyService>
    {
        /// <summary>
        /// حقل _properties.
        /// _properties field.
        /// </summary>
        private readonly IEnumerable<Property> _properties;
        /// <summary>
        /// منشئ PropertyServiceSeeder.
        /// PropertyServiceSeeder constructor.
        /// </summary>
        public PropertyServiceSeeder(IEnumerable<Property> properties)
        {
            _properties = properties;
        }

        /// <summary>
        /// دالة SeedData.
        /// SeedData method.
        /// </summary>
        public IEnumerable<PropertyService> SeedData()
        {
            var list = new List<PropertyService>();
            var rnd = new Random(24680);

            var templates = new (string Name, PricingModel Model, decimal YerPrice, decimal UsdPrice, string Icon)[]
            {
                ("خدمة توصيل من وإلى المطار", PricingModel.Fixed, 50m, 50m, "airport_shuttle"),
                ("إفطار", PricingModel.PerPerson, 20m, 20m, "breakfast"),
                ("تنظيف إضافي", PricingModel.PerNight, 25m, 25m, "cleaning_services"),
                ("غسيل ملابس", PricingModel.PerPerson, 15m, 15m, "local_laundry_service"),
                ("نقل داخلي", PricingModel.Fixed, 30m, 30m, "directions_bus"),
            };

            foreach (var p in _properties)
            {
                var currency = "YER";
                var count = rnd.Next(3, templates.Length + 1);
                var selected = templates.OrderBy(_ => rnd.Next()).Take(count).ToList();
                foreach (var t in selected)
                {
                    var amount = t.YerPrice;
                    var service = new PropertyService
                    {
                        Id = Guid.NewGuid(),
                        PropertyId = p.Id,
                        Name = t.Name,
                        Description = null,
                        Icon = t.Icon,
                        PricingModel = t.Model,
                        Price = new Money(amount, currency),
                        CreatedAt = DateTime.UtcNow.AddDays(-rnd.Next(10, 60)),
                        UpdatedAt = DateTime.UtcNow,
                        IsActive = true,
                        IsDeleted = false
                    };

                    SeedLocalizationHelper.ApplyServiceEnglish(service);
                    list.Add(service);
                }
            }

            return list;
        }
    }
}
