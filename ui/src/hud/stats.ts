export type HudStatKey =
  | 'health'
  | 'armor'
  | 'hunger'
  | 'thirst'
  | 'stress'
  | 'stamina'
  | 'oxygen'

export type HudStats = Record<HudStatKey, number>

export type HudComponents = Record<HudStatKey, boolean>

export type VitalBarStyle = 'horizontal' | 'vertical'

export type HudDisplay = {
  bars: boolean
  percentages: boolean
  vitalBars: VitalBarStyle
}

export const defaultDisplay: HudDisplay = {
  bars: true,
  percentages: true,
  vitalBars: 'horizontal',
}

export const defaultComponents: HudComponents = {
  health: true,
  armor: true,
  hunger: true,
  thirst: true,
  stress: true,
  stamina: true,
  oxygen: true,
}

export const defaultStats: HudStats = {
  health: 92,
  armor: 75,
  hunger: 68,
  thirst: 54,
  stress: 18,
  stamina: 86,
  oxygen: 64,
}

export function clampStat(value: number) {
  if (!Number.isFinite(value)) return 0
  return Math.min(100, Math.max(0, value))
}
