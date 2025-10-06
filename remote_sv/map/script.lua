-- All maps list (Lua file with table structure)
Urls.AllMapList = "https://raw.githubusercontent.com/Prompt-Coder/mapdatachecker/refs/heads/main/all_data_full"
-- Direct url to mapdata on Github (%s will be replaced with map names in the format of name1+name2+name3)
Urls.DownloadUrl = "https://github.com/Prompt-Coder/Sandy-Map-Data/archive/refs/heads/SandyMapData----%s"
-- Direct url to mapdata to generate (%s will be replaced with map names in the format of name1+name2+name3)
Urls.PlatformUrl = "https://vertex-hub.com/prompt/map-data/sandy-rework/%s"

-- print("Script version: 2")

-- Getting maps in mapdata (send event)
local returnEventName = "promptmap:return_" .. MapId
CreateThread(function()
    TriggerEvent("prompt:mapdata_sendList", returnEventName)
end)

-- Getting maps in mapdata (return event)
local mapdataMaps = {}
RegisterNetEvent(returnEventName, function(maps)
    mapdataMaps = maps
end)

-- Getting all maps possible
local allMaps = {}
local mapNames = {}
local myName = ""
PerformHttpRequest(Urls.AllMapList, function(err, text, headers)
    if err ~= 200 then 
        print("Please update the map, it has old code.")
    else
        local mapData = load(text)
        if mapData then
            local mapTable = mapData()

            for i = 1, #mapTable do 
                table.insert(allMaps, mapTable[i].static)
                table.insert(mapNames, mapTable[i].name)

                if allMaps[i] == MapId then
                    myName = mapTable[i].name
                end
            end

            if Debug == true then 
                print("Loaded ", #mapTable, " maps from all-data")
            end
        else
            print("Failed to load map data, it has an invalid format.")
        end
    end
end, "GET")

--[[
    LEGACY MAP SUPPORT
--]]

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

--[[
    LEGACY MAP SUPPORT END
--]]

-- I exist event
local iExistName = "promptmap:i_exist_".. MapId
RegisterNetEvent(iExistName, function(existsCB)
    existsCB(true)
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
            table.insert(existList, allMaps[i])
        end
    end

    -- Print legacy maps found message
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

    -- Making a link for Mapdata in case it does not fit
    -- Example: name1+name2+name3 (using names instead of static IDs)
    local ids = ""
    for i = 1, #existList do
        local mapName = ""
        local tempId = 1
        for j = 1, #allMaps do
            if allMaps[j] == existList[i] then
                tempId = j
                break
            end
        end

        mapName = mapNames[tempId]
        ids = ids..mapName
        if i ~= #existList then
            ids = ids.."+"
        end
    end

    local link = string.format(Urls.DownloadUrl, ids)
    local returned = false

    -- Checking if link exists
    PerformHttpRequest(link, function(code, text, headers)
        local finalUrl = ""
        if code == 200 then
            finalUrl = link .. ".zip"
        else
            finalUrl = string.format(Urls.PlatformUrl, ids)
        end
        link = ("| 🔗 Download: %-56s |"):format(finalUrl)

        returned = true
    end, "GET")

    while returned == false do
        Wait(100)
    end

    -- Function to check if mapdata matches installed maps and print results
    local function checkMapdataMatch(mapdataMaps, existList, link)
        -- helper: quick lookup sets
        local function toSet(list)
            local s = {}
            for i = 1, #list do s[list[i]] = true end
            return s
        end
    
        -- helper: id -> pretty name (falls back to id)
        local function idToName(id)
            for i = 1, #allMaps do
                if allMaps[i] == id then
                    return mapNames[i] or id
                end
            end
            return id
        end
    
        -- copy + sort for equality check (kept from your logic)
        local tempMapdataMaps, tempExistList = {}, {}
        for i = 1, #mapdataMaps do tempMapdataMaps[i] = mapdataMaps[i] end
        for i = 1, #existList do tempExistList[i] = existList[i] end
        table.sort(tempMapdataMaps)
        table.sort(tempExistList)
    
        local same = true
        if #tempMapdataMaps ~= #tempExistList then same = false end
        if same then
            for i = 1, #tempMapdataMaps do
                if tempMapdataMaps[i] ~= tempExistList[i] then
                    same = false
                    break
                end
            end
        end
    
        if same then
            local box = CreateBox({ "✅ ^2Mapdata is the same as maps installed^7" })
            for _, line in ipairs(box) do print(line) end
            return
        end
    
        -- compute diffs
        local existSet = toSet(existList)
        local mapdataSet = toSet(mapdataMaps)
    
        local excess, missing = {}, {}
        for i = 1, #existList do
            local id = existList[i]
            if not mapdataSet[id] then table.insert(excess, id) end
        end
        for i = 1, #mapdataMaps do
            local id = mapdataMaps[i]
            if not existSet[id] then table.insert(missing, id) end
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
        local header = "❌ ^8 Mapdata is not the same as maps installed^7"
        local moreLess
        if #existList > #mapdataMaps then
            moreLess = "^8 There are more maps than mapdata supports!^7"
        elseif #existList < #mapdataMaps then
            moreLess = "^8 There are less maps than mapdata supports!^7"
        else
            -- same count but different contents
            moreLess = "^8 The sets differ even though counts match.^7"
        end
    
        local boxLines = {
            header,
            moreLess,
            "^8 Excess (installed but not in mapdata):^7 " .. namesCSV(excess),
            "^8 Missing (in mapdata but not installed):^7 " .. namesCSV(missing),
            "^8" .. link .. "^7"
        }
    
        local box = CreateBox(boxLines)
        for _, line in ipairs(box) do print(line) end
    end


    -- Checking if this map is last 
    if existList[#existList] == MapId then
        -- Checking if mapdata exists
        if #mapdataMaps > 0 then 
            -- Check if mapdata matches installed maps
            checkMapdataMatch(mapdataMaps, existList, link)
        else 
            -- Check for legacy mapdata events
            local legacyMapdataMaps = {}
            local foundLegacyMapdata = false
            
            -- Loop through all maps in existList to check for legacy mapdata events
            for i = 1, #existList do
                local legacyMapdataCheckName = existList[i] .. ":mapDataExists"
                local legacyMapdataExists = false
                
                if Debug == true then
                    print("Checking for legacy mapdata: " .. existList[i])
                end
                
                TriggerEvent(legacyMapdataCheckName, function(existsCB)
                    legacyMapdataExists = existsCB
                end)
                Wait(100)
                
                if legacyMapdataExists == true then
                    if Debug == true then
                        print("Found legacy mapdata for: " .. existList[i])
                    end
                    table.insert(legacyMapdataMaps, existList[i])
                    foundLegacyMapdata = true
                end
            end
            
            if foundLegacyMapdata == true then
                -- Update mapdataMaps with legacy data
                mapdataMaps = legacyMapdataMaps
                
                -- Check if mapdata matches installed maps
                checkMapdataMatch(mapdataMaps, existList, link)
            else
                local boxLines = {
                    "❌ ^8 Mapdata does not exist ^7",
                    "^8" .. link .. "^7"
                }
                
                local box = CreateBox(boxLines)
                for _, line in ipairs(box) do
                    print(line)
                end
            end
        end
    else 
        -- Legacy Final Map support 
        local finalMapName = existList[#existList].. ":mapFinal"
        TriggerEvent(finalMapName, allMaps, existList)
    end
end)
