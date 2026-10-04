local visible = true

local function push(action, data)
    SendNUIMessage({
        action = action,
        data = data,
    })
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

    push('setVisible', true)
end)
