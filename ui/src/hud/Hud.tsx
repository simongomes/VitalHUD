import type { ReactNode } from 'react'
import { BrainIcon, DropletIcon, HeartIcon, RunnerIcon, ShieldIcon, UtensilsIcon } from './icons'
import type { HudStatKey, HudStats } from './stats'
import './Hud.css'

type IconComponent = (props: { className?: string }) => ReactNode

const vitals: { key: Extract<HudStatKey, 'health' | 'armor'>; Icon: IconComponent }[] = [
  { key: 'health', Icon: HeartIcon },
  { key: 'armor', Icon: ShieldIcon },
]

const needs: { key: Exclude<HudStatKey, 'health' | 'armor'>; Icon: IconComponent }[] = [
  { key: 'hunger', Icon: UtensilsIcon },
  { key: 'thirst', Icon: DropletIcon },
  { key: 'stress', Icon: BrainIcon },
  { key: 'stamina', Icon: RunnerIcon },
]

function formatPercent(value: number) {
  return `${Math.round(value)}%`
}

type HudProps = {
  stats: HudStats
}

export function Hud({ stats }: HudProps) {
  return (
    <section className="hud" aria-label="Status">
      <div className="vitals">
        {vitals.map(({ key, Icon }) => (
          <div className="panel vital" key={key}>
            <Icon className={`icon vital-icon ${key}`} />
            <div className="track vital-track" aria-hidden="true">
              <div className={`fill ${key}`} style={{ width: `${stats[key]}%` }} />
            </div>
            <span className="vital-value">{formatPercent(stats[key])}</span>
          </div>
        ))}
      </div>

      <div className="needs">
        {needs.map(({ key, Icon }) => (
          <div className="panel need" key={key}>
            <div className="need-main">
              <Icon className="icon need-icon" />
              <div className="need-value">{formatPercent(stats[key])}</div>
            </div>
            <div className="track need-track" aria-hidden="true">
              <div className={`fill ${key}`} style={{ width: `${stats[key]}%` }} />
            </div>
          </div>
        ))}
      </div>
    </section>
  )
}
