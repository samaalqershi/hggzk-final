using System;
using System.Collections.Generic;
using YemenBooking.Core.Entities;

namespace YemenBooking.Core.Seeds
{
    /// <summary>
    /// يضيف النظائر الإنجليزية المنسقة إلى البيانات المزروعة الثابتة.
    /// Adds curated English counterparts to fixed seed data.
    /// </summary>
    internal static class SeedLocalizationHelper
    {
        private static readonly Dictionary<string, string> CityNames = new(StringComparer.Ordinal)
        {
            ["صنعاء"] = "Sana'a",
            ["عدن"] = "Aden",
            ["تعز"] = "Taiz",
            ["الحديدة"] = "Al Hudaydah",
            ["إب"] = "Ibb",
            ["ذمار"] = "Dhamar",
            ["المكلا"] = "Mukalla",
            ["سيئون"] = "Seiyun",
            ["المهرة"] = "Al Mahrah",
            ["شبوة"] = "Shabwah",
            ["اليمن"] = "Yemen",
        };

        private static readonly Dictionary<string, string> AmenityNames = new(StringComparer.Ordinal)
        {
            ["Wi-Fi مجاني"] = "Free Wi-Fi",
            ["تكييف هواء"] = "Air Conditioning",
            ["تلفزيون"] = "Television",
            ["مطبخ مجهز"] = "Equipped Kitchen",
            ["غسالة ملابس"] = "Washing Machine",
            ["موقف سيارات مجاني"] = "Free Parking",
            ["مسبح"] = "Swimming Pool",
            ["حراسة أمنية"] = "Security Service",
            ["خدمة تنظيف يومية"] = "Daily Housekeeping",
            ["إفطار مجاني"] = "Free Breakfast",
            ["حديقة"] = "Garden",
            ["منطقة شواء"] = "BBQ Area",
            ["منطقة ألعاب أطفال"] = "Kids Play Area",
            ["صالة رياضية"] = "Gym",
            ["إطلالة بحرية"] = "Sea View",
            ["حمام خاص"] = "Private Bathroom",
            ["شرفة"] = "Balcony",
            ["مصعد"] = "Elevator",
            ["مناسب لذوي الاحتياجات الخاصة"] = "Accessible for Guests with Disabilities",
            ["يسمح بالحيوانات الأليفة"] = "Pet Friendly",
        };

        private static readonly Dictionary<string, string> AmenityDescriptions = new(StringComparer.Ordinal)
        {
            ["إنترنت لاسلكي مجاني"] = "Complimentary wireless internet access",
            ["مكيف هواء في جميع الغرف"] = "Air conditioning in all rooms",
            ["شاشة تلفزيون في الغرفة"] = "Television screen inside the room",
            ["مطبخ كامل مع الأجهزة"] = "Full kitchen with essential appliances",
            ["غسالة ملابس متاحة"] = "Laundry machine available for guests",
            ["موقف سيارات مجاني في الموقع"] = "Complimentary on-site parking",
            ["مسبح خاص أو مشترك"] = "Private or shared swimming pool",
            ["حراسة أمنية على مدار 24 ساعة"] = "24-hour security service",
            ["تنظيف يومي للغرف"] = "Daily room cleaning service",
            ["وجبة إفطار مجانية"] = "Complimentary breakfast meal",
            ["حديقة خارجية"] = "Outdoor garden area",
            ["منطقة شواء خارجية"] = "Outdoor barbecue zone",
            ["منطقة ألعاب للأطفال"] = "Play area dedicated to children",
            ["صالة رياضية مجهزة"] = "Equipped fitness room",
            ["إطلالة على البحر"] = "View overlooking the sea",
            ["حمام خاص في الغرفة"] = "Private bathroom inside the room",
            ["شرفة خاصة"] = "Private balcony",
            ["مصعد كهربائي"] = "Electric elevator",
            ["مرافق مخصصة لذوي الاحتياجات الخاصة"] = "Facilities tailored for guests with disabilities",
            ["مسموح إحضار الحيوانات الأليفة"] = "Pets are allowed on the property",
        };

        private static readonly Dictionary<string, string> PropertyTypeNames = new(StringComparer.Ordinal)
        {
            ["فندق"] = "Hotel",
            ["شاليه"] = "Chalet",
            ["استراحة"] = "Retreat",
            ["فيلا"] = "Villa",
            ["شقة"] = "Apartment",
        };

