if GetResourceState('qbx_core') ~= 'started' then return {} end
local QBoxBridge = {}
QBoxBridge.QBCore = exports['qb-core']:GetCoreObject()

function QBoxBridge.GetPlayerData()
    return QBoxBridge.QBCore.Functions.GetPlayerData()
end

function QBoxBridge.HasJob(job)
    local playerData = QBoxBridge.GetPlayerData()
    return playerData and playerData.job and playerData.job.name == job
end

function QBoxBridge.IsJobBlacklisted()
    local playerData = QBoxBridge.GetPlayerData()
    if playerData and playerData.job then
        for _, blacklistedJob in ipairs(Config.BlacklistJobs) do
            if playerData.job.name == blacklistedJob then
                return true
            end
        end
    end
    return false
end

function QBoxBridge.HasItem(item, count)
    count = count or 1
    local hasItem = QBoxBridge.QBCore.Functions.HasItem(item, count)
    return hasItem
end

function QBoxBridge.GetItemCount(item)
    local playerItems = QBoxBridge.GetPlayerData().items
    local count = 0
    if playerItems then
        for _, v in pairs(playerItems) do
            if v.name == item then
                local itemCount = v.amount or v.count or 0
                count = count + itemCount
            end
        end
    end
    return count
end

function QBoxBridge.GetPlayerInventory()
    return QBoxBridge.GetPlayerData().items
end

return QBoxBridge