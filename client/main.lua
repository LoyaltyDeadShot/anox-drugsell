local Bridge = require('bridge/init')
local isSellingDrug = false
local activeBuyer = nil
local activeBuyerBlip = nil
local activeSaleData = nil
local playerReputation = {}

Citizen.CreateThread(function()
    if not Bridge.Init() then
        if Config.Debug then
            print("[ANOX-DRUGSELL] Failed to initialize framework bridge")
        end
        return
    end

    Bridge.RegisterCommand('drugsell', _L('command_description'), function()
        if isSellingDrug then
            return Bridge.Notify(_L('already_selling'), 'error')
        end
        if Bridge.IsJobBlacklisted() then
            return Bridge.Notify(_L('job_blacklisted'), 'error')
        end
        OpenDrugSellingMenu()
    end)

    SetupNPCTargets()

    TriggerServerEvent('anox-drugsell:getReputationData')

    if Config.Debug then
        print("[ANOX-DRUGSELL] Client-side initialized successfully")
    end
end)

function SetupNPCTargets()
    for _, model in ipairs(Config.NPCSettings.models) do
        Bridge.RegisterTarget(GetHashKey(model), {
            {
                name = 'anox-drugsell:interact',
                icon = 'fas fa-capsules',
                label = _L('interact_with_buyer'),
                canInteract = function(entity)
                    return activeBuyer and entity == activeBuyer
                end,
                onSelect = function()
                    if activeSaleData then
                        StartDrugSale(activeSaleData.drug, activeSaleData.quantity, activeSaleData.price)
                    else
                        Bridge.Notify(_L('sale_error'), 'error')
                    end
                end,
                distance = 2.0
            }
        })
    end
    
    if Config.Debug then
        print("[ANOX-DRUGSELL] NPC target interactions registered")
    end
end

function OpenDrugSellingMenu()
    local inventory = Bridge.GetPlayerInventory()
    local availableDrugs = {}
    local menuOptions = {}
    for drugName, drugData in pairs(Config.Drugs) do
        local count = Bridge.GetItemCount(drugName)
        if count > 0 then
            availableDrugs[drugName] = {
                count = count,
                data = drugData
            }
            table.insert(menuOptions, {
                title = '💊 ' .. drugData.label .. ' (' .. count .. ')',
                description = _L('price_range', drugData.minPrice, drugData.maxPrice),
                icon = 'fa-solid fa-capsules',
                onSelect = function()
                    OpenQuantityInputMenu(drugName, count, drugData)
                end
            })
        else
            table.insert(menuOptions, {
                title = '🚫 ' .. drugData.label .. ' (0)',
                description = _L('not_available'),
                icon = 'fa-solid fa-ban',
                disabled = true
            })
        end
    end
    if #menuOptions == 0 then
        return Bridge.Notify(_L('no_drugs'), 'error')
    end
    local menuData = {
        id = 'anox_drugsell_menu',
        title = '🚬 ' .. _L('drug_menu_title'),
        options = menuOptions
    }
    Bridge.CreateMenu(menuData)
    Bridge.ShowMenu('anox_drugsell_menu')
end

function OpenQuantityInputMenu(drugName, maxCount, drugData)
    local input = lib.inputDialog(_L('quantity_dialog_title'), {
        {
            type = 'number',
            label = '📦 ' .. _L('quantity_label'),
            description = _L('max_quantity', maxCount),
            icon = 'fa-solid fa-boxes-stacked',
            min = 1,
            max = maxCount,
            default = 1
        },
        {
            type = 'number',
            label = '💵 ' .. _L('price_per_unit_label'),
            description = _L('price_range', drugData.minPrice, drugData.maxPrice),
            icon = 'fa-solid fa-dollar-sign',
            min = drugData.minPrice,
            max = drugData.maxPrice,
            default = math.floor((drugData.minPrice + drugData.maxPrice) / 2)
        }
    })
    
    if not input then return end    
    local quantity = input[1]
    local pricePerUnit = input[2]
    if not quantity or not pricePerUnit then
        return Bridge.Notify(_L('invalid_input'), 'error')
    end
    quantity = math.floor(tonumber(quantity))
    pricePerUnit = math.floor(tonumber(pricePerUnit))
    if quantity <= 0 or quantity > maxCount then
        return Bridge.Notify(_L('invalid_quantity'), 'error')
    end
    if pricePerUnit < drugData.minPrice or pricePerUnit > drugData.maxPrice then
        return Bridge.Notify(_L('invalid_price'), 'error')
    end
    local totalPrice = quantity * pricePerUnit
    local confirm = Bridge.AlertDialog(
        _L('confirm_sale_title'),
        _L('confirm_sale', quantity, drugData.label, pricePerUnit, totalPrice),
        true
    )
    if confirm == 'confirm' then
        SpawnDrugBuyer(drugName, quantity, pricePerUnit)
    end
