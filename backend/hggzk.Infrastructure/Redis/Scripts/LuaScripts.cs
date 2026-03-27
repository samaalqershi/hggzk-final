namespace YemenBooking.Infrastructure.Redis.Scripts;

/// <summary>
/// Optimized Lua scripts for Redis search and filtering.
/// سكربتات Lua المحسّنة لعمليات البحث والفلترة على Redis.
/// </summary>
public static class LuaScripts
{
    #region === البحث المحسّن عن الوحدات المتاحة ===
    
    /// <summary>
    /// Returns available units while excluding blocked ones.
    /// يعيد الوحدات المتاحة مع استثناء الوحدات المحجوزة.
    /// </summary>
    public const string SearchAvailableUnitsScript = @"
        local unitsIndex = KEYS[1]
        local availIndex = KEYS[2]
        local unitsQuery = ARGV[1]
        local availQuery = ARGV[2]
        local limit = tonumber(ARGV[3]) or 100
        
        -- 1. Find blocked units. / 1. البحث عن الوحدات المحجوزة.
        local blockedResult = redis.call('FT.SEARCH', availIndex, availQuery, 'NOCONTENT', 'LIMIT', '0', '10000')
        
        local blockedUnits = {}
        if blockedResult and #blockedResult > 1 then
            -- Result shape: [totalCount, key1, key2, ...] / النتيجة: [totalCount, key1, key2, ...]
            for i = 2, #blockedResult do
                local key = blockedResult[i]
                -- Extract unitId from the key (period:avail:{id}). / استخراج unitId من المفتاح.
                local fields = redis.call('HGET', key, 'unitId')
                if fields then
                    blockedUnits[fields] = true
                end
            end
        end
        
        -- 2. Search units. / البحث في الوحدات.
        local unitsResult = redis.call('FT.SEARCH', unitsIndex, unitsQuery, 'LIMIT', '0', tostring(limit * 2))
        
        local availableUnits = {}
        if unitsResult and #unitsResult > 1 then
            -- Result shape: [totalCount, key1, fields1, key2, fields2, ...] / النتيجة: [...]
            for i = 2, #unitsResult, 2 do
                if i + 1 <= #unitsResult then
                    local key = unitsResult[i]
                    local fields = unitsResult[i + 1]
                    
                    -- Extract unitId. / استخراج unitId.
                    local unitId = nil
                    for j = 1, #fields, 2 do
                        if fields[j] == 'unitId' then
                            unitId = fields[j + 1]
                            break
                        end
                    end
                    
                    -- Keep only non-blocked units. / الاحتفاظ بالوحدات غير المحجوزة.
                    if unitId and not blockedUnits[unitId] then
                        table.insert(availableUnits, key)
                        if #availableUnits >= limit then
                            break
                        end
                    end
                end
            end
        end
        
        return availableUnits
    ";
    
    #endregion
    
    #region === حساب الأسعار الجماعي (Batch) ===
    
    /// <summary>
    /// Calculates prices for a batch of units.
    /// يحسب الأسعار لمجموعة من الوحدات دفعة واحدة.
    /// </summary>
    public const string BatchCalculatePricesScript = @"
        local pricingIndex = KEYS[1]
        local unitIdsStr = ARGV[1]
        local checkInTs = tonumber(ARGV[2])
        local checkOutTs = tonumber(ARGV[3])
        
        -- Split unit IDs. / تقسيم معرفات الوحدات.
        local function split(str, delimiter)
            local result = {}
            for match in (str..delimiter):gmatch('(.-)'..delimiter) do
                table.insert(result, match)
            end
            return result
        end
        
        local unitIds = split(unitIdsStr, ',')
        local results = {}
        
        -- لكل وحدة، البحث عن فترات التسعير
        for _, unitId in ipairs(unitIds) do
            local query = '@unitId:{' .. unitId .. '} @startDateTs:[-inf ' .. checkOutTs .. '] @endDateTs:[' .. checkInTs .. ' +inf]'
            
            local pricingResult = redis.call('FT.SEARCH', pricingIndex, query, 'LIMIT', '0', '100')
            
