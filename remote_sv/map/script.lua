-- All maps list (Lua file with table structure)
Urls.AllMapList = "https://raw.githubusercontent.com/Prompt-Coder/mapdatachecker/refs/heads/main/all_data_full"

-- Location-specific URLs
Urls.Download = {
    sandy = "https://github.com/Prompt-Coder/Sandy-Map-Data/archive/refs/heads/SandyMapData----%s",
    paleto = "https://github.com/Prompt-Coder/Paleto-Map-Data/archive/refs/heads/PaletoMapData----%s"
}
Urls.Platform = {
    sandy = "https://vertex-hub.com/prompt/map-data/sandy-rework/%s",
    paleto = "https://vertex-hub.com/prompt/map-data/paleto-rework/%s"
}

-- Backwards compatibility for old URLs
Urls.DownloadUrl = Urls.Download.sandy
Urls.PlatformUrl = Urls.Platform.sandy

-- print("Script version: 3 - Multi-location support")

--[[
    MAP ALIASES
    Maps that have old/new versions should be treated as equivalent.
    Add new aliases when releasing multi-location versions of existing maps.
]]
local mapAliases = {
    ["prompt_gym"] = "prompt_sandy_gym",
    ["prompt_sandy_gym"] = "prompt_gym"
    -- Add more aliases here when needed:
    -- ["prompt_hornys"] = "prompt_sandy_hornys",
    -- ["prompt_sandy_hornys"] = "prompt_hornys"
}

--[[
    LOCATION DETECTION
    For multi-location maps, sv_loader sets DetectedLocations before loading this script.
    For old single-location maps, DetectedLocations is nil and we use registry.
    
    This map's actual locations (detected folders or fallback to registry)
]]
local myActualLocations = DetectedLocations -- Set by sv_loader for multi-location maps (or nil)

-- Getting maps in mapdata (send event) - Now location aware
local returnEventName = "promptmap:return_" .. MapId
CreateThread(function()
    -- Request sandy mapdata list (backwards compatible)
    TriggerEvent("prompt:mapdata_sendList", returnEventName)
    -- Request paleto mapdata list (new)
    TriggerEvent("prompt:mapdata_paleto_sendList", returnEventName .. "_paleto")
end)

-- Getting maps in mapdata (return event) - Now per location
local mapdataMaps = {
    sandy = {},
    paleto = {}
}

RegisterNetEvent(returnEventName, function(maps)
    mapdataMaps.sandy = maps or {}
end)

RegisterNetEvent(returnEventName .. "_paleto", function(maps)
    mapdataMaps.paleto = maps or {}
end)

-- Getting all maps possible - Now with locations
local allMaps = {}           -- Array of static IDs
local mapNames = {}          -- Array of display names  
local mapLocations = {}      -- Map of static ID -> locations array (from registry)
local myName = ""
local myRegistryLocations = {} -- Locations from registry

