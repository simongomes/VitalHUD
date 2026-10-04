export type HudStatKey =
  | 'health'
  | 'armor'
  | 'hunger'
  | 'thirst'
  | 'stress'
  | 'stamina'

export type HudStats = Record<HudStatKey, number>

export const defaultStats: HudStats = {
  health: 92,
  armor: 75,
  hunger: 68,
  thirst: 54,
  stress: 18,
  stamina: 86,
}

export function clampStat(value: number) {
  if (!Number.isFinite(value)) return 0
  return Math.min(100, Math.max(0, value))
}