end

function SpawnDrugBuyer(drugName, quantity, pricePerUnit)
    if isSellingDrug then
        return Bridge.Notify(_L('already_selling'), 'error')
    end
    isSellingDrug = true
    isTimerFinished = false
    local modelName = Config.NPCSettings.models[math.random(#Config.NPCSettings.models)]
    local modelHash = GetHashKey(modelName)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(10)
    end
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local minDist = Config.SaleSettings.minDistanceFromPlayer
    local maxDist = Config.SaleSettings.maxDistanceFromPlayer
    local maxAttempts = 10
    local attempt = 0
    local validLocation = false
    local x, y, z, groundZ
    local buyerCoords
    while not validLocation and attempt < maxAttempts do
        attempt = attempt + 1
        local angle = math.random() * 2.0 * math.pi
        local distance = minDist + math.random() * (maxDist - minDist)
        x = playerCoords.x + math.cos(angle) * distance
        y = playerCoords.y + math.sin(angle) * distance
        local success, groundZ = GetGroundZFor_3dCoord(x, y, playerCoords.z, false)
        if success then
            local isOnRoad = IsPointOnRoad(x, y, groundZ)
            local heightDifference = math.abs(playerCoords.z - groundZ)
            if (isOnRoad or attempt > maxAttempts/2) and heightDifference < 5.0 then
                z = groundZ
                validLocation = true
                local _, hit, _, _, _ = StartShapeTestRay(x, y, z + 0.5, x, y, z + 4.0, 1, 0, 0)
                if hit == 1 then
                    validLocation = false
                end
            end
        end
        
        if Config.Debug then
            print("[ANOX-DRUGSELL] Spawn attempt " .. attempt .. ", Valid: " .. tostring(validLocation))
        end
    end
    if not validLocation then
        Bridge.Notify(_L('spawn_location_warning'), 'warning')
        local success, safeZ = GetSafeCoordForPed(x, y, playerCoords.z, false, 16)
        if success then
            z = safeZ
        else
            z = playerCoords.z
        end
    end
    buyerCoords = vector3(x, y, z)
    local heading = GetHeadingFromVector_2d(playerCoords.x - x, playerCoords.y - y)
    activeBuyer = CreatePed(4, modelHash, buyerCoords.x, buyerCoords.y, buyerCoords.z, heading, false, true)
    SetEntityAsMissionEntity(activeBuyer, true, true)
    SetBlockingOfNonTemporaryEvents(activeBuyer, true)
    SetPedCanRagdoll(activeBuyer, false)
    activeBuyerBlip = AddBlipForEntity(activeBuyer)
    SetBlipSprite(activeBuyerBlip, Config.NPCSettings.blipSprite)
    SetBlipColour(activeBuyerBlip, Config.NPCSettings.blipColor)
    SetBlipScale(activeBuyerBlip, Config.NPCSettings.blipScale)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(_L('buyer_blip_name'))
    EndTextCommandSetBlipName(activeBuyerBlip)
    activeSaleData = {
        drug = drugName,
        quantity = quantity,
        price = pricePerUnit,
        totalPrice = quantity * pricePerUnit,
        timeout = Config.SaleSettings.interactionTimeout
    }
    local dispatchChance = math.random(1, 100)
    local successChance = math.random(1, 100)
    local isInSellingZone = false
    local currentZone = "Unknown"
    local zoneMultiplier = 1.0
    if Config.UseZones then
        for _, zone in ipairs(Config.Zones) do
            local distanceFromZone = #(playerCoords - zone.coords)
            if distanceFromZone <= zone.radius then
                isInSellingZone = true
                currentZone = zone.name
                zoneMultiplier = zone.multiplier
                break
            end
        end
    end
    Bridge.Notify(_L('buyer_spawned'), 'success')

    Citizen.CreateThread(function()
        if activeBuyer == nil then return end
        local timeLeft = Config.SaleSettings.interactionTimeout
        while activeBuyer and timeLeft > 0 do
            Wait(1000)
            timeLeft = timeLeft - 1
            if Config.SellingDetails and not isTimerFinished then
                lib.showTextUI(string.format(
                    "%s %d  %s %d%%  %s %d%%\n%s %s",
                    _L('timer_label'), timeLeft,
                    _L('dispatch_label'), dispatchChance,
                    _L('success_label'), successChance,
                    _L('zone_bonus_label'), isInSellingZone and _L('enabled_label') or _L('disabled_label')
                ), {
                    position = 'top-center',
                    icon = 'clock',
                    style = {
                        borderRadius = 8,
                        backgroundColor = '#2f2f2f',
                        color = 'white',
                        padding = '8px 12px',
                        border = '2px solid #e60000',
                        font = 'Arial',
                        fontSize = '14px',
                        textShadow = '2px 2px 4px rgba(0,0,0,0.5)',
                        lineHeight = '20px'
                    }
                })
            end
            if timeLeft == 30 or timeLeft == 10 then
                Bridge.Notify(_L('time_remaining', timeLeft), 'inform')
            end
            if timeLeft == 0 then
                isTimerFinished = true
                if Config.SellingDetails then
                    lib.hideTextUI()
                end
            end
        end
        if activeBuyer then
            Bridge.Notify(_L('buyer_leaving'), 'error')
            CleanupBuyer()
        end
    end)

    TaskGoToEntity(activeBuyer, playerPed, -1, Config.NPCSettings.walkDistance, 1.0, 0, 0)
    
    if Config.Debug then
        print("[ANOX-DRUGSELL] Spawned drug buyer at " .. x .. ", " .. y .. ", " .. z)
    end
    
    SetModelAsNoLongerNeeded(modelHash)
end

function StartDrugSale(drugName, quantity, pricePerUnit)
    if not activeBuyer or not activeSaleData then
        return Bridge.Notify(_L('sale_error'), 'error')
    end
    local playerPed = PlayerPedId()
    local drugData = Config.Drugs[drugName]
    local totalPrice = quantity * pricePerUnit
    local drugRep = playerReputation[drugName] or 0
    local priceRatio = (pricePerUnit - drugData.minPrice) / (drugData.maxPrice - drugData.minPrice)
    local successRate = Config.SaleChance.baseSuccessRate
    successRate = successRate + (drugRep * Config.SaleChance.reputationFactor)
    local priceFactor = Config.SaleChance.priceFactor.min - 
                         (priceRatio * (Config.SaleChance.priceFactor.min - Config.SaleChance.priceFactor.max))
    successRate = successRate * priceFactor
    successRate = math.max(0.05, math.min(0.95, successRate))
    local dispatchChance = Config.DispatchChance.baseChance
    dispatchChance = dispatchChance - (drugRep * Config.DispatchChance.reputationFactor)
    dispatchChance = dispatchChance + (priceRatio * Config.DispatchChance.priceFactor)
    dispatchChance = math.max(0.01, math.min(0.75, dispatchChance))
    local zoneMultiplier = 1.0
    if Config.UseZones then
        local playerCoords = GetEntityCoords(playerPed)
        for _, zone in pairs(Config.Zones) do
            local distance = #(playerCoords - zone.coords)
            if distance <= zone.radius then
                zoneMultiplier = zone.multiplier
                if Config.Debug then
                    print("[ANOX-DRUGSELL] Player in zone: " .. zone.name .. " with multiplier: " .. zoneMultiplier)
                end
                break
            end
        end
    end
    
    if Config.Debug then
        print("[ANOX-DRUGSELL] Sale attempt - Success rate: " .. successRate .. ", Dispatch chance: " .. dispatchChance)
    end

    FreezeEntityPosition(playerPed, true)
    FreezeEntityPosition(activeBuyer, true)
    local playerCoords = GetEntityCoords(playerPed)
    local buyerCoords = GetEntityCoords(activeBuyer)
    TaskTurnPedToFaceCoord(playerPed, buyerCoords.x, buyerCoords.y, buyerCoords.z, 1000)
    TaskTurnPedToFaceCoord(activeBuyer, playerCoords.x, playerCoords.y, playerCoords.z, 1000)
    Wait(1000)
    local propObject = nil
    if drugData.prop then
        local propHash = GetHashKey(drugData.prop)
        RequestModel(propHash)
        while not HasModelLoaded(propHash) do
            Wait(10)
        end
        propObject = CreateObject(propHash, playerCoords.x, playerCoords.y, playerCoords.z, true, true, true)
        AttachEntityToEntity(propObject, playerPed, GetPedBoneIndex(playerPed, 57005), 0.13, 0.02, 0.0, -90.0, 0, 0, true, true, false, true, 1, true)
        SetModelAsNoLongerNeeded(propHash)
    end
    local dict = "mp_common"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
    TaskPlayAnim(playerPed, dict, "givetake1_a", 8.0, -8.0, -1, 0, 0, false, false, false)
    TaskPlayAnim(activeBuyer, dict, "givetake1_a", 8.0, -8.0, -1, 0, 0, false, false, false)
    local result = Bridge.ProgressBar(_L('selling_drug', drugData.label), Config.SaleSettings.saleAnimationTime, {
        canCancel = false
    })
    if propObject then
        DeleteObject(propObject)
    end
    FreezeEntityPosition(playerPed, false)
    FreezeEntityPosition(activeBuyer, false)
    ClearPedTasks(playerPed)
    ClearPedTasks(activeBuyer)
    local roll = math.random()
    local success = roll <= successRate
    if success then
        TriggerServerEvent('anox-drugsell:completeSale', drugName, quantity, pricePerUnit, zoneMultiplier)
        Bridge.Notify(_L('sale_successful', totalPrice*zoneMultiplier), 'success')
        local cashProp = CreateObject(GetHashKey('prop_anim_cash_pile_01'), 0, 0, 0, true, true, true)
        AttachEntityToEntity(cashProp, activeBuyer, GetPedBoneIndex(activeBuyer, 57005), 0.1, 0.0, 0.0, 90.0, 0.0, 0.0, true, true, false, true, 1, true)
        RequestAnimDict('mp_common')
        while not HasAnimDictLoaded('mp_common') do
            Citizen.Wait(0)
        end
        TaskPlayAnim(activeBuyer, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 0, 0, false, false, false)
        TaskPlayAnim(playerPed, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 0, 0, false, false, false)
        Citizen.Wait(2000)
        DeleteObject(cashProp)
        ClearPedTasks(activeBuyer)
        ClearPedTasks(playerPed)
    else
        Bridge.Notify(_L('sale_failed'), 'error')
        TriggerServerEvent('anox-drugsell:failedSale', drugName)
        TaskSmartFleePed(activeBuyer, playerPed, 100.0, -1, false, false)
    end
    local dispatchRoll = math.random()
    if dispatchRoll <= dispatchChance then
        local coords = GetEntityCoords(playerPed)
        TriggerServerEvent('anox-drugsell:alertDispatch', coords)
    end
    Citizen.SetTimeout(Config.NPCSettings.despawnTime * 1000, CleanupBuyer)
end

function CleanupBuyer()
    if activeBuyer then
        DeleteEntity(activeBuyer)
        activeBuyer = nil
    end
    if activeBuyerBlip then
        RemoveBlip(activeBuyerBlip)
        activeBuyerBlip = nil
    end
    activeSaleData = nil
    isSellingDrug = false
    lib.hideTextUI()
    isTimerFinished = true
end

RegisterNetEvent('anox-drugsell:setReputationData')
AddEventHandler('anox-drugsell:setReputationData', function(repData)
    playerReputation = repData
    
    if Config.Debug then
        print("[ANOX-DRUGSELL] Received reputation data:")
        for drug, rep in pairs(playerReputation) do
            print("  " .. drug .. ": " .. rep)
        end
    end
end)

RegisterNetEvent('anox-drugsell:dispatchAlert')
AddEventHandler('anox-drugsell:dispatchAlert', function(coords, message)
    if Config.Dispatch == 'ox' then
        lib.notify({
            id = 'anox_drugsell_dispatch',
            title = _L('police_alert_title'),
            description = message,
            position = 'center-right',
            style = {
                backgroundColor = '#141517',
                color = '#C1C2C5',
                borderRadius = '8px',
                border = '1px solid #ff0000'
            },
            icon = 'bell',
            iconColor = '#ff0000'
        })
    else
        Bridge.Notify(message, 'inform', 8000)
    end
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 51)
    SetBlipColour(blip, 1)
    SetBlipScale(blip, 1.0)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(_L('drug_activity_blip'))
    EndTextCommandSetBlipName(blip)
    Citizen.SetTimeout(60000, function()
        RemoveBlip(blip)
    end)
end)

function DebugPrint(text)
    if Config.Debug then
        print("[ANOX-DRUGSELL] " .. text)
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    CleanupBuyer()
end)