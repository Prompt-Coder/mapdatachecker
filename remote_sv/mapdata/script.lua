--[[
    SANDY SHORES MAPDATA SCRIPT
    This script is loaded by the sandy mapdata resource.
    It responds to map detection events and reports which maps the mapdata covers.
    
    Required variable from mapdata resource:
    - Maps: table of map static IDs that this mapdata covers
    - Debug: boolean for debug messages (optional)
]]

CreateThread(function()
    local exists = false 
    TriggerEvent("prompt:mapdata_exists", function(varExists)
        exists = varExists
    end)

    -- Legacy event support
    local legacy = false 
    TriggerEvent("lyn-mapdata:exists", function(res)
        legacy = res
    end)

    Wait(500)

    if legacy == true then 
        print("^8 !!!! You have also a legacy mapdata version installed (old version) alongside the new one, please consider deleting it so script can run the new version")
    end

    -- Legacy mapdata support
    for i = 1, #Maps do 
        if Debug == true then 
            print("Adding legacy mapdata support for: ", Maps[i])
        end
        local mapdataExists = Maps[i].. ":mapDataExists"
        RegisterNetEvent(mapdataExists, function(cb)
            cb(true)
        end)
    end
end)

-- Sandy mapdata list event (backwards compatible)
RegisterNetEvent("prompt:mapdata_sendList", function(returnevent)
    if Debug == true then
        print("[Sandy Mapdata] Sending maps list to: ", returnevent)
    end
    TriggerEvent(returnevent, Maps)
end)

-- Sandy mapdata exists event
RegisterNetEvent("prompt:mapdata_exists", function(returnValue)
    returnValue(true)
end)
