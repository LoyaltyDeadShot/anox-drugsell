local Bridge = require('bridge/init')

Citizen.CreateThread(function()
    if not Bridge.Init() then
        if Config.Debug then
            print("[ANOX-DRUGSELL] Failed to initialize framework bridge")
        end
        return
    end
    if Config.Debug then
        print("[ANOX-DRUGSELL] Server-side initialized successfully")
    end
end)

local function GetPlayerReputation(identifier)
    if not identifier then return {} end
    local reputation = {}
    local result = exports.oxmysql:query_async('SELECT drug, rep FROM anox_drugrep WHERE license = ?', {
        identifier
    })
    if result and #result > 0 then
        for _, data in ipairs(result) do
            reputation[data.drug] = tonumber(data.rep)
        end
    end
    return reputation
end

local function UpdatePlayerReputation(identifier, drug, change)
    if not identifier or not drug then 
        if Config.Debug then
            print("[ANOX-DRUGSELL] Missing identifier or drug in UpdatePlayerReputation")
        end
        return false 
    end
    local currentRep = exports.oxmysql:scalar_async('SELECT rep FROM anox_drugrep WHERE license = ? AND drug = ?', {
        identifier, drug
    }) or 0
    currentRep = tonumber(currentRep) or 0
    local newRep = math.max(0, math.min(Config.Reputation.Max, currentRep + change))
    exports.oxmysql:execute('INSERT INTO anox_drugrep (license, drug, rep) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE rep = ?', {
        identifier, drug, newRep, newRep
    })
    
    if Config.Debug then
        print("[ANOX-DRUGSELL] Updated reputation for " .. identifier .. " - Drug: " .. drug .. ", Old: " .. currentRep .. ", New: " .. newRep)
    end
    return true
end

RegisterNetEvent('anox-drugsell:getReputationData')
AddEventHandler('anox-drugsell:getReputationData', function()
    local source = source
    local identifier = Bridge.GetPlayerIdentifier(source, 'license')
    if identifier then
        local repData = GetPlayerReputation(identifier)
        TriggerClientEvent('anox-drugsell:setReputationData', source, repData)
        if Config.Debug then
            print("[ANOX-DRUGSELL] Sent reputation data to player " .. source)
        end
    else
        if Config.Debug then
            print("[ANOX-DRUGSELL] Failed to get identifier for player " .. source)
        end
    end
end)

RegisterNetEvent('anox-drugsell:completeSale')
AddEventHandler('anox-drugsell:completeSale', function(drugName, quantity, pricePerUnit, zoneMultiplier)
    local source = source
    local identifier = Bridge.GetPlayerIdentifier(source, 'license')
    if not identifier then
        if Config.Debug then
            print("[ANOX-DRUGSELL] Failed to get identifier for player " .. source)
        end
        return
    end
    local hasItem = Bridge.RemoveItem(source, drugName, quantity)
    if not hasItem then
        if Config.Debug then
            print("[ANOX-DRUGSELL] Player " .. source .. " tried to sell drug they don't have: " .. drugName)
        end
        return
    end
    local drugData = Config.Drugs[drugName]
    local totalPrice = math.floor(quantity * pricePerUnit * (zoneMultiplier or 1.0))
    local accountType = drugData.DirtyMoney and 'black_money' or 'cash'
    Bridge.AddMoney(source, accountType, totalPrice)
    UpdatePlayerReputation(identifier, drugName, Config.Reputation.Gain)
    local repData = GetPlayerReputation(identifier)
    TriggerClientEvent('anox-drugsell:setReputationData', source, repData)

    if Config.Debug then
        print("[ANOX-DRUGSELL] Player " .. source .. " sold " .. quantity .. " " .. drugName .. " for $" .. totalPrice)
    end
end)

RegisterNetEvent('anox-drugsell:failedSale')
AddEventHandler('anox-drugsell:failedSale', function(drugName)
    local source = source
    local identifier = Bridge.GetPlayerIdentifier(source, 'license')
    if not identifier then return end
    UpdatePlayerReputation(identifier, drugName, -Config.Reputation.Loss)
    local repData = GetPlayerReputation(identifier)
    TriggerClientEvent('anox-drugsell:setReputationData', source, repData)
    
    if Config.Debug then
        print("[ANOX-DRUGSELL] Player " .. source .. " failed to sell " .. drugName .. ", reputation decreased")
    end
end)

RegisterNetEvent('anox-drugsell:alertDispatch')
AddEventHandler('anox-drugsell:alertDispatch', function(coords)
    local source = source
    local players = Bridge.GetPlayersByJob('police')
    if #players > 0 then
        local message = _L('dispatch_message')
        for _, xPlayer in pairs(players) do
            TriggerClientEvent('anox-drugsell:dispatchAlert', xPlayer.source, coords, message)
        end
        
        if Config.Debug then
            print("[ANOX-DRUGSELL] Dispatched drug sale alert to " .. #players .. " police officers")
        end
    end
end)

function DebugPrint(text)
    if Config.Debug then
        print("[ANOX-DRUGSELL] " .. text)
    end
end