        private static readonly Dictionary<string, string> PropertyTypeDescriptions = new(StringComparer.Ordinal)
        {
            ["منشأة فندقية تقدم خدمات الإقامة"] = "Hospitality property that provides lodging services",
            ["شاليه أو منتجع"] = "Chalet or resort property",
            ["استراحة عائلية"] = "Family retreat property",
            ["فيلا أو منزل مستقل"] = "Villa or standalone house",
            ["شقة مفروشة"] = "Furnished apartment property",
        };

        private static readonly Dictionary<string, (string NameEn, string DescriptionAr, string DescriptionEn)> ServiceTemplates = new(StringComparer.Ordinal)
        {
            ["خدمة توصيل من وإلى المطار"] = ("Airport Transfer", "خدمة نقل مريحة بين العقار والمطار.", "Comfortable transfer service between the property and the airport."),
            ["إفطار"] = ("Breakfast", "وجبة إفطار يمكن إضافتها إلى الحجز.", "Breakfast service that can be added to the booking."),
            ["تنظيف إضافي"] = ("Extra Cleaning", "جلسة تنظيف إضافية أثناء فترة الإقامة.", "Additional housekeeping session during the stay."),
            ["غسيل ملابس"] = ("Laundry Service", "خدمة غسيل وكي للملابس عند الطلب.", "On-demand laundry and pressing service."),
            ["نقل داخلي"] = ("Local Transport", "خدمة تنقل داخل المدينة أو إلى المواقع القريبة.", "Transport service within the city or to nearby destinations."),
        };

        private static readonly Dictionary<Guid, (string NameEn, string AddressEn, string DescriptionEn)> PropertyContent = new()
        {
            [PropertySeeder.Property1Id] = ("Al Zahraa Hotel", "Al Zubairi Street, Old Sana'a", "An upscale hotel in the heart of Old Sana'a with beautiful views over the historic city."),
            [PropertySeeder.Property2Id] = ("Sea Resort", "Aden Corniche, Khormaksar", "A luxury beachfront resort with world-class services and integrated leisure facilities."),
            [PropertySeeder.Property3Id] = ("Palm Furnished Apartments", "Al Rawdah District, Taiz", "Family furnished apartments with high-quality finishes and modern facilities."),
            [PropertySeeder.Property4Id] = ("Jasmine Villa", "Haddah, Al Nasr Street", "A luxury villa for full rental, ideal for families and private occasions."),
            [PropertySeeder.Property5Id] = ("Mountain Retreat", "Wadi Dhahr, west of Sana'a", "A peaceful mountain retreat surrounded by nature, ideal for families."),
            [PropertySeeder.Property6Id] = ("Al Murjan Hotel", "Al Mualla, Aden", "An affordable hotel in a strategic location near the airport and port."),
            [PropertySeeder.Property7Id] = ("Tourist Valley Resort", "Wadi Al Dabab, Taiz", "A mountain resort with a stunning view over the green valley."),
            [PropertySeeder.Property8Id] = ("Al Saeed Furnished Apartments", "Taiz Street, New Sana'a", "Modern fully equipped furnished apartments suitable for long stays."),
            [PropertySeeder.Property9Id] = ("Red Sea Villa", "Gold Mohur, Aden", "A luxury beachfront villa with a private pool and VIP services."),
            [PropertySeeder.Property10Id] = ("Heritage Guest House", "Bab Al Yemen, Old Sana'a", "An authentic Yemeni heritage house with classic decor and modern hospitality."),
            [PropertySeeder.Property11Id] = ("Al Nahda Studios", "Jamal Street, Taiz", "Compact economical studios suitable for solo travelers."),
            [PropertySeeder.Property12Id] = ("Golden Palace Hotel", "Crater, Aden", "A premium hotel in the heart of the historic city center."),
            [PropertySeeder.Property13Id] = ("Countryside Chalets", "Haddah Area, north of Sana'a", "Independent chalets surrounded by green gardens and barbecue facilities."),
            [PropertySeeder.Property14Id] = ("Al Andalus Hotel Suites", "Al Mudhaffar, Taiz", "Spacious hotel suites with a separate living room and compact kitchen."),
            [PropertySeeder.Property15Id] = ("Coastal Tourism Resort", "Abyan Beach, Aden", "An upscale beach resort with full leisure facilities and water sports offerings."),
        };

