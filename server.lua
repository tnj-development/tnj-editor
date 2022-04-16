local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent("aj-editor:server:syncPfx", function(hitCoords, asset, name)
    TriggerClientEvent("aj-editor:client:syncPfx", -1, hitCoords, asset, name)
end)

QBCore.Commands.Add('openeditor', 'Opens the Editor', {}, false, function(source, args)
    local src = source
    TriggerClientEvent('aj:togglecam', src)
end)