import type { ReactNode } from 'react'
import { BrainIcon, DropletIcon, HeartIcon, LungsIcon, RunnerIcon, ShieldIcon, UtensilsIcon } from './icons'
import type { HudComponents, HudDisplay, HudStatKey, HudStats } from './stats'
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
  { key: 'oxygen', Icon: LungsIcon },
]

function formatPercent(value: number) {
  return `${Math.round(value)}%`
}

const componentsPerRow = 4

function vitalGridColumn(index: number, vitalCount: number, rowColumns: number) {
  if (rowColumns === 0) return `${index + 1}`
  if (vitalCount === 1) return `1 / span ${rowColumns}`

  const firstSpan = Math.ceil(rowColumns / 2)
  if (index === 0) return `1 / span ${firstSpan}`
  return `${firstSpan + 1} / span ${rowColumns - firstSpan}`
}

type HudProps = {
  stats: HudStats
  components: HudComponents
  display: HudDisplay
}

export function Hud({ stats, components, display }: HudProps) {
  const visibleVitals = vitals.filter(({ key }) => components[key])
  const visibleNeeds = needs.filter(({ key }) => components[key])

  if (visibleVitals.length === 0 && visibleNeeds.length === 0) return null

  const columns = visibleNeeds.length || Math.max(visibleVitals.length, 1)
  const vitalColumns = visibleNeeds.length === 0 ? 0 : Math.min(componentsPerRow, visibleNeeds.length)
  const needRow = visibleVitals.length > 0 ? 2 : 1

  return (
    <section
      className="hud"
      aria-label="Status"
      style={{ gridTemplateColumns: `repeat(${columns}, max-content)` }}
    >
      {visibleVitals.length > 0 && (
        <div className="vitals">
          {visibleVitals.map(({ key, Icon }, index) => {
            const place = {
              gridColumn: vitalGridColumn(index, visibleVitals.length, vitalColumns),
              gridRow: 1,
            }

            return display.vitalBars === 'vertical' ? (
              <div
                className="panel need"
                key={key}
                style={place}
                aria-label={`${key} ${formatPercent(stats[key])}`}
              >
                <Icon className={`icon need-icon vital-icon ${key}`} />
                {display.bars && (
                  <div className="track need-track" aria-hidden="true">
                    <div className={`fill ${key}`} style={{ height: `${stats[key]}%` }} />
                  </div>
                )}
                {display.percentages && <span className="need-value">{formatPercent(stats[key])}</span>}
              </div>
            ) : (
              <div
                className={`panel vital${display.bars ? '' : ' no-bar'}${display.percentages ? '' : ' no-value'}`}
                key={key}
                style={place}
                aria-label={`${key} ${formatPercent(stats[key])}`}
              >
                <Icon className={`icon vital-icon ${key}`} />
                {display.bars && (
                  <div className="track vital-track" aria-hidden="true">
                    <div className={`fill ${key}`} style={{ width: `${stats[key]}%` }} />
                  </div>
                )}
                {display.percentages && <span className="vital-value">{formatPercent(stats[key])}</span>}
              </div>
            )
          })}
        </div>
      )}

      {visibleNeeds.length > 0 && (
        <div className="needs">
          {visibleNeeds.map(({ key, Icon }, index) => (
            <div
              className="panel need"
              key={key}
              style={{ gridColumn: index + 1, gridRow: needRow }}
              aria-label={`${key} ${formatPercent(stats[key])}`}
            >
              <Icon className="icon need-icon" />
              {display.bars && (
                <div className="track need-track" aria-hidden="true">
                  <div className={`fill ${key}`} style={{ height: `${stats[key]}%` }} />
                </div>
              )}
              {display.percentages && <span className="need-value">{formatPercent(stats[key])}</span>}
            </div>
          ))}
        </div>
      )}
    </section>
  )
}
