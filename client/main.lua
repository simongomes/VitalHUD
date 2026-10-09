local visible = true

local componentKeys = { 'health', 'armor', 'hunger', 'thirst', 'stress', 'stamina', 'oxygen' }

local function push(action, data)
    SendNUIMessage({
        action = action,
        data = data,
    })
end

local function componentSettings()
    local configured = type(Config) == 'table' and Config.Components or nil
    local settings = {}

    for i = 1, #componentKeys do
        local key = componentKeys[i]
        local enabled = true

        if type(configured) == 'table' and configured[key] ~= nil then
            enabled = configured[key] == true
        end

        settings[key] = enabled
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

RegisterCommand('vitalhud', function()
    visible = not visible
    push('setVisible', visible)
end, false)

RegisterNetEvent('vital-hud:updateStats', function(stats)
    if type(stats) ~= 'table' then
        return
    end

    push('updateStats', stats)
end)

AddEventHandler('onClientResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

    push('setComponents', componentSettings())
    push('setDisplay', displaySettings())
    push('setVisible', true)
end)
