using System;
using System.Collections.Generic;
using System.Linq;
using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Seeds
{
    /// <summary>
    /// يولد أماكن قريبة واقعية لكل عقار اعتمادًا على المدينة.
    /// </summary>
    public class PropertyNearbyPlaceSeeder
    {
        private static readonly DateTime SeedDate = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc);

        /// <summary>
        /// يولد 5 أماكن قريبة واقعية لكل عقار seeded.
        /// </summary>
        public IEnumerable<PropertyNearbyPlace> SeedData()
        {
            var properties = new PropertySeeder().SeedData().ToList();
            return SeedData(properties);
        }

        /// <summary>
        /// يولد أماكن قريبة واقعية بناءً على العقارات المعطاة.
        /// </summary>
        public IEnumerable<PropertyNearbyPlace> SeedData(IEnumerable<Property> properties)
        {
            var propertyList = properties
                .Where(property => !string.IsNullOrWhiteSpace(property.City))
                .OrderBy(property => property.Id)
                .ToList();

            var nearbyPlaces = new List<PropertyNearbyPlace>();
            var sequence = 1;

            foreach (var property in propertyList)
            {
                if (!NearbyPlaceTemplates.TryGetValue(property.City, out var templates))
                {
                    continue;
                }

                foreach (var item in templates.Take(5).Select((template, index) => new { template, index }))
                {
                    nearbyPlaces.Add(new PropertyNearbyPlace
                    {
                        Id = CreateSeedId(sequence),
                        PropertyId = property.Id,
                        Name = item.template.Name,
                        NameEn = item.template.NameEn,
                        Description = item.template.Description,
                        DescriptionEn = item.template.DescriptionEn,
                        Category = item.template.Category,
                        Icon = item.template.Icon,
                        Latitude = property.Latitude + item.template.LatitudeOffset,
                        Longitude = property.Longitude + item.template.LongitudeOffset,
                        DistanceInMeters = item.template.DistanceInMeters,
                        WalkingMinutes = item.template.WalkingMinutes,
                        DrivingMinutes = item.template.DrivingMinutes,
                        DisplayOrder = item.index + 1,
                        IsActive = true,
                        IsDeleted = false,
                        CreatedAt = SeedDate.AddMinutes(sequence),
                        UpdatedAt = SeedDate.AddMinutes(sequence)
                    });

                    sequence++;
                }
            }

            return nearbyPlaces;
        }

        private static Guid CreateSeedId(int sequence)
        {
            return Guid.Parse($"90000000-0000-0000-0000-{sequence:000000000000}");
        }

        private sealed record NearbyPlaceTemplate(
            string Name,
            string NameEn,
            string Description,
            string DescriptionEn,
            string Category,
            string Icon,
            decimal LatitudeOffset,
            decimal LongitudeOffset,
            int DistanceInMeters,
            int WalkingMinutes,
            int DrivingMinutes);

        private static readonly Dictionary<string, List<NearbyPlaceTemplate>> NearbyPlaceTemplates =
            new(StringComparer.OrdinalIgnoreCase)
            {
                ["صنعاء"] = new List<NearbyPlaceTemplate>
                {
                    new(
                        "باب اليمن",
                        "Bab al-Yemen",
                        "أحد أشهر المعالم التاريخية في صنعاء القديمة ويقصده الزوار يوميًا.",
                        "One of the most famous historical landmarks in Old Sana'a and a daily visitor destination.",
                        "معلم تاريخي",
                        "historic_site",
                        0.0012m,
                        -0.0010m,
                        650,
                        8,
                        3),
                    new(
                        "الجامع الكبير بصنعاء",
                        "Great Mosque of Sana'a",
                        "جامع تاريخي بارز قريب من مراكز الإقامة في صنعاء القديمة.",
                        "A major historic mosque near accommodation hubs in Old Sana'a.",
                        "مسجد",
                        "mosque",
                        0.0008m,
                        -0.0006m,
                        900,
                        11,
                        4),
                    new(
                        "سوق الملح",
                        "Souq Al-Milh",
                        "سوق شعبي يمني مشهور للتسوق والمنتجات المحلية.",
                        "A famous Yemeni traditional market for shopping and local products.",
                        "سوق",
                        "market",
                        0.0015m,
                        0.0009m,
                        1200,
                        15,
                        5),
                    new(
                        "مستشفى الكويت الجامعي",
                        "Kuwait University Hospital",
                        "مستشفى رئيسي يقدم خدمات طبية متقدمة داخل صنعاء.",
                        "A major hospital providing advanced medical services in Sana'a.",
                        "مستشفى",
                        "hospital",
                        -0.0018m,
                        0.0014m,
                        1800,
                        22,
                        7),
                    new(
                        "حديقة السبعين",
                        "Al-Sabeen Park",
                        "حديقة ومتنزه معروف للتنزه والفعاليات في العاصمة.",
                        "A well-known park and leisure area for walks and events in the capital.",
                        "حديقة",
                        "park",
                        -0.0022m,
                        0.0018m,
                        2400,
                        28,
                        9)
                },
                ["عدن"] = new List<NearbyPlaceTemplate>
                {
                    new(
                        "شاطئ جولد مور",
                        "Gold Mohur Beach",
                        "شاطئ شهير في عدن مناسب للتنزه ومشاهدة البحر.",
                        "A famous Aden beach ideal for walks and sea views.",
                        "شاطئ",
                        "beach",
                        0.0010m,
                        0.0016m,
                        700,
                        9,
                        3),
                    new(
                        "صهاريج عدن",
                        "Aden Cisterns",
                        "معلم تاريخي بارز من أشهر وجهات الزوار في المدينة.",
                        "A prominent historical landmark and one of the city's top visitor spots.",
                        "معلم تاريخي",
                        "historic_site",
                        -0.0013m,
                        -0.0009m,
                        1100,
                        13,
                        5),
                    new(
                        "مول عدن",
                        "Aden Mall",
                        "مركز تسوق حديث قريب من مناطق الإقامة والخدمات.",
                        "A modern shopping center close to accommodation and services.",
                        "مول",
                        "mall",
                        0.0017m,
                        -0.0011m,
                        1600,
                        19,
                        6),
                    new(
                        "مستشفى الجمهورية التعليمي",
                        "Al-Jumhuriya Teaching Hospital",
                        "مستشفى تعليمي معروف يخدم أحياء عدن الرئيسية.",
                        "A well-known teaching hospital serving the main Aden districts.",
                        "مستشفى",
                        "hospital",
                        -0.0020m,
                        0.0012m,
                        2100,
                        25,
                        8),
                    new(
                        "كورنيش صيرة",
                        "Sira Corniche",
                        "كورنيش بحري مفضل للزوار والجلسات المسائية.",
                        "A seafront corniche favored by visitors for evening outings.",
                        "كورنيش",
                        "beach",
                        0.0023m,
                        0.0019m,
                        2600,
                        31,
                        10)
                },
                ["تعز"] = new List<NearbyPlaceTemplate>
                {
                    new(
                        "قلعة القاهرة",
                        "Cairo Castle",
                        "من أشهر معالم تعز التاريخية ويطل على أجزاء واسعة من المدينة.",
                        "One of Taiz's most famous historical landmarks overlooking large parts of the city.",
                        "معلم تاريخي",
                        "historic_site",
                        0.0011m,
                        -0.0012m,
                        800,
                        10,
                        4),
                    new(
                        "جامعة تعز",
                        "Taiz University",
                        "مرفق أكاديمي رئيسي وحيوي بالقرب من عدد من الأحياء السكنية.",
                        "A major academic hub located near several residential districts.",
                        "جامعة",
                        "university",
                        -0.0010m,
                        0.0010m,
                        1300,
                        16,
                        5),
                    new(
                        "سوق الشنيني",
                        "Al-Shanini Market",
                        "سوق محلي مشهور للمواد اليومية والتسوق الشعبي.",
                        "A popular local market for daily goods and traditional shopping.",
                        "سوق",
                        "market",
                        0.0016m,
                        0.0008m,
                        1700,
                        21,
                        7),
                    new(
                        "مستشفى الثورة العام",
                        "Al-Thawra General Hospital",
                        "مستشفى رئيسي يقدم خدمات طبية لسكان مدينة تعز.",
                        "A main hospital serving the residents of Taiz city.",
                        "مستشفى",
                        "hospital",
                        -0.0019m,
                        -0.0014m,
                        2200,
                        27,
                        9),
                    new(
                        "وادي الضباب",
                        "Wadi Al-Dhabab",
                        "وجهة طبيعية معروفة في تعز تناسب التنزه والرحلات القصيرة.",
                        "A well-known natural destination in Taiz for outings and short trips.",
                        "منتزه طبيعي",
                        "park",
                        0.0022m,
                        -0.0018m,
                        2800,
                        34,
                        11)
                }
            };
    }
}
