if GetResourceState('qb-core') ~= 'started' then return {} end
local QBBridge = {}
QBBridge.QBCore = exports['qb-core']:GetCoreObject()

function QBBridge.RemoveItem(source, item, count, metadata)
    local Player = QBBridge.QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    return Player.Functions.RemoveItem(item, count or 1, metadata and metadata.slot)
end

function QBBridge.AddMoney(source, account, amount)
    local Player = QBBridge.QBCore.Functions.GetPlayer(source)
    if not Player or not amount or amount <= 0 then return false end
    if account == 'cash' or account == 'money' then
        return Player.Functions.AddMoney('cash', amount)
    elseif account == 'black_money' or account == 'markedbills' then
        local totalWorth = amount
        local removedItems = false
        for slot, item in pairs(Player.PlayerData.items) do
            if item.name == 'markedbills' then
                local itemWorth = item.info.worth or 0
                totalWorth = totalWorth + itemWorth
                Player.Functions.RemoveItem('markedbills', 1, slot)
                removedItems = true
            end
        end
        local success = Player.Functions.AddItem('markedbills', 1, false, { worth = totalWorth })
        if success and removedItems then
            TriggerClientEvent('inventory:client:ItemBox', source, QBBridge.QBCore.Shared.Items['markedbills'], "remove")
        end
        if success then
            TriggerClientEvent('inventory:client:ItemBox', source, QBBridge.QBCore.Shared.Items['markedbills'], "add")
        end
        return success
    end
    return false
end

function QBBridge.GetPlayerIdentifier(source, type)
    local Player = QBBridge.QBCore.Functions.GetPlayer(source)
    if not Player then return nil end
    type = type and type:lower() or 'citizenid'
    if type == 'license' then
        return Player.PlayerData.license
    elseif type == 'steam' then
        return Player.PlayerData.steam
    elseif type == 'fivem' then
        return Player.PlayerData.fivem
    else
        return Player.PlayerData.citizenid
    end
end

function QBBridge.GetPlayersByJob(job, grade)
    local players = {}
    local qbPlayers = QBBridge.QBCore.Functions.GetQBPlayers()
    for _, Player in pairs(qbPlayers) do
        if Player.PlayerData.job.name == job then
            if not grade or Player.PlayerData.job.grade.level >= grade then
                table.insert(players, {
                    source = Player.PlayerData.source,
                    name = Player.PlayerData.charinfo.firstname..' '..Player.PlayerData.charinfo.lastname,
                    grade = Player.PlayerData.job.grade
                })
            end
        end
    end
    return players
end

return QBBridge