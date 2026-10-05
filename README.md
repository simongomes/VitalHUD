# Vital HUD

A FiveM resource that draws a compact survival HUD in the bottom-left of the screen. Health and armor are wide bars. Hunger, thirst, stress, and stamina are smaller panels with an icon and a percentage.

The page background is transparent, so the game stays visible. The HUD does not take mouse focus.

## Requirements

- A FiveM server
- Node.js 20 or newer, only needed to build the UI

## Project layout

```
fxmanifest.lua    Resource manifest
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
})
```

Each value is a percentage from 0 to 100. A message can include any subset of those stats.

The interface also listens for NUI messages:

| Action | Data |
| --- | --- |
| `setVisible` | `true` or `false` |
| `updateStats` | `{ health, armor, hunger, thirst, stress, stamina }` |

## Branches

`master` is the main branch. `dev` is for ongoing work.
