local isPlacing = false
local currentProp = nil

Citizen.CreateThread(function()
    Wait(5000)
    TriggerServerEvent('InitPropsOnStart')
end)

RegisterNetEvent('spawnProp')
AddEventHandler('spawnProp', function(model, x, y, z)
    local hash = GetHashKey(model)
    RequestModel(hash)
    
    while not HasModelLoaded(hash) do
        Wait(500)
    end
    
    local prop = CreateObject(hash, x, y, z, false, false, true)
    
    local playerPed = GetPlayerPed(-1)
    local playerHeading = GetEntityHeading(playerPed)
    SetEntityHeading(prop, playerHeading)
    
    SetEntityHasGravity(prop, false)
    FreezeEntityPosition(prop, true)
    SetEntityCollision(prop, true, true)
    Wait(500) 

    isPlacing = true
    TriggerServerEvent('savePropToDB', model, x, y, z)
end)

RegisterCommand('placeobject', function(source, args)
    local modelName = args[1]
    if modelName then
        exports['ud-objects']:ToggleCreationLaser(modelName, function(coords)
            local x, y, z = coords.x, coords.y, coords.z
            TriggerEvent('spawnProp', modelName, x, y, z)
        end)
    else
        print("INVALID MODEL NAME DUMBASS")
    end
end, false)

RegisterNetEvent('SpawnPropsFromDB')
AddEventHandler('SpawnPropsFromDB', function(model, x, y, z, rx, ry, rz)
    local hash = GetHashKey(model)
    RequestModel(hash)
    
    while not HasModelLoaded(hash) do
        Wait(500)
    end
    
    local prop = CreateObject(hash, x, y, z, true, false, true)
    SetEntityRotation(prop, rx, ry, rz, 2, true)
    FreezeEntityPosition(prop, true)
end)