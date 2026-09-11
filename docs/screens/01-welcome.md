# Welcome

Route `/welcome` · unauthenticated · Phase 0

First thing a new person sees. One job: say what this is in a sentence and
offer two ways in.

## Layout

Single column, `Space.lg` side padding, top padding clears the status bar.

1. **Wordmark** — top left. A 9px `accent` dot, then "WISP LIFE" in
   `AppType.monoLabel`, `textSecondary`, wide tracking.
2. **Centre block** (fills remaining space, centred):
   - The **orb** — 104px, `BorderRadius.circular(Radii.live)`, radial
     gradient from `accentInk` at 38%/34% through `accent` at 42% to
     `accentDim`. A 132px ring behind it in `accent`, expanding and fading
     on the same 5.2s cycle (`Motion.cycle`).
   - Headline — `AppType.displayLarge`, centred: *"A quiet place to put
     things down"*
   - Subhead — `AppType.bodyLarge`, `textSecondary`, max ~30 characters per
     line: *"Check in daily, write when you need to, and talk it through
     whenever the hour gets long."*
3. **Actions** (bottom):
   - Primary, full width, 54px: **Create an account** → `/sign-up`
   - Secondary outlined, 54px: **I already have one** → `/sign-in`
   - Caption, centred, `textTertiary`: *"Nothing you write is shared unless
     you choose to share it."*

Two soft radial washes sit behind everything — `accent` at 9% opacity top
left, `ember` at 7% bottom right. Decorative only; they must not affect
layout.

## Motion

The orb breathes: scale 1.0 → 1.075 → 1.0 over `Motion.cycle`, ease-in-out.
The ring expands 0.92 → 1.5 while fading to zero on the same period. Both
stop under reduce-motion — use `Motion.respecting`.

## States

Only one. If a valid session already exists, the splash routes past this
screen entirely; it is never shown to a signed-in user.

## Data

None. No network call on this screen.
