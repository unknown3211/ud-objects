RegisterNetEvent('savePropToDB')
AddEventHandler('savePropToDB', function(model, x, y, z, rx, ry, rz)
    rx = rx or 0
    ry = ry or 0
    rz = rz or 0

    exports.oxmysql:execute('INSERT INTO objects (model, x, y, z, rx, ry, rz) VALUES (@model, @x, @y, @z, @rx, @ry, @rz)', {
        ['@model'] = model,
        ['@x'] = x,
        ['@y'] = y,
        ['@z'] = z,
        ['@rx'] = rx,
        ['@ry'] = ry,
        ['@rz'] = rz
    })
end)

RegisterServerEvent('InitPropsOnStart')
AddEventHandler('InitPropsOnStart', function()
    local src = source
    exports.oxmysql:execute('SELECT * FROM objects', {}, function(result)
        if result then
            for i=1, #result do
                local propData = result[i]
                TriggerClientEvent('SpawnPropsFromDB', src, propData.model, propData.x, propData.y, propData.z, propData.rx, propData.ry, propData.rz)
            end
        end
    end)
end)
