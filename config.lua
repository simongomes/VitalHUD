Config = {}

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