        private static readonly Dictionary<string, string> UnitNames = new(StringComparer.Ordinal)
        {
            ["غرفة عادية 101"] = "Standard Room 101",
            ["غرفة ديلوكس 201"] = "Deluxe Room 201",
            ["جناح 301"] = "Suite 301",
            ["غرفة إطلالة بحرية 102"] = "Sea View Room 102",
            ["غرفة ديلوكس بإطلالة 202"] = "Deluxe View Room 202",
            ["جناح بريميوم 302"] = "Premium Suite 302",
            ["جناح رويال 401"] = "Royal Suite 401",
            ["استوديو A1"] = "Studio A1",
            ["شقة غرفة واحدة B2"] = "One-Bedroom Apartment B2",
            ["شقة غرفتين C3"] = "Two-Bedroom Apartment C3",
            ["فيلا عائلية"] = "Family Villa",
            ["فيلا فاخرة بمسبح"] = "Luxury Villa with Pool",
            ["استراحة الوادي"] = "Valley Retreat",
            ["استراحة الجبل الكبيرة"] = "Grand Mountain Retreat",
            ["غرفة اقتصادية 103"] = "Economy Room 103",
            ["غرفة ديلوكس 203"] = "Deluxe Room 203",
            ["جناح 303"] = "Suite 303",
            ["غرفة عادية 104"] = "Standard Room 104",
            ["غرفة ديلوكس بإطلالة جبلية 204"] = "Deluxe Mountain View Room 204",
            ["جناح الوادي 304"] = "Valley Suite 304",
            ["جناح بريميوم 404"] = "Premium Suite 404",
            ["جناح رويال 504"] = "Royal Suite 504",
            ["استوديو D1"] = "Studio D1",
            ["شقة غرفة واحدة E2"] = "One-Bedroom Apartment E2",
            ["شقة غرفتين F3"] = "Two-Bedroom Apartment F3",
            ["شقة عائلية G4"] = "Family Apartment G4",
            ["شاليه بحري A"] = "Seaside Chalet A",
            ["شاليه عائلي كبير B"] = "Large Family Chalet B",
            ["شاليه VIP بمسبح"] = "VIP Chalet with Pool",
            ["غرفة تراثية 105"] = "Heritage Room 105",
            ["غرفة تراثية ديلوكس 205"] = "Heritage Deluxe Room 205",
            ["جناح تراثي 305"] = "Heritage Suite 305",
            ["استوديو H1"] = "Studio H1",
            ["استوديو I2"] = "Studio I2",
            ["شقة غرفة واحدة J3"] = "One-Bedroom Apartment J3",
            ["شقة غرفتين K4"] = "Two-Bedroom Apartment K4",
            ["غرفة قياسية 106"] = "Standard Room 106",
            ["غرفة ديلوكس 206"] = "Deluxe Room 206",
            ["جناح فاخر 306"] = "Luxury Suite 306",
            ["جناح رويال 406"] = "Royal Suite 406",
            ["جناح بريزيدنتال 506"] = "Presidential Suite 506",
            ["شاليه الريف C"] = "Countryside Chalet C",
            ["شاليه عائلي D"] = "Family Chalet D",
            ["شاليه كبير E"] = "Large Chalet E",
            ["استوديو L1"] = "Studio L1",
            ["شقة غرفة واحدة M2"] = "One-Bedroom Apartment M2",
            ["شقة غرفتين N3"] = "Two-Bedroom Apartment N3",
            ["شقة عائلية O4"] = "Family Apartment O4",
            ["شقة فاخرة P5"] = "Luxury Apartment P5",
            ["شاليه بحري F"] = "Seaside Chalet F",
            ["شاليه عائلي بمسبح G"] = "Family Chalet with Pool G",
            ["شاليه VIP بإطلالة بحرية H"] = "VIP Sea View Chalet H",
        };

        private static readonly Dictionary<string, string> UnitTypeNames = new(StringComparer.Ordinal)
        {
            ["غرفة عادية"] = "Standard Room",
            ["غرفة ديلوكس"] = "Deluxe Room",
            ["جناح"] = "Suite",
            ["شاليه عادي"] = "Standard Chalet",
            ["شاليه عائلي كبير"] = "Large Family Chalet",
            ["استراحة عادية"] = "Standard Retreat",
            ["استراحة كبيرة"] = "Large Retreat",
            ["فيلا عادية"] = "Standard Villa",
            ["فيلا فاخرة"] = "Luxury Villa",
            ["استوديو"] = "Studio",
            ["شقة غرفة نوم واحدة"] = "One-Bedroom Apartment",
            ["شقة غرفتي نوم"] = "Two-Bedroom Apartment",
        };

