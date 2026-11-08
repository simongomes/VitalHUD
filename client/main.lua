local enabled = true
local shown = nil
local lastStats = {}
local lastComponents = nil
local manual = {}
local breathCapacity = nil
local coreObject = nil

local componentKeys = { 'health', 'armor', 'hunger', 'thirst', 'stress', 'stamina', 'oxygen' }

local function push(action, data)
    SendNUIMessage({
        action = action,
        data = data,
    })
end

local function frameworkName()
    local configured = Config.Framework

    if type(configured) ~= 'string' or configured == '' or configured == 'auto' then
        if GetResourceState('qbx_core') ~= 'missing' then
            return 'qbx'
        end

        if GetResourceState('qb-core') ~= 'missing' then
            return 'qb'
        end

        return 'standalone'
    end

    return configured
end

local function componentSettings()
    local configured = type(Config) == 'table' and Config.Components or nil
    local settings = {}

    for i = 1, #componentKeys do
        local key = componentKeys[i]
        local shownComponent = true

        if type(configured) == 'table' and configured[key] ~= nil then
            shownComponent = configured[key] == true
        end

        settings[key] = shownComponent
    end

    return settings
end

local function displaySettings()
    local configured = type(Config) == 'table' and Config.Display or nil
    local bars = true
    local percentages = true
    local vitalBars = 'horizontal'

    if type(configured) == 'table' then
        if configured.bars ~= nil then
            bars = configured.bars == true
        end

        if configured.percentages ~= nil then
            percentages = configured.percentages == true
        end

        if configured.vitalBars == 'vertical' then
            vitalBars = 'vertical'
        end
    end

    return {
        bars = bars,
        percentages = percentages,
        vitalBars = vitalBars,
    }
end

local function clamp(value)
    value = tonumber(value)

    if not value or value ~= value or value == math.huge or value == -math.huge then
        return 0
    end

    if value < 0 then
        return 0
    end

    if value > 100 then
        return 100
    end

    return value
end

local function percent(value)
    return math.floor(clamp(value) + 0.5)
end

local function statSettings(key)
    local stats = type(Config.Stats) == 'table' and Config.Stats or nil
    local settings = stats and stats[key] or nil

    if type(settings) ~= 'table' then
        return {}
    end

    return settings
end

local function metadataValue(key)
    local name = frameworkName()

    if name ~= 'qbx' and name ~= 'qb' then
        return nil
    end

    if GetResourceState('qb-core') ~= 'started' then
        return nil
    end

    if not coreObject then
        local ok, core = pcall(function()
            return exports['qb-core']:GetCoreObject()
        end)

        if not ok or type(core) ~= 'table' then
            return nil
        end

        coreObject = core
    end

    local getter = coreObject.Functions and coreObject.Functions.GetPlayerData

    if type(getter) ~= 'function' then
        return nil
    end

    local ok, data = pcall(getter)

    if not ok then
        return nil
    end

    local metadata = type(data) == 'table' and data.metadata or nil

    if type(metadata) ~= 'table' then
        return nil
    end

    return metadata[key]
end

local function stateValue(key, fallback)
    local value = LocalPlayer.state[key]

    if type(value) == 'number' then
        return value
    end

    local metadata = metadataValue(key)

    if type(metadata) == 'number' then
        return metadata
    end

    return fallback
end

local function forcedZero(settings)
    local keys = settings.zeroWhen

    if type(keys) ~= 'table' then
        return false
    end

    for i = 1, #keys do
        if LocalPlayer.state[keys[i]] == true then
            return true
        end
    end

    return false
end

local function readHealth(ped, settings)
    if forcedZero(settings) then
        return 0
    end

    local health = GetEntityHealth(ped)
    local minHealth = tonumber(settings.min) or 100
    local maxHealth = tonumber(settings.max) or GetEntityMaxHealth(ped)
    local span = maxHealth - minHealth

    if span <= 0 then
        return health > minHealth and 100 or 0
    end

    return ((health - minHealth) / span) * 100
end

local function readArmor(ped, settings)
    local maxArmor = tonumber(settings.max) or 100

    if maxArmor <= 0 then
        return 0
    end

    return (GetPedArmour(ped) / maxArmor) * 100
end

local function readStamina(settings)
    local spent = GetPlayerSprintStaminaRemaining(PlayerId())

    if settings.invert ~= false then
        return 100 - spent
    end

    return spent
end

local function isUnderwater(ped, settings)
    if IsPedSwimmingUnderWater(ped) then
        return true
    end

    local level = tonumber(settings.submergedLevel)

    if not level then
        return false
    end

    return GetEntitySubmergedLevel(ped) >= level
end

local function readOxygen(ped, settings)
    local surface = settings.surfaceValue

    if surface == nil then
        surface = 100
    end

    if settings.underwaterOnly ~= false and not isUnderwater(ped, settings) then
        breathCapacity = nil
        return surface
    end

    local remaining = GetPlayerUnderwaterTimeRemaining(PlayerId())
    local configuredMax = tonumber(settings.maxSeconds) or 10.0

    if not breathCapacity or remaining > breathCapacity then
        breathCapacity = math.max(configuredMax, remaining)
    end

    if breathCapacity <= 0 then
        return 0
    end

    return (remaining / breathCapacity) * 100
