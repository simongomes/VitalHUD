import { useEffect, useState } from 'react'
import { Hud } from './hud/Hud'
import {
  clampStat,
  defaultComponents,
  defaultDisplay,
  defaultStats,
  type HudComponents,
  type HudDisplay,
  type HudStats,
} from './hud/stats'

type NuiMessage =
  | { action: 'setVisible'; data?: boolean }
  | { action: 'setComponents'; data?: Partial<HudComponents> }
  | { action: 'setDisplay'; data?: Partial<HudDisplay> }
  | { action: 'updateStats'; data?: Partial<HudStats> }

function isStatKey(key: string): key is keyof HudStats {
  return key in defaultStats
}

function mergeComponents(current: HudComponents, patch: Partial<HudComponents> | undefined) {
  if (!patch) return current

  const next = { ...current }
  for (const [key, value] of Object.entries(patch)) {
    if (!isStatKey(key) || typeof value !== 'boolean') continue
    next[key] = value
  }
  return next
}

function mergeDisplay(current: HudDisplay, patch: Partial<HudDisplay> | undefined) {
  if (!patch) return current

  const next = { ...current }
  if (typeof patch.bars === 'boolean') next.bars = patch.bars
  if (typeof patch.percentages === 'boolean') next.percentages = patch.percentages
  if (patch.vitalBars === 'horizontal' || patch.vitalBars === 'vertical') next.vitalBars = patch.vitalBars
  return next
}

function mergeStats(current: HudStats, patch: Partial<HudStats> | undefined) {
  if (!patch) return current

  const next = { ...current }
  for (const [key, value] of Object.entries(patch)) {
    if (!isStatKey(key) || typeof value !== 'number') continue
    next[key] = clampStat(value)
  }
  return next
}

export default function App() {
  const [visible, setVisible] = useState(true)
  const [components, setComponents] = useState<HudComponents>(defaultComponents)
  const [display, setDisplay] = useState<HudDisplay>(defaultDisplay)
  const [stats, setStats] = useState<HudStats>(defaultStats)

  useEffect(() => {
    const onMessage = (event: MessageEvent<NuiMessage>) => {
      const message = event.data
      if (!message || typeof message !== 'object') return

      if (message.action === 'setVisible') {
        setVisible(Boolean(message.data))
      }

      if (message.action === 'setComponents') {
        setComponents((current) => mergeComponents(current, message.data))
      }

      if (message.action === 'setDisplay') {
        setDisplay((current) => mergeDisplay(current, message.data))
      }

      if (message.action === 'updateStats') {
        setStats((current) => mergeStats(current, message.data))
      }
    }

    window.addEventListener('message', onMessage)
    return () => window.removeEventListener('message', onMessage)
  }, [])

  if (!visible) return null

  return <Hud stats={stats} components={components} display={display} />
}
