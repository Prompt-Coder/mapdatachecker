--[[
    PALETO BAY MAPDATA SCRIPT
    This script is loaded by the paleto mapdata resource.
    It responds to map detection events and reports which maps the mapdata covers.
    
    Required variable from mapdata resource:
    - Maps: table of map static IDs that this mapdata covers
    - Debug: boolean for debug messages (optional)
]]

CreateThread(function()
    local exists = false 
    TriggerEvent("prompt:mapdata_paleto_exists", function(varExists)
        exists = varExists
    end)

    Wait(500)

    -- Legacy mapdata support for paleto
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

-- Paleto mapdata list event
RegisterNetEvent("prompt:mapdata_paleto_sendList", function(returnevent)
    if Debug == true then
        print("[Paleto Mapdata] Sending maps list to: ", returnevent)
    end
    TriggerEvent(returnevent, Maps)
end)

-- Paleto mapdata exists event
RegisterNetEvent("prompt:mapdata_paleto_exists", function(returnValue)
    returnValue(true)
end)

