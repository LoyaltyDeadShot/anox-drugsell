if GetResourceState('qb-core') ~= 'started' then return {} end
local QBBridge = {}
QBBridge.QBCore = exports['qb-core']:GetCoreObject()

function QBBridge.GetPlayerData()
    return QBBridge.QBCore.Functions.GetPlayerData()
end

function QBBridge.HasJob(job)
    local playerData = QBBridge.GetPlayerData()
    return playerData and playerData.job and playerData.job.name == job
end

function QBBridge.IsJobBlacklisted()
    local playerData = QBBridge.GetPlayerData()
    if playerData and playerData.job then
        for _, blacklistedJob in ipairs(Config.BlacklistJobs) do
            if playerData.job.name == blacklistedJob then
                return true
            end
        end
    end
    return false
end

function QBBridge.HasItem(item, count)
    count = count or 1
    local hasItem = QBBridge.QBCore.Functions.HasItem(item, count)
    return hasItem
end

function QBBridge.GetItemCount(item)
    local playerItems = QBBridge.GetPlayerData().items
    local count = 0
    if playerItems then
        for _, v in pairs(playerItems) do
            if v.name == item then
                count = count + v.amount
            end
        end
    end
    
    return count
end

function QBBridge.GetPlayerInventory()
    return QBBridge.GetPlayerData().items
end

return QBBridge