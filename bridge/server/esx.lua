if GetResourceState('es_extended') ~= 'started' then return {} end
local ESXBridge = {}
ESXBridge.ESX = exports['es_extended']:getSharedObject()

function ESXBridge.RemoveItem(source, item, count)
    local xPlayer = ESXBridge.ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.removeInventoryItem(item, count)
        return true
    end
    return false
end

function ESXBridge.AddMoney(source, account, amount)
    local xPlayer = ESXBridge.ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    local esxAccount = account
    if account == 'cash' then
        esxAccount = 'money'
    elseif account == 'markedbills' then
        esxAccount = 'black_money'
    end
    return xPlayer.addAccountMoney(esxAccount, amount)
end

function ESXBridge.GetPlayerIdentifier(source, type)
    local xPlayer = ESXBridge.ESX.GetPlayerFromId(source)
    if xPlayer then
        if type == 'license' then
            return xPlayer.getIdentifier()
        end
        return xPlayer.identifier
    end
    return nil
end

function ESXBridge.GetPlayersByJob(job)
    local players = {}
    if ESXBridge.ESX.GetExtendedPlayers then
        return ESXBridge.ESX.GetExtendedPlayers('job', job)
    else
        local xPlayers = ESXBridge.ESX.GetPlayers()
        for i=1, #xPlayers do
            local xPlayer = ESXBridge.ESX.GetPlayerFromId(xPlayers[i])
            if xPlayer and xPlayer.job.name == job then
                table.insert(players, xPlayer)
            end
        end
    end
    return players
end

return ESXBridge