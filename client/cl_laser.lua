local creationLaser = false

function ToggleCreationLaser(modelName, callback)
    creationLaser = not creationLaser
    local hit, coords = false, nil
    local lastModelHash = nil
    local previewObject = nil
    local zOffset = 0.1

    if creationLaser then
        local modelHash = GetHashKey(modelName)
        if modelHash ~= lastModelHash then
            RequestModel(modelHash)
            while not HasModelLoaded(modelHash) do
                Wait(1)
            end
            lastModelHash = modelHash
        end

        CreateThread(function()
            while creationLaser do
                hit, coords = RayCastGamePlayCamera(20.0)
                if hit then
                    if not DoesEntityExist(previewObject) or modelHash ~= lastModelHash then
                        if DoesEntityExist(previewObject) then
                            DeleteObject(previewObject)
                        end
                        previewObject = CreateObject(modelHash, coords.x, coords.y, coords.z + zOffset, false, false, true)
                        SetEntityCollision(previewObject, false, true)
                        lastModelHash = modelHash
                    else
                        SetEntityCoordsNoOffset(previewObject, coords.x, coords.y, coords.z + zOffset, true, true, true)
                    end
                elseif DoesEntityExist(previewObject) then
                    DeleteObject(previewObject)
                    previewObject = nil
                end

                if hit and IsControlJustReleased(0, 38) then
                    creationLaser = false
                    if DoesEntityExist(previewObject) then
                        DeleteObject(previewObject)
                        previewObject = nil
                    end
                    callback(coords)
                end
                Wait(0)
            end
            if DoesEntityExist(previewObject) then
                DeleteObject(previewObject)
                previewObject = nil
            end
        end)
    end
end

exports('ToggleCreationLaser', ToggleCreationLaser)

function DrawLaser(color)
    local hit, coords = RayCastGamePlayCamera(20.0)

    if hit then
        local position = GetEntityCoords(PlayerPedId())
        DrawLine(position.x, position.y, position.z, coords.x, coords.y, coords.z, color.r, color.g, color.b, color.a)
        DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, color.r, color.g, color.b, color.a, false, true, 2, nil, nil, false)
    end

    return hit, coords
end

exports('DrawLaser', DrawLaser)

function RotationToDirection(rotation)
    local adjustedRotation =
    {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    local direction =
    {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return direction
end

function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = RotationToDirection(cameraRotation)
    local destination =
    {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }
    local _, hit, endCoords, _, _ = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
    return hit == 1, endCoords
end

function Draw2DText(content, font, colour, scale, x, y)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(colour[1],colour[2],colour[3], 255)
    SetTextEntry("STRING")
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    AddTextComponentString(content)
    DrawText(x, y)
end