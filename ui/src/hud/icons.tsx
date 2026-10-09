import type { ReactNode } from 'react'

type IconProps = {
  className?: string
}

function Icon({ className, children }: IconProps & { children: ReactNode }) {
  return (
    <svg className={className} viewBox="0 0 24 24" aria-hidden="true">
      {children}
    </svg>
  )
}

export function HeartIcon({ className }: IconProps) {
  return (
    <Icon className={className}>
      <path
        fill="currentColor"
        d="M12 21.3 10.6 20C5.4 15.4 2 12.3 2 8.5 2 5.4 4.4 3 7.5 3c1.7 0 3.4.8 4.5 2.1C13.1 3.8 14.8 3 16.5 3 19.6 3 22 5.4 22 8.5c0 3.8-3.4 6.9-8.6 11.5L12 21.3z"
      />
      <path
        d="M2.2 12.2h4.4l1.5-2.6 2.1 4.2 1.7-3.4 1.3 1.8h8.6"
        fill="none"
        stroke="#fff"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Icon>
  )
}

export function ShieldIcon({ className }: IconProps) {
  return (
    <Icon className={className}>
      <path
        fill="currentColor"
        d="M12 2.2 4 5.4v6.2c0 5 3.4 8.4 8 10.2 4.6-1.8 8-5.2 8-10.2V5.4l-8-3.2z"
      />
    </Icon>
  )
}

export function UtensilsIcon({ className }: IconProps) {
  return (
    <svg className={className} viewBox="0 0 24 24" aria-hidden="true">
      <rect x="4" y="2" width="1.5" height="6.4" rx="0.75" fill="currentColor" />
      <rect x="6.7" y="2" width="1.5" height="7.6" rx="0.75" fill="currentColor" />
      <rect x="9.4" y="2" width="1.5" height="6.4" rx="0.75" fill="currentColor" />
      <rect x="6.7" y="8.4" width="1.5" height="13.2" rx="0.75" fill="currentColor" />
      <path
        fill="currentColor"
        d="M16.2 2.2h1.6c1 0 1.8.8 1.8 2.4v5c0 1.3-1.2 2.2-2.6 2.2h-.8V2.2z"
      />
      <rect x="16.6" y="11.4" width="1.6" height="10.2" rx="0.8" fill="currentColor" />
    </svg>
  )
}

export function DropletIcon({ className }: IconProps) {
  return (
    <Icon className={className}>
      <path
        fill="currentColor"
        d="M12 2.2s6.4 7.1 6.4 11.4a6.4 6.4 0 0 1-12.8 0C5.6 9.3 12 2.2 12 2.2z"
      />
    </Icon>
  )
}

export function BrainIcon({ className }: IconProps) {
  return (
    <Icon className={className}>
      <path
        fill="currentColor"
        d="M9.2 3.6A3.2 3.2 0 0 0 6.2 6.4 3 3 0 0 0 4 9.2a3.2 3.2 0 0 0 .6 5.2A3 3 0 0 0 7.4 19c1.1.5 2.3.3 3.2-.2.3-.2.5-.4.7-.6V5.1c-.2-.2-.5-.5-.8-.7A3 3 0 0 0 9.2 3.6zm5.6 0c-.5 0-1 .2-1.3.5-.3.2-.6.5-.8.7v13.1c.2.2.4.4.7.6.9.5 2.1.7 3.2.2a3 3 0 0 0 2.8-4.6 3.2 3.2 0 0 0 .6-5.2 3 3 0 0 0-2.2-2.8 3.2 3.2 0 0 0-3-2.5z"
      />
      <path d="M12 5.2v14" stroke="#1b212b" strokeWidth="1.3" strokeLinecap="round" />
    </Icon>
  )
}

export function LungsIcon({ className }: IconProps) {
  return (
    <Icon className={className}>
      <path fill="currentColor" d="M11.2 2.2h1.6v5.2h-1.6z" />
      <path
        fill="currentColor"
        d="M11.6 7.6C9.2 8.2 6.6 10 5.6 12.8 4.4 16 5 19.4 7.2 20.8c1.6 1 3.2.2 3.6-1.4.3-1.4 0-2.8-.8-3.8.6-.4 1-1.1 1-1.9V7.6z"
      />
      <path
        fill="currentColor"
        d="M12.4 7.6c2.4.6 5 2.4 6 5.2 1.2 3.2.6 6.6-1.6 8-1.6 1-3.2.2-3.6-1.4-.3-1.4 0-2.8.8-3.8-.6-.4-1-1.1-1-1.9V7.6z"
      />
    </Icon>
  )
}

export function RunnerIcon({ className }: IconProps) {
  return (
    <Icon className={className}>
      <path
        fill="currentColor"
        d="M14.2 5.4a2 2 0 1 0 0-4 2 2 0 0 0 0 4zM9.8 20.6l1.1-4.6 2.2 2.1v5.4h2.1v-6.6l-2.2-2.1.7-3.1c1.4 1.6 3.4 2.6 5.6 2.6v-2.1c-1.8 0-3.4-1-4.2-2.4l-1-1.7c-.4-.6-1-1-1.7-1-.3 0-.5.1-.8.1L6.2 9.4v4.8h2.1V11l1.6-.6-1.7 8.4-5 .9-.4 2.1 7 1.8z"
      />
    </Icon>
  )
}
