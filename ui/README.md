# Vital HUD interface

React and TypeScript page for the Vital HUD resource. The resource docs, config, and in-game behavior are in the parent [README](../README.md).

FiveM loads the production build at `ui/dist/index.html`. The page background is transparent in that build. The dev server uses a black page so the HUD is easy to see.

```bash
npm install
npm run dev      # browser preview at http://127.0.0.1:5173
npm run build    # writes ui/dist
npm run lint
```

The preview shows sample stats. In game, `client/main.lua` replaces those values. On load, the page posts `ready` so the client can push the current vitals.