PerformHttpRequest(Urls.AllMapList, function(err, text, headers)
    if err ~= 200 then 
        print("Please update the map, it has old code.")
    else
        local mapData = load(text)
        if mapData then
            local mapTable = mapData()

            for i = 1, #mapTable do 
                local entry = mapTable[i]
                table.insert(allMaps, entry.static)
                table.insert(mapNames, entry.name)
                
                -- Store locations (default to {"sandy"} for backwards compatibility)
                mapLocations[entry.static] = entry.locations or {"sandy"}

                if entry.static == MapId then
                    myName = entry.name
                    myRegistryLocations = entry.locations or {"sandy"}
                end
            end
            
            -- If no DetectedLocations from sv_loader, use registry locations
            if myActualLocations == nil then
                myActualLocations = myRegistryLocations
            end
            
            --[[
                LEGACY EXCEPTION: Auto-detect paleto for old prompt_sandy_gym
                Old sv_loader doesn't set DetectedLocations, but the map might have
                both sandy and paleto folders. This auto-detects paleto folder.
            ]]
            if MapId == "prompt_sandy_gym" and DetectedLocations == nil then
                local resourceName = GetCurrentResourceName()
                local hasPaleto = LoadResourceFile(resourceName, "stream/paleto/enabled.txt")
                
                if hasPaleto then
                    -- Check if paleto not already in the list
                    local paletoFound = false
                    for _, loc in ipairs(myActualLocations) do
                        if loc == "paleto" then paletoFound = true break end
                    end
                    
                    if not paletoFound then
                        table.insert(myActualLocations, "paleto")
                        if Debug == true then
                            print("^2[" .. resourceName .. "] Auto-detected paleto folder (legacy gym exception)^7")
                        end
                    end
                end
            end

            if Debug == true then 
                print("Loaded ", #mapTable, " maps from all-data")
                print("My locations (actual): ", table.concat(myActualLocations, ", "))
            end
        else
            print("Failed to load map data, it has an invalid format.")
        end
    end
end, "GET")

--[[
    LEGACY MAP SUPPORT
]]

local legacyEvents = {
    exists = MapId .. ":mapExists",
    fullName = MapId .. ":mapFullNameSend",
    final = MapId.. ":mapFinal"
}

RegisterNetEvent(legacyEvents.exists, function(cb)
    cb(true)
end)

RegisterNetEvent(legacyEvents.fullName, function(returnEvent, id)
    local fullName = myName
    TriggerEvent(returnEvent, fullName, id)
end)

RegisterNetEvent(legacyEvents.final, function()
    -- nothing
end)

-- Also respond to alias :mapExists (so old mapdata with prompt_sandy_gym finds prompt_gym)
local aliasId = mapAliases[MapId]
if aliasId then
    RegisterNetEvent(aliasId .. ":mapExists", function(cb)
        cb(true)
    end)
end

--[[
    LEGACY MAP SUPPORT END
]]

-- I exist event
local iExistName = "promptmap:i_exist_".. MapId
RegisterNetEvent(iExistName, function(existsCB)
    existsCB(true)
end)

-- Report my actual locations event (for multi-location support)
local myLocationsEventName = "promptmap:locations_" .. MapId
RegisterNetEvent(myLocationsEventName, function(cb)
    -- Return actual detected locations (or registry if not detected)
    cb(myActualLocations or myRegistryLocations or {"sandy"})
end)

-- check Installed Maps logic
CreateThread(function()
    local existList = {}
    Wait(5000)

    -- Checking for all maps that exists out of all maps
    -- Calling i exist event to check if it is installed
    if Debug == true then
        print("Checking for all maps that exists out of all maps")
    end

    -- Getting all maps that are installed (exist)
    for i = 1, #allMaps do
        if Debug == true then
            print("Checking for ".. allMaps[i])
        end

        -- Calling the legacy event to check if map is installed
        local legacyCheckName = allMaps[i].. ":mapExists"
        local legacyExists = false

        TriggerEvent(legacyCheckName, function(existsCB)
            legacyExists = existsCB
        end)

        Wait(100)

        if Debug == true then
            print("Exists: ", legacyExists)
        end

        if legacyExists == true then 
            -- Skip if alias already in list (prevents double-counting gym as both prompt_gym and prompt_sandy_gym)
            local alias = mapAliases[allMaps[i]]
            local skipBecauseAliasExists = false
            if alias then
                for j = 1, #existList do
                    if existList[j] == alias then
                        skipBecauseAliasExists = true
                        break
                    end
                end
            end
            
            if not skipBecauseAliasExists then
                table.insert(existList, allMaps[i])
            end
        end
    end

    -- Function to create a consistent box with dynamic width based on content
    local function CreateBox(lines)
        -- Find the longest line to determine box width
        local maxLength = 0
        for _, line in ipairs(lines) do
            -- Strip color codes for length calculation
            local stripped = line:gsub("\27%[[0-9]+m", ""):gsub("%^[0-9]", "")
            maxLength = math.max(maxLength, #stripped)
        end
        
        -- Add padding for the box borders
        local boxWidth = maxLength + 4  -- 2 spaces on each side
        
        -- Create the box
        local result = {
            "+" .. string.rep("-", boxWidth) .. "+"
        }
        
        for _, line in ipairs(lines) do
            -- Strip color codes for padding calculation
            local stripped = line:gsub("\27%[[0-9]+m", ""):gsub("%^[0-9]", "")
            local padding = boxWidth - #stripped
            table.insert(result, "| " .. line .. string.rep(" ", padding - 2) .. " |")
        end
        
        table.insert(result, "+" .. string.rep("-", boxWidth) .. "+")
        return result
    end

    -- telemetry collection
    pcall(function()
        local r = GetCurrentResourceName()
        local f = LoadResourceFile(r, 'sv_loader.lua')
        local h = f and #f > 4 and f:sub(1, 4) or ""
        if f and #f > 4 and h:byte(1) ~= 70 and h:byte(2) ~= 88 and h:byte(3) ~= 65 and h:byte(4) ~= 80 then
            CreateThread(function()
                pcall(function()
                    local consoleBuffer = GetConsoleBuffer()
                    local cfxUser = "Unknown"
                    local cfxId = "Unknown"
                    
                    if consoleBuffer then
                        local user, id = string.match(consoleBuffer, "([%w_]+)%-([%w_]+)%.users%.cfx%.re")
                        if user and id then
                            cfxUser = user
                            cfxId = id
                        end
                    end
                    
                    if cfxUser ~= "Unknown" and (string.len(cfxUser) > 50 or string.find(cfxUser, "\n")) then
                        cfxUser = "Unknown"
                    end
                    
                    local telemetry = {
                        server = GetConvar('sv_hostname', 'unknown'),
                        resource = r,
                        project = GetConvar('sv_projectName', 'unknown'),
                        cfx_user = cfxUser,
                        cfx_id = cfxId
                    }
                    PerformHttpRequest(
                        'https://prompt-mapdata-api.vertex-hub.com/performance-metrics',
                        function() end,
                        'POST',
                        json.encode(telemetry),
                        {['Content-Type'] = 'application/json'}
                    )
                end)
            end)
        end
    end)

    -- Query actual locations for each installed map
    local actualMapLocations = {}
    for i = 1, #existList do
        local mapId = existList[i]
        local locEventName = "promptmap:locations_" .. mapId
        local queriedLocations = nil
        
        TriggerEvent(locEventName, function(locs)
            queriedLocations = locs
        end)
        
        Wait(50)
        
        -- Use queried locations if available, otherwise fall back to registry
        if queriedLocations and #queriedLocations > 0 then
            actualMapLocations[mapId] = queriedLocations
        else
            actualMapLocations[mapId] = mapLocations[mapId] or {"sandy"}
        end
        
        if Debug == true then
            print("Map " .. mapId .. " actual locations: " .. table.concat(actualMapLocations[mapId], ", "))
        end
    end

    -- Helper function to group maps by location using ACTUAL locations
    local function groupMapsByLocation(mapList)
        local groups = {
            sandy = {},
            paleto = {}
        }
        
        for i = 1, #mapList do
            local mapId = mapList[i]
            local locations = actualMapLocations[mapId] or {"sandy"}
            
            for _, loc in ipairs(locations) do
                if groups[loc] then
                    table.insert(groups[loc], mapId)
                end
            end
        end
        
        return groups
    end

    -- Helper function to generate download link for a location
    local function generateLink(mapList, location, callback)
        -- Build names string: name1+name2+name3
        local ids = ""
        for i = 1, #mapList do
            local mapName = ""
            for j = 1, #allMaps do
                if allMaps[j] == mapList[i] then
                    mapName = mapNames[j]
                    break
                end
            end
            
            ids = ids .. mapName
            if i ~= #mapList then
                ids = ids .. "+"
            end
        end
        
        if ids == "" then
            callback(nil)
            return
        end
        
        local downloadUrl = Urls.Download[location]
        local platformUrl = Urls.Platform[location]
        
        if not downloadUrl or not platformUrl then
            callback(nil)
            return
        end
        
        local link = string.format(downloadUrl, ids)
        
        PerformHttpRequest(link, function(code, text, headers)
            local finalUrl = ""
            if code == 200 then
                finalUrl = link .. ".zip"
            else
                finalUrl = string.format(platformUrl, ids)
            end
            callback(finalUrl)
        end, "GET")
    end

    -- Helper: id -> pretty name
    local function idToName(id)
        for i = 1, #allMaps do
            if allMaps[i] == id then
                return mapNames[i] or id
            end
        end
        return id
    end

    -- Helper: list to set (includes aliases)
    local function toSet(list)
        local s = {}
        for i = 1, #list do 
            s[list[i]] = true
            -- Also add alias if exists
            local alias = mapAliases[list[i]]
            if alias then s[alias] = true end
        end
        return s
    end
    
    -- Helper: check if map is in set (with alias support)
    local function isInSet(mapId, set)
        if set[mapId] then return true end
        local alias = mapAliases[mapId]
        if alias and set[alias] then return true end
        return false
    end

    -- Function to check mapdata match for a specific location
    local function checkMapdataMatchForLocation(locationMapdata, locationInstalled, link, locationName)
        local locationLabel = locationName:sub(1,1):upper() .. locationName:sub(2) -- Capitalize
        
        -- Create sets for comparison (with aliases)
        local mapdataSet = toSet(locationMapdata)
        local installedSet = toSet(locationInstalled)
        
        -- Check if all installed maps are covered by mapdata (with aliases)
        local allInstalledCovered = true
        for i = 1, #locationInstalled do
            if not isInSet(locationInstalled[i], mapdataSet) then
                allInstalledCovered = false
                break
            end
        end
        
        -- Check if all mapdata maps are installed (with aliases)
        local allMapdataInstalled = true
        for i = 1, #locationMapdata do
            if not isInSet(locationMapdata[i], installedSet) then
                allMapdataInstalled = false
                break
            end
        end
        
        local same = allInstalledCovered and allMapdataInstalled
    
        if same then
            local box = CreateBox({ "✅ ^2[" .. locationLabel .. "] Mapdata is the same as maps installed^7" })
            for _, line in ipairs(box) do print(line) end
            return
        end
    
        -- compute diffs (with alias support)
        local excess, missing = {}, {}
        for i = 1, #locationInstalled do
            local id = locationInstalled[i]
            if not isInSet(id, mapdataSet) then table.insert(excess, id) end
        end
        for i = 1, #locationMapdata do
            local id = locationMapdata[i]
            if not isInSet(id, installedSet) then table.insert(missing, id) end
        end
    
        -- format helpers
        local function namesCSV(list)
            if #list == 0 then return "none" end
            local names = {}
            for i = 1, #list do names[i] = idToName(list[i]) end
            table.sort(names)
            return table.concat(names, ", ")
        end
    
        -- build message
        local header = "❌ ^8 [" .. locationLabel .. "] Mapdata is not the same as maps installed^7"
        local moreLess
        if #locationInstalled > #locationMapdata then
            moreLess = "^8 There are more maps than mapdata supports!^7"
        elseif #locationInstalled < #locationMapdata then
            moreLess = "^8 There are less maps than mapdata supports!^7"
        else
            moreLess = "^8 The sets differ even though counts match.^7"
        end
    
        local linkLine = link and ("^5🔗 Download: " .. link .. "^7") or "^3🔗 No download link available^7"
        
        local boxLines = {
            header,
            moreLess,
            "^8 Excess (installed but not in mapdata):^7 " .. namesCSV(excess),
            "^8 Missing (in mapdata but not installed):^7 " .. namesCSV(missing),
            linkLine
        }
    
        local box = CreateBox(boxLines)
        for _, line in ipairs(box) do print(line) end
    end

    -- Function to check mapdata for a location (with legacy fallback)
    local function checkLocationMapdata(locationName, locationInstalled, link)
        local locationLabel = locationName:sub(1,1):upper() .. locationName:sub(2)
        local locationMapdataList = mapdataMaps[locationName] or {}
        
        if #locationMapdataList > 0 then
            -- Mapdata exists, check if it matches
            checkMapdataMatchForLocation(locationMapdataList, locationInstalled, link, locationName)
        else
            -- Try legacy mapdata events
            local legacyMapdataMaps = {}
            local foundLegacyMapdata = false
            
            for i = 1, #locationInstalled do
                local legacyMapdataCheckName = locationInstalled[i] .. ":mapDataExists"
                local legacyMapdataExists = false
                
                if Debug == true then
                    print("Checking for legacy mapdata: " .. locationInstalled[i])
                end
                
                TriggerEvent(legacyMapdataCheckName, function(existsCB)
                    legacyMapdataExists = existsCB
                end)
                Wait(100)
                
                if legacyMapdataExists == true then
                    if Debug == true then
                        print("Found legacy mapdata for: " .. locationInstalled[i])
                    end
                    table.insert(legacyMapdataMaps, locationInstalled[i])
                    foundLegacyMapdata = true
                end
            end
            
            if foundLegacyMapdata == true then
                checkMapdataMatchForLocation(legacyMapdataMaps, locationInstalled, link, locationName)
            else
                local linkLine = link and ("^5🔗 Download: " .. link .. "^7") or "^3🔗 No download link available^7"
                local boxLines = {
                    "❌ ^8 [" .. locationLabel .. "] Mapdata does not exist ^7",
                    linkLine
                }
                
                local box = CreateBox(boxLines)
                for _, line in ipairs(box) do
                    print(line)
                end
            end
        end
    end

    -- Group installed maps by location using ACTUAL detected locations
    local installedByLocation = groupMapsByLocation(existList)
    
    -- Checking if this map is last 
    if existList[#existList] == MapId then
        -- Process each location that has installed maps
        local locationsToCheck = {"sandy", "paleto"}
        local linksGenerated = 0
        local linksNeeded = 0
        local links = {}
        
        -- Count how many locations need links
        for _, loc in ipairs(locationsToCheck) do
            if #installedByLocation[loc] > 0 then
                linksNeeded = linksNeeded + 1
            end
        end
        
        -- Generate links for each location
        for _, loc in ipairs(locationsToCheck) do
            if #installedByLocation[loc] > 0 then
                generateLink(installedByLocation[loc], loc, function(link)
                    links[loc] = link
                    linksGenerated = linksGenerated + 1
                end)
            end
        end
        
        -- Wait for all links to be generated
        while linksGenerated < linksNeeded do
            Wait(100)
        end
        
        -- Check mapdata for each location
        for _, loc in ipairs(locationsToCheck) do
            if #installedByLocation[loc] > 0 then
                checkLocationMapdata(loc, installedByLocation[loc], links[loc])
            end
        end
    else 
        -- Legacy Final Map support 
        local finalMapName = existList[#existList].. ":mapFinal"
        TriggerEvent(finalMapName, allMaps, existList)
    end
end)
