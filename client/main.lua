local visible = false

local function setVisible(state)
    visible = state
    SendNUIMessage({
        action = 'setVisible',
        data = state,
    })
end

RegisterCommand('vitalhud', function()
    setVisible(not visible)
end, false)

AddEventHandler('onClientResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

    setVisible(true)
end)