            local periods = {}
            if pricingResult and #pricingResult > 1 then
                for i = 2, #pricingResult, 2 do
                    if i + 1 <= #pricingResult then
                        local fields = pricingResult[i + 1]
                        
                        local period = {}
                        for j = 1, #fields, 2 do
                            local fieldName = fields[j]
                            local fieldValue = fields[j + 1]
                            
                            if fieldName == 'startDateTs' then
                                period.startTs = tonumber(fieldValue)
                            elseif fieldName == 'endDateTs' then
                                period.endTs = tonumber(fieldValue)
                            elseif fieldName == 'price' then
                                period.price = tonumber(fieldValue)
                            end
                        end
                        
                        if period.startTs and period.endTs and period.price then
                            table.insert(periods, period)
                        end
                    end
                end
            end
            
            -- Compute the total price. / حساب السعر الإجمالي.
            local totalPrice = 0
            local daySeconds = 86400
            local numberOfDays = math.floor((checkOutTs - checkInTs) / daySeconds)
            
            if #periods > 0 then
                -- Compute the price for each day. / حساب السعر لكل يوم.
                for day = 0, numberOfDays - 1 do
                    local dayStartTs = checkInTs + (day * daySeconds)
                    local dayEndTs = dayStartTs + daySeconds
                    
                    local dailyPrice = 0
                    local foundPrice = false
                    
                    -- Find the matching price for the day. / البحث عن السعر المناسب لهذا اليوم.
                    for _, period in ipairs(periods) do
                        if dayStartTs >= period.startTs and dayStartTs < period.endTs then
                            dailyPrice = period.price
                            foundPrice = true
                            break
                        end
                    end
                    
                    -- If no price is found, fallback happens in C#. / إن لم يوجد سعر، تتم المعالجة في C#.
                    if foundPrice then
                        totalPrice = totalPrice + dailyPrice
                    end
                end
            end
            
            results[unitId] = tostring(totalPrice)
        end
        
        -- Convert the results to an array. / تحويل النتائج إلى مصفوفة.
        local output = {}
        for unitId, price in pairs(results) do
            table.insert(output, unitId)
            table.insert(output, price)
        end
        
        return output
    ";
    
    #endregion
    
    #region === التقاطع المحسّن لمعرفات الوحدات ===
    
    /// <summary>
    /// Builds an intersection of unit-id sets.
    /// يبني تقاطعاً بين مجموعات معرفات الوحدات.
    /// </summary>
    public const string IntersectUnitIdsScript = @"
        local limit = tonumber(ARGV[1]) or 100
        
        if #KEYS == 0 then
            return {}
        end
        
        if #KEYS == 1 then
            -- Single set, return members directly. / مجموعة واحدة، أعد العناصر مباشرة.
            return redis.call('SMEMBERS', KEYS[1])
        end
        
        -- Create a temporary key for the intersection. / إنشاء مفتاح مؤقت للتقاطع.
        local tempKey = 'temp:intersect:' .. redis.call('TIME')[1]
        
        -- Execute the intersection. / تنفيذ التقاطع.
        redis.call('SINTERSTORE', tempKey, unpack(KEYS))
        
        -- Fetch the results. / جلب النتائج.
        local results = redis.call('SMEMBERS', tempKey)
        
        -- Delete the temporary key. / حذف المفتاح المؤقت.
        redis.call('DEL', tempKey)
        
        -- Apply the limit. / تطبيق الحد.
        if #results > limit then
            local limited = {}
            for i = 1, limit do
                limited[i] = results[i]
            end
            return limited
        end
        
        return results
    ";
    
    #endregion
    
    #region === البحث المركب المحسّن ===
    
    /// <summary>
    /// Script شامل للبحث بجميع المعايير
    /// يجمع بين الإتاحة والفلاتر والأسعار في عملية واحدة
    /// 
    /// المدخلات:
    /// KEYS[1] = فهرس الوحدات
    /// KEYS[2] = فهرس الإتاحة
    /// KEYS[3] = فهرس التسعير
    /// ARGV[1] = استعلام الوحدات
    /// ARGV[2] = استعلام الإتاحة
    /// ARGV[3] = checkIn timestamp
    /// ARGV[4] = checkOut timestamp
    /// ARGV[5] = حد النتائج
    /// 
    /// المخرجات:
    /// مصفوفة: [unitId1, price1, unitId2, price2, ...]
    /// </summary>
    public const string ComprehensiveSearchScript = @"
        local unitsIndex = KEYS[1]
        local availIndex = KEYS[2]
        local pricingIndex = KEYS[3]
        local unitsQuery = ARGV[1]
        local availQuery = ARGV[2]
        local checkInTs = tonumber(ARGV[3])
        local checkOutTs = tonumber(ARGV[4])
        local limit = tonumber(ARGV[5]) or 50
        
