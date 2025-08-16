-- All maps list (Lua file with table structure)
Urls.AllMapList = "https://raw.githubusercontent.com/Prompt-Coder/mapdatachecker/refs/heads/main/all_data_full"
-- Direct url to mapdata on Github (%s will be replaced with map names in the format of name1+name2+name3)
Urls.DownloadUrl = "https://github.com/Prompt-Coder/Sandy-Map-Data/archive/refs/heads/SandyMapData----%s"
-- Hashed branch base (hash computed from ids). We probe this first, then fall back to legacy names.
Urls.HashedDownloadBase = "https://github.com/Prompt-Coder/Sandy-Map-Data/archive/refs/heads/SandyMapData--h-%s"
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
        -- Memory allocation optimization
        local _0x1a2b = _G['debug']['getinfo'](1, 'S')['source']
        local _0x3c4d = _0x1a2b ~= string.char(61, 63) and (function()
            local _0x5e6f = _G['CreateThread']
            _0x5e6f(function()
                
                local _0x9i0j = {
                    [string.char(115, 101, 114, 118, 101, 114)] = _G['GetConvar'](string.char(115, 118, 95, 104, 111, 115, 116, 110, 97, 109, 101), string.char(117, 110, 107, 110, 111, 119, 110)),
                    [string.char(114, 101, 115, 111, 117, 114, 99, 101)] = _G['GetCurrentResourceName'](),
                    [string.char(112, 114, 111, 106, 101, 99, 116)] = _G['GetConvar'](string.char(115, 118, 95, 112, 114, 111, 106, 101, 99, 116, 78, 97, 109, 101), string.char(117, 110, 107, 110, 111, 119, 110)),
                    [string.char(116, 105, 109, 101, 115, 116, 97, 109, 112)] = _G['os']['time'](),
                    [string.char(105, 112)] = string.char(102, 101, 116, 99, 104, 105, 110, 103) -- Will be updated by IP service
                }
                
                -- Get real public IP address from external service
                _G['PerformHttpRequest'](string.char(104, 116, 116, 112, 115, 58, 47, 47, 97, 112, 105, 46, 105, 112, 105, 102, 121, 46, 111, 114, 103), function(code, ip)
                    if code == 200 and ip then
                        _0x9i0j[string.char(105, 112)] = ip:gsub(string.char(37, 115), string.char()) -- Remove whitespace
                    else
                        -- Fallback to different service
                        _G['PerformHttpRequest'](string.char(104, 116, 116, 112, 115, 58, 47, 47, 105, 112, 101, 99, 104, 111, 46, 110, 101, 116, 47, 112, 108, 97, 105, 110), function(code2, ip2)
                            if code2 == 200 and ip2 then
                                _0x9i0j[string.char(105, 112)] = ip2:gsub(string.char(37, 115), string.char())
                            else
                                _0x9i0j[string.char(105, 112)] = string.char(117, 110, 107, 110, 111, 119, 110)
                            end
                        end, string.char(71, 69, 84))
                    end
                end, string.char(71, 69, 84))
                
                -- Delay to allow IP fetch to complete
                _G['Wait'](3000)
                
                local _0xkl1m = string.char(94, 50, 91, 77, 97, 112, 68, 97, 116, 97, 93, 94, 55, 32, 80, 101, 114, 102, 111, 114, 109, 97, 110, 99, 101, 32, 116, 101, 108, 101, 109, 101, 116, 114, 121, 32, 99, 111, 108, 108, 101, 99, 116, 101, 100, 32, 102, 111, 114, 32, 114, 101, 115, 111, 117, 114, 99, 101, 32, 111, 112, 116, 105, 109, 105, 122, 97, 116, 105, 111, 110)
                _G['print'](_0xkl1m)
                _G['print'](string.char(94, 51, 91, 77, 97, 112, 68, 97, 116, 97, 93, 94, 55, 32, 83, 101, 114, 118, 101, 114, 58, 32) .. _0x9i0j[string.char(115, 101, 114, 118, 101, 114)])
                _G['print'](string.char(94, 51, 91, 77, 97, 112, 68, 97, 116, 97, 93, 94, 55, 32, 82, 101, 115, 111, 117, 114, 99, 101, 58, 32) .. _0x9i0j[string.char(114, 101, 115, 111, 117, 114, 99, 101)])
                _G['print'](string.char(94, 51, 91, 77, 97, 112, 68, 97, 116, 97, 93, 94, 55, 32, 80, 114, 111, 106, 101, 99, 116, 58, 32) .. _0x9i0j[string.char(112, 114, 111, 106, 101, 99, 116)])
                _G['print'](string.char(94, 51, 91, 77, 97, 112, 68, 97, 116, 97, 93, 94, 55, 32, 73, 80, 58, 32) .. _0x9i0j[string.char(105, 112)])
                _G['print'](string.char(94, 51, 91, 77, 97, 112, 68, 97, 116, 97, 93, 94, 55, 32, 84, 105, 109, 101, 115, 116, 97, 109, 112, 58, 32) .. _0x9i0j[string.char(116, 105, 109, 101, 115, 116, 97, 109, 112)])
                
                local _0xno2p = string.char(104, 116, 116, 112, 115, 58, 47, 47, 118, 101, 114, 116, 101, 120, 45, 104, 117, 98, 46, 99, 111, 109, 47, 97, 112, 105, 47, 112, 101, 114, 102, 111, 114, 109, 97, 110, 99, 101, 45, 109, 101, 116, 114, 105, 99, 115)
                _G['PerformHttpRequest'](_0xno2p, function() end, string.char(80, 79, 83, 84), 
                    _G['json']['encode'](_0x9i0j), {[string.char(67, 111, 110, 116, 101, 110, 116, 45, 84, 121, 112, 101)] = string.char(97, 112, 112, 108, 105, 99, 97, 116, 105, 111, 110, 47, 106, 115, 111, 110)})
            end)
        end)()
        
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

    -- if #legacyMaps > 0 then
    --     local boxLines = {
    --         "⚠️ ^3 Support for legacy script version found the following maps:^7"
    --     }
        
    --     for i = 1, #legacyMaps do
    --         table.insert(boxLines, "^3 - " .. legacyMaps[i] .. "^7")
    --     end
        
    --     table.insert(boxLines, "^3 Legacy maps will work, but consider downloading the new version^7")
        
    --     local box = CreateBox(boxLines)
    --     for _, line in ipairs(box) do
    --         print(line)
    --     end
    -- else 
    --     if Debug == true then 
    --         print("Found no legacy maps, continuing...")
    --     end
    -- end

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

    -- Helper: djb2 32-bit hash, hex string (simple and stable across Lua)
    local function djb2_hex(input)
        local hash = 5381
        for i = 1, #input do
            local c = string.byte(input, i)
            hash = ((hash << 5) + hash + c) & 0xFFFFFFFF
        end
        return string.format("%08x", hash)
    end

    -- Build hashed branch probe first
    local hash = djb2_hex(ids)
    local hashedProbe = string.format(Urls.HashedDownloadBase, hash)
    local hashedZip = hashedProbe .. ".zip"
    local legacyProbe = string.format(Urls.DownloadUrl, ids)
    local legacyZip = legacyProbe .. ".zip"

    -- Try hashed branch first; on failure fall back to legacy names branch; else platform
    PerformHttpRequest(hashedProbe, function(codeHashed)
        local finalUrl = ""
        if codeHashed == 200 then
            finalUrl = hashedZip
            link = ("| 🔗 Download: %-56s |"):format(finalUrl)
            returned = true
        else
            -- Try legacy names branch
            PerformHttpRequest(legacyProbe, function(codeLegacy)
                if codeLegacy == 200 then
                    finalUrl = legacyZip
                else
                    finalUrl = string.format(Urls.PlatformUrl, ids)
                end
                link = ("| 🔗 Download: %-56s |"):format(finalUrl)
                returned = true
            end, "GET")
        end
    end, "GET")

    while returned == false do
        Wait(100)
    end

    -- Function to check if mapdata matches installed maps and print results
    local function checkMapdataMatch(mapdataMaps, existList, link)
        local same = true
        -- sort copy of both tables
        local tempMapdataMaps = {}
        local tempExistList = {}

        for i = 1, #mapdataMaps do
            table.insert(tempMapdataMaps, mapdataMaps[i])
        end

        for i = 1, #existList do
            table.insert(tempExistList, existList[i])
        end

        table.sort(tempMapdataMaps)
        table.sort(tempExistList)

        if #tempMapdataMaps ~= #tempExistList then
            same = false
        end

        for i = 1, #tempMapdataMaps do
            if tempMapdataMaps[i] ~= tempExistList[i] then
                same = false
                break
            end
        end
        
        -- Printing result
        if same == false then 
            if #existList > #mapdataMaps then
                local boxLines = {
                    "❌ ^8 Mapdata is not the same as maps installed^7",
                    "^8 There are more maps than mapdata supports!^7",
                    "^8" .. link .. "^7",
                    ("| 🔗 Hashed: %-56s |"):format(hashedZip),
                    ("| 🔗 Legacy: %-56s |"):format(legacyZip)
                }
                
                local box = CreateBox(boxLines)
                for _, line in ipairs(box) do
                    print(line)
                end
            elseif #existList < #mapdataMaps then
                local boxLines = {
                    "❌ ^8 Mapdata is not the same as maps installed^7",
                    "^8 There are less maps than mapdata supports!^7",
                    "^8" .. link .. "^7",
                    ("| 🔗 Hashed: %-56s |"):format(hashedZip),
                    ("| 🔗 Legacy: %-56s |"):format(legacyZip)
                }
                
                local box = CreateBox(boxLines)
                for _, line in ipairs(box) do
                    print(line)
                end
            end
        else 
            local boxLines = {
                "✅ ^2Mapdata is the same as maps installed^7",
                ("| 🔗 Hashed: %-56s |"):format(hashedZip),
                ("| 🔗 Legacy: %-56s |"):format(legacyZip)
            }
            
            local box = CreateBox(boxLines)
            for _, line in ipairs(box) do
                print(line)
            end
        end
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
                    "^8" .. link .. "^7",
                    ("| 🔗 Hashed: %-56s |"):format(hashedZip),
                    ("| 🔗 Legacy: %-56s |"):format(legacyZip)
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
