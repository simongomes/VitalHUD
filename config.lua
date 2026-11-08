Config = {}

-- Milliseconds between vital reads. Lower is smoother and costs more.
Config.UpdateInterval = 200

-- Wait this long after start before the first push, so the NUI page is loaded.
Config.StartupDelay = 500

-- Push a stat again only after it changes by at least this many percent.
Config.MinChange = 1

-- Chat command that shows or hides the HUD.
Config.Command = 'vitalhud'

-- 'auto' uses qbx_core, then qb-core, then standalone.
-- 'qbx' and 'qb' read hunger, thirst, and stress from player state, which qbx_core already updates.
-- 'standalone' leaves those three at their defaults unless a stat source is 'manual'.
Config.Framework = 'auto'

Config.Visibility = {
    hideOnPause = true,
    -- nil requires login on qbx and qb, and skips that check on standalone.
    requireLogin = nil,
    loginState = 'isLoggedIn',
}

-- Set a component to false to hide it. Restart the resource after changing this file.
Config.Components = {
    health = true,
    armor = true,
    hunger = true,
    thirst = true,
    stress = true,
    stamina = true,
    oxygen = true,
}

-- Show or hide the meter and the percentage inside every component.
-- vitalBars: 'horizontal' or 'vertical' for health and armor.
Config.Display = {
    bars = true,
    percentages = true,
    vitalBars = 'horizontal',
}

-- Hide a component while its displayed percent equals this number.
-- Omit a stat to leave Config.Components in charge.
Config.HideAt = {
    -- armor = 0,
    -- oxygen = 100,
}

-- source:
--   ped     health and armor from the player ped
--   native  stamina and oxygen from game natives
--   state   player state bag, then framework metadata
--   manual  only the vital-hud:updateStats event
Config.Stats = {
    health = {
        source = 'ped',
        -- Player health runs from min (the death floor) to max. nil max uses GetEntityMaxHealth.
        min = 100,
        max = nil,
        -- qbx_medical keeps the ped alive for animations: full health while dead, about 150 in last stand.
        -- isDead covers both, so the bar shows 0 instead of that scripted health.
        zeroWhen = { 'isDead' },
        default = 100,
    },
    armor = {
        source = 'ped',
        max = 100,
        default = 0,
    },
    hunger = {
        source = 'state',
        state = 'hunger',
        default = 100,
    },
    thirst = {
        source = 'state',
        state = 'thirst',
        default = 100,
    },
    stress = {
        source = 'state',
        state = 'stress',
        default = 0,
    },
    stamina = {
        source = 'native',
        -- The native reports spent stamina, so the bar uses 100 minus that value.
        -- Set invert to false if the bar empties while standing still.
        invert = true,
        default = 100,
    },
    oxygen = {
        source = 'native',
        -- Breath capacity in seconds. A longer breath, such as dive gear, raises this on the first underwater sample.
        maxSeconds = 10.0,
        -- Shown while the ped is not underwater.
        surfaceValue = 100,
        underwaterOnly = true,
        -- Extra test from 0.0 to 1.0 using GetEntitySubmergedLevel. nil uses swimming underwater only.
        submergedLevel = nil,
        default = 100,
    },
}
