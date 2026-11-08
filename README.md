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
config.lua        Vital sources, visibility, and HUD layout
client/main.lua   Reads vitals and updates the HUD
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

`config.lua` controls the HUD. Restart the resource after changing it.

The client reads vitals on a timer (`Config.UpdateInterval`) and pushes them to the UI when they change by at least `Config.MinChange` percent.

| Vital | Default source | What it follows |
| --- | --- | --- |
| Health | Player ped | `(health - min) / (max - min)`. Default min is `100`. `nil` max uses the ped's max health. `qbx_medical` holds the ped at full health while dead and about `150` in last stand, so `zeroWhen` includes `isDead` and the bar shows `0` in both cases. |
| Armor | Player ped | Armor divided by `Config.Stats.armor.max` (default `100`). |
| Hunger | Player state `hunger` | Qbox metadata. `qbx_core` drains this on its own loop. |
| Thirst | Player state `thirst` | Qbox metadata. `qbx_core` drains this on its own loop. |
| Stress | Player state `stress` | Qbox metadata. Stress still rises from `qbx_hud` while that resource is running. |
| Stamina | Sprint native | `100 - GetPlayerSprintStaminaRemaining`. Set `invert = false` if the bar moves the wrong way. |
| Oxygen | Underwater breath | Full on land. Underwater it uses remaining breath against `maxSeconds` (default `10`). A longer breath, such as dive gear, raises the capacity from the first underwater sample. |

`Config.Framework` is `'auto'`, `'qbx'`, `'qb'`, or `'standalone'`. Auto prefers `qbx_core`, then `qb-core`. State bag values win, then framework metadata, then the stat default. Standalone keeps hunger, thirst, and stress at their defaults unless that stat's `source` is `'manual'`.

`Config.Visibility.hideOnPause` hides the HUD while the pause menu is open. `requireLogin` defaults to on for Qbox and QB, and off for standalone. The login flag is the `isLoggedIn` state bag.

`Config.HideAt` hides a component while its displayed percent equals a number. For example, `armor = 0` hides an empty armor bar. Omit a key to keep showing that component.

`config.lua` also controls which components are drawn. Set a value to `false` to hide that component. Every component is shown by default.

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

`/vitalhud` shows or hides the HUD. Rename it with `Config.Command`.

The HUD stays hidden until the player is logged in, and while the pause menu is open.

Other client scripts can drive a stat after its `source` is set to `'manual'`:

```lua
TriggerEvent('vital-hud:updateStats', {
    hunger = 60,
    thirst = 55,
    stress = 20,
})
```

Each value is a percentage from 0 to 100. A message can include any subset of the stats. Automatic sources keep reading the ped, natives, or player state, so this event does not override them.

The interface also listens for NUI messages:

| Action | Data |
| --- | --- |
| `setVisible` | `true` or `false` |
| `setComponents` | `{ health, armor, hunger, thirst, stress, stamina, oxygen }` as booleans |
| `setDisplay` | `{ bars, percentages, vitalBars }` — booleans, and `vitalBars` as `horizontal` or `vertical` |
| `updateStats` | `{ health, armor, hunger, thirst, stress, stamina, oxygen }` |

## Branches

`master` is the main branch. `dev` is for ongoing work.