        private static readonly Dictionary<string, string> UnitTypeDescriptions = new(StringComparer.Ordinal)
        {
            ["غرفة فندقية عادية"] = "Standard hotel room",
            ["غرفة فندقية ديلوكس"] = "Deluxe hotel room",
            ["جناح فندقي فاخر"] = "Luxury hotel suite",
            ["شاليه عائلي عادي"] = "Standard family chalet",
            ["شاليه عائلي كبير"] = "Large family chalet",
            ["استراحة عائلية عادية"] = "Standard family retreat",
            ["استراحة عائلية كبيرة"] = "Large family retreat",
            ["فيلا عائلية عادية"] = "Standard family villa",
            ["فيلا فاخرة"] = "Luxury villa",
            ["شقة استوديو"] = "Studio apartment",
            ["شقة بغرفة نوم واحدة"] = "Apartment with one bedroom",
            ["شقة بغرفتي نوم"] = "Apartment with two bedrooms",
        };

        private static readonly Dictionary<string, string> FieldDisplayNames = new(StringComparer.Ordinal)
        {
            ["مساحة الغرفة (م²)"] = "Room Area (m²)",
            ["إطلالة بحرية"] = "Sea View",
            ["نوع السرير"] = "Bed Type",
            ["عدد الأسرة"] = "Beds Count",
            ["مساحة الجناح (م²)"] = "Suite Area (m²)",
            ["عدد غرف النوم"] = "Bedrooms Count",
            ["يحتوي على صالة معيشة"] = "Includes Living Room",
            ["مساحة الشاليه (م²)"] = "Chalet Area (m²)",
            ["يحتوي على مسبح خاص"] = "Includes Private Pool",
            ["يحتوي على حديقة"] = "Includes Garden",
            ["مساحة الاستراحة (م²)"] = "Retreat Area (m²)",
            ["منطقة شواء"] = "BBQ Area",
            ["مساحة الفيلا (م²)"] = "Villa Area (m²)",
            ["مساحة الاستوديو (م²)"] = "Studio Area (m²)",
            ["يحتوي على مطبخ"] = "Includes Kitchen",
            ["مساحة الشقة (م²)"] = "Apartment Area (m²)",
            ["يحتوي على مطبخ كامل"] = "Includes Full Kitchen",
            ["عدد دورات المياه"] = "Bathrooms Count",
        };

        private static readonly Dictionary<string, string> FieldDescriptions = new(StringComparer.Ordinal)
        {
            ["مساحة الغرفة بالمتر المربع"] = "Room area measured in square meters",
            ["هل الغرفة لها إطلالة على البحر"] = "Whether the room overlooks the sea",
            ["نوع السرير المتوفر"] = "Available bed configuration",
            ["عدد الأسرة في الغرفة"] = "Number of beds inside the room",
            ["عدد غرف النوم"] = "Number of bedrooms",
            ["عدد الحمامات"] = "Number of bathrooms",
            ["حقل إضافي"] = "Additional field",
        };

