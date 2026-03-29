using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using YemenBooking.Application.Features.SearchAndFilters.DTOs;
using YemenBooking.Application.Features.SearchAndFilters.Services;
using YemenBooking.Core.Entities;
using YemenBooking.Core.Indexing.Models;
using YemenBooking.Infrastructure.Data.Context;
using YemenBooking.Infrastructure.DependencyInjection;
using YemenBooking.Infrastructure.Postgres.Configuration;

namespace YemenBooking.Infrastructure.Postgres.Indexing;

/// <summary>
/// Builds live facets directly from PostgreSQL using the active search criteria.
/// يبني الفلاتر والعدادات الحية مباشرة من PostgreSQL وفق معايير البحث الحالية.
/// </summary>
public sealed class PostgresSearchFacetService : ISearchFacetService
{
    private readonly YemenBookingDbContext _context;
    private readonly IMemoryCache _cache;
    private readonly ILogger<PostgresSearchFacetService> _logger;
    private readonly SearchEngineOptions _searchEngineOptions;

    public PostgresSearchFacetService(
        YemenBookingDbContext context,
        IMemoryCache cache,
        ILogger<PostgresSearchFacetService> logger,
        SearchEngineOptions searchEngineOptions)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
        _cache = cache ?? throw new ArgumentNullException(nameof(cache));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        _searchEngineOptions = searchEngineOptions ?? new SearchEngineOptions();
    }

    public async Task<SearchFiltersDto> BuildFacetsAsync(
        PropertyWithUnitsSearchRequest request,
        CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(request);

        LogRequestSnapshot(request);

        Dictionary<string, decimal>? exchangeRates = null;
        if (request.MinPrice.HasValue || request.MaxPrice.HasValue || !string.IsNullOrWhiteSpace(request.PreferredCurrency))
        {
            exchangeRates = await GetExchangeRatesAsync(request.PreferredCurrency, cancellationToken);
        }

        var query = BuildCompleteQuery(request, exchangeRates);
        LogQuerySql("facets-base-query", query);

        var facets = new SearchFiltersDto();

        await PopulateCitiesAsync(query, facets, cancellationToken);
        await PopulatePropertyTypesAsync(query, facets, cancellationToken);
        await PopulateUnitTypesAsync(query, facets, cancellationToken);
        await PopulateAmenitiesAsync(query, facets, cancellationToken);
        await PopulateServicesAsync(query, facets, cancellationToken);
        await PopulateDynamicFieldsAsync(query, facets, cancellationToken);
        await PopulatePriceRangeAsync(query, request, exchangeRates, facets, cancellationToken);
        await PopulateDistanceRangeAsync(query, request, facets, cancellationToken);
        await PopulateCapacitiesAsync(query, facets, cancellationToken);
        await PopulateSupportedCurrenciesAsync(facets, cancellationToken);
        await PopulateStarRatingsAsync(query, facets, cancellationToken);

        facets.AvailableCities = facets.Cities.Select(city => city.Name).ToList();

        return facets;
    }

    private IQueryable<Unit> BuildCompleteQuery(
        UnitSearchRequest request,
        Dictionary<string, decimal>? exchangeRates = null)
    {
        var query = _context.Units
            .AsNoTracking()
            .Where(u => u.IsActive && !u.IsDeleted && u.Property.IsApproved && !u.Property.IsDeleted);

        if (!string.IsNullOrWhiteSpace(request.City))
        {
            query = query.Where(u =>
                EF.Functions.ILike((u.Property.City ?? string.Empty).Trim(), request.City.Trim()));
        }

        if (request.UnitTypeId.HasValue)
        {
            query = query.Where(u => u.UnitTypeId == request.UnitTypeId.Value);
        }

        if (request.PropertyTypeId.HasValue)
        {
            query = query.Where(u => u.Property.TypeId == request.PropertyTypeId.Value);
        }

        if (request.MinPrice.HasValue || request.MaxPrice.HasValue)
        {
            exchangeRates ??= new Dictionary<string, decimal> { ["YER"] = 1m };

            var minPrice = request.MinPrice ?? 0m;
            var maxPrice = request.MaxPrice ?? decimal.MaxValue;

            decimal? yerMin = null, yerMax = null;
            decimal? usdMin = null, usdMax = null;
            decimal? eurMin = null, eurMax = null;
            decimal? sarMin = null, sarMax = null;
            decimal? gbpMin = null, gbpMax = null;

            foreach (var rate in exchangeRates)
            {
                var currencyMin = minPrice * rate.Value;
                var currencyMax = maxPrice * rate.Value;
                switch (rate.Key.ToUpperInvariant())
                {
                    case "YER":
                        yerMin = currencyMin;
                        yerMax = currencyMax;
                        break;
                    case "USD":
                        usdMin = currencyMin;
                        usdMax = currencyMax;
                        break;
                    case "EUR":
                        eurMin = currencyMin;
                        eurMax = currencyMax;
                        break;
                    case "SAR":
                        sarMin = currencyMin;
                        sarMax = currencyMax;
                        break;
                    case "GBP":
                        gbpMin = currencyMin;
                        gbpMax = currencyMax;
                        break;
                }
            }

            if (request.CheckIn.HasValue && request.CheckOut.HasValue)
            {
                var checkIn = request.CheckIn.Value.Date;
                var checkOut = request.CheckOut.Value.Date;
                query = query.Where(u =>
                    PostgreSqlFunctionsConfiguration.CheckUnitPriceInRange(
                        u.Id,
                        checkIn,
                        checkOut,
                        yerMin, yerMax,
                        usdMin, usdMax,
                        eurMin, eurMax,
                        sarMin, sarMax,
                        gbpMin, gbpMax));
            }
            else
            {
                query = query.Where(u =>
                    PostgreSqlFunctionsConfiguration.CheckUnitAnyPriceInRange(
                        u.Id,
                        yerMin, yerMax,
                        usdMin, usdMax,
                        eurMin, eurMax,
                        sarMin, sarMax,
                        gbpMin, gbpMax));
            }
        }

        if (request.MinRating.HasValue)
        {
            query = query.Where(u => u.Property.AverageRating >= request.MinRating.Value);
        }

        if (request.MinStarRating.HasValue)
        {
            query = query.Where(u => u.Property.StarRating >= request.MinStarRating.Value);
        }

        if (request.FeaturedOnly == true)
        {
            query = query.Where(u => u.Property.IsFeatured);
        }

        if (request.GuestsCount.HasValue && request.GuestsCount.Value > 0)
        {
            query = query.Where(u => u.MaxCapacity >= request.GuestsCount.Value);
        }
        else if (request.AdultsCount.HasValue || request.ChildrenCount.HasValue)
        {
            var totalGuests = Math.Max(0, request.AdultsCount ?? 0) + Math.Max(0, request.ChildrenCount ?? 0);
            if (totalGuests > 0)
            {
                query = query.Where(u => u.MaxCapacity >= totalGuests);
            }
        }

        if (request.RequiredAmenities != null && request.RequiredAmenities.Any())
        {
            var requiredAmenityIds = request.RequiredAmenities.Distinct().ToList();
            var minimumAmenityMatches = request.MinimumAmenityMatches.HasValue
                ? Math.Max(1, Math.Min(request.MinimumAmenityMatches.Value, requiredAmenityIds.Count))
                : requiredAmenityIds.Count;

            if (minimumAmenityMatches >= requiredAmenityIds.Count)
            {
                foreach (var amenityId in requiredAmenityIds)
                {
                    var currentAmenityId = amenityId;
                    query = query.Where(u => u.Property.Amenities.Any(a => a.PropertyTypeAmenity.AmenityId == currentAmenityId));
                }
            }
            else
            {
                query = query.Where(u =>
                    u.Property.Amenities.Count(a => requiredAmenityIds.Contains(a.PropertyTypeAmenity.AmenityId)) >=
                    minimumAmenityMatches);
            }
        }

        if (request.RequiredServices != null && request.RequiredServices.Any())
        {
            var requiredServiceIds = request.RequiredServices.Distinct().ToList();
            query = query.Where(u => u.Property.Services.Any(service => requiredServiceIds.Contains(service.Id)));
        }

        if (request.DynamicFieldFilters != null && request.DynamicFieldFilters.Any())
        {
            foreach (var filter in request.DynamicFieldFilters.Where(filter => !string.IsNullOrWhiteSpace(filter.Key) && !string.IsNullOrWhiteSpace(filter.Value)))
            {
                var fieldName = filter.Key.Trim();
                var fieldValue = filter.Value.Trim();

                if (fieldValue.StartsWith("~", StringComparison.Ordinal))
                {
                    var searchValue = fieldValue[1..].Trim();
                    if (string.IsNullOrWhiteSpace(searchValue))
                    {
                        continue;
                    }

                    query = query.Where(u => u.FieldValues.Any(fv =>
                        fv.UnitTypeField != null &&
                        fv.UnitTypeField.FieldName == fieldName &&
                        EF.Functions.ILike(fv.FieldValue, $"%{searchValue}%")));
                    continue;
                }

                if (fieldValue.Contains("..", StringComparison.Ordinal))
                {
                    var parts = fieldValue.Split("..", StringSplitOptions.TrimEntries);
                    if (parts.Length == 2 &&
                        decimal.TryParse(parts[0], out var min) &&
                        decimal.TryParse(parts[1], out var max))
                    {
                        query = query.Where(u => u.FieldValues.Any(fv =>
                            fv.UnitTypeField != null &&
                            fv.UnitTypeField.FieldName == fieldName &&
                            PostgreSqlFunctionsConfiguration.IsNumericInRange(fv.FieldValue, min, max)));
                    }

                    continue;
                }

                query = query.Where(u => u.FieldValues.Any(fv =>
                    fv.UnitTypeField != null &&
                    fv.UnitTypeField.FieldName == fieldName &&
                    fv.FieldValue == fieldValue));
            }
        }

        if (!string.IsNullOrWhiteSpace(request.SearchText))
        {
            var searchText = request.SearchText.Trim();
            query = query.Where(u =>
                EF.Functions.ToTsVector(
                    "simple",
                    (u.Name ?? string.Empty) + " " +
                    (u.Property.Name ?? string.Empty) + " " +
                    (u.Property.Description ?? string.Empty) + " " +
                    (u.Property.Address ?? string.Empty) + " " +
                    (u.Property.City ?? string.Empty) + " " +
                    (u.UnitType.Name ?? string.Empty))
                .Matches(EF.Functions.WebSearchToTsQuery("simple", searchText))
                || EF.Functions.ILike(u.Name, $"%{searchText}%")
                || EF.Functions.ILike(u.Property.Name, $"%{searchText}%")
                || EF.Functions.ILike(u.Property.Description ?? string.Empty, $"%{searchText}%")
                || EF.Functions.ILike(u.Property.City ?? string.Empty, $"%{searchText}%")
                || EF.Functions.ILike(u.Property.Address ?? string.Empty, $"%{searchText}%"));
        }

        if (request.Latitude.HasValue && request.Longitude.HasValue && request.RadiusKm.HasValue)
        {
            var userLat = (double)request.Latitude.Value;
            var userLng = (double)request.Longitude.Value;
            var radiusKm = request.RadiusKm.Value;

            query = query.Where(u =>
                PostgreSqlFunctionsConfiguration.CalculateDistanceKm(
                    userLat,
                    userLng,
                    (double)u.Property.Latitude,
                    (double)u.Property.Longitude) <= radiusKm);
        }

        if (request.CheckIn.HasValue && request.CheckOut.HasValue)
        {
            var checkIn = request.CheckIn.Value.Date;
            var rangeEndExclusive = request.CheckOut.Value.Date > checkIn
                ? request.CheckOut.Value.Date
                : checkIn.AddDays(1);

            query = query.Where(u => !_context.DailyUnitSchedules.Any(ds =>
                ds.UnitId == u.Id &&
                ds.Status != "Available" &&
                ds.Date >= checkIn &&
                ds.Date < rangeEndExclusive &&
                (ds.BookingId == null ||
                 ds.Booking == null ||
                 (ds.Date >= ds.Booking.CheckIn.Date && ds.Date < ds.Booking.CheckOut.Date))));
        }

        return query;
    }

    private async Task PopulateCitiesAsync(IQueryable<Unit> query, SearchFiltersDto facets, CancellationToken cancellationToken)
    {
        var cityQuery = query
            .Select(u => new
            {
                PropertyIdText = u.PropertyId.ToString(),
                u.Property.City
            })
            .Distinct()
            .GroupBy(x => x.City)
            .Select(group => new
            {
                Name = group.Key,
                PropertiesCount = group.Select(x => x.PropertyIdText).Distinct().Count()
            })
            .OrderBy(city => city.Name);

        LogQuerySql("facets-cities", cityQuery);

        var cityRows = await cityQuery.ToListAsync(cancellationToken);
        facets.Cities = cityRows
            .Select(city => new CityFilterDto
            {
                Id = Guid.Empty,
                Name = city.Name ?? string.Empty,
                PropertiesCount = city.PropertiesCount
            })
            .ToList();
    }

    private async Task PopulatePropertyTypesAsync(IQueryable<Unit> query, SearchFiltersDto facets, CancellationToken cancellationToken)
    {
        var propertyTypesQuery = query
            .Select(u => new
            {
                PropertyIdText = u.PropertyId.ToString(),
                TypeIdText = u.Property.TypeId.ToString(),
                TypeName = u.Property.PropertyType.Name
            })
            .Distinct()
            .GroupBy(x => new { x.TypeIdText, x.TypeName })
            .Select(group => new
            {
                group.Key.TypeIdText,
                Name = group.Key.TypeName ?? string.Empty,
                PropertiesCount = group.Select(x => x.PropertyIdText).Distinct().Count()
            })
            .OrderBy(type => type.Name);

        LogQuerySql("facets-property-types", propertyTypesQuery);

        var propertyTypeRows = await propertyTypesQuery.ToListAsync(cancellationToken);
        facets.PropertyTypes = propertyTypeRows
            .Select(type => new PropertyTypeFilterDto
            {
                Id = ParseGuidOrEmpty(type.TypeIdText),
                Name = type.Name,
                PropertiesCount = type.PropertiesCount
            })
            .ToList();
    }

    private async Task PopulateUnitTypesAsync(IQueryable<Unit> query, SearchFiltersDto facets, CancellationToken cancellationToken)
    {
        var unitTypesQuery = query
            .GroupBy(u => new
            {
                UnitTypeIdText = u.UnitTypeId.ToString(),
                Name = u.UnitType.Name,
                NameEn = u.UnitType.NameEn,
                PropertyTypeIdText = u.Property.TypeId.ToString(),
                u.UnitType.IsHasAdults,
                u.UnitType.IsHasChildren,
                u.UnitType.IsMultiDays,
                u.UnitType.IsRequiredToDetermineTheHour
            })
            .Select(group => new
            {
                group.Key.UnitTypeIdText,
                Name = group.Key.Name ?? string.Empty,
                NameEn = group.Key.NameEn,
                group.Key.PropertyTypeIdText,
                UnitsCount = group.Count(),
                IsHasAdults = group.Key.IsHasAdults,
                IsHasChildren = group.Key.IsHasChildren,
                IsMultiDays = group.Key.IsMultiDays,
                IsRequiredToDetermineTheHour = group.Key.IsRequiredToDetermineTheHour
            })
            .OrderBy(type => type.Name);

        LogQuerySql("facets-unit-types", unitTypesQuery);

        var unitTypeRows = await unitTypesQuery.ToListAsync(cancellationToken);
        facets.UnitTypes = unitTypeRows
            .Select(type => new UnitTypeFilterDto
            {
                Id = ParseGuidOrEmpty(type.UnitTypeIdText),
                Name = type.Name,
                NameEn = type.NameEn,
                PropertyTypeId = ParseGuidOrEmpty(type.PropertyTypeIdText),
                UnitsCount = type.UnitsCount,
                IsHasAdults = type.IsHasAdults,
                IsHasChildren = type.IsHasChildren,
                IsMultiDays = type.IsMultiDays,
                IsRequiredToDetermineTheHour = type.IsRequiredToDetermineTheHour
            })
            .ToList();
    }

    private async Task PopulateAmenitiesAsync(IQueryable<Unit> query, SearchFiltersDto facets, CancellationToken cancellationToken)
    {
        var amenitiesQuery = query
            .SelectMany(u => u.Property.Amenities.Select(amenity => new
            {
                PropertyIdText = amenity.PropertyId.ToString(),
                AmenityIdText = amenity.PropertyTypeAmenity.AmenityId.ToString(),
                AmenityName = amenity.PropertyTypeAmenity.Amenity.Name,
                AmenityIcon = amenity.PropertyTypeAmenity.Amenity.Icon,
                PropertyTypeIdText = u.Property.TypeId.ToString()
            }))
            .Distinct()
            .GroupBy(x => new { x.AmenityIdText, x.AmenityName, x.AmenityIcon })
            .Select(group => new
            {
                group.Key.AmenityIdText,
                Name = group.Key.AmenityName ?? string.Empty,
                Category = "عام",
                Icon = group.Key.AmenityIcon ?? string.Empty,
                PropertiesCount = group.Select(x => x.PropertyIdText).Distinct().Count(),
                PropertyTypeIds = group.Select(x => x.PropertyTypeIdText).Distinct().ToList()
            })
            .OrderBy(amenity => amenity.Name);

        LogQuerySql("facets-amenities", amenitiesQuery);

        var amenityRows = await amenitiesQuery.ToListAsync(cancellationToken);
        facets.Amenities = amenityRows
            .Select(amenity => new AmenityFilterDto
            {
                Id = ParseGuidOrEmpty(amenity.AmenityIdText),
                Name = amenity.Name,
                Category = amenity.Category,
                Icon = amenity.Icon,
                PropertiesCount = amenity.PropertiesCount,
                PropertyTypeIds = amenity.PropertyTypeIds
                    .Select(ParseGuidOrEmpty)
                    .Where(id => id != Guid.Empty)
                    .Distinct()
                    .ToList()
            })
            .ToList();
    }

    private async Task PopulateServicesAsync(IQueryable<Unit> query, SearchFiltersDto facets, CancellationToken cancellationToken)
    {
        var servicesQuery = query
            .SelectMany(u => u.Property.Services.Select(service => new
            {
                IdText = service.Id.ToString(),
                service.Name,
                service.NameEn,
                service.Icon,
                PropertyIdText = service.PropertyId.ToString()
            }))
            .Distinct()
            .GroupBy(x => new { x.IdText, x.Name, x.NameEn, x.Icon })
            .Select(group => new
            {
                group.Key.IdText,
                Name = group.Key.Name ?? string.Empty,
                NameEn = group.Key.NameEn,
                Icon = group.Key.Icon ?? string.Empty,
                PropertiesCount = group.Select(x => x.PropertyIdText).Distinct().Count()
            })
            .OrderBy(service => service.Name);

        LogQuerySql("facets-services", servicesQuery);

        var serviceRows = await servicesQuery.ToListAsync(cancellationToken);
        facets.Services = serviceRows
            .Select(service => new ServiceFilterDto
            {
                Id = ParseGuidOrEmpty(service.IdText),
                Name = service.Name,
                NameEn = service.NameEn,
                Icon = service.Icon,
                PropertiesCount = service.PropertiesCount
            })
            .ToList();
    }

    private async Task PopulateDynamicFieldsAsync(IQueryable<Unit> query, SearchFiltersDto facets, CancellationToken cancellationToken)
    {
        var dynamicFieldsQuery = query
            .SelectMany(u => u.FieldValues.Select(fieldValue => new
            {
                PropertyIdText = u.PropertyId.ToString(),
                FieldName = fieldValue.UnitTypeField != null ? fieldValue.UnitTypeField.FieldName : string.Empty,
                DisplayName = fieldValue.UnitTypeField != null
                    ? (fieldValue.UnitTypeField.DisplayName ?? fieldValue.UnitTypeField.FieldName)
                    : string.Empty,
                fieldValue.FieldValue
            }))
            .Where(x => !string.IsNullOrWhiteSpace(x.FieldName) && !string.IsNullOrWhiteSpace(x.FieldValue))
            .Distinct()
            .GroupBy(x => new { x.FieldName, x.DisplayName, x.FieldValue })
            .Select(group => new DynamicFieldValueFilterDto
            {
                FieldName = group.Key.FieldName,
                DisplayName = string.IsNullOrWhiteSpace(group.Key.DisplayName)
                    ? group.Key.FieldName
                    : group.Key.DisplayName,
                Value = group.Key.FieldValue,
                Count = group.Select(x => x.PropertyIdText).Distinct().Count()
            })
            .OrderBy(field => field.DisplayName)
            .ThenBy(field => field.Value);

        LogQuerySql("facets-dynamic-fields", dynamicFieldsQuery);
        facets.DynamicFieldValues = await dynamicFieldsQuery.ToListAsync(cancellationToken);
    }

    private async Task PopulatePriceRangeAsync(
        IQueryable<Unit> query,
        PropertyWithUnitsSearchRequest request,
        Dictionary<string, decimal>? exchangeRates,
        SearchFiltersDto facets,
        CancellationToken cancellationToken)
    {
        var effectiveCurrency = string.IsNullOrWhiteSpace(request.PreferredCurrency)
            ? await _context.Currencies.AsNoTracking().Where(currency => currency.IsDefault).Select(currency => currency.Code).FirstOrDefaultAsync(cancellationToken) ?? "YER"
            : request.PreferredCurrency!.ToUpperInvariant();

        var checkIn = request.CheckIn?.Date;
        var checkOut = request.CheckOut?.Date;
        var rangeEndExclusive = checkIn.HasValue && checkOut.HasValue && checkOut.Value > checkIn.Value
            ? checkOut.Value
            : checkIn?.AddDays(1);

        var priceCandidatesQuery = query
            .Select(unit => new
            {
                UnitId = unit.Id,
                Price = checkIn.HasValue && rangeEndExclusive.HasValue
                    ? _context.DailyUnitSchedules
                        .Where(schedule =>
                            schedule.UnitId == unit.Id &&
                            schedule.Date >= checkIn.Value &&
                            schedule.Date < rangeEndExclusive.Value &&
                            schedule.PriceAmount.HasValue &&
                            schedule.Status == "Available")
                        .Average(schedule => (decimal?)schedule.PriceAmount) ?? 0m
                    : _context.DailyUnitSchedules
                        .Where(schedule =>
                            schedule.UnitId == unit.Id &&
                            schedule.Date >= DateTime.UtcNow.Date &&
                            schedule.PriceAmount.HasValue &&
                            schedule.Status == "Available")
                        .Min(schedule => (decimal?)schedule.PriceAmount) ?? 0m,
                Currency = _context.DailyUnitSchedules
                    .Where(schedule => schedule.UnitId == unit.Id && schedule.PriceAmount.HasValue)
                    .OrderBy(schedule => schedule.Date)
                    .Select(schedule => schedule.Currency)
                    .FirstOrDefault() ?? unit.Property.Currency ?? "YER"
            })
            .Where(candidate => candidate.Price > 0);

        LogQuerySql("facets-price-range", priceCandidatesQuery);
        var priceCandidates = await priceCandidatesQuery.ToListAsync(cancellationToken);

        if (!priceCandidates.Any())
        {
            facets.PriceRange = new PriceRangeDto();
            return;
        }

        var convertedPrices = priceCandidates
            .Select(candidate => ConvertAmount(candidate.Price, candidate.Currency, effectiveCurrency, exchangeRates))
            .Where(amount => amount > 0)
            .ToList();

        if (!convertedPrices.Any())
        {
            facets.PriceRange = new PriceRangeDto();
            return;
        }

        facets.PriceRange = new PriceRangeDto
        {
            MinPrice = convertedPrices.Min(),
            MaxPrice = convertedPrices.Max(),
            AveragePrice = convertedPrices.Average()
        };
    }

    private async Task PopulateDistanceRangeAsync(
        IQueryable<Unit> query,
        PropertyWithUnitsSearchRequest request,
        SearchFiltersDto facets,
        CancellationToken cancellationToken)
    {
        if (!request.Latitude.HasValue || !request.Longitude.HasValue)
        {
            facets.DistanceRange = new DistanceRangeDto();
            return;
        }

        var originLat = (double)request.Latitude.Value;
        var originLng = (double)request.Longitude.Value;

        var distancesQuery = query
            .Select(u => new
            {
                PropertyIdText = u.PropertyId.ToString(),
                Distance = PostgreSqlFunctionsConfiguration.CalculateDistanceKm(
                    originLat,
                    originLng,
                    (double)u.Property.Latitude,
                    (double)u.Property.Longitude)
            })
            .Distinct()
            .Select(x => x.Distance);

        LogQuerySql("facets-distance-range", distancesQuery);
        var distances = await distancesQuery.ToListAsync(cancellationToken);

        facets.DistanceRange = distances.Any()
            ? new DistanceRangeDto
            {
                MinDistance = distances.Min(),
                MaxDistance = distances.Max()
            }
            : new DistanceRangeDto();
    }

    private async Task PopulateCapacitiesAsync(IQueryable<Unit> query, SearchFiltersDto facets, CancellationToken cancellationToken)
    {
        var capacitiesQuery = query
            .Select(u => (int?)u.MaxCapacity)
            ;

        LogQuerySql("facets-capacity", capacitiesQuery);
        facets.MaxGuestCapacity = await capacitiesQuery.MaxAsync(cancellationToken) ?? 0;
    }

    private async Task PopulateSupportedCurrenciesAsync(SearchFiltersDto facets, CancellationToken cancellationToken)
    {
        var currenciesQuery = _context.Currencies
            .AsNoTracking()
            .OrderByDescending(currency => currency.IsDefault)
            .ThenBy(currency => currency.Code)
            .Select(currency => currency.Code);

        LogQuerySql("facets-supported-currencies", currenciesQuery);
        facets.SupportedCurrencies = await currenciesQuery.ToListAsync(cancellationToken);
    }

    private async Task PopulateStarRatingsAsync(IQueryable<Unit> query, SearchFiltersDto facets, CancellationToken cancellationToken)
    {
        var starRatingsQuery = query
            .Select(u => new
            {
                PropertyIdText = u.PropertyId.ToString(),
                u.Property.StarRating
            })
            .Distinct()
            .Where(x => x.StarRating > 0)
            .GroupBy(x => x.StarRating)
            .Select(group => new StarRatingFilterDto
            {
                Value = group.Key,
                PropertiesCount = group.Select(x => x.PropertyIdText).Distinct().Count()
            })
            .OrderBy(option => option.Value)
            ;

        LogQuerySql("facets-star-ratings", starRatingsQuery);
        facets.StarRatingOptions = await starRatingsQuery.ToListAsync(cancellationToken);

        facets.StarRatings = facets.StarRatingOptions.Select(option => option.Value).ToList();
    }

    private async Task<Dictionary<string, decimal>> GetExchangeRatesAsync(
        string? searchCurrency,
        CancellationToken cancellationToken)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(searchCurrency))
            {
                searchCurrency = await _context.Currencies
                    .AsNoTracking()
                    .Where(currency => currency.IsDefault)
                    .Select(currency => currency.Code)
                    .FirstOrDefaultAsync(cancellationToken) ?? "YER";
            }

            var cacheKey = $"FacetExchangeRates_{searchCurrency}";
            if (_cache.TryGetValue(cacheKey, out Dictionary<string, decimal>? cachedRates) &&
                cachedRates != null &&
                cachedRates.Any())
            {
                return cachedRates;
            }

            var currencies = await _context.Currencies
                .AsNoTracking()
                .Where(currency => currency.ExchangeRate.HasValue || currency.IsDefault)
                .Select(currency => new
                {
                    currency.Code,
                    currency.ExchangeRate,
                    currency.IsDefault
                })
                .ToListAsync(cancellationToken);

            var defaultCurrency = currencies.FirstOrDefault(currency => currency.IsDefault);
            if (defaultCurrency == null)
            {
                return new Dictionary<string, decimal> { ["YER"] = 1m };
            }

            var rates = new Dictionary<string, decimal>(StringComparer.OrdinalIgnoreCase);

            if (string.Equals(searchCurrency, defaultCurrency.Code, StringComparison.OrdinalIgnoreCase))
            {
                foreach (var currency in currencies)
                {
                    if (currency.IsDefault)
                    {
                        rates[currency.Code] = 1m;
                    }
                    else if (currency.ExchangeRate.HasValue && currency.ExchangeRate.Value > 0)
                    {
                        rates[currency.Code] = 1m / currency.ExchangeRate.Value;
                    }
                }
            }
            else
            {
                var searchCurrencyItem = currencies.FirstOrDefault(currency =>
                    string.Equals(currency.Code, searchCurrency, StringComparison.OrdinalIgnoreCase));

                if (searchCurrencyItem == null || !searchCurrencyItem.ExchangeRate.HasValue || searchCurrencyItem.ExchangeRate.Value <= 0)
                {
                    rates[defaultCurrency.Code] = 1m;
                    return rates;
                }

                var searchCurrencyRate = searchCurrencyItem.ExchangeRate.Value;
                foreach (var currency in currencies)
                {
                    if (string.Equals(currency.Code, searchCurrency, StringComparison.OrdinalIgnoreCase))
                    {
                        rates[currency.Code] = 1m;
                    }
                    else if (currency.IsDefault)
                    {
                        rates[currency.Code] = searchCurrencyRate;
                    }
                    else if (currency.ExchangeRate.HasValue && currency.ExchangeRate.Value > 0)
                    {
                        rates[currency.Code] = searchCurrencyRate / currency.ExchangeRate.Value;
                    }
                }
            }

            if (!rates.Any())
            {
                rates["YER"] = 1m;
            }

            _cache.Set(
                cacheKey,
                rates,
                new MemoryCacheEntryOptions
                {
                    AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(30),
                    SlidingExpiration = TimeSpan.FromMinutes(15)
                });

            return rates;
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Unable to build exchange rates for facets. Falling back to YER.");
            return new Dictionary<string, decimal> { ["YER"] = 1m };
        }
    }

    private static decimal ConvertAmount(
        decimal amount,
        string? sourceCurrency,
        string targetCurrency,
        IReadOnlyDictionary<string, decimal>? exchangeRates)
    {
        if (amount <= 0)
        {
            return 0m;
        }

        if (string.IsNullOrWhiteSpace(sourceCurrency) ||
            string.Equals(sourceCurrency, targetCurrency, StringComparison.OrdinalIgnoreCase) ||
            exchangeRates == null ||
            !exchangeRates.Any())
        {
            return amount;
        }

        return exchangeRates.TryGetValue(sourceCurrency.ToUpperInvariant(), out var rate)
            ? amount / rate
            : amount;
    }

    private static Guid ParseGuidOrEmpty(string? value)
        => Guid.TryParse(value, out var parsed) ? parsed : Guid.Empty;

    private void LogRequestSnapshot(PropertyWithUnitsSearchRequest request)
    {
        if (!_searchEngineOptions.EnableDetailedLogging)
        {
            return;
        }

        try
        {
            _logger.LogInformation("🧾 facets request: {RequestJson}", JsonSerializer.Serialize(request));
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Unable to serialize facets request snapshot");
        }
    }

    private void LogQuerySql(string label, IQueryable query)
    {
        if (!_searchEngineOptions.EnableDetailedLogging)
        {
            return;
        }

        try
        {
            _logger.LogInformation("🧾 SQL [{Label}]:\n{Sql}", label, query.ToQueryString());
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Unable to render facets SQL for {Label}", label);
        }
    }
}