end

local function readConfigured(key, ped)
    local settings = statSettings(key)
    local source = settings.source

    if source == 'manual' then
        if manual[key] ~= nil then
            return manual[key]
        end

        return settings.default or 0
    end

    if key == 'health' and (source == nil or source == 'ped') then
        return readHealth(ped, settings)
    end

    if key == 'armor' and (source == nil or source == 'ped') then
        return readArmor(ped, settings)
    end

    if key == 'stamina' and (source == nil or source == 'native') then
        return readStamina(settings)
    end

    if key == 'oxygen' and (source == nil or source == 'native') then
        return readOxygen(ped, settings)
    end

    local stateKey = settings.state or key
    return stateValue(stateKey, settings.default or 0)
end

local function readStats()
    local ped = PlayerPedId()
    local stats = {}

    for i = 1, #componentKeys do
        local key = componentKeys[i]
        stats[key] = percent(readConfigured(key, ped))
    end

    return stats
end

local function visibleComponents(stats)
    local components = componentSettings()
    local hideAt = type(Config.HideAt) == 'table' and Config.HideAt or nil

    if not hideAt then
        return components
    end

    for i = 1, #componentKeys do
        local key = componentKeys[i]
        local hiddenValue = hideAt[key]

        if components[key] and type(hiddenValue) == 'number' and stats[key] == math.floor(hiddenValue + 0.5) then
            components[key] = false
        end
    end

    return components
end

local function sameComponents(current, nextComponents)
    if current == nil then
        return false
    end

    for i = 1, #componentKeys do
        local key = componentKeys[i]

        if current[key] ~= nextComponents[key] then
            return false
        end
    end

    return true
end

local function statsChanged(stats)
    local minChange = tonumber(Config.MinChange) or 1

    if minChange < 0 then
        minChange = 0
    end

    for i = 1, #componentKeys do
        local key = componentKeys[i]
        local previous = lastStats[key]

        if previous == nil or math.abs(previous - stats[key]) >= minChange then
            return true
        end
    end

    return false
end

local function loginRequired()
    local visibility = Config.Visibility

    if type(visibility) == 'table' and visibility.requireLogin ~= nil then
        return visibility.requireLogin == true
    end

    local name = frameworkName()
    return name == 'qbx' or name == 'qb'
end

local function shouldShow()
    if not enabled then
        return false
    end

    local visibility = type(Config.Visibility) == 'table' and Config.Visibility or {}

    if visibility.hideOnPause ~= false and IsPauseMenuActive() then
        return false
    end

    if loginRequired() then
        local key = visibility.loginState or 'isLoggedIn'

        if LocalPlayer.state[key] ~= true then
            return false
        end
    end

    return true
end

local function publish(force)
    local stats = readStats()

    if force or statsChanged(stats) then
        lastStats = stats
        push('updateStats', stats)
    end

    local components = visibleComponents(stats)

    if force or not sameComponents(lastComponents, components) then
        lastComponents = components
        push('setComponents', components)
    end

    local visible = shouldShow()

    if force or visible ~= shown then
        shown = visible
        push('setVisible', visible)
    end
end

local function updateInterval()
    local ms = tonumber(Config.UpdateInterval) or 200

    if ms < 50 then
        return 50
    end

    return math.floor(ms)
end

RegisterNetEvent('vital-hud:updateStats', function(stats)
    if type(stats) ~= 'table' then
        return
    end

    for key, value in pairs(stats) do
        if type(value) == 'number' then
            manual[key] = value
        end
    end

    publish(true)
end)

RegisterNUICallback('ready', function(_, cb)
    push('setDisplay', displaySettings())
    publish(true)
    cb('ok')
end)

local commandName = type(Config.Command) == 'string' and Config.Command or 'vitalhud'

if commandName ~= '' then
    RegisterCommand(commandName, function()
        enabled = not enabled
        publish(true)
    end, false)
end

if Config.HideNativeBars ~= false then
    CreateThread(function()
        local minimap = RequestScaleformMovie('minimap')

        while not HasScaleformMovieLoaded(minimap) do
            Wait(0)
        end

        -- Reload the minimap once so the health and armor layout applies.
        SetRadarBigmapEnabled(true, false)
        Wait(0)
        SetRadarBigmapEnabled(false, false)

        while true do
            BeginScaleformMovieMethod(minimap, 'SETUP_HEALTH_ARMOUR')
            ScaleformMovieMethodAddParamInt(3)
            EndScaleformMovieMethod()
            Wait(0)
        end
    end)
end

CreateThread(function()
    local delay = tonumber(Config.StartupDelay) or 0

    if delay > 0 then
        Wait(math.floor(delay))
    end

    push('setDisplay', displaySettings())
    publish(true)

    while true do
        publish(false)
        Wait(updateInterval())
    end
end)