        private static readonly Dictionary<string, string> PolicyDescriptions = new(StringComparer.Ordinal)
        {
            ["سياسة إلغاء مرنة: يمكن الإلغاء مجاناً قبل 48 ساعة من موعد تسجيل الوصول"] = "Flexible cancellation policy: free cancellation is available up to 48 hours before check-in.",
            ["يتطلب دفع مقدمة 20% عند الحجز، والباقي عند تسجيل الوصول"] = "A 20% deposit is required at booking, with the balance due at check-in.",
            ["تسجيل الوصول من الساعة 2 ظهراً، تسجيل المغادرة حتى 12 ظهراً"] = "Check-in starts at 2:00 PM and check-out is until 12:00 PM.",
            ["الأطفال أقل من 6 سنوات مجاناً، من 6-12 سنة بنصف السعر"] = "Children under 6 stay free, and ages 6 to 12 are charged half price.",
            ["لا يُسمح باصطحاب الحيوانات الأليفة"] = "Pets are not allowed.",
            ["يمكن تعديل الحجز مجاناً قبل 24 ساعة من موعد الوصول"] = "The booking can be modified free of charge up to 24 hours before arrival.",
            ["سياسة إلغاء صارمة: استرداد 50% إذا تم الإلغاء قبل 7 أيام"] = "Strict cancellation policy: a 50% refund is available if cancellation happens 7 days before arrival.",
            ["يتطلب الدفع الكامل عند تأكيد الحجز"] = "Full payment is required when confirming the booking.",
            ["تسجيل الوصول من 3 عصراً، المغادرة حتى 11 صباحاً"] = "Check-in starts at 3:00 PM and check-out is until 11:00 AM.",
            ["الأطفال أقل من 12 سنة مجاناً مع والديهم"] = "Children under 12 stay free with their parents.",
            ["يُسمح بالحيوانات الأليفة الصغيرة مقابل رسوم إضافية"] = "Small pets are allowed for an additional fee.",
            ["سياسة إلغاء معتدلة: إلغاء مجاني قبل 5 أيام، بعدها يُحتفظ بالمقدمة"] = "Moderate cancellation policy: free cancellation up to 5 days before arrival, after which the deposit is retained.",
            ["دفع مقدمة 30% عند الحجز، الباقي نقداً عند الوصول"] = "A 30% deposit is required at booking, with the balance payable in cash on arrival.",
            ["تسجيل الوصول مرن من 12 ظهراً إلى 10 مساءً"] = "Flexible check-in is available from 12:00 PM to 10:00 PM.",
            ["مرحب بالأطفال من جميع الأعمار، أطفال أقل من 3 سنوات مجاناً"] = "Children of all ages are welcome, and children under 3 stay free.",
            ["سياسة إلغاء شديدة الصرامة: لا استرداد للمبالغ المدفوعة"] = "Very strict cancellation policy: paid amounts are non-refundable.",
            ["الدفع الكامل مطلوب عند الحجز لتأكيد الحجز"] = "Full payment is required at booking to confirm the reservation.",
            ["تسجيل وصول مرن حسب الاتفاق المسبق"] = "Flexible check-in is available upon prior arrangement.",
            ["لا يُسمح بالحيوانات الأليفة مطلقاً"] = "Pets are strictly not allowed.",
            ["لا يمكن تعديل الحجز بعد التأكيد"] = "The booking cannot be modified after confirmation.",
            ["سياسة إلغاء مرنة جداً: إلغاء مجاني حتى 24 ساعة قبل الوصول"] = "Highly flexible cancellation policy: free cancellation is available up to 24 hours before arrival.",
            ["مقدمة رمزية 10% للحجز، الباقي عند الوصول"] = "A symbolic 10% deposit is required, with the balance due on arrival.",
            ["عائلي 100%: مرحب بالأطفال، ألعاب ومرافق خاصة متوفرة"] = "Family-focused policy: children are welcome and dedicated kids facilities are available.",
            ["يُسمح بالحيوانات الأليفة بدون رسوم إضافية"] = "Pets are allowed with no additional fee.",
            ["تعديل مجاني للحجز في أي وقت قبل 12 ساعة من الوصول"] = "The booking can be modified free of charge any time up to 12 hours before arrival.",
        };

        private static readonly Dictionary<string, string> TextReplacements = new(StringComparer.Ordinal)
        {
            ["بطاقة ائتمان"] = "Credit Card",
            ["نقداً"] = "Cash",
            ["تحويل بنكي"] = "Bank Transfer",
            ["متاح بطلب مسبق"] = "Available upon request",
            ["متاح مقابل رسوم"] = "Available for an extra fee",
            ["فقدان المقدمة"] = "Deposit is non-refundable",
            ["10 كجم"] = "10 kg",
            ["متوفرة عند الطلب"] = "Available upon request",
            ["حجز غير قابل للتعديل"] = "Non-modifiable booking",
            ["50% من سعر الليلة"] = "50% of the nightly rate",
            ["10% من قيمة الحجز"] = "10% of the booking value",
            ["للحفاظ على راحة جميع النزلاء"] = "To preserve the comfort of all guests",
        };

        public static void ApplyCityEnglish(City city)
        {
            city.NameEn = Translate(city.Name, CityNames);
            city.CountryEn = Translate(city.Country, CityNames);
        }

        public static void ApplyAmenityEnglish(Amenity amenity)
        {
            amenity.NameEn = Translate(amenity.Name, AmenityNames);
            amenity.DescriptionEn = Translate(amenity.Description, AmenityDescriptions);
        }

