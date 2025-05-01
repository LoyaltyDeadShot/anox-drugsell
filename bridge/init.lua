local Bridge = {}

local function GetFrameworkType()
    local framework = Config.Framework and Config.Framework:lower()
    if framework == 'auto' then
        if GetResourceState('es_extended') == 'started' then
            return 'esx'
        elseif GetResourceState('qbx_core') == 'started' then
            return 'qbox'
        elseif GetResourceState('qb-core') == 'started' then
            return 'qbcore'
        else
            return nil -- No known framework running
        end
    elseif framework == 'esx' or framework == 'qbcore' or framework == 'qbox' then
        return framework
    else
        return nil -- Invalid framework specified
    end
end

local frameworkType = GetFrameworkType()

local function LoadBridge()
    local isServer = IsDuplicityVersion()
    local prefix = isServer and 'server' or 'client'
    local bridgePath = ('bridge/%s/%s.lua'):format(prefix, frameworkType)
    if frameworkType == nil then
        if Config.Debug then
            print("[ANOX-DRUGSELL] No supported framework found")
        end
        return false
    end
    if Config.Debug then
        print("[ANOX-DRUGSELL] Loading " .. frameworkType .. " bridge (" .. prefix .. ")")
    end
    local resourceName = GetCurrentResourceName()
    local bridgeContent = LoadResourceFile(resourceName, bridgePath)
    if not bridgeContent then
        if Config.Debug then
            print("[ANOX-DRUGSELL] Failed to load bridge file: " .. bridgePath)
        end
        return false
    end
    local bridgeFunction, err = load(bridgeContent)
    if not bridgeFunction then
        if Config.Debug then
            print("[ANOX-DRUGSELL] Error loading bridge: " .. tostring(err))
        end
        return false
    end
    local success, result = pcall(bridgeFunction)
    if not success then
        if Config.Debug then
            print("[ANOX-DRUGSELL] Error executing bridge: " .. tostring(result))
        end
        return false
    end
    for k, v in pairs(result) do
        Bridge[k] = v
    end
    return true
end

function Bridge.Init()
    if not LoadBridge() then
        if Config.Debug then
            print("[ANOX-DRUGSELL] Failed to initialize framework bridge")
        end
        return false
    end

    if Config.Debug then
        print("[ANOX-DRUGSELL] Framework bridge initialized successfully for: " .. frameworkType)
    end

    Bridge.Notify = function(text, type, duration)
        if Config.Notify == 'ox' then
            lib.notify({
                title = _L('notification_title'),
                description = text,
                type = type or 'inform',
                duration = duration or 5000,
                position = 'center-right',
                style = {
                    backgroundColor = 'rgba(30, 30, 30, 0.95)',
                    color = '#FF4C4C',
                    borderRadius = 14,
                    fontSize = '16px',
                    fontWeight = 'bold',
                    textAlign = 'left',
                    padding = '14px 20px',
                }
            })
        else
            BeginTextCommandThefeedPost('STRING')
            AddTextComponentSubstringPlayerName(text)
            EndTextCommandThefeedPostTicker(false, false)
        end
    end
    Bridge.ProgressBar = function(text, duration, options)
        if Config.ProgressBar == 'ox' then
            return lib.progressBar({
                duration = duration,
                label = text,
                useWhileDead = false,
                canCancel = options and options.canCancel or false,
                anim = options and options.anim,
                prop = options and options.prop
            })
        else
            Citizen.Wait(duration)
            return true
        end
    end
    Bridge.AlertDialog = function(title, message, confirm, cancel)
        if Config.AlertDialog == 'ox' then
            return lib.alertDialog({
                header = title,
                content = message,
                centered = true,
                cancel = cancel
            })
        else
            Bridge.Notify(message, 'info', 5000)
            return 'confirm'
        end
    end
    Bridge.CreateMenu = function(data)
        if Config.Menu == 'ox' then
            return lib.registerContext(data)
        else
            return false
        end
    end
    Bridge.ShowMenu = function(id)
        if Config.Menu == 'ox' then
            lib.showContext(id)
            return true
        else
            Bridge.Notify(_L('menu_not_supported'), 'error')
            return false
        end
    end
    Bridge.RegisterCommand = function(name, description, callback, suggestion)
        RegisterCommand(name, callback, false)
        if suggestion then
            TriggerEvent('chat:addSuggestion', '/' .. name, description, suggestion)
        else
            TriggerEvent('chat:addSuggestion', '/' .. name, description)
        end
    end
    Bridge.RegisterTarget = function(model, options)
        if Config.Target == 'ox' then
            return exports.ox_target:addModel(model, options)
        elseif Config.Target == 'qb' then
            local qbOptions = {}
            for _, opt in ipairs(options) do
                table.insert(qbOptions, {
                    type = "client",
                    event = "",
                    icon = opt.icon,
                    label = opt.label,
                    canInteract = opt.canInteract,
                    action = opt.onSelect,
                    name = opt.name,
                })
            end
            return exports['qb-target']:AddTargetModel(model, {
                options = qbOptions,
                distance = options[1] and options[1].distance or 2.0 -- fallback to 2.0 if not defined
            })
        else
            if Config.Debug then
                print("[ANOX-DRUGSELL] Target system not configured, skipping target registration")
            end
            return false
        end
    end
    
    return true
end

return Bridge