        -- 1. البحث عن الوحدات المحجوزة
        local blockedResult = redis.call('FT.SEARCH', availIndex, availQuery, 'NOCONTENT', 'LIMIT', '0', '10000')
        
        local blockedUnits = {}
        if blockedResult and #blockedResult > 1 then
            for i = 2, #blockedResult do
                local fields = redis.call('HGET', blockedResult[i], 'unitId')
                if fields then
                    blockedUnits[fields] = true
                end
            end
        end
        
        -- 2. Search units and exclude blocked ones. / 2. البحث في الوحدات واستثناء المحجوزة.
        local unitsResult = redis.call('FT.SEARCH', unitsIndex, unitsQuery, 'LIMIT', '0', tostring(limit * 2))
        
        local availableUnits = {}
        if unitsResult and #unitsResult > 1 then
            for i = 2, #unitsResult, 2 do
                if i + 1 <= #unitsResult then
                    local key = unitsResult[i]
                    local fields = unitsResult[i + 1]
                    
                    local unitId = nil
                    local basePrice = 0
                    
                    for j = 1, #fields, 2 do
                        if fields[j] == 'unitId' then
                            unitId = fields[j + 1]
                        elseif fields[j] == 'basePrice' then
                            basePrice = tonumber(fields[j + 1]) or 0
                        end
                    end
                    
                    if unitId and not blockedUnits[unitId] then
                        table.insert(availableUnits, {id = unitId, basePrice = basePrice, key = key})
                        if #availableUnits >= limit then
                            break
                        end
                    end
                end
            end
        end
        
        -- 3. Calculate prices for each unit. / 3. حساب الأسعار لكل وحدة.
        local results = {}
        local daySeconds = 86400
        local numberOfDays = math.floor((checkOutTs - checkInTs) / daySeconds)
        
        for _, unit in ipairs(availableUnits) do
            local query = '@unitId:{' .. unit.id .. '} @startDateTs:[-inf ' .. checkOutTs .. '] @endDateTs:[' .. checkInTs .. ' +inf]'
            local pricingResult = redis.call('FT.SEARCH', pricingIndex, query, 'LIMIT', '0', '100')
            
            local periods = {}
            if pricingResult and #pricingResult > 1 then
                for i = 2, #pricingResult, 2 do
                    if i + 1 <= #pricingResult then
                        local fields = pricingResult[i + 1]
                        local period = {}
                        
                        for j = 1, #fields, 2 do
                            if fields[j] == 'startDateTs' then
                                period.startTs = tonumber(fields[j + 1])
                            elseif fields[j] == 'endDateTs' then
                                period.endTs = tonumber(fields[j + 1])
                            elseif fields[j] == 'price' then
                                period.price = tonumber(fields[j + 1])
                            end
                        end
                        
                        if period.startTs and period.endTs and period.price then
                            table.insert(periods, period)
                        end
                    end
                end
            end
            
            -- حساب السعر الإجمالي
            local totalPrice = 0
            
            if #periods > 0 then
                for day = 0, numberOfDays - 1 do
                    local dayStartTs = checkInTs + (day * daySeconds)
                    local dailyPrice = unit.basePrice
                    
                    for _, period in ipairs(periods) do
                        if dayStartTs >= period.startTs and dayStartTs < period.endTs then
                            dailyPrice = period.price
                            break
                        end
                    end
                    
                    totalPrice = totalPrice + dailyPrice
                end
            else
                totalPrice = unit.basePrice * numberOfDays
            end
            
            table.insert(results, unit.id)
            table.insert(results, tostring(totalPrice))
            table.insert(results, unit.key)
        end
        
        return results
    ";
    
    #endregion
}
