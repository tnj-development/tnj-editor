local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent("aj-editor:server:syncPfx", function(hitCoords, asset, name)
    TriggerClientEvent("aj-editor:client:syncPfx", -1, hitCoords, asset, name)
end)

QBCore.Commands.Add('openeditor', 'Opens the Editor', {}, false, function(source, args)
    local src = source
    if QBCore.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command') then
        TriggerClientEvent('aj:togglecam', src)
    else
    TriggerClientEvent('QBCore:Notify', src, "Access Denied")
    end
end)