        public static void ApplyPropertyTypeEnglish(PropertyType propertyType)
        {
            propertyType.NameEn = Translate(propertyType.Name, PropertyTypeNames);
            propertyType.DescriptionEn = Translate(propertyType.Description, PropertyTypeDescriptions);
        }

        public static void ApplyServiceEnglish(PropertyService service)
        {
            if (!ServiceTemplates.TryGetValue(service.Name, out var content))
            {
                return;
            }

            service.NameEn = content.NameEn;
            service.Description ??= content.DescriptionAr;
            service.DescriptionEn = content.DescriptionEn;
        }

        public static void ApplyPropertyEnglish(Property property)
        {
            if (PropertyContent.TryGetValue(property.Id, out var content))
            {
                property.NameEn = content.NameEn;
                property.AddressEn = content.AddressEn;
                property.CityEn = Translate(property.City, CityNames);
                property.DescriptionEn = content.DescriptionEn;
            }

            property.ShortDescription ??= BuildShortDescription(property.Description);
            property.ShortDescriptionEn ??= BuildShortDescription(property.DescriptionEn ?? property.Description);
        }

        public static void ApplyUnitEnglish(Unit unit)
        {
            unit.NameEn = Translate(unit.Name, UnitNames);
            unit.CustomFeaturesEn ??= unit.CustomFeatures;
        }

        public static void ApplyUnitTypeEnglish(UnitType unitType)
        {
            unitType.NameEn = Translate(unitType.Name, UnitTypeNames);
            unitType.DescriptionEn = Translate(unitType.Description, UnitTypeDescriptions);
        }

        public static void ApplyFieldEnglish(UnitTypeField field)
        {
            field.DisplayNameEn = Translate(field.DisplayName, FieldDisplayNames);
            field.DescriptionEn = Translate(field.Description, FieldDescriptions);
            field.CategoryEn = TranslateCategory(field.Category);
            field.FieldOptionsEn = BuildFieldOptionsEn(field);
        }

        public static void ApplyPolicyEnglish(PropertyPolicy policy)
        {
            policy.DescriptionEn = Translate(policy.Description, PolicyDescriptions);
            policy.RulesEn = TranslateInlineText(policy.Rules);
            policy.CancellationPenaltyAfterDeadlineEn = TranslateInlineText(policy.CancellationPenaltyAfterDeadline);
            policy.CheckInEarlyCheckInNoteEn = TranslateInlineText(policy.CheckInEarlyCheckInNote);
            policy.CheckInLateCheckOutNoteEn = TranslateInlineText(policy.CheckInLateCheckOutNote);
            policy.CheckInLateCheckOutFeeEn = TranslateInlineText(policy.CheckInLateCheckOutFee);
            policy.ChildrenCribsNoteEn = TranslateInlineText(policy.ChildrenCribsNote);
            policy.PetsReasonEn = TranslateInlineText(policy.PetsReason);
            policy.PetsMaxWeightEn = TranslateInlineText(policy.PetsMaxWeight);
            policy.ModificationFeesAfterEn = TranslateInlineText(policy.ModificationFeesAfter);
            policy.ModificationReasonEn = TranslateInlineText(policy.ModificationReason);
        }

        private static string BuildShortDescription(string? description)
        {
            if (string.IsNullOrWhiteSpace(description))
            {
                return string.Empty;
            }

            var markerIndex = description.IndexOf('،');
            return markerIndex > 0 ? description[..markerIndex].Trim() : description.Trim();
        }

        private static string? BuildFieldOptionsEn(UnitTypeField field)
        {
            if (!string.IsNullOrWhiteSpace(field.FieldOptions))
            {
                return TranslateInlineText(field.FieldOptions);
            }

            return field.FieldName == "bed_type"
                ? "[\"Single Bed\",\"Double Bed\",\"Twin Beds\"]"
                : field.FieldOptions;
        }

        private static string TranslateCategory(string? category)
        {
            return category switch
            {
                "basic" => "Basic",
                "features" => "Features",
                "amenities" => "Amenities",
                _ => category ?? string.Empty,
            };
        }

        private static string Translate(string value, Dictionary<string, string> map)
        {
            return map.TryGetValue(value, out var translated) ? translated : value;
        }

        private static string? TranslateInlineText(string? value)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                return value;
            }

            var translated = value;
            foreach (var replacement in TextReplacements)
            {
                translated = translated.Replace(replacement.Key, replacement.Value, StringComparison.Ordinal);
            }

            return translated;
        }
    }
}
