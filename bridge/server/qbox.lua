if GetResourceState('qbx_core') ~= 'started' then return {} end
local QBoxBridge = {}
QBoxBridge.QBCore = exports['qb-core']:GetCoreObject()

function QBoxBridge.RemoveItem(source, item, count, metadata)
    local Player = QBoxBridge.QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    return Player.Functions.RemoveItem(item, count or 1, metadata and metadata.slot)
end

function QBoxBridge.AddMoney(source, account, amount)
    local Player = QBoxBridge.QBCore.Functions.GetPlayer(source)
    if not Player or not amount or amount <= 0 then return false end
    if account == 'cash' or account == 'money' then
        return Player.Functions.AddMoney('cash', amount)
    elseif account == 'black_money' then
        return Player.Functions.AddItem('black_money', amount, false, nil)
    else
        return Player.Functions.AddMoney(account, amount)
    end
    return false
end

function QBoxBridge.GetPlayerIdentifier(source, type)
    local Player = QBoxBridge.QBCore.Functions.GetPlayer(source)
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

function QBoxBridge.GetPlayersByJob(job, grade)
    local players = {}
    local qbPlayers = QBoxBridge.QBCore.Functions.GetQBPlayers()
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


return QBoxBridge