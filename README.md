# Vital HUD

A FiveM resource that draws a compact survival HUD in the bottom-left of the screen. Health and armor sit on the top row. Hunger, thirst, stress, stamina, and oxygen stay on a single row underneath.

With horizontal health and armor bars, each bar is half of the first four bottom components. Health lines up with hunger and thirst. Armor lines up with stress and stamina. Oxygen continues past the armor bar. Set `vitalBars` to `'vertical'` to use the same upright meter as the other components.

The page background is transparent, so the game stays visible. The HUD does not take mouse focus.

## Requirements

- A FiveM server
- Node.js 20 or newer, only needed to build the UI

## Project layout

```
fxmanifest.lua    Resource manifest
config.lua        Which HUD components are shown
client/main.lua   Shows the HUD and forwards stat updates
server/main.lua   Server entry
ui/               Vite, React, and TypeScript interface
```

## UI

From `ui`:

```bash
npm install
npm run dev      # browser preview at http://127.0.0.1:5173
npm run build    # writes ui/dist, which FiveM loads
npm run lint
```

Build the UI before starting the resource. The manifest serves `ui/dist/index.html`.

The browser preview uses a black page so the HUD is easy to see. The production build keeps the page transparent.

## Settings

`config.lua` controls which components are drawn. Set a value to `false` to hide that component, then restart the resource. Every component is shown by default.

```lua
Config.Components = {
    health = true,
    armor = true,
    hunger = true,
    thirst = true,
    stress = true,
    stamina = true,
    oxygen = true,
}
```

`Config.Display` shows or hides the meter and the percentage inside every component. The icon stays either way.

```lua
Config.Display = {
    bars = true,
    percentages = true,
    vitalBars = 'horizontal',
}
```

`vitalBars` changes health and armor. `'horizontal'` keeps the wide bars. `'vertical'` uses the same upright meter as the other components.

## In game

`/vitalhud` shows or hides the HUD.

Other client scripts can push stats:

```lua
TriggerEvent('vital-hud:updateStats', {
    health = 80,
    armor = 40,
    hunger = 60,
    thirst = 55,
    stress = 20,
    stamina = 90,
    oxygen = 100,
})
```

Each value is a percentage from 0 to 100. A message can include any subset of those stats.

The interface also listens for NUI messages:

| Action | Data |
| --- | --- |
| `setVisible` | `true` or `false` |
| `setComponents` | `{ health, armor, hunger, thirst, stress, stamina, oxygen }` as booleans |
| `setDisplay` | `{ bars, percentages, vitalBars }` — booleans, and `vitalBars` as `horizontal` or `vertical` |
| `updateStats` | `{ health, armor, hunger, thirst, stress, stamina, oxygen }` |

## Branches

`master` is the main branch. `dev` is for ongoing work.
