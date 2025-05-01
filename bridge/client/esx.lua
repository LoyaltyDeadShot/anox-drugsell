if GetResourceState('es_extended') ~= 'started' then return {} end
local ESXBridge = {}
ESXBridge.ESX = exports['es_extended']:getSharedObject()


function ESXBridge.GetPlayerData()
    return ESXBridge.ESX.GetPlayerData()
end

function ESXBridge.HasJob(job)
    local playerData = ESXBridge.GetPlayerData()
    return playerData and playerData.job and playerData.job.name == job
end

function ESXBridge.IsJobBlacklisted()
    local playerData = ESXBridge.GetPlayerData()
    if playerData and playerData.job then
        for _, blacklistedJob in ipairs(Config.BlacklistJobs) do
            if playerData.job.name == blacklistedJob then
                return true
            end
        end
    end
    return false
end

function ESXBridge.HasItem(item, count)
    count = count or 1
    local item = ESXBridge.ESX.SearchInventory(item, count)
    return item and item.count >= count
end

function ESXBridge.GetItemCount(item)
    local item = ESXBridge.ESX.SearchInventory(item)
    return item and item.count or 0
end

function ESXBridge.GetPlayerInventory()
    return ESXBridge.ESX.GetPlayerData().inventory
end

return ESXBridge