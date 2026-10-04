import { useEffect, useState } from 'react'
import { clampStat, defaultStats, type HudStats } from './hud/stats'

type NuiMessage =
  | { action: 'setVisible'; data?: boolean }
  | { action: 'updateStats'; data?: Partial<HudStats> }

function isStatKey(key: string): key is keyof HudStats {
  return key in defaultStats
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
  const [, setStats] = useState<HudStats>(defaultStats)

  useEffect(() => {
    const onMessage = (event: MessageEvent<NuiMessage>) => {
      const message = event.data
      if (!message || typeof message !== 'object') return

      if (message.action === 'setVisible') {
        setVisible(Boolean(message.data))
      }

      if (message.action === 'updateStats') {
        setStats((current) => mergeStats(current, message.data))
      }
    }

    window.addEventListener('message', onMessage)
    return () => window.removeEventListener('message', onMessage)
  }, [])

  if (!visible) return null

  return null
}
